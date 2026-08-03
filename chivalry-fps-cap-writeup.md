# Removing the online frame-rate cap in Chivalry: Medieval Warfare

A reverse-engineering writeup: locating the compiled-in 90/120 FPS ceilings in a
stripped UE3 binary, explaining why the in-game `UNCAPFPS` command never worked
online, and removing the limit with two byte edits.

**Status: confirmed working.** Online matches now render above 120 FPS.

---

## 1. Summary

Chivalry caps client frame rate online at 90 FPS. The in-game `UNCAPFPS` console
command appears to do nothing in multiplayer, while working perfectly offline.

The cause is two frame-rate limiters in the engine, one of which `UNCAPFPS` can reach
and one of which it cannot. Disabling the first is what *activates* the second.

The fix is two single-byte-region edits to `CMW.exe`: bypass the netdriver branch in
`UGameEngine::GetMaxTickRate`, and stop `MaxSmoothedFrameRate` being clamped to 120 at
config load. Neither changes instruction length.

---

## 2. Targets

| | Client | Dedicated server |
|---|---|---|
| File | `CMW.exe` | `UDK.exe` |
| SHA-256 | `bb7b1f52e49bf647e9ec24c5745d36427f725a18442355cd77335c7481facdaa` | `561540d30cba8277ef876d978b56eb8f3f9b872d7c323f42f84c2fbfc62ea358` |
| Functions | 105,398 | 76,491 |

Both Win64 PE, image base `0x140000000`, fully stripped (no symbols — every function is
`FUN_*`), UE3/UDK, built from the same engine source.

Both have `.text` at VA `0x1000` with `PointerToRawData 0x400`, so for either binary:

```
file_offset = VA - 0x140000000 - 0xC00
```

---

## 3. How it was found

No symbols, so the entry point was string data. Two console-command strings sit adjacent
in `.rdata`:

- `GETMAXTICKRATE` @ `0x14130afc0`, referenced from `0x140479386`
- `UNCAPFPS` @ `0x14130afe0`, referenced from `0x1404793d2`

Both land inside `FUN_140478100` (`UEngine::Exec`). The `GETMAXTICKRATE` handler makes a
virtual call through slot `0x280`, which named the function to look for. The `UNCAPFPS`
handler gave up the mechanism directly:

```asm
1404793e6  MOV dword ptr [0x1417f6884],ESI        ; vsync -> D3DPRESENT_INTERVAL_IMMEDIATE
1404793ec  AND dword ptr [RDI+0x398],0xfffffeff   ; clear bit 0x100 at this+0x3F8
```

A negative result was equally informative: there is no `bSmoothFrameRate`,
`MinSmoothedFrameRate` or `MaxSmoothedFrameRate` string anywhere in either binary, even
though `NetServerMaxTickRate` and `bClampListenServerTickRate` both exist. The stock UE3
ini-driven smoothing config had been stripped, which suggested compiled-in constants
rather than config values.

Byte-scanning `.rdata` for the IEEE-754 encoding of 90.0f (`00 00 B4 42`) returned three
hits; one of them, `0x1411e4ef8`, was referenced from `FUN_140463f20` — inside a clamp,
immediately above an integer clamp against `0x78`. That was the function.

Useful searches, for reproduction:

| Goal | Pattern |
|---|---|
| 90.0f / 120.0f constants in `.rdata` | `00 00 B4 42` / `00 00 F0 42` |
| The 120 integer clamp | `B8 78 00 00 00 3B C8 0F 4C C1` (unique in both binaries) |
| Accesses to a field at `+0x604` | `F3 0F 5E ?? 04 06 00 00` (DIVSS) |
| Immediate writes to `+0x700` | `C7 ?? 00 07 00 00` |

---

## 4. The cap chain

Two functions, called in sequence.

