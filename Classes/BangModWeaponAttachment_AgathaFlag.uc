/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
*
* Original Author: Michael Bao
*
* BangMod Weapon Attachment: Agatha Flag
*/
class BangModWeaponAttachment_AgathaFlag extends AOCWeaponAttachment_AgathaFlag;

DefaultProperties
{
	// Override WeaponClass to point to BangMod version
	WeaponClass=class'BangModWeapon_AgathaFlag'

	// Scale down by 30% (same pattern as SpikedMace scale-up)
	Begin Object Name=SkeletalMeshComponent0
		Scale=0.82
	End Object

	Begin Object Name=SkeletalMeshComponent2
		Scale=0.82
	End Object

	WeaponStaticMeshScale=0.82

	Skins(0)={(
		SkeletalMeshPath="chv_flags.WEP_A_Flag",
		StaticMeshPath="WP_spr_Spear.sm_spear",
		MaterialPath="",
		StaticMeshScale=0.82,
		ImagePath="UI_CustWeaponImages_SWF.skin_bardiche_png"
		)};
}
