# SlumpMod Late Parry Recovery Lockout Fix Handoff

## Target

Repository: `https://github.com/visridge/SlumpMod`

Current inspected branch/head: `main` at `caf446ab6aa7183595a111ba6acbe7c50a1b010c`

Primary file to edit:

```text
Classes/XangModMeleeWeapon.uc
```

This is for XangMod, a Chivalry mod. 

## Bug

On a dedicated server with variable player ping, a defender can successfully parry an attack very late in the attacker's release phase, but still be unable to parry again immediately afterward. The player feels stuck in parry recovery/lockout for roughly the normal parry recovery duration, about 500 ms.

Observed symptom: it behaves like the successful parry state was not processed in time before `ParryRelease` fell into `Recovery`, so `Recovery` disables `bCanParry` and the next parry is blocked.

## Failed Previous Fix

Commit:

```text
28a372aed52d9b2eaacd85274a541915dda55a86
```

Commit URL:

```text
https://github.com/visridge/SlumpMod/commit/28a372aed52d9b2eaacd85274a541915dda55a86
```
Code added:
simulated state ParryRelease
{
	simulated function OnStateAnimationEnd()
	{
		if (bSuccessfulParry && !bParryHitCounter)
			GotoState('Active');
		else if (!bParryHitCounter)
			SetTimer(0.15f, false, 'ParryGraceExpired');
		else
			GotoState('Release');
	}

	simulated function ParryGraceExpired()
	{
		if (bSuccessfulParry)
			GotoState('Active');
		else
			GotoState('Recovery');
	}

	simulated function SuccessfulParry(EAttack Type, int Dir)
	{
		super.SuccessfulParry(Type, Dir);
		// The DirParryHitAnim timer will now fire OnStateAnimationEnd -> Active naturally.
		// Cancel the grace fallback so both don't fire.
		ClearTimer('ParryGraceExpired');
	}

	simulated event EndState(Name NextStateName)
	{
		ClearTimer('ParryGraceExpired');
		super.EndState(NextStateName);
	}
}
in XangModMeleeWeapon.uc, but was removed later due to bug.

That commit/code added a `ParryRelease` grace timer:

```uc
SetTimer(0.15f, false, 'ParryGraceExpired');
```

Problem with that approach: it holds `ParryRelease` open longer. This repairs some late success notifications, but it also changes normal parry cadence by extending the active/parry-release phase. Result: parry-to-parry takes longer and gameplay flow feels worse.

Do not reintroduce that timer-based `ParryRelease` grace window.

## Diagnosis

The better fix is not to extend `ParryRelease`.

The race is:

1. Defender is in `ParryRelease`.
2. Server resolves a very late enemy release hit as a valid parry.
3. Defender client/server may already have transitioned from `ParryRelease` to `Recovery`.
4. The late `SuccessfulParry` notification arrives while the weapon is in `Recovery`.
5. `Recovery` has no `SuccessfulParry` override, so the late success does not repair the state.
6. `Recovery` keeps the player in parry recovery lockout until the recovery animation ends.

Vanilla `AOCMeleeWeapon.ParryRelease.OnStateAnimationEnd()` already handles success correctly if `bSuccessfulParry` is true before the animation ends:

```uc
if (bSuccessfulParry && !bParryHitCounter)
	GotoState('Active');
else if (!bParryHitCounter)
	GotoState('Recovery');
else
	GotoState('Release');
```

So the fix should catch only the late-success race after `ParryRelease -> Recovery`, then immediately return to `Active`, where `bCanParry` is restored by the normal active state.

## Intended Behavior

If a successful parry notification arrives after a parry has just transitioned into recovery, and that recovery came from `ParryRelease`, treat it as the same success that arrived slightly late.

The fix must:

- Avoid extending the active parry window.
- Avoid extending `ParryRelease`.
- Avoid changing normal parry misses.
- Avoid changing shield behavior.
- Clear the recovery animation timer before forcing `Active`.
- Let existing `Active.BeginState()` restore normal parry behavior and consume any buffered parry input.

## Exact Code Change

### 1. Add A New Flag

In `Classes/XangModMeleeWeapon.uc`, near the existing parry timing vars:

Current area:

```uc
// Server-side parry validation for ping normalization
var float fServerParryStartTime;  // When parry became active on server
var float fParryGracePeriod;      // Grace period for parry timing validation (75ms for RTT compensation)
var float fDamageTraceActivationDelay;  // Delay before release traces can deal damage
```

Add:

```uc
var bool bAcceptLateParrySuccessInRecovery; // True only for ParryRelease -> Recovery race repair.
```

Result:

