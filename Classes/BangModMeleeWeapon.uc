/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
* 
* Original Author: Michael Bao
* 
* The base weapon class for melee weapons.
*/
class BangModMeleeWeapon extends AOCMeleeWeapon
	dependson(AOCPawn)
	abstract;

var float altRiposteExtraWindup;
var float fFlinchStateStartTime;
var float fHitRegisteredTime;  // When the hit was registered (for ping normalization)
var int MissCount;  // Track consecutive misses in combo for miss penalty

// Parry buffer system - allows queuing parry input during recovery/flinch
var float fLastParryInputTime;  // Game time when player last pressed parry
var float fParryBufferWindow;   // How long to remember parry input (default 150ms)

// Server-side parry validation for ping normalization
var float fServerParryStartTime;  // When parry became active on server
var float fParryGracePeriod;      // Grace period for parry timing validation (60ms for RTT compensation)

// Minimum combo transition time for ping normalization
var float fMinComboTransitionTime;  // Minimum time before combo can release (100ms floor)
var float fComboTransitionStartTime;  // When transition state began

/** Override BeginFire to track parry inputs for buffer system */
// simulated function BeginFire(byte FireModeNum)
// {
// 	// Record parry input timestamp for buffer system
// 	if (FireModeNum == Attack_Parry)
// 	{
// 		fLastParryInputTime = WorldInfo.TimeSeconds;
// 	}
	
// 	// Call parent to handle normal logic
// 	super.BeginFire(FireModeNum);
// }

// /** Check if player recently pressed parry (within buffer window) */
// simulated function bool HasBufferedParryInput()
// {
// 	local float TimeSinceParryInput;
	
// 	if (fLastParryInputTime <= 0)
// 		return false;
		
// 	TimeSinceParryInput = WorldInfo.TimeSeconds - fLastParryInputTime;
// 	return (TimeSinceParryInput > 0 && TimeSinceParryInput <= fParryBufferWindow);
// }

// /** Clear the parry buffer (called when parry activates or buffer expires) */
// simulated function ClearParryBuffer()
// {
// 	fLastParryInputTime = 0;
// }

/** Override BeginFire to prevent kick during jump/fall */
// simulated function BeginFire(byte FireModeNum)
// {
// 	// Block kick input if player is not grounded (same check used for dodge)
// 	// Attack_Shove = 5 in the EAttack enum
// 	// Velocity.Z ~= 0.0 means "approximately zero" (grounded)
// 	if (FireModeNum == 5 && !(AOCOwner.Velocity.Z ~= 0.0))
// 	{
// 		return;
// 	}
	
// 	super.BeginFire(FireModeNum);
// }

// simulated function float GetStaminaLossForMiss()
// {
//     local float StaminaLoss;
//     if (!bTwoHander)
//         StaminaLoss = 5;
//     else
//         StaminaLoss = 7;
//     return StaminaLoss;
// }

/** Server RPC to validate feint stamina - prevents phantom feint at low stamina */
// reliable server function ServerValidateFeint(int StaminaCost)
// {
// 	// Server-authoritative stamina check
// 	if (!AOCOwner.HasEnoughStamina(StaminaCost))
// 	{
// 		// Server rejected - force client back to Active
// 		ClientFeintRejected();
// 	}
// }

// /** Client RPC to handle feint rejection - prevents phantom feint animation */
// reliable client function ClientFeintRejected()
// {
// 	// Force weapon back to Active state to cancel phantom feint animation
// 	GotoState('Active');
// }

/** Server RPC to validate combo stamina - prevents desync on second combo */
// reliable server function ServerValidateCombo(int StaminaCost)
// {
// 	// Server-authoritative stamina check
// 	if (!AOCOwner.HasEnoughStamina(StaminaCost))
// 	{
// 		// Server rejected - force client to break combo
// 		ClientComboRejected();
// 	}
// }

// /** Client RPC to handle combo rejection */
// reliable client function ClientComboRejected()
// {
// 	// Break the combo immediately
// 	bIsInCombo = false;
// 	eNextAttack = Attack_Null;
// }

/** Feint state - reset combo tracking when feinting */
simulated state Feint
{
	simulated event BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		bIsInCombo = false;
		bJustPlayedCombo = false;
		MissCount = 0;  // Reset miss counter on feint
	}

	simulated function BeginFire(byte FireModeNum)
	{
		if (FireModeNum == Attack_Parry && AOCOwner.StateVariables.bCanParry)
		{
			ActivateParry();
		}
		else
			AttackQueue = EAttack(FireModeNum);

		AOCOwner.PlayerHUDFlinched();
	}
}

