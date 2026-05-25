/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
*
* Original Author: Michael Bao
*
* Weapon attachment: Spiked Mace - Bastard Sword behavior with scaled Holy Water Sprinkler visuals
*/
class BangModWeaponAttachment_SpikedMace extends BangModWeaponAttachment_BastardSword;

simulated function float GetHandleTracerPercent(int i)
{
	local vector vStart, vMid, vEnd;
	local float HandleLength, WeaponLength;
	local float HandleTracerPercent;

	if (Mesh.GetSocketByName('TraceMid') == None)
	{
		return 0.30f;
	}
	Mesh.GetSocketWorldLocationAndRotation('TraceStart', vStart);
	Mesh.GetSocketWorldLocationAndRotation('TraceMid', vMid);
	Mesh.GetSocketWorldLocationAndRotation('TraceEnd', vEnd);

	WeaponLength = VSize(vEnd - vStart);
	HandleLength = VSize(vMid - vStart);
	HandleTracerPercent = (HandleLength / WeaponLength);

	if (HandleTracerPercent < 0.30f)
	{
		return 0.30f;
	}

	return HandleTracerPercent;
}

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

	AttackTypeInfo(0)=(fBaseDamage=70.0, fForce=20000, cDamageType="AOC.AOCDmgType_Blunt", iWorldHitLenience=6)
	AttackTypeInfo(1)=(fBaseDamage=75.0, fForce=20000, cDamageType="AOC.AOCDmgType_Blunt", iWorldHitLenience=6)
	AttackTypeInfo(2)=(fBaseDamage=30.0, fForce=22500, cDamageType="AOC.AOCDmgType_PierceBlunt", iWorldHitLenience=6)
	AttackTypeInfo(3)=(fBaseDamage=0.0, fForce=22500, cDamageType="AOC.AOCDmgType_Blunt", iWorldHitLenience=6)
	AttackTypeInfo(4)=(fBaseDamage=0.0, fForce=32500, cDamageType="AOC.AOCDmgType_Blunt", iWorldHitLenience=6)
	AttackTypeInfo(5)=(fBaseDamage=5.0, fForce=45500.0, cDamageType="AOC.AOCDmgType_Shove", iWorldHitLenience=12)

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