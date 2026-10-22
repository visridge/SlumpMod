/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
*
* Original Author: Richard Pragnell
*
* Weapon: Smoke Pot
*/
class XangModWeapon_SmokePot extends AOCWeapon_SmokePot;

DefaultProperties
{
	CurrentWeaponType = EWEP_SmokePot
	// set maximum ammo
	AmmoCount=2
	MaxAmmoCount=2
	AIRange=5000

	WeaponProjectiles(0)=class'XangModProj_ThrownSmokePot'

	AttachmentClass=class'AOCWeaponAttachment_SmokePot'
	// should never be part of inventory attachment
	InventoryAttachmentClass=class'AOCInventoryAttachment_SmokePot'

	ProjectileSpawnLocation=ProjPoint
	bCanPickupAmmoOffCorpse=false

	/*
	 * Formerly in UDKNewWeapon.ini - [AOC.AOCWeapon_SmokePot]
	 */
	// Range Weapon ConfigProjectileBaseDamage Info
	// 0 - Bodkin
	// 1 - Broadhead
	// 2 - Fire
	// 3 - Steel
	// 4 - Javelin
	// 5 - Default
	// NOTE: Javelin sprint damage bonus found in DefaultWeapon.ini
	// The ones that aren't used shouldn't need to be set but I do it just to be safe.
	ConfigProjectileBaseDamage[0]=(Damage=0,InitialSpeed=0,MaxSpeed=0,AmmoCount=0,InitialGravityScale=0,Drag=0,PitchCorrection=0.0, bInfiniteAmmo=false, MinDamage=0, MinimumFireTime=0)
	ConfigProjectileBaseDamage[1]=(Damage=0,InitialSpeed=0,MaxSpeed=0,AmmoCount=0,InitialGravityScale=0,Drag=0,PitchCorrection=0.0, bInfiniteAmmo=false, MinDamage=0, MinimumFireTime=0)
	ConfigProjectileBaseDamage[2]=(Damage=0,InitialSpeed=0,MaxSpeed=0,AmmoCount=0,InitialGravityScale=0,Drag=0,PitchCorrection=0.0, bInfiniteAmmo=false, MinDamage=0, MinimumFireTime=0)
	ConfigProjectileBaseDamage[3]=(Damage=0,InitialSpeed=0,MaxSpeed=0,AmmoCount=0,InitialGravityScale=0,Drag=0,PitchCorrection=0.0, bInfiniteAmmo=false, MinDamage=0, MinimumFireTime=0)
	ConfigProjectileBaseDamage[4]=(Damage=0,InitialSpeed=0,MaxSpeed=0,AmmoCount=0,InitialGravityScale=0,Drag=0,PitchCorrection=0.0, bInfiniteAmmo=false, MinDamage=0, MinimumFireTime=0)
	ConfigProjectileBaseDamage[5]=(Damage=0,InitialSpeed=1500,MaxSpeed=2000,AmmoCount=2,InitialGravityScale=1.0,Drag=0.000001,PitchCorrection=60.0, bInfiniteAmmo=false, MinDamage=0, MinimumFireTime=0)
	iFeintStaminaCost=0
	WeaponFontSymbol="*"
	WeaponReach=100
	WeaponLargePortrait="UI_WeaponImages_SWF.weapon_select_smokepot"
	WeaponSmallPortrait="UI_WeaponImages_SWF.icon_weapon_select_smokepot_png"
	HorizontalRotateSpeed=75000.0
	VerticalRotateSpeed=65000.0
	AttackHorizRotateSpeed=65000.0
	SprintAttackHorizRotateSpeed=20000.0
	SprintAttackVerticalRotateSpeed=20000.0
	WindupAnimations(0)=(AnimationName=3p_1hsharp_throwdowntoup,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.broadsword_windup',bFullBody=False,bCombo=False,bLoop=False,bForce=false,fModifiedMovement=1.0,fAnimationLength=.6,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	WindupAnimations(1)=(AnimationName=3p_1hsharp_slash02downtoup,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.broadsword_windup',bFullBody=False,bCombo=False,bLoop=False,bForce=false,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	WindupAnimations(2)=(AnimationName=3p_1hsharp_stabdowntoup,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.broadsword_windup',bFullBody=False,bCombo=False,bLoop=False,bForce=false,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	ReleaseAnimations(0)=(AnimationName=3p_1hsharp_throwrelease,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.broadsword_attack_01',bFullBody=False,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	ReleaseAnimations(1)=(AnimationName=3p_1hsharp_slash02release,ComboAnimation=3p_1hsharp_slash021release,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.Broadsword_Attack_02',bFullBody=False,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	ReleaseAnimations(2)=(AnimationName=3p_1hsharp_stabrelease,ComboAnimation=3p_1hsharp_stabrelease,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.Broadsword_Attack_03',bFullBody=False,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	ReleaseAnimations(3)=(AnimationName=3p_1hsharp_sattackrelease_new,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.broadsword_sprint_attack',bFullBody=True,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	ReleaseAnimations(4)=(AnimationName=3p_1hsharp_parryup,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.Broadsword_Parry',bFullBody=False,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.375,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	ReleaseAnimations(5)=(AnimationName=3p_1hsharp_shoverelease_new,ComboAnimation=,AssociatedSoundCue=,bFullBody=True,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.2,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false,bUseRMM=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	ReleaseAnimations(6)=(AnimationName=,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	ReleaseAnimations(7)=(AnimationName=,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	ReleaseAnimations(8)=(AnimationName=3p_1hsharp_equipup,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.mace_draw',bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.5,fBlendInTime=0.00,fBlendOutTime=0.01,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	ReleaseAnimations(9)=(AnimationName=3p_1hsharp_equipdown,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.mace_sheath',bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.5,fBlendInTime=0.00,fBlendOutTime=0.01,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	RecoveryAnimations(0)=(AnimationName=3p_1hsharp_throwrecover,ComboAnimation=3p_1hsharp_slash011recover,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	RecoveryAnimations(1)=(AnimationName=3p_1hsharp_slash02recover,ComboAnimation=3p_1hsharp_slash021recover,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.10,fBlendOutTime=0.1,bLastAnimation=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	RecoveryAnimations(2)=(AnimationName=3p_1hsharp_stabrecover,ComboAnimation=3p_1hsharp_stabrecover,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	RecoveryAnimations(3)=(AnimationName=3p_1hsharp_sattackrecover_new,ComboAnimation=,AssociatedSoundCue=,bFullBody=true,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=0.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	RecoveryAnimations(4)=(AnimationName=3p_1hsharp_parryrecover,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.4,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	RecoveryAnimations(5)=(AnimationName=3p_1hsharp_shoverecover,ComboAnimation=,AssociatedSoundCue=,bFullBody=true,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=0.0,fAnimationLength=0.5,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	RecoveryAnimations(6)=(AnimationName=,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	RecoveryAnimations(7)=(AnimationName=,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	RecoveryAnimations(8)=(AnimationName=,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	RecoveryAnimations(9)=(AnimationName=,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	HoldAnimations[0]=(AnimationName=3p_1hsharp_throwupidle,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=true,bForce=false,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.0,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	ReloadAnimations[0]=(AnimationName=3p_1hsharp_throwthrowreload,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.0,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	StateAnimations(0)=(AnimationName=3p_1hsharp_parried,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.8,fBlendInTime=0.00,fBlendOutTime=0.08,bLastAnimation=true)
	StateAnimations(1)=(AnimationName=3p_1hsharp_dazed,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.2,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	StateAnimations(2)=(AnimationName=3p_1hsharp_hitF01,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.9,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	StateAnimations(3)=(AnimationName=3p_1hsharp_hitB01,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.9,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	StateAnimations(4)=(AnimationName=3p_1hsharp_hitL,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.4,fBlendInTime=0.00,fBlendOutTime=0.08,bLastAnimation=false)
	TurnInfo(0)=(AnimationName=3p_1hsharp_turnL,ComboAnimation=,AssociatedSoundCue=,bFullBody=true,bCombo=false,bLoop=true,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=false,bLowerBody=true)
	TurnInfo(1)=(AnimationName=3p_1hsharp_turnR,ComboAnimation=,AssociatedSoundCue=,bFullBody=true,bCombo=false,bLoop=true,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=false)
	DazedAnimations(0)=(AnimationName=3p_1hsharp_dazedB01,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=1.1,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	DazedAnimations(1)=(AnimationName=3p_1hsharp_dazedR01,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=1.1,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	DazedAnimations(2)=(AnimationName=3p_1hsharp_dazedF01,AlternateAnimation=3p_1hsharp_parrydazed,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=1.1,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	DazedAnimations(3)=(AnimationName=3p_1hsharp_dazedL01,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=1.1,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	DazedAnimations(4)=(AnimationName=3p_1hsharp_dazedBL,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=1.1,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	DazedAnimations(5)=(AnimationName=3p_1hsharp_dazedBR,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=1.1,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	DazedAnimations(6)=(AnimationName=3p_1hsharp_dazedFL,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=1.1,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	DazedAnimations(7)=(AnimationName=3p_1hsharp_dazedFR,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=1.1,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	BattleCryAnim=(AnimationName=3p_1hsharp_battlecry,ComboAnimation=,AssociatedSoundCue=,bFullBody=true,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=0.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	DirHitAnimation(0)=(AnimationName=ADD_3p_1hsharp_hitFL,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.4,fBlendInTime=0.00,fBlendOutTime=0.1,bLastAnimation=false,bUseSlotSystem=true)
	DirHitAnimation(1)=(AnimationName=ADD_3p_1hsharp_hitFR,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.4,fBlendInTime=0.00,fBlendOutTime=0.1,bLastAnimation=false,bUseSlotSystem=true)
	DirHitAnimation(2)=(AnimationName=ADD_3p_1hsharp_hitBL,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.4,fBlendInTime=0.00,fBlendOutTime=0.1,bLastAnimation=false,bUseSlotSystem=true)
	DirHitAnimation(3)=(AnimationName=ADD_3p_1hsharp_hitBR,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.4,fBlendInTime=0.00,fBlendOutTime=0.1,bLastAnimation=false,bUseSlotSystem=true)


	// Mercenaries 1.996 numeric weapon values (Workshop 705710406).
	SpecialDazeLength=1.8
	ShieldStaminaDrainDelay=4
	QuickKickWindow=0.35
	EndFeintWindowTime=0.15
	EndFeintWindowTimeCombo=0.25
	FlinchTime1H=0.8
	FlinchTime2H=0.9
	bCanSprint=true
	bCanDodge=true
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