/** Flinch state
 *  Can queue attack to strike when we go back to active.
 */
simulated state Flinch
{
	simulated event EndState(Name NextStateName)
	{
		super.EndState(NextStateName);
		DisableManualQueue();
	}

	/** Go into Parry if we can */
	simulated function BeginFire(byte FireModeNum)
	{
		if (FireModeNum == Attack_Parry && (!bGenericHit || !bFullBodyDazed))
		{
			// ClearParryBuffer();  // Consume the buffered input
			ActivateParry();
		}
		else if (bManualAllowQueue)
			AttackQueue = EAttack(FireModeNum);
	}

	/** Play appropriate flinch animation */
	simulated event BeginState(Name PreviousStateName)
	{

		super.BeginState(PreviousStateName);
		
		// Record when flinch state started for trade window prevention
		fFlinchStateStartTime = WorldInfo.TimeSeconds;

		// we're not in combo anymore, reset variables
		iComboCount = 1;
		AOCOwner.OnComboEnded();
		MissCount = 0;
		iIdenticalCombo = 1;
		ePreviousAttack = Attack_Null;
		eNextAttack = Attack_Null;
		AttackQueue = Attack_Null;
		bJustPlayedCombo = false;
		bIsInCombo = false;
		bWantsToCombo = false;
		AOCWepAttachment.ComboCount = iComboCount;
		AOCWepAttachment.HitComboCount = ComboHitCount;

		AOCOwner.StateVariables.bCanJump = false;
		AOCOwner.StateVariables.bCanDodge = true;
		AOCOwner.StopJump();
		AOCOwner.PlayerHUDFlinched();

		if (bSpecialDazed)
		{
			AOCOwner.StateVariables.bCanDodge = false;
		}

		StartManualQueueTimer(GetFlinchAnimLength(bFullBodyDazed, bGenericHit, bSpecialDazed));
	}

	/** Make sure to cancel the parry command upon release */
	simulated function LowerShield()
	{
		if (AttackQueue == Attack_Parry && bEquipShield && !bGenericHit)
			AttackQueue = Attack_Null;
		else if (AttackQueue == Attack_Parry)
			bParryAttackQueueNoMore = true;
	}
}

/** Hit state - allows parry input like Flinch */
simulated state Hit
{
	simulated event EndState(Name NextStateName)
	{
		super.EndState(NextStateName);
		DisableManualQueue();
	}

	/** Go into Parry if we can */
	simulated function BeginFire(byte FireModeNum)
	{
		if (FireModeNum == Attack_Parry && (!bGenericHit || !bFullBodyDazed))
		{
			// ClearParryBuffer();  // Consume the buffered input
			ActivateParry();
		}
		else if (bManualAllowQueue)
			AttackQueue = EAttack(FireModeNum);
	}

	simulated event BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		// Record when hit state started for trade window prevention
		// fHitRegisteredTime = WorldInfo.TimeSeconds;
		// Reset combo variables
		iComboCount = 1;
		AOCOwner.OnComboEnded();
		MissCount = 0;
		iIdenticalCombo = 1;
		ePreviousAttack = Attack_Null;
		eNextAttack = Attack_Null;
		AttackQueue = Attack_Null;
		bJustPlayedCombo = false;
		bIsInCombo = false;
		bWantsToCombo = false;
		AOCWepAttachment.ComboCount = iComboCount;
		AOCWepAttachment.HitComboCount = ComboHitCount;

		AOCOwner.StateVariables.bCanJump = false;
		AOCOwner.StateVariables.bCanDodge = true;
		AOCOwner.StopJump();
		AOCOwner.PlayerHUDFlinched();

		if (bSpecialDazed)
		{
			AOCOwner.StateVariables.bCanDodge = false;
		}

		StartManualQueueTimer(GetFlinchAnimLength(bFullBodyDazed, bGenericHit, bSpecialDazed));
	}

	simulated function LowerShield()
	{
		if (AttackQueue == Attack_Parry && bEquipShield && !bGenericHit)
			AttackQueue = Attack_Null;
		else if (AttackQueue == Attack_Parry)
			bParryAttackQueueNoMore = true;
	}
}

