/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
*
* Original Author: Michael Bao
*
* Weapon attachment: Katana (2H) - Mirrors Longsword values, uses DW-WP_SamuraiKatana mesh
*/
class BangModWeaponAttachment_Katana extends AOCWeaponAttachment_Longsword;

simulated function float GetHandleTracerPercent(int i)
{
    local vector vStart, vMid, vEnd;
    local float HandleLength, WeaponLength;

    if (Mesh.GetSocketByName('TraceMid') == None)
    {
        return 0.0f;
    }
    Mesh.GetSocketWorldLocationAndRotation('TraceStart', vStart);
    Mesh.GetSocketWorldLocationAndRotation('TraceMid', vMid);
    Mesh.GetSocketWorldLocationAndRotation('TraceEnd', vEnd);

    WeaponLength = VSize(vEnd - vStart);
    HandleLength = VSize(vMid - vStart);

    return (HandleLength / WeaponLength)*3;
}

DefaultProperties
{
	`include(BangMod/Include/BangModWeaponAttachment.uci);

KickOffset=(X=50, Y=0, Z=-65)
	KickSize=20.f

	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'DW-WP_SamuraiKatana.WEP_sm_katana'
	End Object

	Begin Object Name=SkeletalMeshComponent2
		SkeletalMesh=SkeletalMesh'DW-WP_SamuraiKatana.WEP_sm_katana'
	End Object

	WeaponID=EWEP_Longsword
	WeaponClass=class'BangModWeapon_Katana'
	WeaponSocket=wep2hpoint

	bUseAlternativeKick=true
			
	AttackTypeInfo(0)=(fBaseDamage=79.0, fForce=24000, cDamageType="AOC.AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(1)=(fBaseDamage=86.0, fForce=24000, cDamageType="AOC.AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(2)=(fBaseDamage=64.0, fForce=24000, cDamageType="AOC.AOCDmgType_Pierce", iWorldHitLenience=6)
	AttackTypeInfo(3)=(fBaseDamage=0.0, fForce=22500, cDamageType="AOC.AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(4)=(fBaseDamage=0.0, fForce=32500, cDamageType="AOC.AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(5)=(fBaseDamage=5.0, fForce=45500.0, cDamageType="AOC.AOCDmgType_Shove", iWorldHitLenience=12)

	

WeaponStaticMeshScale=1

Skins(0)={(
SkeletalMeshPath="DW-WP_SamuraiKatana.WEP_sm_katana",
StaticMeshPath="DW-WP_SamuraiKatana.WEP_sm_katana",
MaterialPath="DW-WP_SamuraiKatana.Materials.M_katana",
StaticMeshScale=1.0,
ImagePath="UI_WeaponImages_SWF.weapon_select_longsword"
)};
Skins(1)={(
SkeletalMeshPath="DW-WP_SamuraiKatana.WEP_sm_katana",
StaticMeshPath="DW-WP_SamuraiKatana.WEP_sm_katana",
MaterialPath="DW-WP_SamuraiKatana.Materials.M_katana",
StaticMeshScale=1.0,
ImagePath="UI_WeaponImages_SWF.weapon_select_longsword"
)};
Skins(2)={(
SkeletalMeshPath="DW-WP_SamuraiKatana.WEP_sm_katana",
StaticMeshPath="DW-WP_SamuraiKatana.WEP_sm_katana",
MaterialPath="DW-WP_SamuraiKatana.Materials.M_katana",
StaticMeshScale=1.0,
ImagePath="UI_WeaponImages_SWF.weapon_select_longsword"
)};
Skins(3)={(
SkeletalMeshPath="DW-WP_SamuraiKatana.WEP_sm_katana",
StaticMeshPath="DW-WP_SamuraiKatana.WEP_sm_katana",
MaterialPath="DW-WP_SamuraiKatana.Materials.M_katana",
StaticMeshScale=1.0,
ImagePath="UI_WeaponImages_SWF.weapon_select_longsword"
)};
Skins(4)={(
SkeletalMeshPath="DW-WP_SamuraiKatana.WEP_sm_katana",
StaticMeshPath="DW-WP_SamuraiKatana.WEP_sm_katana",
MaterialPath="DW-WP_SamuraiKatana.Materials.M_katana",
StaticMeshScale=1.0,
ImagePath="UI_WeaponImages_SWF.weapon_select_longsword"
)};
}
