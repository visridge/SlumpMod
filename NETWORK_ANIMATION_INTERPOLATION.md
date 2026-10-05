# Network Animation Interpolation

This document describes a future, visual-only network animation interpolation pass for XangMod. It is an implementation and test plan, not a claim that the feature is already present.

## Goal

Make remote pawn animations appear at the correct phase and remain visually stable when replicated animation events arrive at different times.

The feature must not change:

- Server-authoritative hit detection.
- Parry, riposte, or hit-trade arbitration.
- Root-motion authority.
- The locally controlled pawn's input response.
- The existing animation asset keyframes.

The intended result is smoother remote presentation, not client-side combat authority.

## Current Pipeline

The important control points are:

- `AOC/classes/AOCPawn.uc`
  - `ReplicatedEvent()` starts replicated animation playback.
  - `CalcAnimRate()` changes playback speed to fit a requested duration.
  - `PlayAnimationOnSlots()` and `PlayAnimationOnBlendNodes()` start animation nodes.
- `AOC/classes/AOCAnimNodeSeqWep.uc`
  - Native `TickAnim` advances the current skeletal animation locally.
  - `WeaponAnimationRates` changes the animation rate selected for a weapon.
- `XangMod/Include/Pawn/Camera.uci`
  - XangMod pawns request `NetUpdateFrequency=120`.
- `XangMod/Include/Pawn/Netcode.uci`
  - `GetNetPriority()` requests 120 Hz pawn updates and high network priority.
  - Clock offset smoothing and ping reconstruction are used for combat timing only.
- `XangMod/Include/PC/Core.uci`
  - `ReplicateMove()` sends autonomous movement at `0.00833` seconds when possible.

The current animation path is event-driven. A client receives an animation state and immediately starts the corresponding local animation. Blend times smooth the pose transition, while `CalcAnimRate()` changes duration. Neither one interpolates between network animation samples.

## Keyframes Versus Runtime Interpolation

### Adding keyframes

New skeletal keyframes must be created in the animation asset inside the relevant `.upk` package. UnrealScript can select and play an animation, but it cannot add authoring keyframes to an existing sequence.

Asset work requires a compatible UE3/UDK animation workflow and a package rebuild. Test the resulting animation in the animation tree before changing network code.

### Adding runtime interpolation

Runtime interpolation can be implemented in UnrealScript by replicating a timestamped animation snapshot and evaluating the expected animation phase on the client.

The client should interpolate presentation only. It should not move the authoritative pawn or perform local hit tests from the interpolated pose.

## Recommended Design

### 1. Add a timestamped visual snapshot

Do not overload the existing `ReplicatedAnimation` behavior initially. Add a separate XangMod snapshot so the vanilla path remains available as a rollback path.

The snapshot should contain the minimum data needed to reconstruct a visual animation:

```unrealscript
struct XangModAnimationSnapshot
{
    var name AnimationName;
    var name ComboAnimation;
    var float ServerStartTime;
    var float Duration;
    var float PlaybackRate;
    var float StartPosition;
    var float BlendInTime;
    var float BlendOutTime;
    var bool bLoop;
    var bool bFullBody;
    var bool bLowerBody;
    var bool bUseRMM;
    var byte Sequence;
};
```

This is illustrative. Reuse the existing `AnimationInfo` fields where possible, and do not duplicate fields whose meaning is already defined by the base game.

The snapshot needs to be:

- Written by the server when the authoritative animation starts.
- Replicated to simulated proxies.
- Marked with a sequence value so two identical attacks still produce separate updates.
- Kept separate from local-owner playback.

Place new pawn variables in `Include/Pawn/Vars.uci`. If a new replicated property is required, add the replication declaration in the owning XangMod pawn class, not only in an include file that is compiled in multiple contexts.

### 2. Establish a server/client time relationship

A client cannot reliably evaluate `ServerStartTime` against its own `WorldInfo.TimeSeconds` unless the two clocks are known to be aligned.

Use one of these approaches, in order of preference:

