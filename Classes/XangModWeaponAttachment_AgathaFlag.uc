/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
*
* Original Author: Michael Bao
*
* XangMod Weapon Attachment: Agatha Flag
*/
class XangModWeaponAttachment_AgathaFlag extends AOCWeaponAttachment_AgathaFlag;

DefaultProperties
{
	// Override WeaponClass to point to XangMod version
	WeaponClass=class'XangModWeapon_AgathaFlag'

	// Scale down by 30% (same pattern as SpikedMace scale-up)
	Begin Object Name=SkeletalMeshComponent0
		Scale=0.80
	End Object

	Begin Object Name=SkeletalMeshComponent2
		Scale=0.80
	End Object

	WeaponStaticMeshScale=0.80

	Skins(0)={(
		SkeletalMeshPath="chv_flags.WEP_A_Flag",
		StaticMeshPath="WP_spr_Spear.sm_spear",
		MaterialPath="",
		StaticMeshScale=0.80,
		ImagePath="UI_CustWeaponImages_SWF.skin_bardiche_png"
		)};
}
