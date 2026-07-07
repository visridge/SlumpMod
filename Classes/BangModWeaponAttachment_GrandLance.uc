/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
*
* Original Author: Michael Bao
*
* Weapon Attachment: Grand Lance.
*/
class BangModWeaponAttachment_GrandLance extends AOCWeaponAttachment_Halberd;

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
		SkeletalMesh=SkeletalMesh'GrandLance.WEP_Grandlance'
	End Object

	Begin Object Name=SkeletalMeshComponent2
		SkeletalMesh=SkeletalMesh'GrandLance.WEP_Grandlance'
	End Object

	WeaponID=EWEP_Halberd
	WeaponClass=class'BangModWeapon_GrandLance'
	WeaponSocket=wepPolepoint

	AttackTypeInfo(0)=(fBaseDamage=25.0, fForce=24000, cDamageType="AOC.AOCDmgType_SwingBlunt", iWorldHitLenience=6)
	AttackTypeInfo(1)=(fBaseDamage=25.0, fForce=24000, cDamageType="AOC.AOCDmgType_SwingBlunt", iWorldHitLenience=6)
	AttackTypeInfo(2)=(fBaseDamage=95.0, fForce=50000, cDamageType="AOC.AOCDmgType_Pierce", iWorldHitLenience=6)
	AttackTypeInfo(3)=(fBaseDamage=100.0, fForce=65000, cDamageType="AOC.AOCDmgType_Pierce", iWorldHitLenience=6)
	AttackTypeInfo(4)=(fBaseDamage=1.0, fForce=35500, cDamageType="AOC.AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(5)=(fBaseDamage=5.0, fForce=45500.0, cDamageType="AOC.AOCDmgType_Shove", iWorldHitLenience=12)

Skins(0)={(
		SkeletalMeshPath="GrandLance.WEP_Grandlance",
		StaticMeshPath="GrandLance.SM_Grandlance",
		MaterialPath="GrandLance.M_Grandlance_INST",
		StaticMeshScale=0.70,
		ImagePath="UI_CustWeaponImages_SWF.skin_bardiche_png"
		)};
	Skins(1)={(
		SkeletalMeshPath="GrandLance.WEP_Grandlance",
		StaticMeshPath="GrandLance.SM_Grandlance",
		MaterialPath="GrandLance.M_Grandlance_INST",
		StaticMeshScale=0.70,
		ImagePath="UI_CustWeaponImages_SWF.skin_bardiche_png"
		)};
	Skins(2)={(
		SkeletalMeshPath="GrandLance.WEP_Grandlance",
		StaticMeshPath="GrandLance.SM_Grandlance",
		MaterialPath="GrandLance.M_Grandlance_INST",
		StaticMeshScale=0.70,
		ImagePath="UI_CustWeaponImages_SWF.skin_bardiche_png"
		)};
	Skins(3)={(
		SkeletalMeshPath="GrandLance.WEP_Grandlance",
		StaticMeshPath="GrandLance.SM_Grandlance",
		MaterialPath="GrandLance.M_Grandlance_INST",
		StaticMeshScale=0.70,
		ImagePath="UI_CustWeaponImages_SWF.skin_bardiche_png"
		)};
	Skins(4)={(
	SkeletalMeshPath="GrandLance.WEP_Grandlance",
		StaticMeshPath="GrandLance.SM_Grandlance",
		MaterialPath="GrandLance.M_Grandlance_INST",
		StaticMeshScale=0.70,
		ImagePath="UI_CustWeaponImages_SWF.skin_bardiche_png"
		)};
}
