/**
 * BangModRoll - The ninja-roll dodge for the Archer.
 *
 * Contains ONLY the roll behaviour: parry/recovery cancel, 1H vs 2H roll-anim
 * selection, velocity kick and visual mesh offset. Extends BangModDodge so the
 * weapon-identifier remap plumbing is shared with the vanilla dodge.
 *
 * The roll only activates when the pawn's family is a BangModFamilyInfo_Archer with
 * bUseCustomDodgeAnims=true; otherwise this class passes straight through to the
 * standard dodge.
 */
class BangModRoll extends BangModDodge;

var BangModFamilyInfo_Archer CachedRollFI;
var bool bCachedRollFI;

/** Lazy-cache the Archer family info (holds the roll config + tuning knobs). */
simulated function CacheRollFI()
{
	if (!bCachedRollFI && OwnerPawn != none && OwnerPawn.PawnFamily != none)
	{
		CachedRollFI = BangModFamilyInfo_Archer(OwnerPawn.PawnFamily);
		bCachedRollFI = true;
	}
}

/** Start the roll without the vanilla dodge sound. Mirrors AOCDodge.StartDodgeSM
 *  but omits the take-off/grunt and the vanilla iDodgeCost charge; the caller plays
 *  RollSound and charges iRollStaminaCost instead. */
simulated function RollStartDodgeSM(byte direction, byte WeaponId)
{
	local float fAnimationLength;
	local AnimationInfo Inf;

	CurrentWeaponId = WeaponId;
	DodgeDir = direction;

	// Create Animation Info and pass to Pawn. Root Motion is handled by the anim system.
	Inf = OwnerPawn.CreateAnimationInfo(name(AllDirAnimations[DodgeDir].DodgeAnims[0]), true, true, false,, true);

	// Replace REPL with proper name
	Inf.AnimationName = name(Repl(string(Inf.AnimationName), "REPL", GetWeaponIdentifier(), true));
	Inf.fBlendOutTime = -1.f;
	Inf.fBlendInTime = 0.0f;
	Inf.bIsDodge = true;
	Inf.bUseRMM = true;
	fAnimationLength = OwnerPawn.Mesh.GetAnimLength(Inf.AnimationName);

	OwnerPawn.ResetRMM();
	if (OwnerPawn.Weapon.IsInState('Flinch'))
	{
		OwnerPawn.ManualReset();
	}

	// Pawn State must be ESTATE_DODGE so the AnimTree picks up the 'Down' state while falling.
	OwnerPawn.ChangePawnState(ESTATE_DODGE);
	OwnerPawn.HandlePawnAnim(false, Inf);

	OwnerPawn.StateVariables.bCanJump = false;
	OwnerPawn.StateVariables.bCanParry = false;

	// Once the animation ends we want to set state to falling.
	bNotifyOnAnimEnd = true;
	bPlayStop = false;

	// Queue up attacks during the first half of the roll.
	AttackQueue = Attack_Null;
	bQueueDodgeAttack = true;
	OwnerPawn.SetTimer(fAnimationLength * 0.5f, false, 'EndDodgeQueue');
}