```
UGameEngine::GetMaxTickRate(DeltaTime, bAllowSmoothing)   client 0x140463f20 / server 0x14040b340
│
├─ netdriver cap -> XMM6   (XMM6 initialised to 0.0f at function entry)
│   ├─ GIsClient == 0              -> Clamp(NetDriver+0xbc, 10, 120)   [dedicated server]
│   ├─ bClampListenServerTickRate  -> Clamp(NetDriver+0xbc, 10, 120)
│   ├─ listen server               -> Clamp(NetDriver+0xbc, 20, 60)
│   └─ pure client                 -> netspeed > 10000 ? (no cap)
│                                     : Clamp(netspeed / divisor, 10.0f, 90.0f)
│
└─ Super = UEngine::GetMaxTickRate(...)                   client 0x14042b920 / server 0x1403d3130
    └─ requires (UEngine+0x3F8 & 0x100) && bAllowSmoothing && GIsClient
        Clamp(1.0f / SmoothedDelta, MinSmoothedFrameRate+0x704, MaxSmoothedFrameRate+0x700)

return Super != 0.0f ? Super : XMM6
```

That final line is the whole trick. The smoothing result wins whenever it is non-zero;
the netdriver cap is a *fallback*.

### Client path, disassembled

```asm
140464020  MOVD   XMM6,dword ptr [RAX+0x70]     ; ServerConnection negotiated netspeed
140464027  CVTDQ2PS XMM6,XMM6
14046402a  CALL   0x140777490                   ; GetWorldInfo()
14046402f  DIVSS  XMM6,dword ptr [RAX+0x6d8]    ; / divisor
140464037  MOV    RAX,[RBX+0x80]
14046403e  CMP    dword ptr [RAX+0x70],0x2710   ; netspeed > 10000 ?
140464045  JG     0x14046408e                   ;   -> skip clamp entirely
140464047  MOVSS  XMM0,[0x1411c8e98]            ; 10.0f
14046404f  COMISS XMM6,XMM0
140464052  JNC    0x140464059
140464054  MOVAPS XMM6,XMM0                     ; clamp up to 10
140464059  MOVSS  XMM0,[0x1411e4ef8]            ; 90.0f
140464061  COMISS XMM6,XMM0
140464064  JB     0x14046408e
140464066  MOVAPS XMM6,XMM0                     ; clamp DOWN to 90   <-- the cap
```

### Tail

```asm
140464098  MOVAPS XMM1,XMM8                     ; DeltaTime
14046409c  MOV    R8D,EDI                       ; bAllowFrameRateSmoothing
14046409f  MOV    RCX,RSI                       ; this
1404640a2  CALL   0x14042b920                   ; Super::UEngine::GetMaxTickRate
1404640b7  UCOMISS XMM0,[0x14118c988]           ; == 0.0f ?
1404640be  JNZ    ret                           ; Super non-zero -> Super wins
1404640c0  MOVAPS XMM0,XMM6                     ; Super == 0 -> return netdriver cap
```

---

## 5. Confirmed field offsets

`FUN_140926790` in the server binary registers `"NetServerMaxTickRate"` (`0x140e8eb10`)
with offset immediate `0xbc`, flags `0x4000` (`CPF_Config`), category `"Client"`.
Registration order gives the neighbours, and the property block
(`MaxClientRate`, `MaxInternetClientRate`, `NetServerMaxTickRate`,
`bClampListenServerTickRate`) identifies the class as `UNetDriver`.

| Object | Offset | Field |
|---|---|---|
| `UNetDriver` | `+0x80` | `ServerConnection` — non-null only on a client |
| `UNetDriver` | `+0xb4` | `MaxClientRate` |
| `UNetDriver` | `+0xb8` | `MaxInternetClientRate` |
| `UNetDriver` | `+0xbc` | `NetServerMaxTickRate` |
| `UNetDriver` | `+0xc0` | `bClampListenServerTickRate` |
| `UEngine` | `+0x3F8` bit `0x100` | `bSmoothFrameRate` |
| `UEngine` | `+0x700` | `MaxSmoothedFrameRate` |
| `UEngine` | `+0x704` | `MinSmoothedFrameRate` |