1. Replicate a server-time sample and estimate a client-side server-clock offset.
2. Include a server timestamp and receive-time sample in an existing periodic synchronization message.
3. Use half of `ExactPing` as a temporary fallback only. This assumes roughly symmetric latency and is less accurate under jitter.

The existing `fClientClockOffset` in `Pawn/Netcode.uci` is server-side combat state. Do not reuse it as though it were already a client-side render clock.

### 3. Compute the target animation phase

For a non-looping animation, the client should calculate approximately:

```text
serverNow = clientNow + estimatedServerClockOffset
elapsed = serverNow - ServerStartTime
phaseSeconds = StartPosition + elapsed * PlaybackRate
phaseSeconds = clamp(phaseSeconds, 0, Duration)
```

For a looping animation, wrap `phaseSeconds` by the animation duration instead of clamping it.

If the timestamp is missing or invalid, fall back to the current vanilla behavior and record a diagnostic counter. Do not silently restart the animation from zero.

### 4. Apply phase without disrupting combat

The first implementation should be limited to simulated remote pawns:

- Keep the local owner on the existing immediate playback path.
- Keep server animation playback unchanged.
- On a remote pawn, start the sequence once when the snapshot changes.
- Correct its phase only when the error exceeds a small threshold.
- Blend into a different animation state using the existing blend nodes.
- Avoid calling `SetPosition()` every frame on root-motion attacks, dodges, or sequences with important animation notifies until those cases are tested.

A practical first pass is:

```text
on snapshot received:
    start the selected animation once
    calculate target phase from the timestamp
    start at target phase when the error is small
    otherwise blend or correct over a short visual interval

each client tick:
    update only the visual phase correction state
    do not call server combat functions
```

The exact UnrealScript calls depend on whether the animation uses slots, blend nodes, or root motion. The existing calls are in `AOCPawn.PlayAnimationOnSlots()` and `AOCPawn.PlayAnimationOnBlendNodes()`.

### 5. Handle late, duplicate, and missing updates

The snapshot sequence value should be compared before applying an update:

- Older sequence values must be ignored, including byte-wrap cases.
- A duplicate sequence must not restart the animation.
- A late packet should correct phase, not rewind the animation blindly.
- A missing packet should allow the current animation to continue until a newer valid state arrives.
- A reset or death animation must explicitly cancel any pending visual correction.

Do not use animation interpolation to hide a server-side state transition indefinitely. The visual state must eventually converge to the replicated authoritative state.

## Ping and Latency Assessment

A round-trip ping of 60 ms corresponds to approximately 30 ms of one-way latency if the path is symmetric:

$$
T_{one-way} \approx \frac{T_{round-trip}}{2} \approx \frac{60\text{ ms}}{2} = 30\text{ ms}
$$

That range is not a problem for visual animation interpolation. It is enough time for the client to receive an animation event after the server started it, but a timestamped snapshot lets the client begin at the correct phase instead of restarting at zero.

The real concern is latency variation and packet jitter. Use a small render buffer separately from ping compensation:

- Start with one or two replication intervals.
- At 120 Hz, one interval is about `8.33 ms`; two are about `16.67 ms`.
- Do not automatically add the full ping as a visual delay.
- If jitter exceeds the buffer, hold the current phase briefly or correct gradually.
- Clamp corrections so a delayed packet cannot visibly rewind a completed attack.

For clients at approximately 60 ms RTT or under, a reasonable first target is:

- Server timestamp correction for animation phase.
- An `8.33` to `16.67` ms visual jitter buffer.
- No change to hit confirmation or parry timing.
- A gradual correction for small phase errors.
- An immediate authoritative transition for death, dodge failure, or other critical state changes.

Higher or unstable ping should degrade presentation quality, not alter combat outcomes. The visual interpolation layer must never be used to decide whether an attack hit.

## Implementation Order

### Phase 0: Instrument without changing behavior

Log or display, for a selected remote pawn:

- Animation sequence value.
- Animation name.
- Server start timestamp.
- Client receive timestamp.
- Estimated packet age.
- Calculated target phase.
- Current local phase, if available.
- Number of corrections and rejected stale updates.