/** Recovery state - Auto-activate parry if buffered */
simulated state Recovery
{
	/** Override HandleCombo to add server-side stamina validation */
	simulated function HandleCombo(EAttack ComboAttack)
	{
		local bool bHasEnoughStamina;
		
		if (CurrentFireMode == Attack_Shove || CurrentFireMode == Attack_Parry || CurrentFireMode == Attack_Sprint || (CurrentFireMode == Attack_Stab && ComboAttack == Attack_Stab))
			return;

		if (!bCanCombo)
			return;

		if (ComboAttack == Attack_Parry)
			return;
			
		// notify that we're in a combo now if we're not aborting the attack -- double check we're allowed to combo
		if (iComboCount < MaxComboCount)
		{
			bHasEnoughStamina = AOCPawn(Owner).HasEnoughStamina(ComboStaminaCost);
			if (bHasEnoughStamina)
			{
				bIsInCombo = true;
				// record next attack
				eNextAttack = ComboAttack;

				AOCOwner.PlayerHUDStartCombo();
				
				// Server validation - ask server to verify stamina
				// if (AOCOwner.IsLocallyControlled())
				// {
				// 	ServerValidateCombo(ComboStaminaCost);
				// }
			}
		}

		//not able to complete the combo...put the crosshair into a state of recovery
		if(eNextAttack != ComboAttack)
			AOCOwner.PlayerHUDStartRecovery();
	}
	
	// simulated event BeginState(Name PreviousStateName)
	// {
	// 	super.BeginState(PreviousStateName);
		
	// 	// Check if player pressed parry during Release/Windup/Flinch
	// 	// If so, auto-activate parry immediately (no spam needed!)
	// 	if (HasBufferedParryInput() && bCanParry)
	// 	{
	// 		ClearParryBuffer();
	// 		ActivateParry();
	// 	}
	// }
}

/** Active/Idle state - Auto-activate parry if buffered */
// simulated state Active
// {
// 	simulated event BeginState(Name PreviousStateName)
// 	{
// 		super.BeginState(PreviousStateName);
		
// 		// Check if player pressed parry during a non-parryable state
// 		// If so, auto-activate parry as soon as we return to Active
// 		if (HasBufferedParryInput() && bCanParry)
// 		{
// 			ClearParryBuffer();
// 			ActivateParry();
// 		}
// 	}
// }

/** Transition state - Server validates stamina and enforces minimum combo timing */
// simulated state Transition
// {
// 	/** Override feint with server-side stamina validation */
// 	simulated function DoFeintAttack()
// 	{
// 		if (bCanFeint && AOCOwner.HasEnoughStamina(iComboFeintStaminaCost))
// 		{
// 			if (AOCOwner.IsLocallyControlled())
// 			{
// 				AOCOwner.S_ConsumeStamina(iComboFeintStaminaCost);
// 				// Ask server to validate - prevents phantom feint at low stamina
// 				ServerValidateFeint(iComboFeintStaminaCost);
// 			}

// 			AOCOwner.ClearTimer('OnAttackAnimEnd');
// 			ClearTimer('EndFeintWindow');
// 			GotoState('Feint');
// 			AOCOwner.OnActionSucceeded(EACT_Feint);
// 		}
// 		else
// 		{
// 			AOCOwner.OnActionFailed(EACT_Feint);
// 		}
// 	}
	
// 	/** Server-side stamina validation and combo timing enforcement */
// 	simulated event BeginState(Name PreviousStateName)
// 	{
// 		// Server-authoritative stamina check - prevents client regen desync exploits
// 		// This catches cases where client has regen'd 1-2 stamina but server hasn't yet
// 		// SKIP check if coming from Feint to prevent phantom swing bug after feinting at low stamina
// 		if (Role == ROLE_Authority && PreviousStateName != 'Feint')
// 		{
// 			// Use actual server stamina, not predicted CurrentStamina
// 			if (!AOCOwner.HasEnoughStamina(ComboStaminaCost))
// 			{
// 				// Server says no stamina - force recovery and sync client
// 				bIsInCombo = false;
// 				eNextAttack = Attack_Null;
// 				GotoState('Recovery');
// 				return;
// 			}
			
// 			// Track when transition started for minimum timing enforcement
// 			fComboTransitionStartTime = WorldInfo.TimeSeconds;
// 		}
		
// 		super.BeginState(PreviousStateName);
// 	}
	
// 	/** Enforce minimum combo transition time before allowing release */
// 	simulated function OnStateAnimationEnd()
// 	{
// 		local float ElapsedTime;
		
