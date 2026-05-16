/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
*
* Original Author: Michael Bao
*
* Weapon attachment: Bastard Sword - Longsword behavior with scaled broadsword visuals
*/
class BangModWeaponAttachment_BastardSword extends BangModWeaponAttachment_Katana;

DefaultProperties
{
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'WP_1hs_Broadsword.WEP_Broadsword'
		Scale=1.3
	End Object

	Begin Object Name=SkeletalMeshComponent2
		SkeletalMesh=SkeletalMesh'WP_1hs_Broadsword.WEP_Broadsword'
		Scale=1.3
	End Object

	WeaponID=EWEP_Longsword
	WeaponClass=class'BangModWeapon_BastardSword'
	WeaponSocket=wep2hpoint
	WeaponStaticMeshScale=1.3

	Skins(0)={(
		SkeletalMeshPath="WP_1hs_Broadsword.WEP_Broadsword",
		StaticMeshPath="WP_1hs_Broadsword.sm_Broadsword",
		MaterialPath="",
		StaticMeshScale=1.3,
		ImagePath="UI_CustWeaponImages_SWF.skin_broadsword_png"
		)};

	Skins(1)={(
		SkeletalMeshPath="WP_1hs_Broadsword_variant_01.WEP_Broadsword",
		StaticMeshPath="WP_1hs_Broadsword_variant_01.sm_Broadsword",
		MaterialPath="",
		StaticMeshScale=1.3,
		ImagePath="UI_CustWeaponImages_SWF.skin_oriental_broadsword_png"
		)};

	Skins(2)={(
		SkeletalMeshPath="WP_1hs_Broadsword_Variant_02.sk_bsword2",
		StaticMeshPath="WP_1hs_Broadsword_Variant_02.sm_bsword2",
		MaterialPath="",
		StaticMeshScale=1.3,
		ImagePath="UI_CustWeaponImages_SWF.skin_temujins_broadsword_png"
		)};

	Skins(3)={(
		SkeletalMeshPath="WP_1hs_Broadsword_Variant_03.WEP_KinSlayer",
		StaticMeshPath="WP_1hs_Broadsword_Variant_03.SM_KinSlayer",
		MaterialPath="",
		StaticMeshScale=1.3,
		ImagePath="UI_CustWeaponImages_SWF.skin_kinslayer_png"
		)};

	Skins(4)={(
		SkeletalMeshPath="WP_1hs_Broadsword_Variant_04.WEP_Bohemiansword",
		StaticMeshPath="WP_1hs_Broadsword_Variant_04.SM_Bohemiansword",
		MaterialPath="",
		StaticMeshScale=1.3,
		ImagePath="ui_custweaponimages_swf.skin_bohemian_broadsword_png"
		)};

	Skins(5)={(
		SkeletalMeshPath="WP_1hs_Broadsword_Variant_06.WEP_Broadsword",
		StaticMeshPath="WP_1hs_Broadsword_Variant_06.sm_Broadsword",
		MaterialPath="",
		StaticMeshScale=1.3,
		ImagePath="ui_custweaponimages_swf.skin_ice_breaker_png"
		)};

	Skins(6)={(
		SkeletalMeshPath="WP_1hs_Broadsword_Variant_05.WEP_Tsword",
		StaticMeshPath="StaticMesh'WP_1hs_Broadsword_Variant_05.SM_Tsword'",
		MaterialPath="",
		StaticMeshScale=1.3,
		ImagePath="ui_custweaponimages_swf.skin_squire_trainer_png"
		)};

	Skins(7)={(
		SkeletalMeshPath="WP_1hs_Broadsword_Variant_07.WEP_XIIBroadsword",
		StaticMeshPath="WP_1hs_Broadsword_Variant_07.SM_XIIBroadsword",
		MaterialPath="",
		StaticMeshScale=1.3,
		ImagePath="ui_custweaponimages_swf.skin_xiibroadsword_png"
		)};
}