Verify that a single attack produces one snapshot and that identical consecutive attacks still produce different sequence values.

### Phase 1: Replicate timestamps

Add the snapshot and server/client clock sample. Leave the existing animation playback unchanged. Compare the calculated target phase with the phase of the animation that vanilla playback would have reached.

### Phase 2: Correct simple remote animations

Enable phase correction for:

- Idle and movement animations.
- A non-root-motion slash or overhead.
- A looping movement animation.

Keep root-motion attacks, dodges, executions, deaths, and animations with important notifies on the vanilla path until separately validated.

### Phase 3: Add controlled blending

Use the existing slot and blend-node paths for state changes. Keep blend durations short enough that a new attack cannot be hidden behind the previous pose.

### Phase 4: Expand by animation class

Add root-motion and combat animations one category at a time. Validate both visual phase and gameplay events after every category.

## Test Matrix

Test on a dedicated server first, then on a listen server. Use two human clients when possible so the animation starts are easy to compare.

| Test | Conditions | Expected result |
|---|---|---|
| Local owner | 0 ms or standalone | No added input or animation delay |
| Remote idle | 0 ms | No visible restart or phase drift |
| Remote attack | 20 ms RTT | Attack begins at the timestamp-corrected phase |
| Remote attack | 40 ms RTT | No visible rewind when the packet arrives |
| Remote attack | 60 ms RTT | Smooth presentation; hit timing unchanged |
| Variable latency | 20 to 60 ms RTT | Small gradual correction, no repeated restart |
| Packet loss | Drop occasional animation packets | Newer state converges without permanent freeze |
| Duplicate state | Repeat the same snapshot | No animation restart |
| Out-of-order state | Deliver an older snapshot after a newer one | Older snapshot is ignored |
| Short animation | Fast slash or stab | No skipped notify or incorrect weapon timing |
| Root motion | Lunge, dodge, or movement attack | No transform or authority regression |
| Parry | Attack and parry under latency | Existing server rollback result is unchanged |
| Death | Kill a pawn during correction | Correction is cancelled and death animation wins |
| Listen server | Host plus remote client | No double playback or owner mesh regression |
| NPC | XangMod NPC at its lower update rate | No assumption that all pawns receive 120 Hz updates |

Record video or timestamps for the same attack at each latency level. Compare the remote animation phase against the server event time rather than judging only whether the motion looks smooth.

## Acceptance Criteria

The feature is ready for broader use only when:

- Remote animation phase error is normally less than one replication interval.
- A replicated attack is not restarted by duplicate or out-of-order data.
- No visual correction changes server hit, parry, or trade results.
- No root-motion pawn is moved by client-only interpolation.
- Local-owner responsiveness is unchanged.
- Packet loss produces convergence instead of a permanent stale animation.
- The vanilla playback path can be restored with one configuration toggle or code guard.

## Build and Deployment Checks

Follow the build notes in `XANGMOD.md`:

1. Compile the full `.uc` class. Do not treat a standalone `.uci` lint result as authoritative.
2. Confirm the generated `XangMod.u` contains the new function or field name.
3. Confirm the cooked package being loaded is newer than the source change.
4. Restore any `.upk` content removed by a cook before testing animations.
5. Test the dedicated-server package and client package together.

The first implementation should remain easy to disable while animation timing and combat behavior are compared against the current build.

## Relevant Source Files

- [AOC/classes/AOCPawn.uc](AOC/classes/AOCPawn.uc)
- [AOC/classes/AOCAnimNodeSeqWep.uc](AOC/classes/AOCAnimNodeSeqWep.uc)
- [XangMod/Include/Pawn/Vars.uci](XangMod/Include/Pawn/Vars.uci)
- [XangMod/Include/Pawn/Netcode.uci](XangMod/Include/Pawn/Netcode.uci)
- [XangMod/Include/Pawn/Camera.uci](XangMod/Include/Pawn/Camera.uci)
- [XangMod/Include/PC/Core.uci](XangMod/Include/PC/Core.uci)
- [XangMod/Include/PC/Effects.uci](XangMod/Include/PC/Effects.uci)
