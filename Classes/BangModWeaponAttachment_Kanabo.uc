/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
*
* The weapon that is replicated to all clients: Kanabo.
* Based on GrandMace attachment.
*/
class BangModWeaponAttachment_Kanabo extends AOCWeaponAttachment_GrandMace;

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
		SkeletalMesh=SkeletalMesh'CHV_DeadliestPorts.Meshes.WEP_Kanabo'
	End Object

	Begin Object Name=SkeletalMeshComponent2
		SkeletalMesh=SkeletalMesh'CHV_DeadliestPorts.Meshes.WEP_Kanabo'
	End Object

	WeaponID=EWEP_GrandMace
	WeaponClass=class'BangModWeapon_Kanabo'
	WeaponSocket=wep2haxepoint

	bUseAlternativeKick=true

	AttackTypeInfo(0)=(fBaseDamage=60.0, fForce=22500, cDamageType="AOC.AOCDmgType_PierceBlunt", iWorldHitLenience=6)
	AttackTypeInfo(1)=(fBaseDamage=70, fForce=22500, cDamageType="AOC.AOCDmgType_PierceBlunt", iWorldHitLenience=6)
	AttackTypeInfo(2)=(fBaseDamage=40, fForce=22500, cDamageType="AOC.AOCDmgType_Blunt", iWorldHitLenience=6)
	AttackTypeInfo(3)=(fBaseDamage=0.0, fForce=22500, cDamageType="AOC.AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(4)=(fBaseDamage=0.0, fForce=32500, cDamageType="AOC.AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(5)=(fBaseDamage=5.0, fForce=45500.0, cDamageType="AOC.AOCDmgType_Shove", iWorldHitLenience=12)

	Skins(0)={(
		SkeletalMeshPath="CHV_DeadliestPorts.Meshes.WEP_Kanabo",
		StaticMeshPath="CHV_DeadliestPorts.Meshes.SM_Kanabo",
		MaterialPath="CHV_DeadliestPorts.Materials.M_Kanabo_INST",
		StaticMeshScale=1.0,
		ImagePath="UI_CustWeaponImages_SWF.skin_bardiche_png"
		)};
	Skins(1)={(
		SkeletalMeshPath="CHV_DeadliestPorts.Meshes.WEP_Kanabo",
		StaticMeshPath="CHV_DeadliestPorts.Meshes.SM_Kanabo",
		MaterialPath="CHV_DeadliestPorts.Materials.M_Kanabo_INST",
		StaticMeshScale=1.0,
		ImagePath="UI_CustWeaponImages_SWF.skin_bardiche_png"
		)};
	Skins(2)={(
		SkeletalMeshPath="CHV_DeadliestPorts.Meshes.WEP_Kanabo",
		StaticMeshPath="CHV_DeadliestPorts.Meshes.SM_Kanabo",
		MaterialPath="CHV_DeadliestPorts.Materials.M_Kanabo_INST",
		StaticMeshScale=1.0,
		ImagePath="UI_CustWeaponImages_SWF.skin_bardiche_png"
		)};
	Skins(3)={(
		SkeletalMeshPath="CHV_DeadliestPorts.Meshes.WEP_Kanabo",
		StaticMeshPath="CHV_DeadliestPorts.Meshes.SM_Kanabo",
		MaterialPath="CHV_DeadliestPorts.Materials.M_Kanabo_INST",
		StaticMeshScale=1.0,
		ImagePath="UI_CustWeaponImages_SWF.skin_bardiche_png"
		)};
	Skins(4)={(
		SkeletalMeshPath="CHV_DeadliestPorts.Meshes.WEP_Kanabo",
		StaticMeshPath="CHV_DeadliestPorts.Meshes.SM_Kanabo",
		MaterialPath="CHV_DeadliestPorts.Materials.M_Kanabo_INST",
		StaticMeshScale=1.0,
		ImagePath="UI_CustWeaponImages_SWF.skin_bardiche_png"
		)};
}
