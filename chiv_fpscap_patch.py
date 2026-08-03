#!/usr/bin/env python3
"""
Chivalry: Medieval Warfare - online frame-rate cap patcher.

Removes the compiled-in frame-rate ceilings in UGameEngine::GetMaxTickRate and
the load-time MaxSmoothedFrameRate ceiling. Test-environment use.

Two modes, because "remove the cap" turned out to mean two different things:

  full   (default)  Bypass the netdriver branch entirely so its contribution stays
                    0.0f. With frame smoothing off (UNCAPFPS) the function then
                    returns 0 -> genuinely uncapped online.

  relax             Leave the netdriver branch running but skip its Clamp(x, 10, 90).
                    The cap becomes the raw computed netspeed/divisor value instead
                    of 90. Measured in practice: ~120. Useful for probing what that
                    raw value is on a given server rather than removing the cap.

Every edit is verified against a byte window before anything is written, the
original is backed up, and the result is re-verified from disk. Nothing is written
unless every selected window matches exactly, so a wrong or updated build fails
closed rather than corrupting the executable.

Usage:
    python chiv_fpscap_patch.py --check CMW.exe          # dry run, report only
    python chiv_fpscap_patch.py CMW.exe                  # apply 'full'
    python chiv_fpscap_patch.py --mode relax CMW.exe
    python chiv_fpscap_patch.py --revert CMW.exe
"""

import argparse
import hashlib
import shutil
import struct
import sys
from pathlib import Path

# ----------------------------------------------------------------------------
# Both binaries: .text VA 0x1000, PointerToRawData 0x400
#   file_offset = VA - image_base - 0xC00
# ----------------------------------------------------------------------------

KNOWN = {
    "bb7b1f52e49bf647e9ec24c5745d36427f725a18442355cd77335c7481facdaa": "client",
    "561540d30cba8277ef876d978b56eb8f3f9b872d7c323f42f84c2fbfc62ea358": "server",
}

MODES = ("full", "relax")


class Patch:
    def __init__(self, name, va, window_off, window, index, new, note, modes=()):
        self.name = name
        self.va = va
        self.window_off = window_off
        self.window = bytes(window)
        self.index = index
        self.new = bytes(new) if new else None
        self.note = note
        self.modes = set(modes)

    @property
    def offset(self):
        return self.window_off + self.index

    @property
    def old(self):
        return self.window[self.index:self.index + len(self.new)]

    def patched_window(self):
        w = bytearray(self.window)
        w[self.index:self.index + len(self.new)] = self.new
        return bytes(w)


# --- client: CMW.exe --------------------------------------------------------

CLIENT = [
    Patch(
        name="netdriver-bypass",
        va=0x140463F4F,
        window_off=0x46334C,
        window=[0x48, 0x85, 0xC9,                            # TEST RCX,RCX
                0x0F, 0x84, 0x43, 0x01, 0x00, 0x00],         # JZ  0x140464098
        index=3,
        new=[0x90, 0xE9],                                    # NOP + JMP rel32 (same rel32)
        note="skip the whole netdriver branch; its contribution stays 0.0f",
        modes={"full"},
    ),
    Patch(
        name="netdriver-90-clamp",
        va=0x140464045,
        window_off=0x46343E,
        window=[0x81, 0x78, 0x70, 0x10, 0x27, 0x00, 0x00,   # CMP [RAX+0x70],10000
                0x7F, 0x47],                                 # JG  skip_clamp
        index=7,
        new=[0xEB],                                          # JG -> JMP
        note="skip Clamp(netspeed/divisor, 10.0f, 90.0f); cap becomes the raw value",
        modes={"relax"},
    ),
    Patch(
        name="smoothing-120-ceiling",
        va=0x1404438D8,
        window_off=0x442CD1,
        window=[0x0F, 0x2F, 0x83, 0x00, 0x07, 0x00, 0x00,   # COMISS XMM0,[RBX+0x700]
                0x73, 0x0A,                                  # JNC   skip
                0xC7, 0x83, 0x00, 0x07, 0x00, 0x00,          # MOV   [RBX+0x700],
                0x00, 0x00, 0xF0, 0x42],                     #       120.0f
        index=7,
        new=[0xEB],                                          # JNC -> JMP
        note="stop MaxSmoothedFrameRate being forced down to 120.0f at config load",
        modes={"full", "relax"},
    ),
    Patch(
        name="netdriver-tick-cap",
        va=0x14046407E,
        window_off=0x46347D,
        window=[0xB8, 0x78, 0x00, 0x00, 0x00,                # MOV   EAX,120
                0x3B, 0xC8,                                  # CMP   ECX,EAX
                0x0F, 0x4C, 0xC1],                           # CMOVL EAX,ECX
        index=1,
        new=None,
        note="Clamp(NetServerMaxTickRate, 10, 120) ceiling; imm32, opt-in",
    ),
]

# --- server: UDK.exe --------------------------------------------------------

SERVER = [
    Patch(
        name="netdriver-90-clamp",
        va=0x14040B465,
        window_off=0x40A85E,
        window=[0x81, 0x78, 0x70, 0x10, 0x27, 0x00, 0x00,
                0x7F, 0x47],
        index=7,
        new=[0xEB],
        note="inert on a dedicated server (GIsClient == 0); applied for consistency",
        modes={"full", "relax"},
    ),
    Patch(
        name="netdriver-tick-cap",
        va=0x14040B49E,
        window_off=0x40A89D,
        window=[0xB8, 0x78, 0x00, 0x00, 0x00,
                0x3B, 0xC8,
                0x0F, 0x4C, 0xC1],
        index=1,
        new=None,
        note="Clamp(NetServerMaxTickRate, 10, 120) ceiling; imm32, opt-in",
    ),
]

