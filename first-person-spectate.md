# First-Person Spectator

Status: **implemented**. This document now describes what shipped, why it is
built the way it is, and what to test. The vanilla-engine background in
sections 2 and 3 is unchanged and is still the reference for anyone touching
this code.

---

## 1. Where the code lives

| File | What it holds |
|------|---------------|
| `XangMod/Include/XangModPlayerController.uci` | `XangModCanFPObserve` / `XangModApplyFPObserve` / `XangModClearFPObserve` / `XangModApplySpectatorPerspective` / `XangModRefreshSpectatorHUD`, the `FirstPersonSpectate` exec, and the `state Spectating` override |
| `XangMod/Include/XangModHUD.uci` | `DrawHUD` override + `XangModDrawSpectatorTarget` / `XangModGetFactionColor` (the followed player's name and class) |

Both includes are pulled into every XangMod player-controller / HUD subclass, so
this is effectively a shared override of `AOCPlayerController` and `AOCBaseHUD`.

The old commented-out block (the two `Client*SpectatorHead` RPCs and the previous
`state Spectating`) has been removed. None of it was needed — see section 4.

---

## 2. Vanilla AOC behavior (unchanged reference)

### 2.1 How you get into spectate

- `AOCPlayerController.JoinSpectatorTeam()` → `GenericSwitchToObs(true, true)`
  → `ClientGotoState('Spectating')` + `ServerSpectate()`.
- XangMod also exposes `AdminForceSpectate` / `AdminForceSpectateAll`
  (`XangModPlayerController.uci` ~lines 1146–1206) which call
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
"seeing inside their head" was. `XangModApplyFPObserve` calls
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

- First person is the default (`bXangModFPSpectate = true`, set in `PostBeginPlay`
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
"no live target" branch of `XangModApplySpectatorPerspective`) do this.

### 4.6 Spectator HUD

**Health / stamina.** `AOCPlayerController.PlayerTick` already pushes
`AOCPawn(ViewTarget).Health / .Stamina` into the HUD when we have no pawn of our
own (line 3667), and `ReplicatedStamina` is in `AOCPawn`'s general replication
block, so the values reach every client. What was missing was visibility:
`DisplayCompleteHUD()` is only called from `ShowHUDElements()` on possession, so
somebody who joined straight into spectate never had the bars turned on.
`XangModRefreshSpectatorHUD` calls it on target change and resets
`PreviousHealth` / `PreviousStamina` to `-1` to defeat the change filter so the
new target's values push immediately.

**Name / class.** Drawn by `XangModDrawSpectatorTarget` in `XangModHUD.uci`
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

`XangModCanFPObserve` gates every apply/clear. It checks everything
`BecomeFirstPersonObserved` and `SetThirdPersonCamera` dereference without their
own none-checks (`OwnerMesh`, `CharacterAssetStore`, `HelmetMeshComp`,
`HelmetEmitter`, `ShieldMesh`, `OverlayShieldMesh`, the
`AOCWeaponAttachment(CurrentWeaponAttachment)` **cast**, and that attachment's
`Mesh`). This matters because `PlayerTick` retries every frame, so an unguarded
apply would turn one partially-replicated target into per-frame "Accessed None"
spam.

---

### 4.8 The stripped 1P mesh (post-release fix)

First testing on a dedicated server showed the view never leaving third person.
Cause: `AOCPawn.SetCharacterAppearance()` (`AOCPawn.uc` ~11890) **destroys** the
first-person `OwnerMesh` on any pawn that was not locally controlled at the moment
it loaded its character assets:

```unrealscript
if( IsLocallyControlled() || bIsBeingFPObserved )
{
    ... OwnerMesh.SetAnimTreeTemplate(...);
    ... OwnerMesh.SetSkeletalMesh( AssetStore.OwnerMesh );
}
else if(Worldinfo.NetMode != NM_DedicatedServer || Controller != none)
{
    DetachComponent(OwnerMesh);
    OwnerMesh = none;
}
```

That runs at spawn, long before anybody spectates, so `bIsBeingFPObserved` is
always false there. `BecomeFirstPersonObserved()` then does
`OwnerMesh.SetSkeletalMesh(...)` on a null component and the whole FP path is
dead on arrival.

Who is affected — this is **not** bot-specific:

| Setup | 1P mesh survives? |
|-------|-------------------|
| Your own pawn | Yes |
| Host (listen/standalone) watching a **bot** | Yes — server-side AI controllers count as locally controlled |
| Client watching a bot | **No** |
| Anyone watching a remote human on a dedicated server | **No** |

The 1P skeletal mesh **asset** is fine: `LoadCharacterAssets()` fetches
`OwnerMeshPath` into `CharacterAssetStore.OwnerMesh` on every non-dedicated client
with no locally-controlled gate. Only the component is missing.

**Fix:** `XangModEnsureOwnerMesh()` in `XangModPawn.uci` rebuilds the component
from the class-default archetype
(`new(self) class'SkeletalMeshComponent'(default.OwnerMesh)`), re-applies the anim
tree, anim sets, skeletal mesh and materials in the same order
`SetCharacterAppearance()` uses, and verifies that `OwnerAimNode` /
`OwnerBlendAnimationListNode` got bound — vanilla relies on
`SetAnimTreeTemplate()` firing `PostInitAnimTree(OwnerMesh)` to populate those,
and there is no other call site that assigns them. If they come back none the
rebuild is reverted so the spectator stays in a clean third person rather than
looking at a static ref-pose.

It is driven from a `BecomeViewTarget` override in `XangModPawn.uci`, which fires
from the native `SetViewTarget` inside `PlayerController.ClientSetViewTarget` —
exactly one step ahead of where `XangModApplySpectatorPerspective()` runs on the
controller. Rebuild cost is one component + anim-tree init per pawn, once, cached
for that pawn's lifetime.

### 4.9 Always establish a camera state (post-release fix)

`state Spectating.ViewAPlayer` deliberately drops vanilla's
`SetBehindView(true)` on every target change (see 4.1). That means XangMod is now
solely responsible for setting the camera state, and the original
`XangModApplySpectatorPerspective()` did not hold up its end:

```unrealscript
if (bXangModFPSpectate)
    XangModApplyFPObserve(P);   // silently no-ops if the guard fails
else
    { XangModClearFPObserve(); SetBehindView(true); }
```

When `XangModApplyFPObserve` bailed on its none-guard -- which, before 4.8, was
**every single pawn on a client** -- neither branch touched `bBehindView` or
`bFreeCamera`. The controller ran on whatever those flags happened to be left at,
with nothing ever refreshing them. `state Spectating.PlayerMove` early-outs on
`!bFreeCamera` before `UpdateRotation()`, so a stale `false` there means a camera
that neither follows anybody nor accepts input.

Fix: `XangModApplyFPObserve` now returns whether it succeeded, and
`XangModApplySpectatorPerspective` falls through to an explicit
`SetBehindView(true)` when first person is not available -- so a definite camera
state is always established, exactly as vanilla guaranteed.

`XangModPerspectivePawn` tracks the pawn we have already settled on, so the
fallback runs once per pawn rather than every frame, while first person is still
cheaply retried in case the 1P mesh only becomes rebuildable after the pawn's
character assets finish streaming.

**Rule of thumb for this file: if you remove a vanilla call, you own everything it
was doing.**

### 4.10 Rebuilt-component gotchas

Three things a second review caught in the 4.8 rebuild, all worth remembering if
anyone ever script-instances a component in this codebase:

- **`new(self) class'X' (Template)` is a plain property copy — it does NOT run
  component instancing.** The `LightEnvironment` pointer it copies still refers to
  the class-default `MyLightEnvironment` subobject, which is not registered in the
  world, so the rebuilt 1P mesh renders unlit (black). Fixed with
  `OwnerMesh.SetLightEnvironment(Mesh.LightEnvironment)` right after
  `AttachComponent`, mirroring `AOCWeaponAttachment.uc:258`.

- **The rebuild only fires from the pawn's `BecomeViewTarget`,** i.e. once per
  view-target change. If the pawn's character assets had not finished streaming at
  that moment, `CharacterAssetStore.OwnerMesh` is none, the rebuild bails, and
  nothing would ever try again — the "retry" in `PlayerTick` was a permanent no-op
  because it only re-checked a component that only that hook creates. `PlayerTick`
  now re-pokes `P.BecomeViewTarget(self)`, rate limited to twice a second via
  `fXangModNextFPRetry`.

- **`AOCPlayerController.state Spectating.SetBehindView` dereferences
  `AOCGRI(WorldInfo.GRI)` unguarded**, and that is reachable the instant a joining
  client enters spectate, before the GRI has replicated.
  `XangModRestoreVanillaCamera()` guards it and sets the flags directly in that
  window.

Still unverified by reading alone: whether the engine's native component attach
fires `PostInitAnimTree` for a script-`new`'d `SkeletalMeshComponent`. The
`OwnerAimNode == none` check in `XangModEnsureOwnerMesh` is the hedge — if it does
not fire, the rebuild reverts itself and you stay in a clean third person rather
than looking at a frozen ref-pose. The log line it emits says which happened.

### 4.11 Post-spawn camera correction (post-release fix)

The camera-stranded-on-spawn bug survived 4.9 through 4.12. Reading
`Engine.PlayerController.ClientRestart()` (PlayerController.uc:4728) rather than
assuming its order explains why — on a client it runs:

```unrealscript
Pawn = NewPawn;
AcknowledgePossession(Pawn);
Pawn.ClientRestart();
if (Role < ROLE_Authority)
{
    SetViewTarget(Pawn);   // still inside state Spectating
    ResetCameraMode();     // no-op unless PlayerCamera exists
    EnterStartState();     // only NOW do we leave Spectating
}
```

Note `Role < ROLE_Authority` — **this whole block is skipped on a listen-server
host**, which is another reason host testing cannot reproduce it.

Two consequences:

1. `SetViewTarget(Pawn)` fires `AOCPawn.BecomeViewTarget()` while the controller is
   *still* in `state Spectating`, so it takes its spectator branch
   (`CurrentObserver = PC; SetThirdPersonCamera(...)`) and never calls
   `super.BecomeViewTarget()`. UTPawn's real possession-view setup — arms attach,
   `SetMeshVisibility(bBehindView)`, `bUpdateEyeHeight = true` — is skipped for your
   own pawn.

2. `PlayerController.GetPlayerViewPoint` reads the view **straight off
   `PlayerCamera`** and ignores `Pawn`/`ViewTarget` entirely whenever one exists.
   The only place AOC destroys it is the non-`CameraActor` branch of
   `state Spectating.GetPlayerViewPoint`, so leaving spectate while one is alive
   strands the view wherever that camera actor sits — a fixed spot on the map, with
   the pawn playing normally underneath. `ResetCameraMode()` cannot rescue this:
   `PlayerController.SetCameraMode()` does nothing at all when `PlayerCamera` is
   None, and only sets `CameraStyle` when it is not.

Rather than fight that ordering, `ClientRestart` is overridden to schedule
`XangModFixCameraAfterSpawn()` on a 0.05s timer. Once the transition has actually
completed it destroys any surviving `PlayerCamera`, clears `bFreeCamera`, clears
the FP-observer flags off our own pawn, forces the view-target transition to
re-run (`SetViewTarget(none)` then `SetViewTarget(Pawn)`) so `BecomeViewTarget`
takes its normal branch this time, and puts the controller's own location back on
the pawn.

**This is a corrective, not a root-cause fix** — it re-asserts the right state
instead of preventing the wrong state. It also logs, via `LogAlwaysInternal`, one
line before and one line after correcting:

```
[XangModFPSpec] post-spawn State=PlayerWalking Pawn=... ViewTarget=... PlayerCamera=... bBehindView=... bFreeCamera=... PCLoc=...
[XangModFPSpec] post-spawn-corrected ...
```

Read the *first* line to identify the real cause:

- `PlayerCamera=` anything but `None` → cause (2), and the correction handles it.
- `ViewTarget=` not your own pawn → cause (1) or a stale spectator target.
- `bFreeCamera=True` → the controller still thinks it is a free camera.
- `State=` still `Spectating` → the client never left the state at all, which would
  be a different bug again.

### 4.12 Diagnostic

`FPSpectateDebug` (console exec, `XangModPlayerController.uci`) works in **any**
state, not just while spectating, and dumps: current state name, netmode, `Pawn`,
`ViewTarget`, `RealViewTarget`, `PlayerCamera`, the perspective flags, both pawn
trackers, then -- if the view target is a pawn -- `bIsBot` / `IsLocallyControlled`,
`bIsBeingFPObserved`, the `OwnerMesh` component, `OwnerAimNode`, the asset store
and its 1P mesh asset, every component `XangModCanFPObserve` gates on, and the
final verdict.

Signatures to look for:

- `OwnerMesh (1P component): None` -- the stripped 1P mesh, section 4.8.
- `PlayerCamera:` anything other than `None` during normal play -- the engine is
  reading the view straight off a `Camera` actor and ignoring `Pawn` / `ViewTarget`.
- `ViewTarget is not our own Pawn while we have one` -- the frozen-camera
  signature: the pawn is alive and taking input while the view is somewhere else.

### 4.13 Do not clear the HUD on leaving spectate (post-release fix)

First build regressed health/stamina in **actual play**: a player's bars were
missing for their whole first life after joining.

`state Spectating.EndState` was calling `AOCBaseHUD.ClearHUDOnDeath()`
unconditionally. The spawn sequence is:

1. server `AOCPlayerController.Possess()` -> `ShowHUDElements()` (reliable client RPC)
   -> `DisplayCompleteHUD()` -> life bars **on**
2. server -> `ClientRestart(Pawn)` (reliable client RPC) -> `Pawn = NewPawn` ->
   `EnterStartState()` -> `EndState('Spectating')`

Both are reliable, so step 1 always lands first and the `EndState` hook then
re-hid the bars, the crosshair and the ammo count. Nothing calls
`DisplayCompleteHUD()` again until the next `Possess()`, i.e. the next respawn --
hence "no bars until you die once". `SetHealthValues()` kept updating the widget
the whole time, it was just invisible, which is why it looked like a data problem
rather than a visibility one.

Fix: guard on `Pawn == none`. `Engine.PlayerController.ClientRestart()` assigns
`Pawn` before `EnterStartState()`, so a non-none `Pawn` at `EndState` reliably
means "we are spawning -- leave the HUD alone". Leaving spectate without a pawn
still tidies up.

Worth remembering generally: this state is also the parent of
`state SpecialSpectating`, and it is the state players sit in during team/class
select -- anything done in its `BeginState`/`EndState` runs far more often, and in
more situations, than "somebody pressed spectate".

---

---

## 4b. Build and deploy — verify this FIRST

Two rounds of debugging were wasted on stale builds. Before diagnosing any "still
broken" report, prove the fix is actually in the build.

**There are two separate copies of the source. They are not linked.**

| Path | Role |
|------|------|
| `C:\Users\Bindon\Documents\GitHub\SlumpMod` | the git repo |
| `F:\SteamLibrary\...\Development\Src\XangMod` | what the SDK actually compiles |

The second is a hand-made copy of the first. Editing only the repo changes
nothing about the build.

```
for f in .../SlumpMod/Include/*.uci; do
    n=$(basename $f); md5sum "$f" ".../Development/Src/XangMod/Include/$n"
done
```

**The package the game loads is neither `UDKGame\Script` nor
`UDKGame\ScriptFinalRelease`** (those belong to the separate megapatch work). It
is loaded as DLC from:

```
UDKGame\CookedSDK\XangMod_F70955F34DCA9EB5481E2392F9B0A2E1\XangMod.u
```

`.u` files store their name table as plain text, so a fix can be confirmed present
without running the game:

```
grep -a -c "XangModFixCameraAfterSpawn" .../CookedSDK/XangMod_*/XangMod.u
```

Zero means the build predates the fix, whatever the source says. Also compare the
`.u` mtime against the `.uci` mtimes.

**Script logging does not work in this build.** The client log
(`Documents\My Games\Chivalry Medieval Warfare\UDKGame\Logs\Launch.log`) contains
zero `ScriptLog` lines — script output is suppressed in the shipping build, so
`LogAlwaysInternal` never appears. `XangModLogCameraState` is therefore inert here;
use the `FPSpectateDebug` exec instead, which goes through
`ClientDisplayConsoleMessage` and renders in game.

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

- [ ] **Leave spectate and spawn: the camera follows your own pawn, you can move
      and look, and the HUD is intact.** (4.9 / 4.11 / 4.13 — this is the one that broke.)
- [ ] Spawn, die, respawn, spectate, spawn again — camera correct every time.
- [ ] Tracked player dies → auto-advance to the next player still works, and the
      new target comes up in first person.
- [ ] Tracked player dies with nobody left alive → no stuck/frozen camera.
- [ ] Tracked player respawns while followed → first person re-applies to the new pawn.
- [ ] Leaving spectate (joining a team, spawning) restores the normal HUD and camera.

HUD:

- [ ] **Join a server, pick a team, spawn: health and stamina bars are visible on the FIRST life.** (4.13)
- [ ] Crosshair and ammo count also survive that first spawn.
- [ ] Health and stamina bars show the **followed player's** values and update live.
- [ ] Bars appear for a client who joined straight into spectate (never possessed a pawn).
- [ ] Bars hide in free camera and when the target dies.
- [ ] Name + class readout shows, tinted by team, and updates on target change.
- [ ] Nothing draws when not spectating.

Networking (this is where 4.8 bit -- do not sign off on host-only testing):

- [ ] All of the above **on a dedicated server**, as a connected client.
- [ ] `FPSpectateDebug` reports a non-None `OwnerMesh` and `CanFPObserve: True` for a remote player.
- [ ] Watching a **bot** from a client (not just from the host) goes first person.
- [ ] Two spectators following the same player at once — neither one's mesh state
      affects the other or the player being watched.

---

## 6. Notes / open items

- **The "camera stranded on spawn" bug was never a spectate bug.** Commit `ed572f9`
  (2026-07-21) renamed 26 asset references across 14 `XangModCharacterInfo_*`
  classes to a package `XangmodCharacters` that was never created. Those classes —
  Knight and Vanguard in every variant, plus BARB Archers — therefore had no
  first-person mesh. `AOCPlayerCamera.UpdateCamera()` reads the camera position
  from a socket on that mesh, and `GetSocketWorldLocationAndRotation` returns
  **without writing its output** when the mesh is NULL, so `CameraLocation` keeps
  whatever it last held. Coming out of spectate that is the spectator camera
  position, hundreds of metres away; in an ordinary respawn it is your own last
  position, which is why it read as harmless jitter for a month.
  Confirmed by test: Archer and MAA fine, Knight and Vanguard broken. Reverted to
  `SlumpCharacters` (the package that actually ships) on 2026-08-21.
  Diagnostic signature in `Launch.log`:
  `Error: Failed to find package for MP character class ...` immediately followed
  by a flood of `Warning: GetSocketWorldLocationAndRotation : Could not find SkeletalMesh`.
- `MasonBarbVanguard1p` does not exist in `SlumpCharacters.upk` either (only a `3p`
  version), so BARB Mason Vanguard still has no 1P mesh and will show this same
  frozen-camera behaviour until the asset is authored.
- No mod content package appeared in a 14 MB client log — no `SlumpCharacters`,
  `TurtleFFA`, `crown` or any other. Untested, but worth confirming content
  actually reaches clients.
- The "bodycam" feel of the previous attempt was a symptom of never setting
  `bIsBeingFPObserved`: the camera was reading the **third-person** mesh's camera
  socket, which carries the full-body locomotion and lean animation. The 1P
  `OwnerMesh` socket is the one the game uses when you play normally. If it still
  reads wrong after this change, the next lever is the smoothing constant in
  `AOCPlayerController.state Spectating.GetPlayerViewPoint`
  (`RInterpTo(CalcViewRotation, TempPOVRot, DeltaTime, 20.0f)`), which XangMod can
  override in its own state if needed.
- `NextCameraAngle` is a no-op in first person and sets `iThirdPersonAngle = 1` in
  orbit follow, matching vanilla. If real cycling is ever wanted, the values live in
  `AOCPlayerController.ThirdPersonCameraPositions` and are consumed by
  `AOCPlayerCamera.CalcThirdPersonLocation`.
- Status as of 2026-08-21: the 1P mesh rebuild (4.8) is **confirmed working on a
  dedicated server** — `ScriptLog: XangModEnsureOwnerMesh: rebuilt 1P mesh
  SK_CH_1P_MAsonArcher` in the client log. First-person spectate is functional on
  any class whose 1P mesh actually loads.
