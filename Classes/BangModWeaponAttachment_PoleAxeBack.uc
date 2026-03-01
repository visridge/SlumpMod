/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
*
* Original Author: Michael Bao
*
* Weapon Attachment: Pole Arm.
*/
class BangModWeaponAttachment_PoleAxeBack extends AOCWeaponAttachment;

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

    return (HandleLength / WeaponLength)/2;
}

DefaultProperties
{

KickOffset=(X=50, Y=0, Z=-65)
	KickSize=20.f

	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'SlumpWep_PaxeBack.SlumpWep_PaxeBack'
	End Object

	Begin Object Name=SkeletalMeshComponent2
		SkeletalMesh=SkeletalMesh'SlumpWep_PaxeBack.SlumpWep_PaxeBack'
	End Object

	WeaponID=EWEP_PaxeBack
	WeaponClass=class'BangModWeapon_PoleAxeBack'

	WeaponSocket=wep2haxepoint
	bUseAlternativeKick=true

	WeaponStaticMeshScale=1

	AttackTypeInfo(0)=(fBaseDamage=70.0, fForce=26000, cDamageType="AOC.AOCDmgType_Blunt", iWorldHitLenience=6)
	AttackTypeInfo(1)=(fBaseDamage=90.0, fForce=26000, cDamageType="AOC.AOCDmgType_Blunt", iWorldHitLenience=6)
	AttackTypeInfo(2)=(fBaseDamage=80.0, fForce=26000, cDamageType="AOC.AOCDmgType_Pierce", iWorldHitLenience=6)
	AttackTypeInfo(3)=(fBaseDamage=0.0, fForce=22500, cDamageType="AOC.AOCDmgType_Blunt", iWorldHitLenience=6)
	AttackTypeInfo(4)=(fBaseDamage=0.0, fForce=35500, cDamageType="AOC.AOCDmgType_Blunt", iWorldHitLenience=6)
	AttackTypeInfo(5)=(fBaseDamage=5.0, fForce=45500.0, cDamageType="AOC.AOCDmgType_Shove", iWorldHitLenience=12)

	Skins(0)={(
		SkeletalMeshPath="SlumpWep_PaxeBack.SlumpWep_PaxeBack",
		StaticMeshPath="SlumpWep_PaxeBack.SlumpWep_PaxeBack_Mesh",
		MaterialPath="",
		StaticMeshScale=1.0,
		ImagePath="UI_CustWeaponImages_SWF.skin_bardiche_png"
		)};
	Skins(1)={(
		SkeletalMeshPath="SlumpWep_PaxeBack.SlumpWep_PaxeBack",
		StaticMeshPath="SlumpWep_PaxeBack.SlumpWep_PaxeBack_Mesh",
		MaterialPath="",
		StaticMeshScale=1.0,
		ImagePath="UI_CustWeaponImages_SWF.skin_bardiche_png"
		)};
	Skins(2)={(
		SkeletalMeshPath="SlumpWep_PaxeBack.SlumpWep_PaxeBack",
		StaticMeshPath="SlumpWep_PaxeBack.SlumpWep_PaxeBack_Mesh",
		MaterialPath="",
		StaticMeshScale=1.0,
		ImagePath="UI_CustWeaponImages_SWF.skin_bardiche_png"
		)};
	Skins(3)={(
		SkeletalMeshPath="SlumpWep_PaxeBack.SlumpWep_PaxeBack",
		StaticMeshPath="SlumpWep_PaxeBack.SlumpWep_PaxeBack_Mesh",
		MaterialPath="",
		StaticMeshScale=1.0,
		ImagePath="UI_CustWeaponImages_SWF.skin_bardiche_png"
		)};
	Skins(4)={(
		SkeletalMeshPath="SlumpWep_PaxeBack.SlumpWep_PaxeBack",
		StaticMeshPath="SlumpWep_PaxeBack.SlumpWep_PaxeBack_Mesh",
		MaterialPath="",
		StaticMeshScale=1.0,
		ImagePath="UI_CustWeaponImages_SWF.skin_bardiche_png"
		)};
	Skins(5)={(
		SkeletalMeshPath="SlumpWep_PaxeBack.SlumpWep_PaxeBack",
		StaticMeshPath="SlumpWep_PaxeBack.SlumpWep_PaxeBack_Mesh",
		MaterialPath="",
		StaticMeshScale=1.0,
		ImagePath="UI_CustWeaponImages_SWF.skin_bardiche_png"
		)};
		
}