TARGETS = {"client": CLIENT, "server": SERVER}


def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def hexs(b):
    return " ".join(f"{x:02X}" for x in b) if b else "<past end of file>"


def classify(data, patch):
    end = patch.window_off + len(patch.window)
    if end > len(data):
        return "mismatch", None
    got = bytes(data[patch.window_off:end])
    if got == patch.window:
        return "unpatched", got
    if patch.new and got == patch.patched_window():
        return "patched", got
    return "mismatch", got


def main():
    ap = argparse.ArgumentParser(
        description="Remove the online frame-rate ceilings from Chivalry: Medieval Warfare.")
    ap.add_argument("binary", type=Path, help="CMW.exe (client) or UDK.exe (server)")
    ap.add_argument("--mode", choices=MODES, default="full",
                    help="full = truly uncapped (default); relax = cap becomes netspeed/divisor")
    ap.add_argument("--check", action="store_true", help="report only, write nothing")
    ap.add_argument("--revert", action="store_true", help="restore from the .bak")
    ap.add_argument("--target", choices=sorted(TARGETS), help="override auto-detection")
    ap.add_argument("--force", action="store_true",
                    help="accept an unrecognised SHA-256, and overwrite an existing backup")
    ap.add_argument("--raise-tick-cap", type=int, metavar="N",
                    help="also raise the Clamp(NetServerMaxTickRate, 10, 120) ceiling to N")
    args = ap.parse_args()

    path = args.binary
    if not path.is_file():
        sys.exit(f"error: no such file: {path}")

    backup = path.with_suffix(path.suffix + ".bak")

    if args.revert:
        if not backup.is_file():
            sys.exit(f"error: no backup at {backup}")
        shutil.copy2(backup, path)
        print(f"reverted {path.name} from {backup.name}")
        return

    digest = sha256(path)
    target = args.target or KNOWN.get(digest)

    if target is None:
        sys.exit(
            "error: unrecognised build\n"
            f"       sha256 {digest}\n"
            "       expected one of:\n"
            + "".join(f"         {h}  ({t})\n" for h, t in KNOWN.items())
            + "       to try anyway: --target client|server --force\n"
              "       (if you have already patched this file, --revert first)"
        )
    if digest not in KNOWN and not args.force:
        sys.exit(
            f"error: sha256 {digest} is not a build this script knows.\n"
            "       If you have already patched it, run --revert first.\n"
            "       Otherwise re-run with --force; byte windows are still checked."
        )

    patches = list(TARGETS[target])
    if args.raise_tick_cap is not None:
        if not 1 <= args.raise_tick_cap <= 0x7FFFFFFF:
            sys.exit("error: --raise-tick-cap must be between 1 and 2147483647")
        for p in patches:
            if p.name == "netdriver-tick-cap":
                p.new = struct.pack("<I", args.raise_tick_cap)
                p.modes = {args.mode}

    data = bytearray(path.read_bytes())

    print(f"file    {path}")
    print(f"sha256  {digest}")
    print(f"target  {target}")
    print(f"mode    {args.mode}")
    print()

    if target == "server":
        print("NOTE: this binary governs the SERVER TICK RATE, not client frame rate.")
        print("      A client's cap is computed from negotiated netspeed, independently")
        print("      of the server's tick rate. Values up to 120 need no patch at all -")
        print("      just set NetServerMaxTickRate in the ini. Use --raise-tick-cap only")
        print("      if you want the server ticking above 120.")
        print()

    selected, blocking = [], False
    for p in patches:
        state, got = classify(data, p)
        chosen = args.mode in p.modes and p.new is not None
        mark = {"unpatched": "  ", "patched": "= ", "mismatch": "! "}[state]
        flag = "" if chosen else "   [not in this mode]"
        print(f"{mark}{p.name}{flag}")
        print(f"    VA 0x{p.va:X}  file 0x{p.offset:X}   {p.note}")
        if state == "mismatch":
            print(f"    expected {hexs(p.window)}")
            print(f"    found    {hexs(got)}")
            if chosen:
                blocking = True
        elif p.new:
            print(f"    {hexs(p.old)} -> {hexs(p.new)}   ({state})")
        print()
        if chosen and state == "unpatched":
            selected.append(p)

    if blocking:
        sys.exit("error: byte window mismatch on a selected patch - nothing was changed.")

    if not selected:
        print("nothing to do: every patch for this mode is already applied")
        return

    if args.check:
        print(f"--check: {len(selected)} patch(es) would be applied, nothing written")
        return

    if backup.exists() and not args.force:
        print(f"backup  {backup.name} already exists, keeping it")
    else:
        shutil.copy2(path, backup)
        print(f"backup  {backup.name}")

    for p in selected:
        data[p.offset:p.offset + len(p.new)] = p.new
    path.write_bytes(bytes(data))

    fresh = path.read_bytes()
    bad = [p.name for p in selected if classify(fresh, p)[0] != "patched"]
    if bad:
        shutil.copy2(backup, path)
        sys.exit(f"error: post-write verification failed for {bad} - reverted from backup")

    print(f"applied {len(selected)} patch(es), verified on disk")
    print(f"new sha256 {sha256(path)}")
    print()
    print("Steam's 'Verify integrity of game files' will undo this, as will --revert.")
    print("After any game update the script will refuse on the new build - that is intended.")


if __name__ == "__main__":
    main()