/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
*
* Original Author: Michael Bao
*
* The weapon that is replicated to all clients: Zweihander.
*/
class BangModWeaponAttachment_Nodachi extends AOCWeaponAttachment_Zweihander;


DefaultProperties
{

	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'CHV_DeadliestPorts.Meshes.WEP_Nodachi'
	End Object

	Begin Object Name=SkeletalMeshComponent2
		SkeletalMesh=SkeletalMesh'CHV_DeadliestPorts.Meshes.WEP_Nodachi'
	End Object

	WeaponID=EWEP_Zweihander
	WeaponClass=class'BangModWeapon_Nodachi'
	WeaponSocket=wep2hpoint

	bUseAlternativeKick=true

	WeaponStaticMeshScale=1

	AttackTypeInfo(0)=(fBaseDamage=79.0, fForce=22400, cDamageType="AOC.AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(1)=(fBaseDamage=84.0, fForce=22400, cDamageType="AOC.AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(2)=(fBaseDamage=71.0, fForce=22400, cDamageType="AOC.AOCDmgType_Pierce", iWorldHitLenience=6)
	AttackTypeInfo(3)=(fBaseDamage=0.0, fForce=28000, cDamageType="AOC.AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(4)=(fBaseDamage=0.0, fForce=28000, cDamageType="AOC.AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(5)=(fBaseDamage=5.0, fForce=36400, cDamageType="AOC.AOCDmgType_Shove", iWorldHitLenience=12)

	Skins(0)={(
		SkeletalMeshPath="CHV_DeadliestPorts.Meshes.WEP_Nodachi",
		StaticMeshPath="CHV_DeadliestPorts.Meshes.SM_Nodachi",
		MaterialPath="CHV_DeadliestPorts.Materials.M_Katana_INST",
		StaticMeshScale=1.0,
		ImagePath="UI_CustWeaponImages_SWF.skin_bardiche_png"
		)};
	Skins(1)={(
		SkeletalMeshPath="CHV_DeadliestPorts.Meshes.WEP_Nodachi",
		StaticMeshPath="CHV_DeadliestPorts.Meshes.SM_Nodachi",
		MaterialPath="CHV_DeadliestPorts.Materials.M_Katana_INST",
		StaticMeshScale=1.0,
		ImagePath="UI_CustWeaponImages_SWF.skin_bardiche_png"
		)};
	Skins(2)={(
		SkeletalMeshPath="CHV_DeadliestPorts.Meshes.WEP_Nodachi",
		StaticMeshPath="CHV_DeadliestPorts.Meshes.SM_Nodachi",
		MaterialPath="CHV_DeadliestPorts.Materials.M_Katana_INST",
		StaticMeshScale=1.0,
		ImagePath="UI_CustWeaponImages_SWF.skin_bardiche_png"
		)};
	Skins(3)={(
		SkeletalMeshPath="CHV_DeadliestPorts.Meshes.WEP_Nodachi",
		StaticMeshPath="CHV_DeadliestPorts.Meshes.SM_Nodachi",
		MaterialPath="CHV_DeadliestPorts.Materials.M_Katana_INST",
		StaticMeshScale=1.0,
		ImagePath="UI_CustWeaponImages_SWF.skin_bardiche_png"
		)};
	Skins(4)={(
		SkeletalMeshPath="CHV_DeadliestPorts.Meshes.WEP_Nodachi",
		StaticMeshPath="CHV_DeadliestPorts.Meshes.SM_Nodachi",
		MaterialPath="CHV_DeadliestPorts.Materials.M_Katana_INST",
		StaticMeshScale=1.0,
		ImagePath="UI_CustWeaponImages_SWF.skin_bardiche_png"
		)};
	
}
