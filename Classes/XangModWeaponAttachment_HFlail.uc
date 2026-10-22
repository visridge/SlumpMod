/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
*
* The weapon that is replicated to all clients: Heavy Flail.
*/
class XangModWeaponAttachment_HFlail extends AOCWeaponAttachment_HFlail;

// Parry-box + netcode overrides. MUST be at class level - see the file header.
`include(XangMod/Include/XangModWeaponAttachmentCode.uci)

DefaultProperties
{
	`include(XangMod/Include/XangModWeaponAttachment.uci);

	Begin Object Name=SkeletalMeshComponent0
		Scale=1.4
	End Object

	Begin Object Name=SkeletalMeshComponent2
		Scale=1.4
	End Object

	WeaponClass=class'XangModWeapon_HFlail'

	WeaponStaticMeshScale=1.4

	Skins(0)={(
		SkeletalMeshPath="WP_DL1_Flail.WEP_H-Flail",
		StaticMeshPath="WP_DL1_Flail.SM_H-Flail",
		MaterialPath="",
		StaticMeshScale=1.4,
		ImagePath="ui_custweaponimages_swf.skin_flail_png"
		)};

	Skins(1)={(
		SkeletalMeshPath="WP_DL1_Flail_Variant_01.WEP_RatFlail",
		StaticMeshPath="WP_DL1_Flail_Variant_01.SM_RatFlail",
		MaterialPath="",
		StaticMeshScale=1.4,
		ImagePath="ui_custweaponimages_swf.skin_rat_flail_png"
		)};

	// Mercenaries 1.996 numeric weapon values (Workshop 705710406).
	KickSize=20
	ParryTracersLength=50
	WeaponWidth=4
	WeaponNumTracers=1
	ParryCheckTraceInc=1
	AttackTypeInfo(0)=(fBaseDamage=70, fForce=22500, cDamageType="AOCDmgType_Blunt", iWorldHitLenience=6)
	AttackTypeInfo(1)=(fBaseDamage=75, fForce=22500, cDamageType="AOCDmgType_Blunt", iWorldHitLenience=6)
	AttackTypeInfo(2)=(fBaseDamage=35, fForce=22500, cDamageType="AOCDmgType_Blunt", iWorldHitLenience=6)
	AttackTypeInfo(3)=(fBaseDamage=0, fForce=22500, cDamageType="AOCDmgType_Blunt", iWorldHitLenience=6)
	AttackTypeInfo(4)=(fBaseDamage=0, fForce=22500, cDamageType="AOCDmgType_Blunt", iWorldHitLenience=6)
	AttackTypeInfo(5)=(fBaseDamage=5, fForce=45500, cDamageType="AOCDmgType_Shove", iWorldHitLenience=12)
}
