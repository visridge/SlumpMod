/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
*
* Original Author: Michael Bao
*
* The weapon that is replicated to all clients: Grand Hammer.
*/
class BangModWeaponAttachment_GrandHammer extends AOCWeaponAttachment_WarHammer;

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
	`include(BangMod/Include/BangModWeaponAttachment.uci);

	KickOffset=(X=50, Y=0, Z=-65)
	KickSize=20.f

	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'CHV_DeadliestPorts.Meshes.WEP_GrandHammer'
		Scale=1.1
	End Object

	Begin Object Name=SkeletalMeshComponent2
		SkeletalMesh=SkeletalMesh'CHV_DeadliestPorts.Meshes.WEP_GrandHammer'
		Scale=1.1
	End Object

	WeaponID=EWEP_WarHammer
	WeaponClass=class'BangModWeapon_GrandHammer'
	WeaponSocket=wepPolepoint

	WeaponStaticMeshScale=1.1

	bUseAlternativeKick=true

	AttackTypeInfo(0)=(fBaseDamage=72.0, fForce=18000, cDamageType="AOC.AOCDmgType_Blunt", iWorldHitLenience=6)
	AttackTypeInfo(1)=(fBaseDamage=75.0, fForce=18000, cDamageType="AOC.AOCDmgType_Blunt", iWorldHitLenience=6)
    AttackTypeInfo(2)=(fBaseDamage=30.0, fForce=18000, cDamageType="AOC.AOCDmgType_PierceBlunt", iWorldHitLenience=6)
	AttackTypeInfo(3)=(fBaseDamage=0.0, fForce=22500, cDamageType="AOC.AOCDmgType_Blunt", iWorldHitLenience=6)
	AttackTypeInfo(4)=(fBaseDamage=0.0, fForce=25500, cDamageType="AOC.AOCDmgType_Blunt", iWorldHitLenience=6)
	AttackTypeInfo(5)=(fBaseDamage=5.0, fForce=45500.0, cDamageType="AOC.AOCDmgType_Shove", iWorldHitLenience=12)

	Skins(0)={(
		SkeletalMeshPath="CHV_DeadliestPorts.Meshes.WEP_GrandHammer",
		StaticMeshPath="CHV_DeadliestPorts.Meshes.SM_GrandHammer",
		MaterialPath="CHV_DeadliestPorts.Materials.M_GrandHammer_INST",
		StaticMeshScale=0.70,
		ImagePath="UI_CustWeaponImages_SWF.skin_bardiche_png"
		)};
	Skins(1)={(
		SkeletalMeshPath="CHV_DeadliestPorts.Meshes.WEP_GrandHammer",
		StaticMeshPath="CHV_DeadliestPorts.Meshes.SM_GrandHammer",
		MaterialPath="CHV_DeadliestPorts.Materials.M_GrandHammer_INST",
		StaticMeshScale=0.70,
		ImagePath="UI_CustWeaponImages_SWF.skin_bardiche_png"
		)};
	Skins(2)={(
		SkeletalMeshPath="CHV_DeadliestPorts.Meshes.WEP_GrandHammer",
		StaticMeshPath="CHV_DeadliestPorts.Meshes.SM_GrandHammer",
		MaterialPath="CHV_DeadliestPorts.Materials.M_GrandHammer_INST",
		StaticMeshScale=0.70,
		ImagePath="UI_CustWeaponImages_SWF.skin_bardiche_png"
		)};
	Skins(3)={(
		SkeletalMeshPath="CHV_DeadliestPorts.Meshes.WEP_GrandHammer",
		StaticMeshPath="CHV_DeadliestPorts.Meshes.SM_GrandHammer",
		MaterialPath="CHV_DeadliestPorts.Materials.M_GrandHammer_INST",
		StaticMeshScale=0.70,
		ImagePath="UI_CustWeaponImages_SWF.skin_bardiche_png"
		)};
	Skins(4)={(
		SkeletalMeshPath="CHV_DeadliestPorts.Meshes.WEP_GrandHammer",
		StaticMeshPath="CHV_DeadliestPorts.Meshes.SM_GrandHammer",
		MaterialPath="CHV_DeadliestPorts.Materials.M_GrandHammer_INST",
		StaticMeshScale=0.70,
		ImagePath="UI_CustWeaponImages_SWF.skin_bardiche_png"
		)};
}