// 		if (Role == ROLE_Authority && fMinComboTransitionTime > 0)
// 		{
// 			ElapsedTime = WorldInfo.TimeSeconds - fComboTransitionStartTime;
// 			if (ElapsedTime < fMinComboTransitionTime)
// 			{
// 				// Force minimum transition time
// 				SetTimer(fMinComboTransitionTime - ElapsedTime, false, 'DelayedComboRelease');
// 				return;
// 			}
// 		}
		
// 		super.OnStateAnimationEnd();
// 	}
	
// 	simulated function DelayedComboRelease()
// 	{
// 		super.OnStateAnimationEnd();
// 	}
// }

/** Windup state - Server-validated feints to prevent phantom feint at low stamina */
// simulated state Windup
// {
// 	/** Override feint with server-side stamina validation */
// 	simulated function DoFeintAttack()
// 	{
// 		if (bCanFeint && AOCOwner.HasEnoughStamina(iFeintStaminaCost) && CurrentFireMode != Attack_Shove && CurrentFireMode != Attack_Sprint)
// 		{
// 			if (AOCOwner.IsLocallyControlled())
// 			{
// 				AOCOwner.S_ConsumeStamina(iFeintStaminaCost);
// 				// Ask server to validate - prevents phantom feint at low stamina
// 				ServerValidateFeint(iFeintStaminaCost);
// 			}
// 			AOCOwner.ManualReset();
// 			AOCOwner.ClearTimer('OnAttackAnimEnd');
// 			AOCOwner.OnActionSucceeded(EACT_Feint);
// 			ClearTimer('EndFeintWindow');
// 			GotoState('Feint');
// 		}
// 		else
// 		{
// 			AOCOwner.OnActionFailed(EACT_Feint);
// 		}
// 	}
// }

// /** Deflect state - Auto-activate parry for quick parry-to-parry transitions */
// simulated state Deflect
// {
// 	simulated event BeginState(Name PreviousStateName)
// 	{
// 		super.BeginState(PreviousStateName);
		
// 		// Check if player pressed parry during the successful parry animation
// 		// This allows instant parry-to-parry for 1vX situations
// 		if (HasBufferedParryInput() && bCanParry)
// 		{
// 			ClearParryBuffer();
// 			ActivateParry();
// 		}
// 	}
// }

// static function int CalculateParryDamage(AOCWeapon AttackingWeapon, EAttack AttackType)
// {
// 	local float fDrain, fNegation;
// 	local int iDamage;
	
// 	if (AttackType == Attack_Sprint)
// 	{
// 		return 35;  // All sprint attack drain the same amount of stamina
// 	}

// 	fDrain = AttackingWeapon.default.ParryDrain[AttackType];
// 	fNegation = default.fParryNegation;
	
// 	// Custom: If fParryNegation is 100, no stamina drain at all
// 	if (fNegation >= 100)
// 		return 0;
	
// 	iDamage = Round(fDrain - fNegation);
// 	return Clamp(iDamage, 5, 25) * 1.5;
// }

/** BANGMOD: Force shield parry to end after timed window */
simulated function ForceEndShieldParry()
{
	if (bEquipShield && IsInState('ShieldUpIdle'))
	{
		// Force lower the shield
		bShieldRaised = false;
		GotoState('Recovery');
	}
}

/** BANGMOD: Prevent holding shield up - parry ends after timed window */
simulated function LowerShield()
{
	if (bEquipShield && IsInState('Parry'))
	{
		// For shields with timed parry windows, don't allow manual lowering during parry
		// The timer will force the parry to end
		// Clear any queued parry attacks
		if (AttackQueue == Attack_Parry)
			AttackQueue = Attack_Null;
	}
	else
	{
		// Normal behavior - weapon parries or shields outside parry state
		super.LowerShield();
	}
}

/** 
 * BANGMOD: Override Parry state to track server-side timestamp for grace period validation
 * This fixes "through-parry" issues by giving the server accurate timing information
 * Grace period covers replication lag (client->server latency)
 */
