/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
* 
* Original Author: Michael Bao
* 
* The Weapon Attachment for the Hunting Knife.
*/
class XangModWeaponAttachment_Rapier extends AOCWeaponAttachment_HuntingKnife;

DefaultProperties
{
	`include(XangMod/Include/XangModWeaponAttachment.uci);

KickOffset=(X=50, Y=0, Z=-65)
	KickSize=20.f

	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'Rapier.WEP_Rapier'
		Scale=1.0
	End Object

	Begin Object Name=SkeletalMeshComponent2
		SkeletalMesh=SkeletalMesh'Rapier.WEP_Rapier'
		Scale=1.0
	End Object

	WeaponID=EWEP_Rapier
	WeaponClass=class'XangModWeapon_Rapier'
	WeaponSocket=wep1hpoint

	AttackTypeInfo(0)=(fBaseDamage=45.0, fForce=8000, cDamageType="AOC.AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(1)=(fBaseDamage=53.0, fForce=12500, cDamageType="AOC.AOCDmgType_Pierce", iWorldHitLenience=6)
	AttackTypeInfo(2)=(fBaseDamage=53.0, fForce=12500, cDamageType="AOC.AOCDmgType_Pierce", iWorldHitLenience=6)
	AttackTypeInfo(3)=(fBaseDamage=0.0, fForce=22500, cDamageType="AOC.AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(4)=(fBaseDamage=0.0, fForce=22500, cDamageType="AOC.AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(5)=(fBaseDamage=5.0, fForce=45500.0, cDamageType="AOC.AOCDmgType_Shove", iWorldHitLenience=12)

Skins(0)={(
		SkeletalMeshPath="Rapier.WEP_Rapier",
		StaticMeshPath="Rapier.Mesh_Rapier",
		MaterialPath="",
		StaticMeshScale=1.0,
		ImagePath="UI_CustWeaponImages_SWF.skin_short_spear_png"
		)};
Skins(1)={(
		SkeletalMeshPath="Rapier.WEP_Rapier",
		StaticMeshPath="Rapier.Mesh_Rapier",
		MaterialPath="",
		StaticMeshScale=1.0,
		ImagePath="UI_CustWeaponImages_SWF.skin_short_spear_png"
		)};
Skins(2)={(
		SkeletalMeshPath="Rapier.WEP_Rapier",
		StaticMeshPath="Rapier.Mesh_Rapier",
		MaterialPath="",
		StaticMeshScale=1.0,
		ImagePath="UI_CustWeaponImages_SWF.skin_short_spear_png"
		)};
Skins(3)={(
		SkeletalMeshPath="Rapier.WEP_Rapier",
		StaticMeshPath="Rapier.Mesh_Rapier",
		MaterialPath="",
		StaticMeshScale=1.0,
		ImagePath="UI_CustWeaponImages_SWF.skin_short_spear_png"
		)};
Skins(4)={(
		SkeletalMeshPath="Rapier.WEP_Rapier",
		StaticMeshPath="Rapier.Mesh_Rapier",
		MaterialPath="",
		StaticMeshScale=1.0,
		ImagePath="UI_CustWeaponImages_SWF.skin_short_spear_png"
		)};

				
}
