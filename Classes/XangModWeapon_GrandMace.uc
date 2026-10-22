/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
*
* Original Author: Richard Pragnell
*
* The weapon class to contain information for the GrandMace
*/

class XangModWeapon_GrandMace extends XangModMeleeWeapon;

simulated state Release
{

	/** Play Release animation */
	simulated function PlayStateAnimation()
	{
		local AnimationInfo Info;
		//`log("RELEASE PLAY STATE ANIMATION");
		if (bIsInCombo)
		{
			// add to number of combos performed
			iComboCount++;
			AOCOwner.OnComboIncreased();

			if (CurrentFireMode != Attack_Sprint && !AOCOwner.bIsCrouching && AOCOwner.Physics != PHYS_Falling)
			{
				if (VSize(AOCOwner.Velocity) > 2.0f && !Info.bUseRMM)
					AOCOwner.Lunge(,,true);
				else if (VSize(AOCOwner.Velocity) <= 2.f && !Info.bUseRMM)
					Info.bFullBody = false;
			}

			// pass this information down to the weapon attachment
			AOCWepAttachment.ComboCount = iComboCount;
			AOCWepAttachment.HitComboCount = ComboHitCount;
			// pass in proper animation, let pawn determine which node to use on the AnimTree
			if (bJustPlayedCombo || ePreviousAttack == Attack_Stab)
			{
				// odd sequential attacks should be the normal attack animation
				AOCOwner.ReplicateCompressedAnimation(ReleaseAnimations[CurrentFireMode], EWST_Release, CurrentFireMode);
				bJustPlayedCombo = false;
			}
			else
			{
				// even sequential attacks should be the combo attack animation
				Info = ReleaseAnimations[CurrentFireMode];
				//`log(bEquipShield@"GOING TO PLAY"@Info.AnimationName);
				Info.bCombo = true;
				AOCOwner.ReplicateCompressedAnimation(Info, EWST_Release, CurrentFireMode);
				bJustPlayedCombo = true;
			}
		}
		else
			super.PlayStateAnimation(); // default handle for playing animation is fine if we are not doing a combo
	}
}