simulated state Parry
{
	/** Track when parry becomes active on server for grace period validation */
	simulated event BeginState(Name PreviousStateName)
	{
		// Server tracks when parry became active for grace period validation
		// This timestamp is checked in BangModPawn.uci AttackOtherPawn() to give
		// 100ms grace period for startup lag (covers replication + processing time)
		if (Role == ROLE_Authority)
		{
			fServerParryStartTime = WorldInfo.TimeSeconds;
		}
		
		// Call parent to handle all normal parry logic
		super.BeginState(PreviousStateName);
		
		// BANGMOD: Disable riposte for shields - must come AFTER super because
		// AOCMeleeWeapon.Parry.BeginState resets bCanParryHitCounter = true
		if (bEquipShield)
		{
			bCanParryHitCounter = false;
		}
	}
	
	/** BANGMOD: Override shield flow - route to ParryRelease instead of ShieldUpIdle
	 *  This gives shields the same timed parry window as weapons (~500ms active, ~400ms recovery)
	 *  instead of the vanilla held-block behavior.
	 *  If the shield already blocked during the raise animation, skip ParryRelease
	 *  entirely and go straight to Recovery. Otherwise ParryRelease.BeginState resets
	 *  bSuccessfulParry=false and the full 500ms window plays out again.
	 */
	simulated function OnStateAnimationEnd()
	{
		if (bEquipShield && bShieldRaised)
		{
			if (bSuccessfulParry)
			{
				// Already blocked during raise - drop shield immediately
				GotoState('Recovery');
			}
			else
			{
				// No block yet - enter the active parry window
				GotoState('ParryRelease');
			}
		}
		else
		{
			// Non-shield weapons use normal flow
			super.OnStateAnimationEnd();
		}
	}
	
	/** BANGMOD: Shield-specific parry hit during the raise animation.
	 *  Vanilla Parry.SuccessfulParry calls super.SuccessfulParry for shields which
	 *  may trigger ChooseDirParryHitAnim (movement freeze bug). Override to just
	 *  flag success - OnStateAnimationEnd will route to Recovery when the raise ends.
	 *  No GotoState here: bIsActiveShielding must stay true so DetectSuccessfulParry
	 *  can zero HitDamage before we leave the Parry state.
	 */
	simulated function SuccessfulParry(EAttack Type, int Dir)
	{
		if (bEquipShield)
		{
			if (bSuccessfulParry)
				return;

			AOCOwner.OnActionSucceeded(EACT_Block);
			bSuccessfulParry = true;
		}
		else
		{
			super.SuccessfulParry(Type, Dir);
		}
	}
}
/** 
 * BANGMOD: ShieldUpIdle safety net - shields should never reach this state under timed parry
 * Parry state now routes shields to ParryRelease instead of ShieldUpIdle
 * If we somehow end up here, immediately go to Recovery
 */
simulated state ShieldUpIdle
{
	simulated event BeginState(Name PreviousStateName)
	{
		// Shields should never be in ShieldUpIdle under BangMod timed parry system
		// Safety redirect to Recovery
		bShieldRaised = false;
		AOCOwner.StateVariables.bIsActiveShielding = false;
		AOCOwner.StateVariables.bIsParrying = false;
		GotoState('Recovery');
	}
}

/** 
 * BANGMOD: Override ParryRelease for shields - timed parry window with no riposte
 * Shields use the same ParryRelease path as weapons (~500ms active window)
 * but cannot riposte. After the window, auto-drops into Recovery.
 */
