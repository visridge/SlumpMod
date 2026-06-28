/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
*
* Firebug (Throwing Mode).
* Auto-throws like JavelinThrow — one-use, single projectile, ignites on hit.
*/
class BangModWeapon_FirebugThrow extends AOCWeapon_JavelinThrow;

// Auto-throw: fires immediately, cannot be held drawn
simulated state Hold
{
	simulated event BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		SetTimer(0.01, false, 'AutoThrow');
	}
}

simulated function AutoThrow()
{
	if (IsInState('Hold'))
	{
		GotoState('Release');
	}
}

DefaultProperties
{
	FiringStatesArray(3)= Windup
	ShotCost(3)=1

	CurrentWeaponType = EWEP_Torch
	AmmoCount=1
	MaxAmmoCount=1
	AIRange=5000

	HorizontalRotateSpeed = 60000
	VerticalRotateSpeed = 50000

	WeaponProjectiles(0)=class'AOCProj_ThrownTorch'
	WeaponProjectiles(3)=class'AOCProj_ThrownTorch'

	AttachmentClass=class'BangModWeaponAttachment_FirebugThrow'
	InventoryAttachmentClass=class'AOCInventoryAttachment_Torch'
	AllowedShieldClass=none
	bHaveShield=false
	bCanSwitchShield=false

	CurrentGenWeaponType=EWT_Torch
	bRetIdle = false
	bRetIdleOriginal=false
	bPlayOnWeapon=false
	bEquipShield=false
	bCanParry=False
	bUseDirParryHitAnims=true

	WeaponIdentifier="torch"

	ProjectileSpawnLocation=ProjJavelinPoint

	ParriedSound=SoundCue'A_Phys_Mat_Impacts.Cudgel_Blocked'
	ParrySound=SoundCue'A_Phys_Mat_Impacts.Cudgel_Blocking'

	StrafeModify=0.75f
	bCanDodge=false
	bUseIdleForTopHalf=true
	AlternativeMode=class'BangModWeapon_Firebug'
	bAlternativeFireStopped=false
	bHasFired=false
	bIgnoreShieldReplacement=true
	bIsReadyToSwitch = false

	/*
	 * Formerly in UDKNewWeapon.ini
	 */
	iFeintStaminaCost=0
	WeaponFontSymbol="A"
	WeaponReach=100
	WeaponLargePortrait="UI_WeaponImages_SWF.weapon_select_cudgel"
	WeaponSmallPortrait="UI_WeaponImages_SWF.icon_weapon_select_cudgel_png"
	HorizontalRotateSpeed=60000.0
	VerticalRotateSpeed=60000.0
	AttackHorizRotateSpeed=60000.0
	SprintAttackHorizRotateSpeed=20000.0
	SprintAttackVerticalRotateSpeed=20000.0

	WindupAnimations(0)=(AnimationName=3p_1hsharp_throwwindup,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.shortsword_windup',bFullBody=False,bCombo=False,bLoop=False,bForce=false,fModifiedMovement=1.0,fAnimationLength=0.5,fBlendInTime=0.10,fBlendOutTime=0.10,bLastAnimation=false)
	WindupAnimations(1)=(AnimationName=,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.shortsword_windup',bFullBody=False,bCombo=False,bLoop=False,bForce=false,fModifiedMovement=0.0,fAnimationLength=0.3,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false)
	WindupAnimations(2)=(AnimationName=,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.shortsword_windup',bFullBody=False,bCombo=False,bLoop=False,bForce=false,fModifiedMovement=0.7,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false)
	WindupAnimations(3)=(AnimationName=3p_1hsharp_sprintthrowstart,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Footsteps.Archer_Dirt_Jump',bFullBody=True,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false)
	WindupAnimations(4)=(AnimationName=3p_1hsharp_parryib,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.shortsword_Parry',bFullBody=False,bCombo=False,bLoop=False,bForce=false,fModifiedMovement=1.0,fAnimationLength=0.125,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false)
	WindupAnimations(5)=(AnimationName=3p_1hsharp_shovestart,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.shortsword_windup',bFullBody=True,bCombo=False,bLoop=False,UniqueShieldSound=none,fModifiedMovement=0.0,fAnimationLength=0.35,fBlendInTime=0.05,fBlendOutTime=0.05,bLastAnimation=false,bUseAltNode=true,bUseAltBoneBranch=true)

	ReleaseAnimations(0)=(AnimationName=3p_1hsharp_throwrelease,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=0.6,fAnimationLength=0.2,fBlendInTime=0.05,fBlendOutTime=0.1,bLastAnimation=false)
	ReleaseAnimations(1)=(AnimationName=3p_1hsharp_slash01release,ComboAnimation=,AssociatedSoundCue=,bFullBody=true,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=0.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false)
	ReleaseAnimations(2)=(AnimationName=3p_1hsharp_stabrelease,ComboAnimation=,AssociatedSoundCue=,bFullBody=true,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false)
	ReleaseAnimations(3)=(AnimationName=3p_1hsharp_sprintthrowrelease,ComboAnimation=,AssociatedSoundCue=,bFullBody=True,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false)
	ReleaseAnimations(4)=(AnimationName=3p_1hsharp_parryup,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.shortsword_Parry',bFullBody=False,bCombo=False,bLoop=True,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false)
	ReleaseAnimations(5)=(AnimationName=3p_1hsharp_shoverelease_new,ComboAnimation=,AssociatedSoundCue=,bFullBody=True,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=0.0,fAnimationLength=0.3,fBlendInTime=0.05,fBlendOutTime=0.1,bLastAnimation=false,bUseAltNode=true,bUseAltBoneBranch=true,bUseRMM=true)
	ReleaseAnimations(6)=(AnimationName=,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false)
	ReleaseAnimations(7)=(AnimationName=,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false)
	ReleaseAnimations(8)=(AnimationName=3p_1hsharp_equipup,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.shortsword_draw',bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.3,fBlendInTime=0.00,fBlendOutTime=0.01,bLastAnimation=false)
	ReleaseAnimations(9)=(AnimationName=3p_1hsharp_equipdown,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.shortsword_sheath',bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.5,fBlendInTime=0.00,fBlendOutTime=0.01,bLastAnimation=false)

	RecoveryAnimations(0)=(AnimationName=3p_1hsharp_throwrecover,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=true)
	RecoveryAnimations(1)=(AnimationName=3p_1hsharp_slash02recover,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=true)
	RecoveryAnimations(2)=(AnimationName=3p_1hsharp_stabrecover,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=true)
	RecoveryAnimations(3)=(AnimationName=3p_1hsharp_sattackrecover_new,ComboAnimation=,AssociatedSoundCue=,bFullBody=true,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=0.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=true)
	RecoveryAnimations(4)=(AnimationName=3p_1hsharp_parryrecover,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.5,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=true)
	RecoveryAnimations(5)=(AnimationName=3p_1hsharp_shoverecover,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.5,fBlendInTime=0.10,fBlendOutTime=0.0,bLastAnimation=true)
	RecoveryAnimations(6)=(AnimationName=,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=true)
	RecoveryAnimations(7)=(AnimationName=,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=true)
	RecoveryAnimations(8)=(AnimationName=,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=true)
	RecoveryAnimations(9)=(AnimationName=,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=true)

	SwapToAnimation=(AnimationName=3p_1hsharp_stabtothrow,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.40,fBlendInTime=0.10,fBlendOutTime=0.01,bLastAnimation=false)
}
