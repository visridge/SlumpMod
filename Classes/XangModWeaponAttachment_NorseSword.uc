/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
*
* Original Author: Michael Bao
*
* The weapon that is replicated to all clients: Norse Sword.
*/
class BangModWeaponAttachment_NorseSword extends AOCWeaponAttachment_NorseSword;

DefaultProperties
{
	`include(BangMod/Include/BangModWeaponAttachment.uci);

KickOffset=(X=50, Y=0, Z=-65)
	KickSize=20.f

	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'WP_1hs_Broadsword.WEP_Broadsword'
	End Object

	Begin Object Name=SkeletalMeshComponent2
		SkeletalMesh=SkeletalMesh'WP_1hs_Broadsword.WEP_Broadsword'
	End Object

	WeaponID=EWEP_Norse
	WeaponClass=class'BangModWeapon_NorseSword'
	WeaponSocket = wep1hpoint

	WeaponStaticMeshScale=1

	AttackTypeInfo(0)=(fBaseDamage=60.0, fForce=12000, cDamageType="AOC.AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(1)=(fBaseDamage=70.0, fForce=12000, cDamageType="AOC.AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(2)=(fBaseDamage=57.0, fForce=18000, cDamageType="AOC.AOCDmgType_Pierce", iWorldHitLenience=6)
	AttackTypeInfo(3)=(fBaseDamage=0.0, fForce=22500, cDamageType="AOC.AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(4)=(fBaseDamage=0.0, fForce=22500, cDamageType="AOC.AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(5)=(fBaseDamage=5.0, fForce=45500.0, cDamageType="AOC.AOCDmgType_Shove", iWorldHitLenience=12)


}