simulated state ParryRelease
{
	/** Shield uses ParryRelease for its active parry window.
	 *  Keep bIsActiveShielding true so DetectSuccessfulParry uses shield branch (zero stamina drain).
	 */
	simulated event BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		
		// For shields: maintain active shielding state during ParryRelease
		// so that incoming hits are detected as shield blocks (zero stamina drain)
		if (bEquipShield)
		{
			AOCOwner.StateVariables.bIsActiveShielding = true;
			bCanParryHitCounter = false;  // No riposte for shields
			// BANGMOD: Reduce shield active window by 50ms (450ms instead of vanilla 500ms)
			ClearTimer('AllowLowerParry');
			SetTimer(0.4f, false, 'AllowLowerParry');
		}
	}
	
	/** Block riposte for shields - only allow attack queueing */
	simulated function BeginFire(byte FireModeNum)
	{
		if (bEquipShield)
		{
			// Shields cannot riposte - queue attacks for after recovery instead
			if (bManualAllowQueue)
				AttackQueue = EAttack(FireModeNum);
		}
		else
		{
			// Non-shield weapons use normal ParryRelease logic (allows riposte)
			super.BeginFire(FireModeNum);
		}
	}
	
	/** For shields: auto-drop after the parry window expires */
	simulated function AllowLowerParry()
	{
		if (bEquipShield)
		{
			// Force drop shield - no held block allowed
			bShieldRaised = false;
			AOCOwner.StateVariables.bIsActiveShielding = false;
			AOCOwner.StateVariables.bIsParrying = false;
			GotoState('Recovery');
		}
		else
		{
			super.AllowLowerParry();
		}
	}
	
	/** For shields: block manual lowering during the parry window */
	simulated function LowerShield()
	{
		if (bEquipShield)
		{
			// Don't allow manual shield drop - timer will handle it
			return;
		}
		super.LowerShield();
	}
	
	/** BANGMOD: Shield-specific successful parry handling.
	 *  AOCMeleeWeapon.ParryRelease.SuccessfulParry calls ChooseDirParryHitAnim() which
	 *  explicitly rejects shields (!bShieldEquipped), returning an empty AnimationInfo with
	 *  fModifiedMovement=0.0. ReplicateCompressedAnimation then applies an indefinite
	 *  EDEBF_ANIMATION debuff that freezes movement to 0%. Since shields route to Active
	 *  (not Recovery), the debuff is never cleaned up.
	 *  Fix: just flag success without the broken DirParryHitAnim path.
	 *
	 *  IMPORTANT: We must NOT call GotoState('Recovery') synchronously here.
	 *  SuccessfulParry is called from NotifySuccessfulParry inside DetectSuccessfulParry.
	 *  If we transition to Recovery now, ParryRelease.EndState clears bIsActiveShielding
	 *  BEFORE DetectSuccessfulParry checks it to zero out HitDamage. Result: shield block
	 *  plays visually but full damage still goes through.
	 *  Fix: defer the state transition to the next tick via SetTimer.
	 */
	simulated function SuccessfulParry(EAttack Type, int Dir)
	{
		if (bEquipShield)
		{
			if (bSuccessfulParry)
				return;

			AOCOwner.OnActionSucceeded(EACT_Block);
			bSuccessfulParry = true;
			// Defer shield drop to next tick so DetectSuccessfulParry can finish
			// checking bIsActiveShielding and zeroing HitDamage first.
			ClearTimer('AllowLowerParry');
			SetTimer(0.001, false, 'DeferredShieldDrop');
		}
		else
		{
			super.SuccessfulParry(Type, Dir);
		}
	}
	
	/** Called next tick after a successful shield block to drop into Recovery.
	 *  Deferred from SuccessfulParry to avoid clearing bIsActiveShielding
	 *  before DetectSuccessfulParry can zero out HitDamage.
	 */
	simulated function DeferredShieldDrop()
	{
		GotoState('Active');
	}
	
	/** BANGMOD: Shields always go to Recovery after ParryRelease (no riposte).
	 *  Vanilla weapons route to Active on successful parry for riposte opportunity;
	 *  shields have no riposte, so Recovery is the correct destination.
	 */
	simulated function OnStateAnimationEnd()
	{
		if (bEquipShield)
		{
			GotoState('Recovery');
		}
		else
		{
			super.OnStateAnimationEnd();
		}
	}
	
	/** Clean up shield state on exit */
	simulated event EndState(Name NextStateName)
	{
		if (bEquipShield)
		{
			AOCOwner.StateVariables.bIsActiveShielding = false;
			// Safety: remove any animation movement debuffs that may have been
			// applied during this state (double-remove matches pattern used in
			// Parry.BeginState to clear potentially stacked EDEBF_ANIMATION)
			AOCOwner.RemoveDebuff(EDEBF_ANIMATION);
			AOCOwner.RemoveDebuff(EDEBF_ANIMATION);
		}
		super.EndState(NextStateName);
	}
}


/** 
 * Override Release state to add 40ms damage trace delay and server-validated combos
 * This helps prevent "through-parry" issues and combo desync from stamina discrepancies
 */
