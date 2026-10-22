/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
*
* Original Author: Michael Bao
*
* Weapon: Throwing Knife.
*/
class XangModWeapon_ThrowingKnife extends AOCWeapon_ThrowingKnife;

simulated state Windup
{
	/** When finished with windup go to the next state */
	simulated function OnStateAnimationEnd()
	{
		if (CurrentFireMode == Attack_Slash)
		{
			bWantToFire = true;
			GotoState('Release');
		
		}
	}


	/** The user released the mouse button and we should fire */
	simulated function EndFire(byte FireModeNum)
	{
		global.EndFire(FireModeNum);

		// release
		if ( CurrentFireMode == Attack_Slash)
		{
			bWantToFire = true;
		}
	}

	simulated function BeginState(name PreviousStateName)
	{
		if (AOCOwner == none)
			CacheWeaponReferences();
		super.BeginState(PreviousStateName);
	}
}

DefaultProperties
{
	CurrentWeaponType = EWEP_ThrownKnife
	// set maximum ammo
	AmmoCount=4
	MaxAmmoCount=4
	AIRange=5000

	WeaponProjectiles(0)=class'XangModProj_ThrownDagger'

	AttachmentClass=class'AOCWeaponAttachment_ThrowingKnife'
	// should never be part of inventory attachment
	InventoryAttachmentClass=class'AOCInventoryAttachment_ThrowingKnife'

	CurrentGenWeaponType=EWT_Throwing
	WeaponIdentifier="1hsharp"  // Use 1hsharp for dodge animations (same as throwing axe)
	WeaponIdleAnim=''
	bNeverFlinch=true

	FiringStatesArray(2)=none
	FiringStatesArray(3)=none
	FiringStatesArray(4)=none
	FiringStatesArray(5)=none

	ProjectileSpawnLocation=ProjPoint
	bRetIdle=true
	bRetIdleOriginal=true
	bCanDodge=false

	/*
	 * Formerly in UDKNewWeapon.ini - [AOC.AOCWeapon_ThrowingKnife]
	 */
	ConfigProjectileBaseDamage[0]=(Damage=0,InitialSpeed=0,MaxSpeed=0,AmmoCount=0,InitialGravityScale=0,Drag=0,PitchCorrection=0.0, bInfiniteAmmo=false, MinDamage=0, MinimumFireTime=0)
	ConfigProjectileBaseDamage[1]=(Damage=0,InitialSpeed=0,MaxSpeed=0,AmmoCount=0,InitialGravityScale=0,Drag=0,PitchCorrection=0.0, bInfiniteAmmo=false, MinDamage=0, MinimumFireTime=0)
	ConfigProjectileBaseDamage[2]=(Damage=0,InitialSpeed=0,MaxSpeed=0,AmmoCount=0,InitialGravityScale=0,Drag=0,PitchCorrection=0.0, bInfiniteAmmo=false, MinDamage=0, MinimumFireTime=0)
	ConfigProjectileBaseDamage[3]=(Damage=0,InitialSpeed=0,MaxSpeed=0,AmmoCount=0,InitialGravityScale=0,Drag=0,PitchCorrection=0.0, bInfiniteAmmo=false, MinDamage=0, MinimumFireTime=0)
	ConfigProjectileBaseDamage[4]=(Damage=0,InitialSpeed=0,MaxSpeed=0,AmmoCount=0,InitialGravityScale=0,Drag=0,PitchCorrection=0.0, bInfiniteAmmo=false, MinDamage=0, MinimumFireTime=0)
	ConfigProjectileBaseDamage[5]=(Damage=32,InitialSpeed=2500,MaxSpeed=3000.0,AmmoCount=4,InitialGravityScale=0.90,Drag=0.000005,PitchCorrection=200, bInfiniteAmmo=false, MinDamage=0, MinimumFireTime=0)
	iFeintStaminaCost=20
	WeaponFontSymbol="S"
	WeaponReach=100
	WeaponLargePortrait="UI_WeaponImages_SWF.weapon_select_throwknife"
	WeaponSmallPortrait="UI_WeaponImages_SWF.icon_weapon_select_throwknife_png"
	HorizontalRotateSpeed=75000
	VerticalRotateSpeed=65000
	AttackHorizRotateSpeed=55000
	SprintAttackHorizRotateSpeed=20000.0
	SprintAttackVerticalRotateSpeed=20000.0
	BattleCryAnim=(AnimationName=3p_throwingknife_battlecry,ComboAnimation=,AssociatedSoundCue=,bFullBody=true,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=0.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	WindupAnimations(0)=(AnimationName=3p_throwingknife_downtoup,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.shortsword_windup',bFullBody=False,bCombo=False,bLoop=False,bForce=false,fModifiedMovement=1.0,fAnimationLength=0.5,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	WindupAnimations(1)=(AnimationName=3p_throwingknife_slash02downtoup,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.shortsword_windup',bFullBody=False,bCombo=False,bLoop=False,bForce=false,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	WindupAnimations(2)=(AnimationName=3p_throwingknife_stabdowntoup,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.shortsword_windup',bFullBody=False,bCombo=False,bLoop=False,bForce=false,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	ReleaseAnimations(0)=(AnimationName=3p_throwingknife_release,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.broaddagger_attack_01',bFullBody=False,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	ReleaseAnimations(1)=(AnimationName=3p_throwingknife_slash02release,ComboAnimation=3p_throwingknife_slash021release,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.Broaddagger_Attack_02',bFullBody=False,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	ReleaseAnimations(2)=(AnimationName=3p_throwingknife_stabrelease,ComboAnimation=3p_throwingknife_stabrelease,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.Broaddagger_Attack_03',bFullBody=False,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	ReleaseAnimations(3)=(AnimationName=3p_throwingknife_sattackrelease_new,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.broaddagger_sprint_attack',bFullBody=True,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	ReleaseAnimations(4)=(AnimationName=3p_throwingknife_parryup,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.Broaddagger_Parry',bFullBody=False,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.375,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	ReleaseAnimations(5)=(AnimationName=3p_throwingknife_shoverelease_new,ComboAnimation=,AssociatedSoundCue=,bFullBody=True,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.2,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false,bUseRMM=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	ReleaseAnimations(6)=(AnimationName=,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	ReleaseAnimations(7)=(AnimationName=,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	ReleaseAnimations(8)=(AnimationName=3p_throwingknife_equipup,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.Knife_draw',bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.8,fBlendInTime=0.00,fBlendOutTime=0.01,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	ReleaseAnimations(9)=(AnimationName=3p_throwingknife_equipdown,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.knife_sheath',bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.5,fBlendInTime=0.00,fBlendOutTime=0.01,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	RecoveryAnimations(0)=(AnimationName=3p_throwingknife_recover,ComboAnimation=3p_throwingknife_slash011recover,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.35,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	RecoveryAnimations(1)=(AnimationName=3p_throwingknife_slash02recover,ComboAnimation=3p_throwingknife_slash021recover,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	RecoveryAnimations(2)=(AnimationName=3p_throwingknife_stabrecover,ComboAnimation=3p_throwingknife_stabrecover,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	RecoveryAnimations(3)=(AnimationName=3p_throwingknife_sattackrecover_new,ComboAnimation=,AssociatedSoundCue=,bFullBody=true,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=0.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	RecoveryAnimations(4)=(AnimationName=3p_throwingknife_parryrecover,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.4,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	RecoveryAnimations(5)=(AnimationName=3p_throwingknife_shoverecover,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.5,fBlendInTime=0.10,fBlendOutTime=0.0,bLastAnimation=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	RecoveryAnimations(6)=(AnimationName=,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	RecoveryAnimations(7)=(AnimationName=,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	RecoveryAnimations(8)=(AnimationName=,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	RecoveryAnimations(9)=(AnimationName=,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	HoldAnimations[0]=(AnimationName=3p_throwingknife_upidle,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=true,bForce=false,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.0,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	ReloadAnimations[0]=(AnimationName=3p_throwingknife_reload,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.0,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	StateAnimations(0)=(AnimationName=3p_throwingknife_parried,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.8,fBlendInTime=0.00,fBlendOutTime=0.08,bLastAnimation=true)
	StateAnimations(1)=(AnimationName=3p_throwingknife_dazed,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.2,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	StateAnimations(2)=(AnimationName=3p_throwingknife_dazedB01,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.9,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	StateAnimations(3)=(AnimationName=3p_throwingknife_dazedF01,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.9,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	StateAnimations(4)=(AnimationName=3p_throwingknife_hitFL,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.4,fBlendInTime=0.00,fBlendOutTime=0.08,bLastAnimation=false)
	TurnInfo(0)=(AnimationName=3p_throwingknife_turnL,ComboAnimation=,AssociatedSoundCue=,bFullBody=true,bCombo=false,bLoop=true,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=false,bLowerBody=true)
	TurnInfo(1)=(AnimationName=3p_throwingknife_turnR,ComboAnimation=,AssociatedSoundCue=,bFullBody=true,bCombo=false,bLoop=true,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=false)
	DazedAnimations(0)=(AnimationName=3p_throwingknife_dazedB01,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=1.1,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	DazedAnimations(1)=(AnimationName=3p_throwingknife_dazedR01,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=1.1,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	DazedAnimations(2)=(AnimationName=3p_throwingknife_dazedF01,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=1.1,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	DazedAnimations(3)=(AnimationName=3p_throwingknife_dazedL01,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=1.1,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	DazedAnimations(4)=(AnimationName=3p_throwingknife_dazedBL,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=1.1,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	DazedAnimations(5)=(AnimationName=3p_throwingknife_dazedBR,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=1.1,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	DazedAnimations(6)=(AnimationName=3p_throwingknife_dazedFL,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=1.1,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	DazedAnimations(7)=(AnimationName=3p_throwingknife_dazedFR,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=1.1,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	DirHitAnimation(0)=(AnimationName=ADD_3p_throwingknife_hitFL,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.4,fBlendInTime=0.00,fBlendOutTime=0.1,bLastAnimation=false,bUseSlotSystem=true)
	DirHitAnimation(1)=(AnimationName=ADD_3p_throwingknife_hitFR,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.4,fBlendInTime=0.00,fBlendOutTime=0.1,bLastAnimation=false,bUseSlotSystem=true)
	DirHitAnimation(2)=(AnimationName=ADD_3p_throwingknife_hitBL,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.4,fBlendInTime=0.00,fBlendOutTime=0.1,bLastAnimation=false,bUseSlotSystem=true)
	DirHitAnimation(3)=(AnimationName=ADD_3p_throwingknife_hitBR,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.4,fBlendInTime=0.00,fBlendOutTime=0.1,bLastAnimation=false,bUseSlotSystem=true)
	// Range Weapon ConfigProjectileBaseDamage Info
	// 0 - Bodkin
	// 1 - Broadhead
	// 2 - Fire
	// 3 - Steel
	// 4 - Javelin
	// 5 - Default
	// NOTE: Javelin sprint damage bonus found in DefaultWeapon.ini
	// The ones that aren't used shouldn't need to be set but I do it just to be safe.


	// Mercenaries 1.996 numeric weapon values (Workshop 705710406).
	SpecialDazeLength=1.8
	ShieldStaminaDrainDelay=4
	QuickKickWindow=0.35
	EndFeintWindowTime=0.15
	EndFeintWindowTimeCombo=0.25
	FlinchTime1H=0.8
	FlinchTime2H=0.9
	bCanSprint=true
	LimitSprintSpeed=1
	iComboFeintStaminaCost=15
	ParryDrain(0)=20
	ParryDrain(1)=30
	ParryDrain(2)=10
	FeintTime=0.4
	TertiaryFeintTime=0.4
	ComboFeintTime=0.5
	StrafeModify=-1
	BackModify=-1
	ForwardModify=-1
	CrouchModify=-1
	fLungeSpeedMultiplier=1.3
	fLungeSpeedZ=150
	fForwardMovementInRelease=-1
	EncircleRadius=1000
	InventoryWeight=2
	MaxHoldTime=5
	MinHoldTime=0.2
	InitialPeakTime=2
	FinalPeakTime=3
	YawRate=-1
	PitchRate=-1
	RollRate=-1
	fGravitySetting=-1
	TraceRadius=-1
	Drag=-1
	fSpread=3500
	fReasonableRefireRate=0.8
	EffectiveDistance=1000
}
