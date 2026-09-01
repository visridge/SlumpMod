/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
*
* Original Author: Michael Bao
*
* Weapon class for Dual Bucklers.
*/
class XangModWeapon_DualBucklers extends XangModMeleeWeapon;

simulated state Transition
{
	/** Play transition animation */
	simulated function AltPlayStateAnimation(optional bool bFromAltRecov = false)
	{
		local AnimationInfo ModInfo;
		local bool bCombo;
		local int StartIndex;

		bCombo = false;
		StartIndex = (eNextAttack - int(eNextAttack == Attack_Parry)) * 5;

		if (eNextAttack == Attack_Stab || eNextAttack == Attack_Parry)
		{
			if (ePreviousAttack == Attack_Overhead)
				StartIndex += 2;

			if (bJustPlayedCombo && ePreviousAttack != Attack_Stab)
				StartIndex++;

			if (ePreviousAttack == Attack_Stab)
			{
				StartIndex = (eNextAttack - int(eNextAttack == Attack_Parry)) * 5 + 4;
			}

			if (eNextAttack == Attack_Parry)
			{
				iComboCount = 1;
				AOCOwner.OnComboEnded();
				iIdenticalCombo = 1;
				ePreviousAttack = Attack_Null;
				bJustPlayedCombo = false;
				AOCWepAttachment.ComboCount = iComboCount;
				AOCWepAttachment.HitComboCount = ComboHitCount;
			}

			if (eNextAttack == Attack_Parry)
			{
				iParryCameFromTransition = StartIndex;
				ActivateParry();
				return;
			}
		}
		else
		{
			if (bJustPlayedCombo && ePreviousAttack != Attack_Stab)
				StartIndex += 2;

			if (ePreviousAttack == Attack_Overhead)
				StartIndex++;

			if (ePreviousAttack == Attack_Stab)
				StartIndex = eNextAttack * 5 + 4;
		}

		if ((eNextAttack == Attack_Slash || eNextAttack == Attack_Overhead)
			&& (AOCOwner.Role < ROLE_Authority || WorldInfo.NetMode == NM_Standalone || (WorldInfo.NetMode == NM_ListenServer && AOCOwner.IsLocallyControlled()))
			&& !AOCOwner.bIsBot)
		{
			if ((eNextAttack != ePreviousAttack && !bJustPlayedCombo) || (eNextAttack == ePreviousAttack && bJustPlayedCombo))
				AOCPlayerController(AOCOwner.Controller).PlayCustomCamAnim(eNextAttack == Attack_Slash ? PrimaryAttackCamWindup : SecondaryAttackCamWindup);
			else
				AOCPlayerController(AOCOwner.Controller).PlayCustomCamAnim(eNextAttack == Attack_Slash ? ComboPrimaryAttackCamWindup : ComboSecondaryAttackCamWindup);
		}

		if (ePreviousAttack == Attack_Stab)
		{
			bCombo = bJustPlayedCombo;
		}

		ModInfo = TransitionAnimations[StartIndex];
		if (!bFromAltRecov)
			ModInfo.fAnimationLength += 0.1f;
		else
			ModInfo.fAnimationLength = GetRealAnimLength(class'AOCWeapon'.static.ConvertToShieldAnimation(WindupAnimations[eNextAttack], bEquipShield, WeaponIdentifier, AllowedShieldClass.default.ShieldIdentifier, bIgnoreShieldReplacement));
		ModInfo.bCombo = bCombo;

		StartFeintWindow(ModInfo);

		AOCOwner.ReplicateCompressedAnimation(ModInfo, EWST_Transition, StartIndex);
	}
}