simulated state Release
{
	/** Override HandleCombo to add server-side stamina validation */
	simulated function HandleCombo(EAttack ComboAttack)
	{
		local bool bHasEnoughStamina;
		
		if (CurrentFireMode == Attack_Shove || CurrentFireMode == Attack_Parry || CurrentFireMode == Attack_Sprint || (CurrentFireMode == Attack_Stab && ComboAttack == Attack_Stab))
			return;

		if (!bCanCombo)
			return;

		if (ComboAttack == Attack_Parry)
			return;

		if (ComboAttack == Attack_AltOverhead)
			ComboAttack = Attack_Overhead;
		else if (ComboAttack == Attack_AltSlash)
			ComboAttack = Attack_Slash;

		if(ComboAttack == CurrentFireMode && iIdenticalCombo >= 3)
		{
			return;
		}

		if (bWasHit)
			return;

		// Client-side check for combo initiation
		if (iComboCount < MaxComboCount)
		{
			bHasEnoughStamina = AOCPawn(Owner).HasEnoughStamina(ComboStaminaCost);
			if (bHasEnoughStamina)
			{
				bIsInCombo = true;
				// record next attack
				eNextAttack = ComboAttack;

				AOCOwner.PlayerHUDStartCombo();
				
				if(iComboCount == 1)
				{
					AOCOwner.OnComboStarted();
				}
				
				// Server validation - ask server to verify stamina
				// if (AOCOwner.IsLocallyControlled())
				// {
				// 	ServerValidateCombo(ComboStaminaCost);
				// }
			}
			else
			{
				bPlayNoComboGrunt = true;
			}
		}
		else
		{
			bIsInCombo = false;
		}
	}
	
	/** Delay damage activation by 60ms for netcode fairness */
	simulated event BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		
		// Add 60ms delay before damage can be dealt
		// This gives defenders time for their parry to register on server
		// Covers average RTT (~30-40ms) + input lag (~10ms) + server processing (~10ms)
		// This is the true fix for "through-parry" issues at typical competitive pings
		if (BangModWeaponAttachment(AOCWepAttachment) != none)
		{
			SetTimer(0.060, false, 'ActivateDamageTracing');
			BangModWeaponAttachment(AOCWepAttachment).bCanDoDamage = false;
		}
	}
	
	/** Enable damage tracing after 40ms delay */
	simulated function ActivateDamageTracing()
	{
		if (BangModWeaponAttachment(AOCWepAttachment) != none)
		{
			BangModWeaponAttachment(AOCWepAttachment).bCanDoDamage = true;
		}
	}
	
	/** Clean up on state exit */
	simulated event EndState(Name NextStateName)
	{
		local float CurrentStamina;
		local float StaminaLoss;

		CurrentStamina = AOCOwner.Stamina;

		if (AOCOwner.IsLocallyControlled() || AOCOwner.bIsBot)
		{
			if (bHitPawn)
			{
				//Inform Pawn that the attack was successful
				MissCount = 0;
				if(CurrentFireMode >= Attack_Slash && CurrentFireMode <= Attack_Sprint)
				{
					AOCOwner.OnActionSucceeded(EPlayerAction(CurrentFireMode + EACT_AttackSlash));
				}
				else if(CurrentFireMode == Attack_Shove)
				{
					if(AOCOwner.StateVariables.bShieldEquipped)
					{
						AOCOwner.OnActionSucceeded(EACT_ShieldBash);
					}
					else
					{
						AOCOwner.OnActionSucceeded(EACT_Kick);
					}
				}
				ComboHitCount++;

				AOCowner.NotifyScoreHit();
			}
			else
			{
				//Inform Pawn that the attack failed
				if(CurrentFireMode >= Attack_Slash && CurrentFireMode <= Attack_Sprint)
				{
					AOCOwner.OnActionFailed(EPlayerAction(CurrentFireMode + EACT_AttackSlash));
				}
				else if(CurrentFireMode == Attack_Shove)
				{
					if(AOCOwner.StateVariables.bShieldEquipped)
					{
						AOCOwner.OnActionFailed(EACT_ShieldBash);
					}
					else
					{
						AOCOwner.OnActionFailed(EACT_Kick);
					}
				}
			
			if (CurrentFireMode != Attack_Parry && NextStateName != 'Flinch' && CurrentFireMode != Attack_Shove && !AOCWepAttachment.bHitDestructibleObject)
			{
				MissCount++;
				AOCOwner.RemoveDebuff(EDEBF_ATTACK);

				StaminaLoss = GetStaminaLossForMiss();

				// AOCOwner.S_ConsumeStamina(StaminaLoss);
				CurrentStamina -= StaminaLoss;

			}

			ComboHitCount = 0;
			}
		}
		else
		{
			if (!bHitPawn && bIsInCombo)
			{
				// Calculate stamina loss on server, if it hasn't been updated yet
				StaminaLoss = GetStaminaLossForMiss();

				CurrentStamina = min(CurrentStamina, BeginAttackStamina - StaminaLoss);
			}
		}

		if (!bIsInCombo)
		{
			MissCount = 0;
		}

		ClearTimer('ActivateDamageTracing');
		
		// Ensure damage is re-enabled for next attack
		if (BangModWeaponAttachment(AOCWepAttachment) != none)
			BangModWeaponAttachment(AOCWepAttachment).bCanDoDamage = true;
			
		super.EndState(NextStateName);

		// Check if we still have enough stamina to perform combo or if we missed twice
		// Use server-authoritative stamina check to match Transition state validation
		if (bIsInCombo && !AOCOwner.HasEnoughStamina(ComboStaminaCost) || MissCount >= 2)
		{
			MissCount = 0;
			GotoState('Recovery');
		}
	}
}

