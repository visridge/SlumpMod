/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
*
* Original Author: Michael Bao
*
* Weapon attachment: Spiked Mace - Bastard Sword behavior with scaled Holy Water Sprinkler visuals
*/
class BangModWeaponAttachment_SpikedMace extends BangModWeaponAttachment_BastardSword;

DefaultProperties
{
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'WP_1hb_HWS_Variant_02.WEP_HWS_v02'
		Scale=2.0
	End Object

	Begin Object Name=SkeletalMeshComponent2
		SkeletalMesh=SkeletalMesh'WP_1hb_HWS_Variant_02.WEP_HWS_v02'
		Scale=2.0
	End Object

	WeaponID=EWEP_HolyWaterSprinkler
	WeaponClass=class'BangModWeapon_SpikedMace'
	WeaponSocket=wep2hpoint
	WeaponStaticMeshScale=2.0

	Skins(0)={(
		SkeletalMeshPath="WP_1hb_HWS_Variant_02.WEP_HWS_v02",
		StaticMeshPath="WP_1hb_HWS_Variant_02.SM_HWS_v02",
		MaterialPath="",
		StaticMeshScale=2.0,
		ImagePath="ui_custweaponimages_swf.skin_holywater_sprinkler_png"
		)};

	Skins(1)={(
		SkeletalMeshPath="WP_1hb_HWS_Variant_02.WEP_HWS_v02",
		StaticMeshPath="WP_1hb_HWS_Variant_02.SM_HWS_v02",
		MaterialPath="",
		StaticMeshScale=2.0,
		ImagePath="ui_custweaponimages_swf.skin_holywater_sprinkler_png"
		)};

	Skins(2)={(
		SkeletalMeshPath="WP_1hb_HWS_Variant_02.WEP_HWS_v02",
		StaticMeshPath="WP_1hb_HWS_Variant_02.SM_HWS_v02",
		MaterialPath="",
		StaticMeshScale=2.0,
		ImagePath="ui_custweaponimages_swf.skin_holywater_sprinkler_png"
		)};
}