```uc
// Server-side parry validation for ping normalization
var float fServerParryStartTime;  // When parry became active on server
var float fParryGracePeriod;      // Grace period for parry timing validation (75ms for RTT compensation)
var bool bAcceptLateParrySuccessInRecovery; // True only for ParryRelease -> Recovery race repair.
var float fDamageTraceActivationDelay;  // Delay before release traces can deal damage
```

### 2. Replace Recovery State Header Logic

Current `Recovery` state begins like this:

```uc
/** Recovery state - Auto-activate parry if buffered */
simulated state Recovery
{
	simulated event BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
			// TryActivateBufferedParry();
	}

	/** Override HandleCombo to add server-side stamina validation */
	simulated function HandleCombo(EAttack ComboAttack)
```

Replace that beginning with:

```uc
/** Recovery state - Auto-activate parry if buffered */
simulated state Recovery
{
	simulated event BeginState(Name PreviousStateName)
	{
		bAcceptLateParrySuccessInRecovery =
			PreviousStateName == 'ParryRelease'
			&& CurrentFireMode == Attack_Parry
			&& !bEquipShield;

		super.BeginState(PreviousStateName);
			// TryActivateBufferedParry();
	}

	simulated function SuccessfulParry(EAttack Type, int Dir)
	{
		if (!bAcceptLateParrySuccessInRecovery || bSuccessfulParry)
			return;

		bAcceptLateParrySuccessInRecovery = false;
		bSuccessfulParry = true;
		bParryHitCounter = false;

		if (AOCOwner != none)
		{
			AOCOwner.ClearTimer('OnAttackAnimEnd');
			AOCOwner.OnActionSucceeded(EACT_Block);
		}

		GotoState('Active');
	}

	/** Override HandleCombo to add server-side stamina validation */
	simulated function HandleCombo(EAttack ComboAttack)
```

### 3. Add Recovery EndState Cleanup

At the end of the same `Recovery` state, before its final closing brace, add:

```uc
	simulated event EndState(Name NextStateName)
	{
		bAcceptLateParrySuccessInRecovery = false;
		super.EndState(NextStateName);
	}
```

Current `Recovery` state currently ends after `HandleCombo`:

```uc
	}
	
}

simulated state Active
```

After the change, it should end like:

```uc
	}

	simulated event EndState(Name NextStateName)
	{
		bAcceptLateParrySuccessInRecovery = false;
		super.EndState(NextStateName);
	}
}

simulated state Active
```

## Why This Fix Is Safer

This only handles the case where a success notification arrives after the state machine has already gone from `ParryRelease` to `Recovery`.

It does not create a new timing window. It does not wait in `ParryRelease`. It does not make active parry last longer.

It repairs the state by going to `Active`, which is the state vanilla would have entered if `bSuccessfulParry` had been set before `ParryRelease.OnStateAnimationEnd()`.

## Important Non-Goals

Do not add this back:

```uc
SetTimer(0.15f, false, 'ParryGraceExpired');
```

Do not override `ParryRelease.OnStateAnimationEnd()` for this bug.

Do not make `Recovery` accept all parry successes forever. It should only accept late success when:

```uc
PreviousStateName == 'ParryRelease'
&& CurrentFireMode == Attack_Parry
&& !bEquipShield
```

## Test Plan

Use a dedicated server with two clients and variable ping.

Test cases:

1. Normal missed parry:
   - Defender parries with no incoming hit.
   - Expected: normal recovery still happens. No faster recovery.

2. Normal successful parry:
   - Defender parries an attack well inside the parry window.
   - Expected: behavior unchanged.

3. Late release parry:
   - Attacker drags/release-hits very late.
   - Defender parries at the very end of the valid parry timing.
   - Expected: if the server resolves it as a successful parry, defender can parry again immediately afterward instead of waiting about 500 ms.

4. Parry-to-parry cadence:
   - Compare repeated successful parry into immediate parry before and after.
   - Expected: cadence should match the pre-`28a372a` feel, without the slower flow caused by the `0.15f` `ParryRelease` grace timer.

5. Shield parry:
   - Test shield block and timed shield drop.
   - Expected: unchanged. The new recovery repair explicitly excludes `bEquipShield`.

## Expected Risk

Main risk: if `SuccessfulParry` can be called in `Recovery` for unrelated reasons, this could incorrectly skip recovery. The guard is intended to prevent that by only arming the repair when recovery began from `ParryRelease` while `CurrentFireMode == Attack_Parry` and the weapon is not a shield.

If this still compiles but does not fix the symptom, the next likely problem is that the server never sent `ClientSuccessfulParry` for the edge case. In that case, inspect the pending-hit/parry rollback path in `Include/XangModPawn.uci`, especially `GetParryHoldSeconds()` and `ResolvePendingHitsAsParry()`.
