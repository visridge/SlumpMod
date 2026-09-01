/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
*
* Original Author: Michael Bao
*
* Weapon Attachment: Fork.
*/
class BangModWeaponAttachment_Fork extends AOCWeaponAttachment_Fork;

DefaultProperties
{
	`include(BangMod/Include/BangModWeaponAttachment.uci);

KickOffset=(X=50, Y=0, Z=-65)
	KickSize=20.f

	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'WP_spr_Spear.WEP_spear'
	End Object

	Begin Object Name=SkeletalMeshComponent2
		SkeletalMesh=SkeletalMesh'WP_spr_Spear.WEP_spear'
	End Object

	WeaponID=EWEP_Fork
	WeaponClass=class'BangModWeapon_Fork'
	WeaponSocket=wep2hpoint
	bUseAlternativeKick=true

	AttackTypeInfo(0)=(fBaseDamage=25.0, fForce=28000, cDamageType="AOC.AOCDmgType_Blunt", iWorldHitLenience=6)
	AttackTypeInfo(1)=(fBaseDamage=65.0, fForce=25200, cDamageType="AOC.AOCDmgType_Pierce", iWorldHitLenience=6)
	AttackTypeInfo(2)=(fBaseDamage=60.0, fForce=20000, cDamageType="AOC.AOCDmgType_Pierce", iWorldHitLenience=6)
	AttackTypeInfo(3)=(fBaseDamage=100.0, fForce=65000, cDamageType="AOC.AOCDmgType_Pierce", iWorldHitLenience=6)
	AttackTypeInfo(4)=(fBaseDamage=0.0, fForce=25500, cDamageType="AOC.AOCDmgType_Pierce", iWorldHitLenience=6)
	AttackTypeInfo(5)=(fBaseDamage=5.0, fForce=45500.0, cDamageType="AOC.AOCDmgType_Shove", iWorldHitLenience=12)


}