`+0x700` / `+0x704` are confirmed by the `Clamp(1/SmoothedDelta, +0x704, +0x700)` shape in
`UEngine::GetMaxTickRate`, which also identifies the object operated on by
`FUN_140441780` (single caller `0x140471cb0`) as the engine.

Smoothing-path constants (server addresses):

| Address | Value | Role |
|---|---|---|
| `0x140c12c10` | `1.0f` | numerator of `1/SmoothedDelta` |
| `0x140cdbb80` | `0.2f` | DeltaTime ceiling — a 5 FPS floor on the smoothing input |
| `0x140d682d8` | `0.003333f` | smoothing alpha, ~1/300 frame time constant |

---

## 6. Three independent ceilings

1. **`MaxSmoothedFrameRate` forced to `<= 120.0f`** at config load
   (client `0x1404438da`). The smoothing path can never return above 120 regardless of
   ini contents. A byte search for immediate writes to `+0x700` across the whole client
   `.text` returns exactly two hits — this one and one unrelated class — so it is the
   only load-time ceiling on that field.
2. **`Clamp(NetServerMaxTickRate, 10, 120)`** — dedicated and listen-clamped server
   paths. A dedicated server cannot tick above 120 whatever the ini says.
3. **`Clamp(netspeed / divisor, 10.0f, 90.0f)`** — pure client online. Skipped entirely
   when negotiated netspeed exceeds 10000.

---

## 7. Why UNCAPFPS failed online

`UNCAPFPS` clears `bSmoothFrameRate`. That makes `UEngine::GetMaxTickRate` return `0.0f`,
which by the `Super != 0 ? Super : XMM6` rule hands control to the netdriver cap.

- **Offline** — no NetDriver, so `XMM6` is still the `0.0f` it was initialised to. The
  function returns 0. Genuinely uncapped.
- **Online** — the netdriver branch has already computed a cap into `XMM6`. That value is
  returned.

`UNCAPFPS` disables the only limiter it can reach and defers to the one it cannot. It
isn't ignored online; it is what puts the netdriver cap in charge.

The smoothing path also requires `GIsClient`, so on a dedicated server it never runs at
all and ceiling #2 always governs.

---

## 8. Empirical confirmation

The static model made falsifiable predictions. All three were tested.

| Stage | Client state | Online result | What it proved |
|---|---|---|---|
| Baseline | unpatched, `UNCAPFPS` on | **90 FPS** | ceiling #3 is live and binding |
| Patch v1 | `JG` at `0x140464045` forced taken | **120 FPS** | the clamp was doing real work, and the *raw* value underneath was ~120 |
| Patch v2 | netdriver branch bypassed | **>120, uncapped** | the netdriver branch was the sole remaining online limiter |

Patch v1 is worth dwelling on, because it was an incomplete fix that turned out to be a
good measurement. Skipping the clamp leaves `XMM6` holding the computed
`netspeed / divisor`; it does not zero it. The cap therefore moved from 90 to the raw
value rather than disappearing. That the raw value was **120** is data unobtainable from
static analysis — the divisor's default lives in the script package, not the executable.

So for this test environment, `netspeed / divisor ≈ 120`. If the divisor is UE3's stock
`42.0`, negotiated netspeed is ~5040; if netspeed is the LAN default 10000, the divisor is
~83. One further experiment would settle it: change netspeed, re-run in `relax` mode, and
see whether the observed cap moves proportionally.

The v2 result also rules out the main competing hypothesis. Had the 120 come from vsync
or a 120 Hz display limit, bypassing the netdriver branch would have left it at exactly
120. It didn't.

---

## 9. The patch

Two edits to `CMW.exe`, neither changing instruction length.

### Bypass the netdriver branch