DefaultProperties
{
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
		bCauseActorAnimEnd=true
	End Object

	bTwoHander=true
	FlinchTime2H=0.9
	bUseRMMDazed=true
	bUseDirHitAnims=true
	EncircleRadius=25.0f
	EffectiveDistance=200.0f
	
	AttachmentClass=class'XangModWeaponAttachment_GrandMace'
	InventoryAttachmentClass=class'AOCInventoryAttachment_GrandMace'
	AllowedShieldClass=none
	CurrentWeaponType=EWEP_PoleArm
	CurrentShieldType=ESHIELD_None
	bHaveShield=false

	ImpactSounds(ESWINGSOUND_Slash)={(
		light=SoundCue'A_Impacts_Melee.Light_Blunt_Average',
		medium=SoundCue'A_Impacts_Melee.Medium_Blunt_Average',
		heavy=SoundCue'A_Impacts_Melee.Heavy_Blunt_Average',
		wood=SoundCue'A_Phys_Mat_Impacts.Mace_Wood',
		mud=SoundCue'A_Phys_Mat_Impacts.Mace_Dirt',
		foliage=SoundCue'A_Phys_Mat_Impacts.Mace_Dirt',
		dirt=SoundCue'A_Phys_Mat_Impacts.Mace_Dirt',
		metal=SoundCue'A_Phys_Mat_Impacts.mace_metal',
		stone=SoundCue'A_Phys_Mat_Impacts.Mace_Stone')}

	ImpactSounds(ESWINGSOUND_SlashCombo)={(
		light=SoundCue'A_Impacts_Melee.Light_Blunt_Average',
		medium=SoundCue'A_Impacts_Melee.Medium_Blunt_Average',
		heavy=SoundCue'A_Impacts_Melee.Heavy_Blunt_Average',
		wood=SoundCue'A_Phys_Mat_Impacts.Mace_Wood',
		mud=SoundCue'A_Phys_Mat_Impacts.Mace_Dirt',
		foliage=SoundCue'A_Phys_Mat_Impacts.Mace_Dirt',
		dirt=SoundCue'A_Phys_Mat_Impacts.Mace_Dirt',
		metal=SoundCue'A_Phys_Mat_Impacts.mace_metal',
		stone=SoundCue'A_Phys_Mat_Impacts.Mace_Stone')}

	ImpactSounds(ESWINGSOUND_Stab)={(
		light=SoundCue'A_Impacts_Melee.Light_Blunt_Small',
		medium=SoundCue'A_Impacts_Melee.Medium_Blunt_Small',
		heavy=SoundCue'A_Impacts_Melee.Heavy_Blunt_Small',
		wood=SoundCue'A_Phys_Mat_Impacts.Mace_Wood',
		mud=SoundCue'A_Phys_Mat_Impacts.Mace_Dirt',
		foliage=SoundCue'A_Phys_Mat_Impacts.Mace_Dirt',
		dirt=SoundCue'A_Phys_Mat_Impacts.Mace_Dirt',
		metal=SoundCue'A_Phys_Mat_Impacts.mace_metal',
		stone=SoundCue'A_Phys_Mat_Impacts.Mace_Stone')}

	ImpactSounds(ESWINGSOUND_StabCombo)={(
		light=SoundCue'A_Impacts_Melee.Light_Blunt_Small',
		medium=SoundCue'A_Impacts_Melee.Medium_Blunt_Small',
		heavy=SoundCue'A_Impacts_Melee.Heavy_Blunt_Small',
		wood=SoundCue'A_Phys_Mat_Impacts.Mace_Wood',
		mud=SoundCue'A_Phys_Mat_Impacts.Mace_Dirt',
		foliage=SoundCue'A_Phys_Mat_Impacts.Mace_Dirt',
		dirt=SoundCue'A_Phys_Mat_Impacts.Mace_Dirt',
		metal=SoundCue'A_Phys_Mat_Impacts.mace_metal',
		stone=SoundCue'A_Phys_Mat_Impacts.Mace_Stone')}


	ImpactSounds(ESWINGSOUND_Overhead)={(
		light=SoundCue'A_Impacts_Melee.Light_Blunt_Large',
		medium=SoundCue'A_Impacts_Melee.Medium_Blunt_Large',
		heavy=SoundCue'A_Impacts_Melee.Heavy_Blunt_Large',
		wood=SoundCue'A_Phys_Mat_Impacts.Mace_Wood',
		mud=SoundCue'A_Phys_Mat_Impacts.Mace_Dirt',
		foliage=SoundCue'A_Phys_Mat_Impacts.Mace_Dirt',
		dirt=SoundCue'A_Phys_Mat_Impacts.Mace_Dirt',
		metal=SoundCue'A_Phys_Mat_Impacts.mace_metal',
		stone=SoundCue'A_Phys_Mat_Impacts.Mace_Stone')}

	ImpactSounds(ESWINGSOUND_OverheadCombo)={(
		light=SoundCue'A_Impacts_Melee.Light_Blunt_Average',
		medium=SoundCue'A_Impacts_Melee.Medium_Blunt_Average',
		heavy=SoundCue'A_Impacts_Melee.Heavy_Blunt_Average',
		wood=SoundCue'A_Phys_Mat_Impacts.Mace_Wood',
		mud=SoundCue'A_Phys_Mat_Impacts.Mace_Dirt',
		foliage=SoundCue'A_Phys_Mat_Impacts.Mace_Dirt',
		dirt=SoundCue'A_Phys_Mat_Impacts.Mace_Dirt',
		metal=SoundCue'A_Phys_Mat_Impacts.mace_metal',
		stone=SoundCue'A_Phys_Mat_Impacts.Mace_Stone')}

	ImpactSounds(ESWINGSOUND_Sprint)={(
		light=SoundCue'A_Impacts_Melee.Light_Blunt_Large',
		medium=SoundCue'A_Impacts_Melee.Medium_Blunt_Large',
		heavy=SoundCue'A_Impacts_Melee.Heavy_Blunt_Large',
		wood=SoundCue'A_Phys_Mat_Impacts.Mace_Wood',
		mud=SoundCue'A_Phys_Mat_Impacts.Mace_Dirt',
		foliage=SoundCue'A_Phys_Mat_Impacts.Mace_Dirt',
		dirt=SoundCue'A_Phys_Mat_Impacts.Mace_Dirt',
		metal=SoundCue'A_Phys_Mat_Impacts.mace_metal',
		stone=SoundCue'A_Phys_Mat_Impacts.Mace_Stone')}

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

	ParriedSound=SoundCue'A_Phys_Mat_Impacts.Mace_Blocked'
	ParrySound=SoundCue'A_Phys_Mat_Impacts.Mace_Blocking'

	ImpactBloodTemplates(0)=ParticleSystem'CHV_Particles_01.Player.P_ImpactBlunt'
	ImpactBloodTemplates(1)=ParticleSystem'CHV_Particles_01.Player.P_ImpactBlunt'
	ImpactBloodTemplates(2)=ParticleSystem'CHV_Particles_01.Player.P_ImpactBlunt'

	BloodSprayTemplates(0)=ParticleSystem'CHV_Particles_01.Player.P_OnWeaponBlood'
	BloodSprayTemplates(1)=ParticleSystem'CHV_Particles_01.Player.P_OnWeaponBlood'
	BloodSprayTemplates(2)=ParticleSystem'CHV_Particles_01.Player.P_OnWeaponBlood'


	AttachmentClass=class'XangModWeaponAttachment_GrandMace'
	InventoryAttachmentClass=class'AOCInventoryAttachment_GrandMace'
	AllowedShieldClass=none
	CurrentWeaponType=EWEP_GrandMace
	CurrentShieldType=ESHIELD_None
	bHaveShield=false
	WeaponIdentifier="doubleaxe"

	CurrentGenWeaponType=EWT_2handsword

	/*
	 * Formerly in UDKNewWeapon.ini - [AOC.AOCWeapon_GrandMace]
	 */
	iFeintStaminaCost=15
	FeintTime=0.2
	TertiaryFeintTime=0.4
	fParryNegation=18
	ParryDrain(0)=34
	ParryDrain(1)=37
	ParryDrain(2)=32
	WeaponFontSymbol="0"
	WeaponLargePortrait="UI_CustWeaponImages_SWF.skin_grand_mace_png"
	WeaponSmallPortrait="UI_WeaponImages_SWF.icon_weapon_select_grandmace_png"
	HorizontalRotateSpeed=53000.0
	WeaponReach=100
	VerticalRotateSpeed=53000.0
	AttackHorizRotateSpeed=53000.0
	SprintAttackHorizRotateSpeed=20000.0
	SprintAttackVerticalRotateSpeed=20000.0
	WindupAnimations(0)=(AnimationName=3p_doubleaxe_slash01downtoup,ComboAnimation=3p_doubleaxe_slash011downtoup,AlternateAnimation=3p_doubleaxe_slash011altdowntoup,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.doubleaxe_windup',bFullBody=False,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.525,fBlendInTime=0.10,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	WindupAnimations(1)=(AnimationName=3p_doubleaxe_slash02downtoup,ComboAnimation=3p_doubleaxe_slash021downtoup,AlternateAnimation=3p_doubleaxe_slash021altdowntoup,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.doubleaxe_windup',bFullBody=False,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.575,fBlendInTime=0.10,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	WindupAnimations(2)=(AnimationName=3p_doubleaxe_stabdowntoup,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.doubleaxe_windup',bFullBody=False,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.6,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	WindupAnimations(3)=(AnimationName=3p_doubleaxe_sattackdowntoup,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Footsteps.Paladin_Dirt_Jump',bFullBody=True,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false,bUseAltBoneBranch=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	WindupAnimations(4)=(AnimationName=3p_doubleaxe_parryib,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.doubleaxe_Parry',bFullBody=False,bCombo=False,bLoop=False,bForce=false,fModifiedMovement=1.0,fAnimationLength=0.5,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	WindupAnimations(5)=(AnimationName=3p_doubleaxe_shovestart,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.doubleaxe_windup',bFullBody=True,bCombo=False,bLoop=False,UniqueShieldSound=none,fModifiedMovement=0.0,fAnimationLength=0.35,fBlendInTime=0.05,fBlendOutTime=0.05,bLastAnimation=false,bUseAltNode=true,bUseAltBoneBranch=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	WindupAnimations(6)=(AnimationName=,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	WindupAnimations(7)=(AnimationName=,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	WindupAnimations(8)=(AnimationName=,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	WindupAnimations(9)=(AnimationName=,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	ReleaseAnimations(0)=(AnimationName=3p_doubleaxe_slash01release,ComboAnimation=3p_doubleaxe_slash011release,AlternateAnimation=3p_doubleaxe_slash011release,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.doubleaxe_attack_01',bFullBody=True,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.6,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	ReleaseAnimations(1)=(AnimationName=3p_doubleaxe_slash02release,ComboAnimation=3p_doubleaxe_slash021release,AlternateAnimation=3p_doubleaxe_slash021release,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.doubleaxe_Attack_02',bFullBody=True,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.6,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	ReleaseAnimations(2)=(AnimationName=3p_doubleaxe_stabrelease,ComboAnimation=3p_doubleaxe_stabrelease,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.doubleaxe_Attack_03',bFullBody=True,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.5,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	ReleaseAnimations(3)=(AnimationName=3p_doubleaxe_sattackrelease,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.doubleaxe_sprint_attack',bFullBody=True,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false,bUseAltBoneBranch=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	ReleaseAnimations(4)=(AnimationName=3p_doubleaxe_parryup,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.doubleaxe_Parry',bFullBody=False,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.5,fBlendInTime=0.10,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	ReleaseAnimations(5)=(AnimationName=3p_doubleaxe_shoverelease_new,ComboAnimation=,AssociatedSoundCue=,bFullBody=True,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=0.0,fAnimationLength=0.3,fBlendInTime=0.05,fBlendOutTime=0.05,bLastAnimation=false,bUseAltNode=true,bUseAltBoneBranch=true,bUseRMM=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	ReleaseAnimations(6)=(AnimationName=,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	ReleaseAnimations(7)=(AnimationName=,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	ReleaseAnimations(8)=(AnimationName=3p_doubleaxe_equipup,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.doubleaxe_draw',bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.6,fBlendInTime=0.00,fBlendOutTime=0.01,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	ReleaseAnimations(9)=(AnimationName=3p_doubleaxe_equipdown,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.doubleaxe_sheath',bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.5,fBlendInTime=0.00,fBlendOutTime=0.01,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	RecoveryAnimations(0)=(AnimationName=3p_doubleaxe_slash01recover,ComboAnimation=3p_doubleaxe_slash011recover,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.9,fBlendInTime=0.10,fBlendOutTime=0.1,bLastAnimation=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	RecoveryAnimations(1)=(AnimationName=3p_doubleaxe_slash02recover,ComboAnimation=3p_doubleaxe_slash021recover,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.9,fBlendInTime=0.10,fBlendOutTime=0.1,bLastAnimation=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	RecoveryAnimations(2)=(AnimationName=3p_doubleaxe_stabrecover,ComboAnimation=3p_doubleaxe_stabrecover,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.75,fBlendInTime=0.10,fBlendOutTime=0.1,bLastAnimation=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	RecoveryAnimations(3)=(AnimationName=3p_doubleaxe_sattackrecover,ComboAnimation=,AssociatedSoundCue=,bFullBody=true,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=true,bUseAltBoneBranch=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	RecoveryAnimations(4)=(AnimationName=3p_doubleaxe_parryrecover,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.5,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	RecoveryAnimations(5)=(AnimationName=3p_doubleaxe_shoverecover,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.4,fBlendInTime=0.10,fBlendOutTime=0.1,bLastAnimation=true,bUseAltNode=true,bUseAltBoneBranch=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	RecoveryAnimations(6)=(AnimationName=,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	RecoveryAnimations(7)=(AnimationName=,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	RecoveryAnimations(8)=(AnimationName=,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	RecoveryAnimations(9)=(AnimationName=,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	StateAnimations(0)=(AnimationName=3p_doubleaxe_parried,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.85,fBlendInTime=0.00,fBlendOutTime=0.08,bLastAnimation=true)
	StateAnimations(1)=(AnimationName=3p_doubleaxe_dazed,ComboAnimation=,AssociatedSoundCue=,bFullBody=true,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.2,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	StateAnimations(2)=(AnimationName=3p_doubleaxe_hitFR,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.9,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	StateAnimations(3)=(AnimationName=3p_doubleaxe_hitFL,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.9,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	StateAnimations(4)=(AnimationName=3p_doubleaxe_hitBL,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.4,fBlendInTime=0.00,fBlendOutTime=0.08,bLastAnimation=false)
	BattleCryAnim=(AnimationName=3p_doubleaxe_battlecry,ComboAnimation=,AssociatedSoundCue=,bFullBody=true,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=0.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	TransitionAnimations(0)=(AnimationName=3p_doubleaxe_slash011downtoup,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.7,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	TransitionAnimations(1)=(AnimationName=3p_doubleaxe_slash02toslash011,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.7,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	TransitionAnimations(2)=(AnimationName=3p_doubleaxe_slash011toslash01,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.7,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	TransitionAnimations(3)=(AnimationName=3p_doubleaxe_slash021toslash01,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.7,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	TransitionAnimations(4)=(AnimationName=3p_doubleaxe_stabtoslash01,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.7,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	TransitionAnimations(5)=(AnimationName=3p_doubleaxe_slash01toslash021,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.7,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	TransitionAnimations(6)=(AnimationName=3p_doubleaxe_slash021downtoup,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.7,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	TransitionAnimations(7)=(AnimationName=3p_doubleaxe_slash011toslash02,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.7,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	TransitionAnimations(8)=(AnimationName=3p_doubleaxe_slash021toslash02,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.7,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	TransitionAnimations(9)=(AnimationName=3p_doubleaxe_stabtoslash02,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.7,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	TransitionAnimations(10)=(AnimationName=3p_doubleaxe_slash01tostab,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.7,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	TransitionAnimations(11)=(AnimationName=3p_doubleaxe_slash011tostab,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.7,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	TransitionAnimations(12)=(AnimationName=3p_doubleaxe_slash02tostab,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.7,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	TransitionAnimations(13)=(AnimationName=3p_doubleaxe_slash021tostab,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.7,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	TransitionAnimations(14)=(AnimationName=THIS_LINE_IS_UNUSED,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.625,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	TransitionAnimations(15)=(AnimationName=3p_doubleaxe_slash01toparry,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.125,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	TransitionAnimations(16)=(AnimationName=3p_doubleaxe_slash011toparry,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.125,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	TransitionAnimations(17)=(AnimationName=3p_doubleaxe_slash02toparry,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.125,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	TransitionAnimations(18)=(AnimationName=3p_doubleaxe_slash021toparry,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.125,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	TransitionAnimations(19)=(AnimationName=3p_doubleaxe_stabtoparry,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.125,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	//OtherParryAnimations(0)=(AnimationName=3p_doubleaxe_parried,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.2,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true,bUseAltNode=true)
	//OtherParryAnimations(1)=(AnimationName=3p_doubleaxe_parried,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.2,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true,bUseAltNode=true)
	ShieldIdleAnim=(AnimationName=3p_buckler_parryupidle,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=true,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=false)
	TurnInfo(0)=(AnimationName=3p_doubleaxe_turnL,ComboAnimation=,AssociatedSoundCue=,bFullBody=true,bCombo=false,bLoop=true,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=false,bLowerBody=true)
	TurnInfo(1)=(AnimationName=3p_doubleaxe_turnR,ComboAnimation=,AssociatedSoundCue=,bFullBody=true,bCombo=false,bLoop=true,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.0,fBlendInTime=0.00,fBlendOutTime=0.0,bLastAnimation=false)
	DazedAnimations(0)=(AnimationName=3p_doubleaxe_dazedB01_new,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=1.1,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	DazedAnimations(1)=(AnimationName=3p_doubleaxe_dazedL01_new,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=1.1,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	DazedAnimations(2)=(AnimationName=3p_doubleaxe_dazedF01_new,AlternateAnimation=3p_doubleaxe_parrydazed,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=1.1,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	DazedAnimations(3)=(AnimationName=3p_doubleaxe_dazedR01_new,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=1.1,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	DazedAnimations(4)=(AnimationName=3p_doubleaxe_dazedBL,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=1.1,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	DazedAnimations(5)=(AnimationName=3p_doubleaxe_dazedBR,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=1.1,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	DazedAnimations(6)=(AnimationName=3p_doubleaxe_dazedFL,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=1.1,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	DazedAnimations(7)=(AnimationName=3p_doubleaxe_dazedFR,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=1.1,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true)
	DirHitAnimation(0)=(AnimationName=ADD_3p_doubleaxe_hitFL,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.4,fBlendInTime=0.00,fBlendOutTime=0.1,bLastAnimation=false,bUseSlotSystem=true)
	DirHitAnimation(1)=(AnimationName=ADD_3p_doubleaxe_hitFR,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.4,fBlendInTime=0.00,fBlendOutTime=0.1,bLastAnimation=false,bUseSlotSystem=true)
	DirHitAnimation(2)=(AnimationName=ADD_3p_doubleaxe_hitBL,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.4,fBlendInTime=0.00,fBlendOutTime=0.1,bLastAnimation=false,bUseSlotSystem=true)
	DirHitAnimation(3)=(AnimationName=ADD_3p_doubleaxe_hitBR,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.4,fBlendInTime=0.00,fBlendOutTime=0.1,bLastAnimation=false,bUseSlotSystem=true)
	DirParryHitAnimations(0)=(AnimationName=3p_doubleaxe_parryhitL,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.3,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true,bUseAltNode=true)
	DirParryHitAnimations(1)=(AnimationName=3p_doubleaxe_parryhitR,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.3,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true,bUseAltNode=true)
	DirParryHitAnimations(2)=(AnimationName=3p_doubleaxe_parryhitH,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.3,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true,bUseAltNode=true)
	DirParryHitAnimations(3)=(AnimationName=3p_doubleaxe_parryhitS,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.3,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true,bUseAltNode=true)
	AlternateRecoveryAnimations(0)=(AnimationName=3p_doubleaxe_dazedB01_new,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.9,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	AlternateRecoveryAnimations(1)=(AnimationName=3p_doubleaxe_dazedB01_new,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.9,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	AlternateRecoveryAnimations(2)=(AnimationName=3p_doubleaxe_dazedB01_new,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.9,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	AlternateRecoveryAnimations(3)=(AnimationName=3p_doubleaxe_dazedB01_new,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.9,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	AlternateRecoveryAnimations(4)=(AnimationName=3p_doubleaxe_dazedB01_new,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.9,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	AlternateRecoveryAnimations(5)=(AnimationName=3p_doubleaxe_dazedB01_new,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.9,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	AlternateRecoveryAnimations(6)=(AnimationName=3p_doubleaxe_dazedB01_new,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.9,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	AlternateRecoveryAnimations(7)=(AnimationName=3p_doubleaxe_dazedB01_new,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.9,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	AlternateRecoveryAnimations(8)=(AnimationName=3p_doubleaxe_dazedB01_new,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.9,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	AlternateRecoveryAnimations(9)=(AnimationName=3p_doubleaxe_dazedB01_new,ComboAnimation=,AssociatedSoundCue=,bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.9,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=true, fShieldAnimLength=0, fBlendListNodeTime=0.15, bAttachArrow=2, StartTime=0)
	//Executions:
	//0 - Front
	//1 - Back
	//2 - Front (attacker has shield equipped)
	//3 - Back (attacker has shield equipped)
	ExecuterAnimations(0)=(AnimationName=3p_doubleaxe_executorF,ComboAnimation=,AssociatedSoundCue=,bFullBody=True,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=0.0,fAnimationLength=0.0,fBlendInTime=0.0,fBlendOutTime=0.00,bLastAnimation=false,fShieldAnimLength=0.0,bUseSlotSystem=True)
	ExecuterAnimations(1)=(AnimationName=3p_doubleaxe_executorB,ComboAnimation=,AssociatedSoundCue=,bFullBody=True,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=0.0,fAnimationLength=0.0,fBlendInTime=0.0,fBlendOutTime=0.00,bLastAnimation=false,fShieldAnimLength=0.0,bUseSlotSystem=True)
	ExecuterAnimations(2)=(AnimationName=3p_doubleaxe_executorF,ComboAnimation=,AssociatedSoundCue=,bFullBody=True,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=0.0,fAnimationLength=0.0,fBlendInTime=0.0,fBlendOutTime=0.00,bLastAnimation=false,fShieldAnimLength=0.0,bUseSlotSystem=True)
	ExecuterAnimations(3)=(AnimationName=3p_doubleaxe_executorB,ComboAnimation=,AssociatedSoundCue=,bFullBody=True,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=0.0,fAnimationLength=0.0,fBlendInTime=0.0,fBlendOutTime=0.00,bLastAnimation=false,fShieldAnimLength=0.0,bUseSlotSystem=True)
	ExecuteeAnimations(0)=(AnimationName=3p_death_doubleaxeFdeath,ComboAnimation=,AssociatedSoundCue=,bFullBody=True,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=0.0,fAnimationLength=0.0,fBlendInTime=0.0,fBlendOutTime=0.00,bLastAnimation=false,fShieldAnimLength=0.0,bUseSlotSystem=True)
	ExecuteeAnimations(1)=(AnimationName=3p_death_doubleaxeBdeath,ComboAnimation=,AssociatedSoundCue=,bFullBody=True,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=0.0,fAnimationLength=0.0,fBlendInTime=0.0,fBlendOutTime=0.00,bLastAnimation=false,fShieldAnimLength=0.0,bUseSlotSystem=True)
	ExecuteeAnimations(2)=(AnimationName=3p_death_doubleaxeFdeath,ComboAnimation=,AssociatedSoundCue=,bFullBody=True,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=0.0,fAnimationLength=0.0,fBlendInTime=0.0,fBlendOutTime=0.00,bLastAnimation=false,fShieldAnimLength=0.0,bUseSlotSystem=True)
	ExecuteeAnimations(3)=(AnimationName=3p_death_doubleaxeBdeath,ComboAnimation=,AssociatedSoundCue=,bFullBody=True,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=0.0,fAnimationLength=0.0,fBlendInTime=0.0,fBlendOutTime=0.00,bLastAnimation=false,fShieldAnimLength=0.0,bUseSlotSystem=True)

	// Mercenaries 1.996 numeric weapon values (Workshop 705710406).
	SpecialDazeLength=1.8
	ShieldStaminaDrainDelay=4
	QuickKickWindow=0.35
	EndFeintWindowTime=0.15
	EndFeintWindowTimeCombo=0.25
	FlinchTime1H=0.8
	bCanSprint=true
	bCanDodge=true
	LimitSprintSpeed=1
	iComboFeintStaminaCost=15
	ComboFeintTime=0.5
	StrafeModify=-1
	BackModify=-1
	ForwardModify=-1
	CrouchModify=-1
	fLungeSpeedMultiplier=1.3
	fLungeSpeedZ=150
	fForwardMovementInRelease=-1
	InventoryWeight=2
	ComboToParryStaminaCost=5
	ComboToParryBlendTime=0.15
	SprintAttackLunge=500
	SprintAttackLungeZ=250
	bCanParry=true
	bCanCombo=true
}
