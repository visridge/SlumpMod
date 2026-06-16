/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
*
* Original Author: Michael Bao
*
* Weapon: Spiked Mace - Bastard Sword gameplay with scaled Holy Water Sprinkler visuals
*/
class BangModWeapon_SpikedMace extends BangModWeapon_Zweihander;

DefaultProperties
{
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

	ParriedSound=SoundCue'A_Phys_Mat_Impacts.Mace_Blocked'
	ParrySound=SoundCue'A_Phys_Mat_Impacts.Mace_Blocking'

	WindupAnimations(4)=(AnimationName=3p_longsword_parryib,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.mace_Parry',bFullBody=False,bCombo=False,bLoop=False,bForce=false,fModifiedMovement=1.0,fAnimationLength=0.5,fBlendInTime=0.00,fBlendOutTime=0.00,bLastAnimation=false,bUseAltNode=true)
	ReleaseAnimations(0)=(AnimationName=3p_longsword_slash01release,ComboAnimation=3p_longsword_slash011release,AlternateAnimation=3p_longsword_slash011release,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.mace_attack_01',bFullBody=true,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.525,fBlendInTime=0.0,fBlendOutTime=0.0,bLastAnimation=false)
	ReleaseAnimations(1)=(AnimationName=3p_longsword_slash02release,ComboAnimation=3p_longsword_slash021release,AlternateAnimation=3p_longsword_slash021release,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.mace_Attack_02',bFullBody=true,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.525,fBlendInTime=0.0,fBlendOutTime=0.0,bLastAnimation=false)
	ReleaseAnimations(2)=(AnimationName=3p_longsword_stabrelease,ComboAnimation=3p_longsword_stabrelease,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.mace_Attack_03',bFullBody=true,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.4,fBlendInTime=0.0,fBlendOutTime=0.0,bLastAnimation=false)
	ReleaseAnimations(3)=(AnimationName=3p_longsword_sattackrelease,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.mace_sprint_attack',bFullBody=True,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.7,fBlendInTime=0.1,fBlendOutTime=0.1,bLastAnimation=false,bUseAltBoneBranch=true)
	ReleaseAnimations(4)=(AnimationName=3p_longsword_parryup,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.mace_Parry',bFullBody=False,bCombo=False,bLoop=False,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.5,fBlendInTime=0.0,fBlendOutTime=0.00,bLastAnimation=false,bUseAltNode=true)
	ReleaseAnimations(8)=(AnimationName=3p_longsword_equipup,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.mace_draw',bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.5,fBlendInTime=0.00,fBlendOutTime=0.01,bLastAnimation=false)
	ReleaseAnimations(9)=(AnimationName=3p_longsword_equipdown,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.mace_sheath',bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=1.0,fAnimationLength=0.5,fBlendInTime=0.00,fBlendOutTime=0.01,bLastAnimation=false)

	AttachmentClass=class'BangModWeaponAttachment_SpikedMace'
	InventoryAttachmentClass=class'AOCInventoryAttachment_HolyWaterSprinkler'
	CurrentWeaponType=EWEP_HolyWaterSprinkler
	WeaponName="Spiked Mace"
	WeaponFontSymbol="B"
	WeaponLargePortrait="UI_WeaponImages_SWF.weapon_select_hws"
	WeaponSmallPortrait="UI_WeaponImages_SWF.icon_weapon_select_hws_png"

	FlinchTime2H=1.05
}