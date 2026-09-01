/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
* 
* Original Author: Michael Bao
* 
* The weapon that is replicated to all clients: Saber
*/
class BangModWeaponAttachment_Saber extends AOCWeaponAttachment_Saber;

DefaultProperties
{
	`include(BangMod/Include/BangModWeaponAttachment.uci);

KickOffset=(X=50, Y=0, Z=-65)
	KickSize=20.f

	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'WP_aux_Shortsword.wep_shortsword'
	End Object

	Begin Object Name=SkeletalMeshComponent2
		SkeletalMesh=SkeletalMesh'WP_aux_Shortsword.wep_shortsword'
	End Object

	WeaponID=EWEP_Saber
	WeaponClass=class'BangModWeapon_Saber'
	WeaponSocket=wep1hpoint

	WeaponStaticMeshScale=1

	AttackTypeInfo(0)=(fBaseDamage=51.0, fForce=9600, cDamageType="AOC.AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(1)=(fBaseDamage=62.0, fForce=9600, cDamageType="AOC.AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(2)=(fBaseDamage=40.0, fForce=16000, cDamageType="AOC.AOCDmgType_Pierce", iWorldHitLenience=6)
	AttackTypeInfo(3)=(fBaseDamage=100.0, fForce=42500, cDamageType="AOC.AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(4)=(fBaseDamage=0.0, fForce=22500, cDamageType="AOC.AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(5)=(fBaseDamage=5.0, fForce=45500.0, cDamageType="AOC.AOCDmgType_Shove", iWorldHitLenience=12)
	
	
}