simulated state Release
{
	simulated function PlayStateAnimation()
	{
		local AnimationInfo Info;

		if (bIsInCombo)
		{
			if ((ePreviousAttack == Attack_Stab && CurrentFireMode == Attack_Slash && !bJustPlayedCombo)
				|| (ePreviousAttack == Attack_Slash && !bJustPlayedCombo && CurrentFireMode == Attack_Stab))
			{
				iComboCount++;
				AOCOwner.OnComboIncreased();

				AOCWepAttachment.ComboCount = iComboCount;
				AOCWepAttachment.HitComboCount = ComboHitCount;

				Info = ReleaseAnimations[CurrentFireMode];
				Info.bCombo = true;
				AOCWepAttachment.bJustPlayComboAnim = true;
				Info.bFullBody = false;
				Info.bForceSameIndex = bParryHitCounter;
				Info.bUseSlotSystem = false;
				TimeLeftInRelease = GetRealAnimLength(Info);
				AOCOwner.ReplicateCompressedAnimation(Info, EWST_Release, CurrentFireMode);
				bJustPlayedCombo = true;
			}
			else if ((ePreviousAttack == Attack_Stab && CurrentFireMode == Attack_Slash && bJustPlayedCombo)
				|| (ePreviousAttack == Attack_Slash && CurrentFireMode == Attack_Stab && bJustPlayedCombo))
			{
				Info = ReleaseAnimations[CurrentFireMode];
				Info.bFullBody = (!bIsInCombo && !AOCOwner.bIsCrouching);
				AOCWepAttachment.bJustPlayComboAnim = false;

				if (AOCOwner.StateVariables.bIsSprinting && !AOCOwner.bFirstAttackInSprint)
				{
					Info.bFullBody = false;
					AOCOwner.bFirstAttackInSprint = true;
				}

				if (AOCOwner.PawnState == ESTATE_DODGE)
					Info.bFullBody = false;

				Info.bForceSameIndex = bParryHitCounter;
				Info.bUseSlotSystem = false;
				TimeLeftInRelease = GetRealAnimLength(Info);
				AOCOwner.ReplicateCompressedAnimation(Info, EWST_Release, CurrentFireMode);
				bJustPlayedCombo = false;
			}
			else
				super.PlayStateAnimation();
		}
		else
			super.PlayStateAnimation();
	}
}

