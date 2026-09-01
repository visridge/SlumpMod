/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
* 
* Original Author: Michael Bao
* 
* The weapon that is replicated to all clients: Sword Of War 1H
*/
class BangModWeaponAttachment_SwordOfWar1H extends AOCWeaponAttachment_SwordOfWar1H;

DefaultProperties
{
	`include(BangMod/Include/BangModWeaponAttachment.uci);

KickOffset=(X=50, Y=0, Z=-65)
	KickSize=20.f

	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'WP_15hs_Longsword.WEP_Longsword'
	End Object

	Begin Object Name=SkeletalMeshComponent2
		SkeletalMesh=SkeletalMesh'WP_15hs_Longsword.WEP_Longsword'
	End Object

	WeaponID=EWEP_SwordOfWar
	WeaponClass=class'BangModWeapon_SwordOfWar1H'
	WeaponSocket=wep1hpoint

	bUseAlternativeKick=true

	WeaponStaticMeshScale=1

	AttackTypeInfo(0)=(fBaseDamage=55.0, fForce=9600, cDamageType="AOC.AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(1)=(fBaseDamage=60.0, fForce=9600, cDamageType="AOC.AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(2)=(fBaseDamage=60.0, fForce=24000, cDamageType="AOC.AOCDmgType_Pierce", iWorldHitLenience=6)
	AttackTypeInfo(3)=(fBaseDamage=0.0, fForce=22500, cDamageType="AOC.AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(4)=(fBaseDamage=0.0, fForce=22500, cDamageType="AOC.AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(5)=(fBaseDamage=5.0, fForce=45500.0, cDamageType="AOC.AOCDmgType_Shove", iWorldHitLenience=12)

}
