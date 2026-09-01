/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
*
* Original Author: Michael Bao
*
* Weapon attachment: Katana (2H) - Mirrors Longsword values, uses DWKatana mesh
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

    return (HandleLength / WeaponLength);
}

DefaultProperties
{
	`include(BangMod/Include/BangModWeaponAttachment.uci);

KickOffset=(X=50, Y=0, Z=-65)
	KickSize=20.f

	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'DWKatana.WEP_DWKatana'
		Scale=0.95
	End Object

	Begin Object Name=SkeletalMeshComponent2
		SkeletalMesh=SkeletalMesh'DWKatana.WEP_DWKatana'
		Scale=0.95
	End Object

	WeaponID=EWEP_Longsword
	WeaponClass=class'BangModWeapon_Katana'
	WeaponSocket=wep2hpoint

	bUseAlternativeKick=true
			
	AttackTypeInfo(0)=(fBaseDamage=90.0, fForce=24000, cDamageType="AOC.AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(1)=(fBaseDamage=90.0, fForce=24000, cDamageType="AOC.AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(2)=(fBaseDamage=40.0, fForce=24000, cDamageType="AOC.AOCDmgType_Pierce", iWorldHitLenience=6)
	AttackTypeInfo(3)=(fBaseDamage=0.0, fForce=22500, cDamageType="AOC.AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(4)=(fBaseDamage=0.0, fForce=32500, cDamageType="AOC.AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(5)=(fBaseDamage=5.0, fForce=45500.0, cDamageType="AOC.AOCDmgType_Shove", iWorldHitLenience=12)

	

WeaponStaticMeshScale=0.95

Skins(0)={(
SkeletalMeshPath="DWKatana.WEP_DWKatana",
StaticMeshPath="DWKatana.SM_DWKatana",
MaterialPath="",
StaticMeshScale=0.95,
ImagePath="UI_WeaponImages_SWF.weapon_select_longsword"
)};
Skins(1)={(
SkeletalMeshPath="DWKatana.WEP_DWKatana",
StaticMeshPath="DWKatana.SM_DWKatana",
MaterialPath="",
StaticMeshScale=0.95,
ImagePath="UI_WeaponImages_SWF.weapon_select_longsword"
)};
Skins(2)={(
SkeletalMeshPath="DWKatana.WEP_DWKatana",
StaticMeshPath="DWKatana.SM_DWKatana",
MaterialPath="",
StaticMeshScale=0.95,
ImagePath="UI_WeaponImages_SWF.weapon_select_longsword"
)};
Skins(3)={(
SkeletalMeshPath="DWKatana.WEP_DWKatana",
StaticMeshPath="DWKatana.SM_DWKatana",
MaterialPath="",
StaticMeshScale=0.95,
ImagePath="UI_WeaponImages_SWF.weapon_select_longsword"
)};
Skins(4)={(
SkeletalMeshPath="DWKatana.WEP_DWKatana",
StaticMeshPath="DWKatana.SM_DWKatana",
MaterialPath="",
StaticMeshScale=0.95,
ImagePath="UI_WeaponImages_SWF.weapon_select_longsword"
)};
Skins(5)={(
SkeletalMeshPath="DWKatana.WEP_DWKatana",
StaticMeshPath="DWKatana.SM_DWKatana",
MaterialPath="",
StaticMeshScale=0.95,
ImagePath="UI_WeaponImages_SWF.weapon_select_longsword"
)};
Skins(6)={(
SkeletalMeshPath="DWKatana.WEP_DWKatana",
StaticMeshPath="DWKatana.SM_DWKatana",
MaterialPath="",
StaticMeshScale=0.95,
ImagePath="UI_WeaponImages_SWF.weapon_select_longsword"
)};
Skins(7)={(
SkeletalMeshPath="DWKatana.WEP_DWKatana",
StaticMeshPath="DWKatana.SM_DWKatana",
MaterialPath="",
StaticMeshScale=0.95,
ImagePath="UI_WeaponImages_SWF.weapon_select_longsword"
)};
Skins(8)={(
SkeletalMeshPath="DWKatana.WEP_DWKatana",
StaticMeshPath="DWKatana.SM_DWKatana",
MaterialPath="",
StaticMeshScale=0.95,
ImagePath="UI_WeaponImages_SWF.weapon_select_longsword"
)};
Skins(9)={(
SkeletalMeshPath="DWKatana.WEP_DWKatana",
StaticMeshPath="DWKatana.SM_DWKatana",
MaterialPath="",
StaticMeshScale=0.95,
ImagePath="UI_WeaponImages_SWF.weapon_select_longsword"
)};
Skins(10)={(
SkeletalMeshPath="DWKatana.WEP_DWKatana",
StaticMeshPath="DWKatana.SM_DWKatana",
MaterialPath="",
StaticMeshScale=0.95,
ImagePath="UI_WeaponImages_SWF.weapon_select_longsword"
)};
}