simulated function StartDodgeSM(byte direction, byte WeaponId)
{
	local vector FwdDir;
	local float KeepZ;

	CacheRollFI();

	if (CachedRollFI != none && CachedRollFI.default.bUseCustomDodgeAnims
		&& direction < 4 && CachedRollFI.default.DodgeAnimUp.Length > direction)
	{
		// Cancel any lingering parry/recovery pose before the roll starts. Vanilla
		// only clears Flinch; without this the torso stays locked in the upper-body
		// parry/recovery animation while the legs roll ("rowboat"). GotoState('Active')
		// fully cancels the parry/recovery state machine so nothing can re-lock the
		// torso mid-roll (its timers and the release-button path are all gone), and
		// Active.BeginState calls ManualReset() to clear the upper-body pose.
		if (OwnerPawn.Weapon != none
			&& (OwnerPawn.Weapon.IsInState('Parry')
				|| OwnerPawn.Weapon.IsInState('ParryRelease')
				|| OwnerPawn.Weapon.IsInState('HeldParryRelease')
				|| OwnerPawn.Weapon.IsInState('Recovery')))
		{
			OwnerPawn.Weapon.GotoState('Active');
		}

		// Two-handed weapons grip the shaft with both hands; use the 2H roll variant
		// (which has the left arm baked to the shaft grip) when one is equipped.
		// Falls back to the 1H roll if no 2H variant is configured.
		if (OwnerPawn.Weapon != none && AOCWeapon(OwnerPawn.Weapon) != none
			&& AOCWeapon(OwnerPawn.Weapon).bTwoHander
			&& CachedRollFI.default.DodgeAnimUp2H.Length > direction
			&& CachedRollFI.default.DodgeAnimUp2H[direction] != "")
		{
			AllDirAnimations[direction].DodgeAnims[0] = CachedRollFI.default.DodgeAnimUp2H[direction];
		}
		else
		{
			AllDirAnimations[direction].DodgeAnims[0] = CachedRollFI.default.DodgeAnimUp[direction];
		}
		AllDirAnimations[direction].DodgeAnims[1] = "";
	}

	// Non-archer (vanilla dodge): defer entirely to the normal dodge flow, which
	// also plays the vanilla dodge take-off + grunt sounds.
	if (!(CachedRollFI != none && CachedRollFI.default.bUseCustomDodgeAnims))
	{
		super.StartDodgeSM(direction, WeaponId);
		return;
	}

	// Archer roll: run the dodge-start logic directly (mirrors AOCDodge.StartDodgeSM)
	// WITHOUT calling super, so the vanilla dodge sound never plays. We play our own
	// roll sound below instead.
	RollStartDodgeSM(direction, WeaponId);

	// Roll stamina cost + roll sound.
	OwnerPawn.ConsumeStamina(CachedRollFI.default.iRollStaminaCost);

	if (CachedRollFI.default.RollSound != none)
		OwnerPawn.PlaySound(CachedRollFI.default.RollSound,, true);

	// Restore defaults so other classes aren't affected
	if (CachedRollFI != none && CachedRollFI.default.bUseCustomDodgeAnims && direction < 4)
	{
		AllDirAnimations[direction].DodgeAnims[0] = default.AllDirAnimations[direction].DodgeAnims[0];
		AllDirAnimations[direction].DodgeAnims[1] = default.AllDirAnimations[direction].DodgeAnims[1];

		// Lower the visual mesh so the roll sits at ground level. SetTranslation is a
		// component-space offset, separate from bone/RMM translation, so it does NOT
		// affect movement or physics. Tune fCustomDodgeHeight in BangModFamilyInfo_Archer.
		if (CachedRollFI.default.fCustomDodgeHeight != 0.f)
		{
			OwnerPawn.Mesh.SetTranslation(vect(0, 0, 0) + (vect(0, 0, 1) * CachedRollFI.default.fCustomDodgeHeight));
		}

		// Give forward/back dodges a velocity kick so jump+roll carries momentum.
		// Scaled by fCustomDodgeSpeed for easy balance tuning.
		if (OwnerPawn.PawnFamily != none && (direction == 0 || direction == 2))
		{
			FwdDir = Normal(Vector(OwnerPawn.Rotation));
			FwdDir.Z = 0.f;
			FwdDir = Normal(FwdDir);

			KeepZ = OwnerPawn.Velocity.Z;   // save vertical (jump/gravity) component

			if (direction == 0)
				OwnerPawn.Velocity = FwdDir * (OwnerPawn.PawnFamily.default.DodgeSpeed * CachedRollFI.default.fCustomDodgeSpeed);
			else
				OwnerPawn.Velocity = FwdDir * -(OwnerPawn.PawnFamily.default.DodgeSpeed * CachedRollFI.default.fCustomDodgeSpeed);

			OwnerPawn.Velocity.Z = KeepZ;   // restore vertical component
		}
	}
}

/** Roll end: no land animation exists, so skip the parent's empty-land play
 *  (which causes a one-frame T-pose) and go straight to idle. */
simulated function StopDodgeSM()
{
	CacheRollFI();

	if (CachedRollFI != none && CachedRollFI.default.bUseCustomDodgeAnims)
	{
		if (bPlayStop) return;
		bPlayStop = true;
		bWaitForStop = false;

		OwnerPawn.Mesh.SetTranslation(vect(0, 0, 0));

		if (OwnerPawn.PawnState == ESTATE_DODGE)
			OwnerPawn.ChangePawnState(ESTATE_IDLE);
		OwnerPawn.StateVariables.bCanJump = true;
		OwnerPawn.DisableDodge();
		bQueueDodgeAttack = false;

		// Stop the 1P owner mesh's dodge animation instantly. The roll's last frame
		// already matches idle, so an instant stop holds idle with no blend twirl.
		if (OwnerPawn.OwnerFullBodySlotDodge != none)
			OwnerPawn.OwnerFullBodySlotDodge.StopCustomAnim(0.0f);

		return;
	}

	super.StopDodgeSM();
}

/** Preserve vanilla momentum flow into the landing phase. */
simulated function GotoWaitForLand()
{
	bNotifyOnAnimEnd = false;
	bWaitForStop = true;

	// Mirror vanilla: discard root motion, then go to PHYS_Falling so remaining
	// momentum (from RMM + velocity) carries the character through the air.
	OwnerPawn.DodgeInfo.Direction = 4;
	OwnerPawn.RMMAnimNodeDodge.StopCustomAnim(0.25f);
	OwnerPawn.RMMAnimNodeDodge.SetRootBoneAxisOption(RBA_Discard, RBA_Discard, RBA_Discard);

	if (OwnerPawn.Velocity.Z <= -5.f)
	{
		OwnerPawn.SetPhysics(PHYS_Falling);
	}
	else
	{
		StopDodgeSM();
	}
}

defaultproperties
{
}