At function entry `XMM6` is zeroed, and a `JZ` already skips the whole branch when there
is no engine pointer. Making that jump unconditional means nothing ever computes a cap.

```
VA 0x140463F4F   file 0x46334F   0F 84  ->  90 E9
```

`0F 84 43 01 00 00` (`JZ rel32`) becomes `90 E9 43 01 00 00` (`NOP` + `JMP rel32`). Both
are six bytes and the next-instruction address is unchanged, so the original `rel32` of
`0x143` still resolves correctly to `0x140464098`. `RBX`/`RBP` are saved *after* this
branch point and never clobbered on the skipped path, so omitting their restore is
correct.

### Free the smoothing ceiling

```
VA 0x1404438D8   file 0x442CD8   73  ->  EB
```

`JNC` becomes `JMP`, so the `MOV dword ptr [RBX+0x700], 120.0f` is never reached and
`MaxSmoothedFrameRate` keeps its configured value.

### Not patched, and why

- The `Clamp(x, 10.0f, 90.0f)` site — unreachable once the branch is bypassed.
- `Clamp(NetServerMaxTickRate, 10, 120)` — server tick rate, independent of client frame
  rate. Values up to 120 need no patch at all, just the ini.
- The `90.0f` literals (client `0x1411e4ef8`, server `0x140c5d7e8`) — pooled `.rdata`
  constants with multiple referrers. Editing them would have side effects elsewhere.

### Applying

`chiv_fpscap_patch.py` verifies a byte window around every edit, backs the file up,
applies, and re-verifies from disk. It fails closed on any mismatch and refuses to touch
a build it doesn't recognise.

```
python chiv_fpscap_patch.py --check CMW.exe    # dry run
python chiv_fpscap_patch.py CMW.exe            # apply (mode 'full')
python chiv_fpscap_patch.py --revert CMW.exe   # restore
```

`--mode relax` reproduces patch v1 — useful as a probe for the raw `netspeed / divisor`
value on a given server rather than as a fix.

Steam's *Verify integrity of game files* undoes everything. The script refuses on any
future build, by design.

---

## 10. What is still unknown

- **The divisor's runtime default.** `WorldInfo+0x604` is read in exactly one place in
  the entire binary — the `DIVSS` in `GetMaxTickRate` — with no writes and no other
  reads. It is a script-side property, so its default lives in the script package or ini
  rather than the executable.
- **Field names.** `CurrentNetSpeed` and `MoveRepSize` match stock UE3 and the arithmetic
  matches, but neither string exists in either binary; they are plain C++ members, not
  `UProperty`s. The offsets and the math are confirmed — the names are inference.
- **Where the server bounds negotiated netspeed.** Presumably readers of
  `UNetDriver+0xb4`/`+0xb8`; the clamp-constant search was inconclusive.
- **The enforcement site.** Whether the cap is realised by sleeping or busy-waiting was
  never established — `appSleep` was not positively identified. Relevant only if frame
  pacing looks uneven rather than merely faster.

---

## 11. Reproduction state

Symbols and comments were written back into both Ghidra projects.

**Client `CMW.exe`** — renamed `UGameEngine_GetMaxTickRate` (`0x140463f20`),
`UEngine_GetMaxTickRate` (`0x14042b920`), `UEngine_Exec` (`0x140478100`),
`EngineConfigValidate_ClampRates` (`0x140441780`); 6 decompiler comments.

**Server `UDK.exe`** — renamed `UGameEngine_GetMaxTickRate` (`0x14040b340`),
`UEngine_GetMaxTickRate` (`0x1403d3130`), `UNetDriver_RegisterProperties`
(`0x140926790`); 6 decompiler comments.

---

## 12. Caveats

This targets a specific build; any game update invalidates every offset here, and the
patcher will refuse rather than guess. The work was done in a test environment with
anti-cheat disabled. Modifying a multiplayer client is a decision with consequences that
depend entirely on where it is run.