DefaultProperties
{
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
		bCauseActorAnimEnd=true
	End Object
	bUseDirParryHitAnims=true
	bUseNewDodgeSystem=true
	bUseStartStopAnims=true
	bUseSprintLeanAnims=true
	bUseRMMDazed=true
	bUseDirHitAnims=true

	ImpactSounds(ESWINGSOUND_Slash)={(
		light=SoundCue'A_Impacts_Melee.Light_Blunt_Average',
		medium=SoundCue'A_Impacts_Melee.Medium_Blunt_Average',
		heavy=SoundCue'A_Impacts_Melee.Heavy_Blunt_Average',
		wood=SoundCue'A_Phys_Mat_Impacts.kick_Wood',
		dirt=SoundCue'A_Phys_Mat_Impacts.kick_Dirt',
		metal=SoundCue'A_Phys_Mat_Impacts.kick_metal',
		stone=SoundCue'A_Phys_Mat_Impacts.kick_Stone')}

	ImpactSounds(ESWINGSOUND_SlashCombo)={(
		light=SoundCue'A_Impacts_Melee.Light_Blunt_Average',
		medium=SoundCue'A_Impacts_Melee.Medium_Blunt_Average',
		heavy=SoundCue'A_Impacts_Melee.Heavy_Blunt_Average',
		wood=SoundCue'A_Phys_Mat_Impacts.kick_Wood',
		dirt=SoundCue'A_Phys_Mat_Impacts.kick_Dirt',
		metal=SoundCue'A_Phys_Mat_Impacts.kick_metal',
		stone=SoundCue'A_Phys_Mat_Impacts.kick_Stone')}

	ImpactSounds(ESWINGSOUND_Stab)={(
		light=SoundCue'A_Impacts_Melee.Light_Blunt_Small',
		medium=SoundCue'A_Impacts_Melee.Medium_Blunt_Small',
		heavy=SoundCue'A_Impacts_Melee.Heavy_Blunt_Small',
		wood=SoundCue'A_Phys_Mat_Impacts.kick_Wood',
		dirt=SoundCue'A_Phys_Mat_Impacts.kick_Dirt',
		metal=SoundCue'A_Phys_Mat_Impacts.kick_metal',
		stone=SoundCue'A_Phys_Mat_Impacts.kick_Stone')}

	ImpactSounds(ESWINGSOUND_StabCombo)={(
		light=SoundCue'A_Impacts_Melee.Light_Blunt_Small',
		medium=SoundCue'A_Impacts_Melee.Medium_Blunt_Small',
		heavy=SoundCue'A_Impacts_Melee.Heavy_Blunt_Small',
		wood=SoundCue'A_Phys_Mat_Impacts.kick_Wood',
		dirt=SoundCue'A_Phys_Mat_Impacts.kick_Dirt',
		metal=SoundCue'A_Phys_Mat_Impacts.kick_metal',
		stone=SoundCue'A_Phys_Mat_Impacts.kick_Stone')}

	ImpactSounds(ESWINGSOUND_Overhead)={(
		light=SoundCue'A_Impacts_Melee.Light_Blunt_Large',
		medium=SoundCue'A_Impacts_Melee.Medium_Blunt_Large',
		heavy=SoundCue'A_Impacts_Melee.Heavy_Blunt_Large',
		wood=SoundCue'A_Phys_Mat_Impacts.kick_Wood',
		dirt=SoundCue'A_Phys_Mat_Impacts.kick_Dirt',
		metal=SoundCue'A_Phys_Mat_Impacts.kick_metal',
		stone=SoundCue'A_Phys_Mat_Impacts.kick_Stone')}

	ImpactSounds(ESWINGSOUND_OverheadCombo)={(
		light=SoundCue'A_Impacts_Melee.Light_Blunt_Average',
		medium=SoundCue'A_Impacts_Melee.Medium_Blunt_Average',
		heavy=SoundCue'A_Impacts_Melee.Heavy_Blunt_Average',
		wood=SoundCue'A_Phys_Mat_Impacts.kick_Wood',
		dirt=SoundCue'A_Phys_Mat_Impacts.kick_Dirt',
		metal=SoundCue'A_Phys_Mat_Impacts.kick_metal',
		stone=SoundCue'A_Phys_Mat_Impacts.kick_Stone')}

	ImpactSounds(ESWINGSOUND_Sprint)={(
		light=SoundCue'A_Impacts_Melee.Light_Blunt_Large',
		medium=SoundCue'A_Impacts_Melee.Medium_Blunt_Large',
		heavy=SoundCue'A_Impacts_Melee.Heavy_Blunt_Large',
		wood=SoundCue'A_Phys_Mat_Impacts.kick_Wood',
		dirt=SoundCue'A_Phys_Mat_Impacts.kick_Dirt',
		metal=SoundCue'A_Phys_Mat_Impacts.kick_metal',
		stone=SoundCue'A_Phys_Mat_Impacts.kick_Stone')}

	ImpactSounds(ESWINGSOUND_Shove)={(
		light=SoundCue'A_Impacts_Melee.Light_Kick_Small',
		medium=SoundCue'A_Impacts_Melee.Medium_Kick_Small',
		heavy=SoundCue'A_Impacts_Melee.Heavy_Kick_Small',
		wood=SoundCue'A_Phys_Mat_Impacts.Kick_Wood',
		dirt=SoundCue'A_Phys_Mat_Impacts.Kick_Dirt',
		metal=SoundCue'A_Phys_Mat_Impacts.Kick_Metal',
		stone=SoundCue'A_Phys_Mat_Impacts.Kick_Stone')}

	ImpactSounds(ESWINGSOUND_ShoveCombo)={(
		light=SoundCue'A_Impacts_Melee.Light_Kick_Small',
		medium=SoundCue'A_Impacts_Melee.Medium_Kick_Small',
		heavy=SoundCue'A_Impacts_Melee.Heavy_Kick_Small',
		wood=SoundCue'A_Phys_Mat_Impacts.Kick_Wood',
		dirt=SoundCue'A_Phys_Mat_Impacts.Kick_Dirt',
		metal=SoundCue'A_Phys_Mat_Impacts.Kick_Metal',
		stone=SoundCue'A_Phys_Mat_Impacts.Kick_Stone')}

	ParriedSound=SoundCue'A_Phys_Mat_Impacts.Buckler_Blocking'
	ParrySound=SoundCue'A_Phys_Mat_Impacts.Buckler_Blocking'

	ImpactBloodTemplates(0)=ParticleSystem'CHV_Particles_01.Player.P_ImpactBlunt'
	ImpactBloodTemplates(1)=ParticleSystem'CHV_Particles_01.Player.P_ImpactBlunt'
	ImpactBloodTemplates(2)=ParticleSystem'CHV_Particles_01.Player.P_ImpactBlunt'

	BloodSprayTemplates(0)=ParticleSystem'CHV_Particles_01.Player.P_OnWeaponBlood'
	BloodSprayTemplates(1)=ParticleSystem'CHV_Particles_01.Player.P_OnWeaponBlood'
	BloodSprayTemplates(2)=ParticleSystem'CHV_Particles_01.Player.P_OnWeaponBlood'

	AttachmentClass=class'XangModWeaponAttachment_DualBucklers'
	InventoryAttachmentClass=class'AOCInventoryAttachment_Fists'
	AllowedShieldClass=none
	CurrentWeaponType=EWEP_Fists
	CurrentShieldType=ESHIELD_None
	bHaveShield=false
	WeaponIdentifier="fist"
	WeaponName="Dual Bucklers"

	CurrentGenWeaponType=EWT_Fists

	iFeintStaminaCost=15
	FeintTime=0.2
	TertiaryFeintTime=0.4
	fParryNegation=100
	ParryDrain(0)=10
	ParryDrain(1)=13
	ParryDrain(2)=9
	WeaponFontSymbol="6"
	WeaponReach=112
	WeaponLargePortrait="UI_CustWeaponImages_SWF.skin_vicomte_buckler_png"
	WeaponSmallPortrait="UI_WeaponImages_SWF.icon_weapon_select_buckler_png"
	HorizontalRotateSpeed=60000.0
	VerticalRotateSpeed=60000.0
	AttackHorizRotateSpeed=60000.0
	SprintAttackHorizRotateSpeed=20000.0
	SprintAttackVerticalRotateSpeed=20000.0
	WindupAnimations(0)=(AnimationName=3p_fist_slash01downtoup,ComboAnimation=3p_fist_slash011downtoup,AlternateAnimation=3p_fist_slash011altdowntoup,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.mace_windup',bFullBody=False,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.45,fBlendInTime=0.10,fBlendOutTime=0.00,bLastAnimation=false)
	WindupAnimations(1)=(AnimationName=3p_fist_slash02downtoup,ComboAnimation=3p_fist_slash021downtoup,AlternateAnimation=3p_fist_slash021altdowntoup,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.mace_windup',bFullBody=False,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.45,fBlendInTime=0.10,fBlendOutTime=0.00,bLastAnimation=false)
	WindupAnimations(2)=(AnimationName=3p_fist_stab01downtoup,ComboAnimation=3p_fist_stab011downtoup,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.mace_windup',bFullBody=False,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.4,fBlendInTime=0.10,fBlendOutTime=0.00,bLastAnimation=false)
	WindupAnimations(3)=(AnimationName=3p_fist_sattackdowntoup,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Footsteps.Vanguard_Dirt_Jump',bFullBody=True,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.55,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false,bUseAltBoneBranch=true,bUseRMM=true)
	WindupAnimations(4)=(AnimationName=3p_fist_parryib,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.mace_Parry',bFullBody=False,bCombo=False,bLoop=False,bForce=false,fModifiedMovement=1.0,fAnimationLength=0.1,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false)
	WindupAnimations(5)=(AnimationName=3p_fist_shovestart,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.mace_windup',bFullBody=True,bCombo=False,bLoop=False,UniqueShieldSound=none,fModifiedMovement=0.0,fAnimationLength=0.35,fBlendInTime=0.05,fBlendOutTime=0.00,bLastAnimation=false,bUseAltNode=true,bUseAltBoneBranch=true)
	WindupAnimations(6)=(AnimationName=,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false)
	WindupAnimations(7)=(AnimationName=,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false)
	WindupAnimations(8)=(AnimationName=,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false)
	WindupAnimations(9)=(AnimationName=,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false)
	ReleaseAnimations(0)=(AnimationName=3p_fist_slash01release,ComboAnimation=3p_fist_slash011release,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.mace_attack_01',bFullBody=true,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.3,fBlendInTime=0.00,fBlendOutTime=0.10,bLastAnimation=false)
	ReleaseAnimations(1)=(AnimationName=3p_fist_slash02release,ComboAnimation=3p_fist_slash021release,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.mace_Attack_02',bFullBody=true,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.3,fBlendInTime=0.00,fBlendOutTime=0.10,bLastAnimation=false)
	ReleaseAnimations(2)=(AnimationName=3p_fist_stab01release,ComboAnimation=3p_fist_stab011release,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.mace_Attack_03',bFullBody=true,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.27,fBlendInTime=0.00,fBlendOutTime=0.10,bLastAnimation=false)
	ReleaseAnimations(3)=(AnimationName=3p_fist_sattackrelease,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.mace_sprint_attack',bFullBody=True,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false,bUseAltBoneBranch=true)
	ReleaseAnimations(4)=(AnimationName=3p_fist_parryup,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.mace_Parry',bFullBody=False,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.5,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false)
	ReleaseAnimations(5)=(AnimationName=3p_fist_shoverelease_new,ComboAnimation=,AssociatedSoundCue=,bFullBody=True,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.3,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false,bUseAltNode=true,bUseAltBoneBranch=true,bUseRMM=true)
	ReleaseAnimations(6)=(AnimationName=,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false)
	ReleaseAnimations(7)=(AnimationName=,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false)
	ReleaseAnimations(8)=(AnimationName=3p_fist_equipup,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.mace_draw',bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.5,fBlendInTime=0.00,fBlendOutTime=0.01,bLastAnimation=false)
	ReleaseAnimations(9)=(AnimationName=3p_fist_equipdown,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.mace_sheath',bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.5,fBlendInTime=0.00,fBlendOutTime=0.01,bLastAnimation=false)
	ReleaseAnimations(10)=(AnimationName=,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.0,fBlendOutTime=0.0,bLastAnimation=false)
	ReleaseAnimations(11)=(AnimationName=3p_fist_shieldup,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.broadsword_draw',bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.5,fBlendInTime=0.00,fBlendOutTime=0.01,bLastAnimation=false)
	ReleaseAnimations(12)=(AnimationName=3p_fist_shielddown,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.broadsword_sheath',bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.5,fBlendInTime=0.00,fBlendOutTime=0.01,bLastAnimation=false)
	RecoveryAnimations(0)=(AnimationName=3p_fist_slash01recover,ComboAnimation=3p_fist_slash011recover,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.45,fBlendInTime=0.10,fBlendOutTime=0.1,bLastAnimation=true)
	RecoveryAnimations(1)=(AnimationName=3p_fist_slash02recover,ComboAnimation=3p_fist_slash021recover,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.5,fBlendInTime=0.10,fBlendOutTime=0.1,bLastAnimation=true)
	RecoveryAnimations(2)=(AnimationName=3p_fist_stab01recover,ComboAnimation=3p_fist_stab011recover,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.4,fBlendInTime=0.10,fBlendOutTime=0.1,bLastAnimation=true)
	RecoveryAnimations(3)=(AnimationName=3p_fist_sattackrecover,ComboAnimation=,AssociatedSoundCue=,bFullBody=true,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.35,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=true,bUseAltBoneBranch=true)
	RecoveryAnimations(4)=(AnimationName=3p_fist_parryrecover,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.5,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=true)
	RecoveryAnimations(5)=(AnimationName=3p_fist_shoverecover,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.4,fBlendInTime=0.10,fBlendOutTime=0.1,bLastAnimation=true,bUseAltNode=true,bUseAltBoneBranch=true)
	RecoveryAnimations(6)=(AnimationName=,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=true)
	RecoveryAnimations(7)=(AnimationName=,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=true)
	RecoveryAnimations(8)=(AnimationName=,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=true)
	RecoveryAnimations(9)=(AnimationName=,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=true)
	StateAnimations(0)=(AnimationName=3p_fist_parried,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.8,fBlendInTime=0.00,fBlendOutTime=0.08,bLastAnimation=true)
	StateAnimations(1)=(AnimationName=3p_fist_dazed,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.25,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	StateAnimations(2)=(AnimationName=3p_fist_dazedB01,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.9,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	StateAnimations(3)=(AnimationName=3p_fist_dazedF01,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.9,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	StateAnimations(4)=(AnimationName=3p_fist_hitFL,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.4,fBlendInTime=0.00,fBlendOutTime=0.08,bLastAnimation=false)
	BattleCryAnim=(AnimationName=3p_fist_battlecry,ComboAnimation=,AssociatedSoundCue=,bFullBody=true,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=0.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.10,bLastAnimation=true)
	TransitionAnimations(0)=(AnimationName=3p_fist_slash011downtoup,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.625,fBlendInTime=0.10,fBlendOutTime=0.10,bLastAnimation=false)
	TransitionAnimations(1)=(AnimationName=3p_fist_slash02toslash01,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.625,fBlendInTime=0.10,fBlendOutTime=0.10,bLastAnimation=false)
	TransitionAnimations(2)=(AnimationName=3p_fist_slash011toslash01,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.625,fBlendInTime=0.10,fBlendOutTime=0.10,bLastAnimation=false)
	TransitionAnimations(3)=(AnimationName=3p_fist_slash021toslash011,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.625,fBlendInTime=0.10,fBlendOutTime=0.10,bLastAnimation=false)
	TransitionAnimations(4)=(AnimationName=3p_fist_stab01toslash011,ComboAnimation=3p_fist_stab011toslash01,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.625,fBlendInTime=0.10,fBlendOutTime=0.10,bLastAnimation=false)
	TransitionAnimations(5)=(AnimationName=3p_fist_slash01toslash02,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.6,fBlendInTime=0.10,fBlendOutTime=0.10,bLastAnimation=false)
	TransitionAnimations(6)=(AnimationName=3p_fist_slash021downtoup,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.6,fBlendInTime=0.10,fBlendOutTime=0.10,bLastAnimation=false)
	TransitionAnimations(7)=(AnimationName=3p_fist_slash011toslash021,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.6,fBlendInTime=0.10,fBlendOutTime=0.10,bLastAnimation=false)
	TransitionAnimations(8)=(AnimationName=3p_fist_slash021toslash02,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.6,fBlendInTime=0.10,fBlendOutTime=0.10,bLastAnimation=false)
	TransitionAnimations(9)=(AnimationName=3p_fist_stab01toslash02,ComboAnimation=3p_fist_stab011toslash021,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.6,fBlendInTime=0.10,fBlendOutTime=0.10,bLastAnimation=false)
	TransitionAnimations(10)=(AnimationName=3p_fist_slash01tostab011,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.625,fBlendInTime=0.10,fBlendOutTime=0.10,bLastAnimation=false)
	TransitionAnimations(11)=(AnimationName=3p_fist_slash011tostab01,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.625,fBlendInTime=0.10,fBlendOutTime=0.10,bLastAnimation=false)
	TransitionAnimations(12)=(AnimationName=3p_fist_slash02tostab01,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.625,fBlendInTime=0.10,fBlendOutTime=0.10,bLastAnimation=false)
	TransitionAnimations(13)=(AnimationName=3p_fist_slash021tostab011,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.625,fBlendInTime=0.10,fBlendOutTime=0.10,bLastAnimation=false)
	TransitionAnimations(14)=(AnimationName=THIS_LINE_IS_UNUSED,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.625,fBlendInTime=0.10,fBlendOutTime=0.10,bLastAnimation=false)
	TransitionAnimations(15)=(AnimationName=3p_fist_slash01toparry,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.25,fBlendInTime=0.10,fBlendOutTime=0.10,bLastAnimation=false)
	TransitionAnimations(16)=(AnimationName=3p_fist_slash011toparry,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.25,fBlendInTime=0.10,fBlendOutTime=0.10,bLastAnimation=false)
	TransitionAnimations(17)=(AnimationName=3p_fist_slash02toparry,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.25,fBlendInTime=0.10,fBlendOutTime=0.10,bLastAnimation=false)
	TransitionAnimations(18)=(AnimationName=3p_fist_slash021toparry,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.25,fBlendInTime=0.00,fBlendOutTime=0.10,bLastAnimation=false)
	TransitionAnimations(19)=(AnimationName=3p_fist_stab01toparry,ComboAnimation=3p_fist_stab011toparry,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.25,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false)
	OtherParryAnimations(0)=(AnimationName=3p_fist_parryhit01,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.3,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true,bUseAltNode=true)
	OtherParryAnimations(1)=(AnimationName=3p_fist_parryhit02,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.3,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true,bUseAltNode=true)
	OtherParryAnimations(2)=(AnimationName=3p_fist_parryhit03,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.3,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true,bUseAltNode=true)
	ShieldIdleAnim=(AnimationName=3p_buckler_parryupidle,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=true,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=false)
	TurnInfo(0)=(AnimationName=3p_fist_turnL,ComboAnimation=,AssociatedSoundCue=,bFullBody=true,bCombo=false,bLoop=true,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=false,bLowerBody=true)
	TurnInfo(1)=(AnimationName=3p_fist_turnR,ComboAnimation=,AssociatedSoundCue=,bFullBody=true,bCombo=false,bLoop=true,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=false)
	DirParryHitAnimations(0)=(AnimationName=3p_fist_parryhitL,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.3,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true,bUseAltNode=true)
	DirParryHitAnimations(1)=(AnimationName=3p_fist_parryhitR,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.3,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true,bUseAltNode=true)
	DirParryHitAnimations(2)=(AnimationName=3p_fist_parryhitH,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.3,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true,bUseAltNode=true)
	DirParryHitAnimations(3)=(AnimationName=3p_fist_parryhitS,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.3,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true,bUseAltNode=true)
	DazedAnimations(0)=(AnimationName=3p_fist_dazedB,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=1.1,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	DazedAnimations(1)=(AnimationName=3p_fist_dazedR,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=1.1,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	DazedAnimations(2)=(AnimationName=3p_fist_dazedF,AlternateAnimation=3p_fist_parrydazed,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=1.1,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	DazedAnimations(3)=(AnimationName=3p_fist_dazedL,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=1.1,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	DazedAnimations(4)=(AnimationName=3p_fist_dazedBL,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=1.1,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	DazedAnimations(5)=(AnimationName=3p_fist_dazedBR,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=1.1,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	DazedAnimations(6)=(AnimationName=3p_fist_dazedFL,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=1.1,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	DazedAnimations(7)=(AnimationName=3p_fist_dazedFR,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=1.1,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	DirHitAnimation(0)=(AnimationName=ADD_3p_fist_hitFL,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.4,fBlendInTime=0.00,fBlendOutTime=0.1,bLastAnimation=false,bUseSlotSystem=true)
	DirHitAnimation(1)=(AnimationName=ADD_3p_fist_hitFR,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.4,fBlendInTime=0.00,fBlendOutTime=0.1,bLastAnimation=false,bUseSlotSystem=true)
	DirHitAnimation(2)=(AnimationName=ADD_3p_fist_hitBL,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.4,fBlendInTime=0.00,fBlendOutTime=0.1,bLastAnimation=false,bUseSlotSystem=true)
	DirHitAnimation(3)=(AnimationName=ADD_3p_fist_hitBR,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.4,fBlendInTime=0.00,fBlendOutTime=0.1,bLastAnimation=false,bUseSlotSystem=true)
	AlternateRecoveryAnimations(0)=(AnimationName=3p_fist_dazedB01,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.9,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	AlternateRecoveryAnimations(1)=(AnimationName=3p_fist_dazedB01,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.9,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	AlternateRecoveryAnimations(2)=(AnimationName=3p_fist_dazedB01,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.9,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	AlternateRecoveryAnimations(3)=(AnimationName=3p_fist_dazedB01,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.9,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	AlternateRecoveryAnimations(4)=(AnimationName=3p_fist_dazedB01,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.9,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	AlternateRecoveryAnimations(5)=(AnimationName=3p_fist_dazedB01,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.9,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	AlternateRecoveryAnimations(6)=(AnimationName=3p_fist_dazedB01,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.9,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	AlternateRecoveryAnimations(7)=(AnimationName=3p_fist_dazedB01,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.9,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	AlternateRecoveryAnimations(8)=(AnimationName=3p_fist_dazedB01,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.9,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	AlternateRecoveryAnimations(9)=(AnimationName=3p_fist_dazedB01,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.9,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
}