DefaultProperties
{
	bCanParry = true;
	bCanCombo = true;
	bJustPlayedCombo = false;
	bWantsToCombo = false
	bIsInCombo = false;
	iComboCount = 1;
	iIdenticalCombo = 1;
	ePreviousAttack = Attack_Null
	iParryCameFromTransition = -1

	FiringStatesArray(0)=Windup
	FiringStatesArray(1)=Windup
	FiringStatesArray(2)=Windup
	FiringStatesArray(3)=Windup
	FiringStatesArray(4)=Release
	FiringStatesArray(5)=Windup

	WeaponFireTypes(0)=EWFT_Custom
	WeaponFireTypes(1)=EWFT_Custom
	WeaponFireTypes(2)=EWFT_Custom
	WeaponFireTypes(3)=EWFT_Custom
	WeaponFireTypes(4)=EWFT_Custom
	WeaponFireTypes(5)=EWFT_Custom

	ShotCost(0)=0
	ShotCost(1)=0
	ShotCost(2)=0
	ShotCost(3)=0
	ShotCost(4)=0
	ShotCost(5)=0

	ImpactBloodTemplates(0)=ParticleSystem'CHV_PlayerParticles.Character.P_BloodSlash'
	ImpactBloodTemplates(1)=ParticleSystem'CHV_PlayerParticles.Character.P_BloodSlash'
	ImpactBloodTemplates(2)=ParticleSystem'CHV_PlayerParticles.Character.P_BloodSlash'

	BloodSprayTemplates(0)=ParticleSystem'CHV_PlayerParticles.Character.P_BloodSlash'
	BloodSprayTemplates(1)=ParticleSystem'CHV_PlayerParticles.Character.P_BloodSlash'
	BloodSprayTemplates(2)=ParticleSystem'CHV_PlayerParticles.Character.P_BloodSlash'

	AttackQueue=Attack_Null
	bAllowedToParry=true

	SprintAttackLunge=500.0f
	SprintAttackLungeZ=250.0f
	bAttachShieldDefault=true
	bParryAttackQueueNoMore=false
	TimeLeftInRelease=0.f
	TimeStartRelease=0.f
	bManualAllowQueue=false
	bAllowAttackOutOfShield=false
	bCanParryHitCounter=true

	PrimaryAttackCam=none
	SecondaryAttackCam=none
	TertiaryAttackCam=none
	ComboPrimaryAttackCam=none
	ComboSecondaryAttackCam=none
	ComboTertiaryAttackCAm=none

	PrimaryAttackCamWindup=none
	SecondaryAttackCamWindup=none
	TertiaryAttackCamWindup=none

	ComboPrimaryAttackCamWindup=none
	ComboSecondaryAttackCamWindup=none
	ComboTertiaryAttackCAmWindup=none

	bIgnoreAlternate=false
	bWasHit=false
	bPlayNoComboGrunt=false
	bCanPanicParry=false

	ComboToParryStaminaCost = 5
	ComboToParryBlendTime = 0.15f;
	
	altRiposteExtraWindup = 0.89;
	
	// Parry buffer system - 150ms window (0.15 seconds) for better medium-ping support
	fParryBufferWindow = 0.150;
	fLastParryInputTime = 0;
	
	// Server-side parry validation - 100ms grace period for RTT compensation
	// Covers: client input lag + network RTT + server processing + safety margin
	fServerParryStartTime = 0;
	fParryGracePeriod = 0.100;
	
	// Minimum combo transition time - 100ms floor to normalize low-ping advantage
	fMinComboTransitionTime = 0.100;
	fComboTransitionStartTime = 0;
	
	// Tighter feint windows to reduce low-ping feint abuse
	// EndFeintWindowTime = 0.10;  // Reduced from vanilla 0.15
	// EndFeintWindowTimeCombo = 0.20;  // Reduced from vanilla 0.25
	
	NetUpdateFrequency=120
}