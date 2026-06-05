/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
*
* Original Author: Michael Bao
*
* Weapon attachment: Bastard Sword - Longsword behavior with scaled broadsword visuals
*/
class BangModWeaponAttachment_BastardSword extends BangModWeaponAttachment_Katana;

simulated function float GetHandleTracerPercent(int i)
{
    local vector vStart, vMid, vEnd;
	local float HandleLength, WeaponLength;
	local float HandleTracerPercent;

    if (Mesh.GetSocketByName('TraceMid') == None)
    {
		return 0.34f;
    }
    Mesh.GetSocketWorldLocationAndRotation('TraceStart', vStart);
    Mesh.GetSocketWorldLocationAndRotation('TraceMid', vMid);
    Mesh.GetSocketWorldLocationAndRotation('TraceEnd', vEnd);

    WeaponLength = VSize(vEnd - vStart);
    HandleLength = VSize(vMid - vStart);
	HandleTracerPercent = (HandleLength / WeaponLength);

	if (HandleTracerPercent < 0.34f)
	{
		return 0.34f;
	}

	return HandleTracerPercent;
}

DefaultProperties
{
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'WP_1hs_Broadsword.WEP_Broadsword'
		Scale=1.2
	End Object

	Begin Object Name=SkeletalMeshComponent2
		SkeletalMesh=SkeletalMesh'WP_1hs_Broadsword.WEP_Broadsword'
		Scale=1.2
	End Object

	WeaponID=EWEP_Broadsword
	WeaponClass=class'BangModWeapon_BastardSword'
	WeaponSocket=wep2hpoint
	WeaponStaticMeshScale=1.2
	bUseAlternativeKick=true

	AttackTypeInfo(0)=(fBaseDamage=65.0, fForce=30000, cDamageType="AOC.AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(1)=(fBaseDamage=70.0, fForce=30000, cDamageType="AOC.AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(2)=(fBaseDamage=68.0, fForce=30000, cDamageType="AOC.AOCDmgType_Pierce", iWorldHitLenience=6)
	AttackTypeInfo(3)=(fBaseDamage=0.0, fForce=22500, cDamageType="AOC.AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(4)=(fBaseDamage=0.0, fForce=32500, cDamageType="AOC.AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(5)=(fBaseDamage=5.0, fForce=45500.0, cDamageType="AOC.AOCDmgType_Shove", iWorldHitLenience=12)

	Skins(0)={(
		SkeletalMeshPath="WP_1hs_Broadsword.WEP_Broadsword",
		StaticMeshPath="WP_1hs_Broadsword.sm_Broadsword",
		MaterialPath="",
		StaticMeshScale=1.2,
		ImagePath="UI_CustWeaponImages_SWF.skin_broadsword_png"
		)};

	Skins(1)={(
		SkeletalMeshPath="WP_1hs_Broadsword.WEP_Broadsword",
		StaticMeshPath="WP_1hs_Broadsword.sm_Broadsword",
		MaterialPath="",
		StaticMeshScale=1.2,
		ImagePath="UI_CustWeaponImages_SWF.skin_broadsword_png"
		)};

	Skins(2)={(
		SkeletalMeshPath="WP_1hs_Broadsword.WEP_Broadsword",
		StaticMeshPath="WP_1hs_Broadsword.sm_Broadsword",
		MaterialPath="",
		StaticMeshScale=1.2,
		ImagePath="UI_CustWeaponImages_SWF.skin_broadsword_png"
		)};

	Skins(3)={(
		SkeletalMeshPath="WP_1hs_Broadsword.WEP_Broadsword",
		StaticMeshPath="WP_1hs_Broadsword.sm_Broadsword",
		MaterialPath="",
		StaticMeshScale=1.2,
		ImagePath="UI_CustWeaponImages_SWF.skin_broadsword_png"
		)};

	Skins(4)={(
		SkeletalMeshPath="WP_1hs_Broadsword.WEP_Broadsword",
		StaticMeshPath="WP_1hs_Broadsword.sm_Broadsword",
		MaterialPath="",
		StaticMeshScale=1.2,
		ImagePath="UI_CustWeaponImages_SWF.skin_broadsword_png"
		)};

	Skins(5)={(
		SkeletalMeshPath="WP_1hs_Broadsword.WEP_Broadsword",
		StaticMeshPath="WP_1hs_Broadsword.sm_Broadsword",
		MaterialPath="",
		StaticMeshScale=1.2,
		ImagePath="UI_CustWeaponImages_SWF.skin_broadsword_png"
		)};

	Skins(6)={(
		SkeletalMeshPath="WP_1hs_Broadsword.WEP_Broadsword",
		StaticMeshPath="WP_1hs_Broadsword.sm_Broadsword",
		MaterialPath="",
		StaticMeshScale=1.2,
		ImagePath="UI_CustWeaponImages_SWF.skin_broadsword_png"
		)};

	Skins(7)={(
		SkeletalMeshPath="WP_1hs_Broadsword.WEP_Broadsword",
		StaticMeshPath="WP_1hs_Broadsword.sm_Broadsword",
		MaterialPath="",
		StaticMeshScale=1.2,
		ImagePath="UI_CustWeaponImages_SWF.skin_broadsword_png"
		)};

	Skins(8)={(
		SkeletalMeshPath="WP_1hs_Broadsword.WEP_Broadsword",
		StaticMeshPath="WP_1hs_Broadsword.sm_Broadsword",
		MaterialPath="",
		StaticMeshScale=1.2,
		ImagePath="UI_CustWeaponImages_SWF.skin_broadsword_png"
		)};

	Skins(9)={(
		SkeletalMeshPath="WP_1hs_Broadsword.WEP_Broadsword",
		StaticMeshPath="WP_1hs_Broadsword.sm_Broadsword",
		MaterialPath="",
		StaticMeshScale=1.2,
		ImagePath="UI_CustWeaponImages_SWF.skin_broadsword_png"
		)};
}