# First-Person Spectator

Status: **implemented**. This document now describes what shipped, why it is
built the way it is, and what to test. The vanilla-engine background in
sections 2 and 3 is unchanged and is still the reference for anyone touching
this code.

---

## 1. Where the code lives

| File | What it holds |
|------|---------------|
| `BangMod/Include/BangModPlayerController.uci` | `BangModCanFPObserve` / `BangModApplyFPObserve` / `BangModClearFPObserve` / `BangModApplySpectatorPerspective` / `BangModRefreshSpectatorHUD`, the `FirstPersonSpectate` exec, and the `state Spectating` override |
| `BangMod/Include/BangModHUD.uci` | `DrawHUD` override + `BangModDrawSpectatorTarget` / `BangModGetFactionColor` (the followed player's name and class) |

Both includes are pulled into every BangMod player-controller / HUD subclass, so
this is effectively a shared override of `AOCPlayerController` and `AOCBaseHUD`.

The old commented-out block (the two `Client*SpectatorHead` RPCs and the previous
`state Spectating`) has been removed. None of it was needed — see section 4.

---

## 2. Vanilla AOC behavior (unchanged reference)

### 2.1 How you get into spectate

- `AOCPlayerController.JoinSpectatorTeam()` → `GenericSwitchToObs(true, true)`
  → `ClientGotoState('Spectating')` + `ServerSpectate()`.
- BangMod also exposes `AdminForceSpectate` / `AdminForceSpectateAll`
  (`BangModPlayerController.uci` ~lines 1146–1206) which call
  `Target.JoinSpectatorTeam()`.

### 2.2 The input chain for "left click follows a player"

From `UDKGame/Config/DefaultInput.ini`:

```
.Bindings=(Name="LeftMouseButton",Command="GBA_SprintAttack|GBA_Fire|GBA_SpectatorNext",...)
.Bindings=(Name="GBA_SpectatorNext",Command="SpectatorNext")
```

Left click, while spectating, runs the `SpectatorNext` **state** function on
`AOCPlayerController` (line 5053), which calls `ServerViewNextPlayer()` →
`ViewAPlayer(+1)` **on the server**.

`AOCPlayerController` overrides `ViewAPlayer` (line 5098) and this is the line
that forced third person:

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

Because this runs server-side (no `LocalPlayer`), `UTPlayerController.SetBehindView`
turns it into a `ClientSetBehindView(true)` RPC, so the *client* is dragged back
into third person on every single target change.

### 2.3 Other bound spectator keys

| Input | Command | Effect |
|-------|---------|--------|
| Left click | `SpectatorNext` | Follow next player |
| `F` | `SpectatorPrevious` | Follow previous player |
| Right click | `SpectatorFreecam` | `SetViewTarget(none)` + `ServerViewSelf()` |
| Space | `SpectatorPerspective` | `BehindView()` — an **empty stub** in vanilla's state |
| Mouse wheel | `SpectatorZoomIn/Out` | Zoom |

---

## 3. How first-person view actually works in this engine

### 3.1 `UsingFirstPersonCamera` / `IsFirstPerson`

`UTPlayerController.UsingFirstPersonCamera()` returns `!bBehindView`
(`UTPlayerController.uc:1791`). `UTPawn.IsFirstPerson()` (`UTPawn.uc:4595`)
returns true when some local player controller has `ViewTarget == self` **and**
`UsingFirstPersonCamera()`. So `bBehindView == false` is what makes the pawn
render/calc in first person.

### 3.2 `AOCPlayerCamera.UpdateCamera` picks the FP socket

`AOCPlayerCamera.uc` lines 70–88:

```unrealscript
if (((OwnerPawn.IsLocallyControlled() && !OwnerPawn.bIsBot) || OwnerPawn.bIsBeingFPObserved) && OwnerPawn.Health > 0)
{
    OwnerPawn.GetCameraSocketLocationAndRotation(true, CameraLocation, CameraRotation);
    CameraRotation.Roll = 0;   // <-- FP path zeroes roll
}
else
{
    OwnerPawn.GetCameraSocketLocationAndRotation(false, CameraLocation, CameraRotation);
}
```

`GetCameraSocketLocationAndRotation(true, ...)` reads `CameraSocket` off the
**first-person `OwnerMesh`**; `false` reads it off the **third-person `Mesh`**.

**`bIsBeingFPObserved` is the master switch.** It also gates the OwnerMesh
animation tree (`AOCPawn.uc` 5189, 5300, 5321, 5348, 5369, 5614), the FP overlay
weapon, `HelmetEmitter` visibility (9208), and the health/stamina HUD push (9140).
Torn Banner built the whole observer path; they just never wired input to it.

### 3.3 `BecomeFirstPersonObserved` flips the pawn into FP mode

`AOCPlayerController.state Spectating.SetBehindView(false)` (line 5129) is the
only thing that calls `AOCPawn.BecomeFirstPersonObserved()`. That is why the
implementation goes through `SetBehindView(false)` rather than assigning
`bBehindView` directly.

### 3.4 `GetPlayerViewPoint` FP branch

`AOCPlayerController.GetPlayerViewPoint` (line 5165, inside `state Spectating`):

- `bFreeCamera == true` → free/orbit camera (this is also what vanilla "3rd
  person follow" actually is)
- `bFreeCamera == false && bBehindView == true` → offset-back follow
- `bFreeCamera == false && bBehindView == false` → first-person follow:
  `POVRotation = RInterpTo(CalcViewRotation, TempPOVRot, DeltaTime, 20.0f)`

---

## 4. What was implemented

### 4.1 Route target changes through the real FP-observer path

`state Spectating.ViewAPlayer` is overridden and **deliberately does not call
`super`**. It reproduces the useful half of vanilla (`GetNextViewablePlayer` →
`SetViewTarget` → `SetReality` → `ClientSetViewTarget`) and drops the
`SetBehindView(true)` force. The client then picks its own perspective inside
`ClientSetViewTarget`, which is the correct client-side hook for "the view target
changed".

### 4.2 Fix vanilla's own call-order bug

`SetBehindView(false)` in the spectating state runs:

```
super.SetBehindView(false)          -> bBehindView = false, bFreeCamera = false,
                                       ViewTarget.SetThirdPersonCamera(false)
AOCPawn.BecomeFirstPersonObserved(self)
    -> BecomeViewTarget(self)
        -> SetThirdPersonCamera(!bIsBeingFPObserved)   // still false here, so this
                                                       // re-runs as SetThirdPersonCamera(TRUE)
    -> bIsBeingFPObserved = true, swap OwnerMesh, attach 1P weapon
```

So vanilla ends with the pawn flagged for a first-person **camera** but still in
third-person **visuals**: 3P body drawn, helmet on, 1P mesh hidden. That is what
"seeing inside their head" was. `BangModApplyFPObserve` calls
`P.SetThirdPersonCamera(false)` immediately afterwards to put the meshes back
into 1P state.

**Consequence: the head-hiding RPCs are gone.** `SetThirdPersonCamera(false)`
already does `Mesh.SetOwnerNoSee(true)` + `HelmetMeshComp.SetOwnerNoSee(true)`,
which is both correct and per-view-target (these components are declared
`bOwnerNoSee` / `bOnlyOwnerSee` in `AOCPawn` defaultproperties), so nothing leaks
onto other players or persists after switching away.

### 4.3 The tilt bug is fixed for free

Because `bIsBeingFPObserved` is now actually set, `AOCPlayerCamera.UpdateCamera`
takes its FP branch and executes its existing `CameraRotation.Roll = 0`. The
sprint-lean roll (`AOCSprintLeanNode`, `Shift+W+A` / `Shift+W+D`) never reaches
the spectator's POV.

The old fix attempt zeroed the **controller's** `Rotation.Roll`, but the POV comes
from the observed pawn's camera socket (`TempPOVRot`), not from controller
rotation — which is why it did nothing.

### 4.4 Feed the 1P aim offset

`AOCPawn.FaceRotation` (line 5611) is the only thing that copies
`AimNode.Aim` → `OwnerAimNode.Aim`, and `FaceRotation` only runs for a locally
controlled pawn (`PlayerController.UpdateRotation` / `ProcessMove`). For a pawn we
are merely observing it never fires, which would leave the 1P mesh — and therefore
the camera socket — refusing to pitch with the observed player's aim.

`state Spectating.PlayerTick` re-copies it every frame while
`bIsBeingFPObserved`. **If a future engine-side change makes this redundant it can
be deleted safely; it is a defensive copy, not load-bearing.**

### 4.5 Perspective toggle

- First person is the default (`bBangModFPSpectate = true`, set in `PostBeginPlay`
  so the choice survives re-entering spectate).
- **Space** (`SpectatorPerspective`, and `BehindView` which routes to it) flips
  between first person and the vanilla orbit follow.
- **Right click** (`SpectatorFreecam`) still detaches to free camera.
- `FirstPersonSpectate <bool>` is a console exec for anyone who wants to default
  to the orbit follow.

Important gotcha handled here: `UTPlayerController.SetBehindView(false)` also sets
`bFreeCamera = false`, and `state Spectating.PlayerMove` early-outs on
`!bFreeCamera` *before* `UpdateRotation()`. Leaving first person therefore has to
call `SetBehindView(true)` to hand `bFreeCamera` back, otherwise the free camera
is frozen and cannot even look around. Both exit paths (`SpectatorFreecam` and the
"no live target" branch of `BangModApplySpectatorPerspective`) do this.

### 4.6 Spectator HUD

**Health / stamina.** `AOCPlayerController.PlayerTick` already pushes
`AOCPawn(ViewTarget).Health / .Stamina` into the HUD when we have no pawn of our
own (line 3667), and `ReplicatedStamina` is in `AOCPawn`'s general replication
block, so the values reach every client. What was missing was visibility:
`DisplayCompleteHUD()` is only called from `ShowHUDElements()` on possession, so
somebody who joined straight into spectate never had the bars turned on.
`BangModRefreshSpectatorHUD` calls it on target change and resets
`PreviousHealth` / `PreviousStamina` to `-1` to defeat the change filter so the
new target's values push immediately.

**Name / class.** Drawn by `BangModDrawSpectatorTarget` in `BangModHUD.uci`
(centred, ~88% down the screen, tinted by faction, with a drop shadow).

Why not the vanilla sub-crosshair info box: `AOCBaseHUD.DrawHUD`'s spectator
branch does support it (`bOverrideSubXhair` / `OverrideText`, lines 679–685), but
a few lines later the same branch unconditionally calls
`ShowInfomationBox(false)` whenever `GetViewName()` fails to resolve a player
under the crosshair — which is the normal case while first-person spectating. So
the readout is drawn directly instead of fighting that.

The faction colour reads `AOCPRI.MyFamilyInfo.FamilyFaction` directly rather than
`AOCPRI.GetCurrentTeam()`, because that function dereferences `Team` without a
none-check on its bot branch.

### 4.7 None-safety

`BangModCanFPObserve` gates every apply/clear. It checks everything
`BecomeFirstPersonObserved` and `SetThirdPersonCamera` dereference without their
own none-checks (`OwnerMesh`, `CharacterAssetStore`, `HelmetMeshComp`,
`HelmetEmitter`, `ShieldMesh`, `OverlayShieldMesh`, the
`AOCWeaponAttachment(CurrentWeaponAttachment)` **cast**, and that attachment's
`Mesh`). This matters because `PlayerTick` retries every frame, so an unguarded
apply would turn one partially-replicated target into per-frame "Accessed None"
spam.

---

## 5. Test plan

Camera:

- [ ] Left click follows the next player **in first person**, no third-person flash.
- [ ] `F` follows the previous player in first person.
- [ ] Space toggles first person ↔ orbit follow, both directions, repeatedly.
- [ ] Right click drops to free camera **and the free camera can move and look around**
      (this is the `bFreeCamera` regression guarded against in 4.5).
- [ ] Space while in free camera does nothing (no target to toggle).
- [ ] The followed player's own body/helmet is not visible from inside their head.
- [ ] After switching from A to B, player A looks normal again (3P body, helmet on,
      no floating 1P mesh).

Tilt (the original bug):

- [ ] Tracked player holds `Shift+W+A` → **no camera roll**.
- [ ] Tracked player holds `Shift+W+D` → **no camera roll**.

Aim:

- [ ] Tracked player looks up/down — the spectator view pitches with them.
- [ ] Tracked player attacks — the view shows the normal Chivalry first-person
      attack camera motion and the 1P weapon.

Lifecycle:

- [ ] Tracked player dies → auto-advance to the next player still works, and the
      new target comes up in first person.
- [ ] Tracked player dies with nobody left alive → no stuck/frozen camera.
- [ ] Tracked player respawns while followed → first person re-applies to the new pawn.
- [ ] Leaving spectate (joining a team, spawning) restores the normal HUD and camera.

HUD:

- [ ] Health and stamina bars show the **followed player's** values and update live.
- [ ] Bars appear for a client who joined straight into spectate (never possessed a pawn).
- [ ] Bars hide in free camera and when the target dies.
- [ ] Name + class readout shows, tinted by team, and updates on target change.
- [ ] Nothing draws when not spectating.

Networking:

- [ ] All of the above on a dedicated server, not just listen/standalone.
- [ ] Two spectators following the same player at once — neither one's mesh state
      affects the other or the player being watched.

---

## 6. Notes / open items

- The "bodycam" feel of the previous attempt was a symptom of never setting
  `bIsBeingFPObserved`: the camera was reading the **third-person** mesh's camera
  socket, which carries the full-body locomotion and lean animation. The 1P
  `OwnerMesh` socket is the one the game uses when you play normally. If it still
  reads wrong after this change, the next lever is the smoothing constant in
  `AOCPlayerController.state Spectating.GetPlayerViewPoint`
  (`RInterpTo(CalcViewRotation, TempPOVRot, DeltaTime, 20.0f)`), which BangMod can
  override in its own state if needed.
- `NextCameraAngle` is a no-op in first person and sets `iThirdPersonAngle = 1` in
  orbit follow, matching vanilla. If real cycling is ever wanted, the values live in
  `AOCPlayerController.ThirdPersonCameraPositions` and are consumed by
  `AOCPlayerCamera.CalcThirdPersonLocation`.
- This has **not been compiled or run** yet — it was written against the vanilla
  source and reviewed for symbol/signature correctness, but the first build is
  still ahead of it.
