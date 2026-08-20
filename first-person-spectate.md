# First-Person Spectator — Re-enable Handoff

This document explains the current state of the (commented-out) first-person
spectator code, how vanilla AOC spectator follow actually works, what the
commented code is trying to do, and the known tilt bug. It is written for the
person who will implement the change.

---

## 1. Where the code lives

The first-person spectator code is entirely inside a single include file that is
pulled into **every** BangMod player-controller subclass:

```
BangMod/Include/BangModPlayerController.uci
```

Every `BangMod*PlayerController.uc` class does:

```unrealscript
`include(BangMod/Include/BangModPlayerController.uci)
```

so this include is effectively the shared override for `AOCPlayerController`.

The commented-out spectator block is roughly **lines 1839–1986** of
`BangMod/Include/BangModPlayerController.uci`. It contains:

| Lines | Item |
|-------|------|
| 1840–1850 | `ClientHideSpectatorHead` — client RPC to hide the target's head |
| 1852–1860 | `ClientShowSpectatorHead` — client RPC to restore the target's head |
| 1861–1986 | `state Spectating` — the whole first-person enforcement state |

The block was already commented out in the repository's initial commit
(`6426738 Initial commit`). It has never been compiled or enabled in this repo.

---

## 2. Vanilla AOC behavior (what we have today)

### 2.1 How you get into spectate

- `AOCPlayerController.JoinSpectatorTeam()` → `GenericSwitchToObs(true, true)`
  → `ClientGotoState('Spectating')` + `ServerSpectate()`.
- BangMod also exposes `AdminForceSpectate` / `AdminForceSpectateAll`
  (`BangModPlayerController.uci` lines ~1146–1206) which call
  `Target.JoinSpectatorTeam()`.

### 2.2 The input chain for "left click follows a player"

From `UDKGame/Config/DefaultInput.ini`:

```
.Bindings=(Name="LeftMouseButton",Command="GBA_SprintAttack|GBA_Fire|GBA_SpectatorNext",...)
...
.Bindings=(Name="GBA_SpectatorNext",Command="SpectatorNext")
```

So left click, while spectating, runs the `SpectatorNext` **state** function.
`AOCPlayerController` defines it inside `state Spectating`
(`AOC/classes/AOCPlayerController.uc` line 5043):

```unrealscript
exec function SpectatorNext()
{
    `log("SpectatorNext");
    ServerViewNextPlayer();
}
```

`ServerViewNextPlayer()` (line 5068) calls `super.ServerViewNextPlayer()`, which
is `Engine/classes/PlayerController.uc`:

```unrealscript
unreliable server function ServerViewNextPlayer()
{
    if (IsSpectating())
        ViewAPlayer(+1);
}

function ViewAPlayer(int dir)
{
    local PlayerReplicationInfo PRI;
    PRI = GetNextViewablePlayer(dir);
    if ( PRI != None )
        SetViewTarget(PRI);
}
```

`AOCPlayerController` **overrides** `ViewAPlayer` (line 5088) and this is the
line that forces third person:

```unrealscript
function ViewAPlayer(int dir)
{
    super.ViewAPlayer(dir);
    if(ViewTarget != none)
    {
        SetReality(ViewTarget.RealityID);
        SetBehindView(true); // <-- refresh behindview on new pawn (3RD PERSON)
    }
    ClientSetViewTarget(ViewTarget);
}
```

**That `SetBehindView(true)` is why vanilla follow is third person.**

### 2.3 Other bound spectator keys (for context)

| Input | Command | Effect |
|-------|---------|--------|
| Left click | `SpectatorNext` | Follow next player |
| `F` | `SpectatorPrevious` | Follow previous player |
| Right click | `SpectatorFreecam` | `SetViewTarget(none)` + `ServerViewSelf()` |
| Space | `SpectatorPerspective` | `BehindView()` (toggle perspective) |
| Mouse wheel | `SpectatorZoomIn/Out` | Zoom |

---

## 3. How first-person view actually works in this engine

This is the important background the implementer needs, because the commented
code bypasses part of this machinery.

### 3.1 `UsingFirstPersonCamera` / `IsFirstPerson`

`UTPlayerController.UsingFirstPersonCamera()` simply returns `!bBehindView`
(`UTGame/classes/UTPlayerController.uc` line 1791).

`UTPawn.IsFirstPerson()` (`UTGame/classes/UTPawn.uc` line 4595) returns true if
some local player controller has `ViewTarget == self` **and**
`UsingFirstPersonCamera()`. So **`bBehindView == false` is what makes the pawn
render/calc in first person.**

### 3.2 `AOCPlayerCamera.UpdateCamera` picks the FP socket

`AOC/classes/AOCPlayerCamera.uc` (lines 70–88):

```unrealscript
simulated function UpdateCamera()
{
    ...
    if (((OwnerPawn.IsLocallyControlled() && !OwnerPawn.bIsBot) || OwnerPawn.bIsBeingFPObserved) && OwnerPawn.Health > 0)
    {
        OwnerPawn.GetCameraSocketLocationAndRotation(true, CameraLocation, CameraRotation);
        CameraRotation.Roll = 0;   // <-- FP path zeroes roll
    }
    else
    {
        OwnerPawn.GetCameraSocketLocationAndRotation(false, CameraLocation, CameraRotation);
    }
    ...
}
```

`AOCPawn.GetCameraSocketLocationAndRotation(bFirstPerson, ...)`
(`AOC/classes/AOCPawn.uc` line 11320) reads the `CameraSocket` (`CameraPoint`)
from the **first-person `OwnerMesh`** when `bFirstPerson == true`, or from the
**third-person `Mesh`** otherwise.

Key gate: the first-person path only runs when the pawn
`bIsBeingFPObserved == true` (or is locally controlled).

### 3.3 `BecomeFirstPersonObserved` flips the pawn into FP mode

`AOC/classes/AOCPawn.uc`:

```unrealscript
simulated event BecomeViewTarget(PlayerController PC)          // line 11019
{
    if(IsLocallyControlled())
        DisableAnimationLodding();

    if (PC.IsLocalPlayerController() && AOCPlayerController(PC).IsInState('Spectating'))
    {
        CurrentObserver = PC;
        SetThirdPersonCamera(!bIsBeingFPObserved);  // starts 3rd person
    }
    else
        super.BecomeViewTarget(PC);
}

simulated function BecomeFirstPersonObserved( PlayerController PC )   // line 11044
{
    BecomeViewTarget(PC);
    bIsBeingFPObserved = true;
    CurrentObserver = PC;
    OwnerMesh.SetSkeletalMesh( CharacterAssetStore.OwnerMesh );       // swap to FP mesh
    AOCWeaponAttachment(CurrentWeaponAttachment).AttachTo(self);       // FP overlay weapon
}

simulated event EndViewTarget(PlayerController PC)                     // line 11056
{
    bIsBeingFPObserved = false;
    CurrentObserver = none;
}
```

`AOCPlayerController.SetBehindView` (line 5119) is the **normal** way
`BecomeFirstPersonObserved` gets invoked:

```unrealscript
simulated function SetBehindView(bool bNewBehindView)
{
    super.SetBehindView(bNewBehindView);
    if(IsLocalPlayerController())
    {
        if ( bBehindView )
            bFreeCamera = !AOCGRI(Worldinfo.GRI).bDisallowFreelookSpectator || IsVoluntarySpectator();
        else if(AOCPawn(ViewTarget) != none)
            AOCPawn(ViewTarget).BecomeFirstPersonObserved(self);   // <-- FP activation
        else
            bFreeCamera = true;
    }
}
```

### 3.4 `GetPlayerViewPoint` FP branch

`AOCPlayerController.GetPlayerViewPoint` (line 5154) is what places the camera
each frame for a pawn `ViewTarget`:

- `bFreeCamera == true` → free/orbit camera (zoom, etc.).
- `bFreeCamera == false && bBehindView == true` → third-person follow
  (offset back by `SpectatorBaseZoomDistance`).
- `bFreeCamera == false && bBehindView == false` → first-person follow:

```unrealscript
else
{
    //Not much we can do here; the ownermesh is still going to be crazy jittery
    POVRotation = RInterpTo(CalcViewRotation, TempPOVRot, DeltaTime, 20.0f);
}
```

`TempPOVRot` came from `ViewTarget.CalcCamera(...)`, which for a first-person
pawn is `GetPawnViewLocation()` / `GetViewRotation()` (the `CameraPoint` socket
on the OwnerMesh).

---

## 4. What the commented-out BangMod code does, function by function

The block declares `state Spectating` in the include, which **replaces** the
vanilla `AOCPlayerController` state of the same name. Important consequence:
functions in the vanilla state that BangMod does **not** redeclare
(`SpectatorNext`, `SpectatorPrevious`, `SpectatorFreecam`,
`SpectatorZoomIn/Out`, `ServerViewNextPlayer`, `ServerViewSelf`, …) are still
inherited, so all the key bindings from section 2.2 keep working. BangMod only
overrides the pieces it wants to change.

### `exec function BehindView()` (lines 1865–1873)
- Blocks the perspective toggle (`super.BehindView()`) unless `bFreeCamera` is
  true. Intent: when following a player you're locked to first person; in free
  camera you may toggle as normal.

### `exec function SpectatorPerspective()` (lines 1876–1884)
- Same gating for the Space-bar perspective toggle.

### `exec function NextCameraAngle()` (lines 1887–1895)
- Same gating for camera-angle cycling (only meaningful in 3rd person).

### `function BeginState(...)` (lines 1898–1911)
- On entering spectate, if `ViewTarget` is a `Pawn`, sets
  `bFreeCamera = false`, `bBehindView = false`, and hides the target's head.

### `function PlayerTick(...)` (lines 1914–1933)
- Every frame while following a pawn:
  1. Force `bBehindView = false`.
  2. Zero `Rotation.Roll` (the author's attempt to kill the lean tilt).
  3. Re-hide the target's head (to survive respawns/state changes).

### `function ViewAPlayer(int dir)` (lines 1936–1963)
- Saves `OldTarget`, calls `super.ViewAPlayer(dir)` (which changes the
  `ViewTarget` — and, via vanilla, calls `SetBehindView(true)`), restores the
  old target's head, then forces `bFreeCamera = false; bBehindView = false;`
  and hides the new target's head.

### `HideViewTargetHead()` / `EndState()` (lines 1966–1985)
- `HideViewTargetHead` fires `ClientHideSpectatorHead` for the current pawn.
- `EndState` restores head visibility via `ClientShowSpectatorHead` then
  `super.EndState(...)`.

### The two head-hiding RPCs (lines 1840–1860)
- `ClientHideSpectatorHead`: `HelmetMeshComp.SetOwnerNoSee(true)` and
  `Mesh.HideBoneByName('b_head', PBO_None)`.
- `ClientShowSpectatorHead`: un-does the above.

---

## 5. Gaps / problems in the commented code (what the implementer must fix)

1. **`BecomeFirstPersonObserved` is never called.**
   The code sets `bBehindView = false` directly in `BeginState`, `ViewAPlayer`
   and `PlayerTick`, instead of calling `SetBehindView(false)`. Because
   `SetBehindView` is what triggers `AOCPawn(ViewTarget).BecomeFirstPersonObserved(self)`,
   `bIsBeingFPObserved` stays `false`. Consequences:
   - `AOCPlayerCamera.UpdateCamera` takes the **third-person** socket branch,
     so the camera reads the 3P mesh's `CameraPoint`, not the 1P OwnerMesh.
   - The FP overlay weapon / FP mesh swap never happens.
   - The roll is **not** zeroed (see bug section).

   **Suggested fix:** in `BeginState`/`ViewAPlayer`/`PlayerTick`, replace the
   direct `bBehindView = false` with `SetBehindView(false)` (and guard against
   re-entry), or explicitly call
   `AOCPawn(ViewTarget).BecomeFirstPersonObserved(self)` +
   `SetThirdPersonCamera(false)`.

2. **`ViewAPlayer` fights vanilla's `SetBehindView(true)`.**
   Vanilla `ViewAPlayer` calls `SetBehindView(true)` immediately after switching
   targets. BangMod then flips `bBehindView` back to `false` afterward. This is
   a one-frame third-person flash and an order-of-operations hazard. A cleaner
   approach is to not call `super.ViewAPlayer` and instead replicate only what's
   needed (SetViewTarget + SetReality + ClientSetViewTarget) and go straight to
   FP.

3. **Head-hiding RPCs hide the wrong mesh.**
   `ClientHideSpectatorHead` does `HelmetMeshComp.SetOwnerNoSee(true)` and
   `Mesh.HideBoneByName('b_head', ...)` — but the first-person view renders the
   **OwnerMesh**, not `Mesh`/`HelmetMeshComp`. The helmet is attached via
   `HandleSocketAttachment(false, HelmetMeshComp, 'HelmetPoint')` on the 3P
   mesh; in FP the relevant pieces are the OwnerMesh head/helmet and the
   `HelmetEmitter` (see `AOCPawn` line ~9198 which already keys
   `HelmetEmitter.SetOwnerNoSee` off `bIsBeingFPObserved`). The vanilla
   `BecomeFirstPersonObserved` + `SetThirdPersonCamera` already handle most
   mesh visibility; the custom head hiding may be redundant or target the wrong
   component. Verify against `OwnerMesh` once FP observation is actually active.

4. **`PlayerTick` roll-zero targets the wrong object.**
   See the bug section below — zeroing the controller's `Rotation.Roll` does not
   fix the camera tilt.

5. **State-function modifiers.**
   Vanilla uses `simulated`/`event` for `Tick`, `BeginState`, `EndState`. The
   commented code uses plain `function`. It will still run on the owning client,
   but keep the modifiers consistent with vanilla to avoid surprises (e.g.
   `simulated` for anything that might run on non-authority clients).

---

## 6. Known bug — camera tilts when the tracked player sprints diagonally

**Symptom**
While first-person spectating a player, if the tracked player holds
`Shift + W + A` the camera tilts/rolls to the left; `Shift + W + D` tilts it to
the right. (Reported against the previous first-person spectate implementation.)

**Root cause**
1. While sprinting, Chivalry plays a **sprint-lean animation** (`AOCSprintLeanNode`,
   children "Lean Left" / "Straight" / "Lean Right") that tilts the skeleton.
   `W+A` leans left, `W+D` leans right.
2. The first-person camera position/rotation comes from the `CameraPoint` socket
   on the OwnerMesh (`GetCameraSocketLocationAndRotation`). Because the socket is
   a child of the leaning skeleton, its world rotation inherits **roll** from the
   lean.
3. In `GetPlayerViewPoint`'s FP branch,
   `POVRotation = RInterpTo(CalcViewRotation, TempPOVRot, DeltaTime, 20.0f)`
   interpolates **all three components, including roll**, straight into the
   spectator's view.
4. Vanilla normally cancels this roll in `AOCPlayerCamera.UpdateCamera`:

   ```unrealscript
   CameraRotation.Roll = 0;
   ```

   but that line only runs when `bIsBeingFPObserved == true`. The commented code
   never set `bIsBeingFPObserved` (see section 5.1), so the roll was never
   zeroed and the lean tilt leaked through to the spectator camera.

**Why the commented `PlayerTick` fix didn't work**
The commented code tried:

```unrealscript
CamRot = Rotation;
if (CamRot.Roll != 0)
{
    CamRot.Roll = 0;
    SetRotation(CamRot);
}
```

This zeroes the **controller's** `Rotation`, but the spectator camera's POV is
computed from the **observed pawn's camera socket** (`TempPOVRot`), not from the
controller rotation. So this had no effect on the tilt.

**Where to actually fix it (pick one or combine)**
1. **Preferred:** make sure `BecomeFirstPersonObserved` runs (section 5.1) so
   `AOCPlayerCamera.UpdateCamera` takes the FP branch and its existing
   `CameraRotation.Roll = 0` line cancels the lean roll.
2. If FP observation is still not guaranteed, zero roll explicitly in the FP
   branch of `AOCPlayerController.GetPlayerViewPoint` before the `RInterpTo`:

   ```unrealscript
   TempPOVRot.Roll = 0;
   POVRotation = RInterpTo(CalcViewRotation, TempPOVRot, DeltaTime, 20.0f);
   ```

   (Also zero `POVRotation.Roll` after the interp for safety.)
3. Alternatively zero roll at the source in `AOCPawn.GetCameraSocketLocationAndRotation`
   for the first-person path.

---

## 7. Suggested implementation plan

1. **Uncomment** the two head-hiding RPCs and the `state Spectating` block in
   `BangMod/Include/BangModPlayerController.uci` (lines 1839–1986).
2. **Switch FP activation to `SetBehindView(false)`** (or explicit
   `BecomeFirstPersonObserved`) in `BeginState`, `ViewAPlayer`, and `PlayerTick`,
   so `bIsBeingFPObserved` gets set and the FP mesh/socket/overlay weapon all
   engage.
3. **Rework `ViewAPlayer`** so it does not fight vanilla's `SetBehindView(true)`
   (either skip `super.ViewAPlayer` or override cleanly) and restores the old
   target's FP state before hiding the new target's head.
4. **Fix the roll/tilt** per section 6 (rely on `AOCPlayerCamera` roll-zero once
   FP observation is active; add `TempPOVRot.Roll = 0` as a belt-and-suspenders).
5. **Validate head/helmet hiding** against the OwnerMesh (1P) rather than the 3P
   `Mesh`/`HelmetMeshComp`.
6. **Test**:
   - left click follows next player in first person;
   - `F` follows previous player in first person;
   - right click still drops to free camera;
   - Space toggles perspective only in free camera;
   - tracked player dies → auto-advance (`AOCPlayerController.Tick` still runs);
   - tracked player sprints `W+A` / `W+D` → no camera roll;
   - switching targets restores the previous player's head/helmet.

## Developer notes

The previous implementation was made by a cheaper/older agent so if you want to rewrite everything that's fine. I abandoned the code because subjectively it felt more like a bodycam than the same sort of viewport you see when you normally play the game. Also, a nice to have would be able to see the health and stamina bar when you first person spectate someone, but if that's too difficult to pull off you can skip it.