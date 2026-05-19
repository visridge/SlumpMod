/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
*
* Original Author: Michael Bao
*
* Weapon attachment: Gladius - Bastard Sword behavior with scaled shortsword visuals
*/
class BangModWeaponAttachment_Gladius extends BangModWeaponAttachment_BastardSword;

DefaultProperties
{
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'WP_aux_Shortsword.wep_shortsword'
		Scale=2.0
	End Object

	Begin Object Name=SkeletalMeshComponent2
		SkeletalMesh=SkeletalMesh'WP_aux_Shortsword.wep_shortsword'
		Scale=2.0
	End Object

	WeaponID=EWEP_Dagesse
	WeaponClass=class'BangModWeapon_Gladius'
	WeaponSocket=wep2hpoint
	WeaponStaticMeshScale=2.0

	Skins(0)={(
		SkeletalMeshPath="WP_aux_Shortsword.wep_shortsword",
		StaticMeshPath="WP_aux_Shortsword.SM_Short_Sword",
		MaterialPath="",
		StaticMeshScale=2.0,
		ImagePath="ui_custweaponimages_swf.skin_shortsword_png"
		)};

	Skins(1)={(
		SkeletalMeshPath="WP_aux_Shortsword_Variant_01.wep_shortsword_variant_01",
		StaticMeshPath="WP_aux_Shortsword_Variant_01.SM_Shortsword_Variant_01",
		MaterialPath="",
		StaticMeshScale=2.0,
		ImagePath="ui_custweaponimages_swf.skin_seax_png"
		)};
}