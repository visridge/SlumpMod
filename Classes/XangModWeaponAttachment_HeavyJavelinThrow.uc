/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
* 
* Original Author: Michael Bao
* 
* Weapon Attachment: Javelin.
*/

class XangModWeaponAttachment_HeavyJavelinThrow extends AOCWeaponAttachment_HeavyJavelinThrow;

DefaultProperties
{
	WeaponClass=class'XangModWeapon_HeavyJavelinThrow'

	// Mercenaries 1.996 numeric weapon values (Workshop 705710406).
	KickSize=20
	ParryTracersLength=50
	WeaponWidth=4
	WeaponNumTracers=1
	ParryCheckTraceInc=1
	AttackTypeInfo(0)=(fBaseDamage=40, fForce=22500, cDamageType="AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(1)=(fBaseDamage=35, fForce=32500, cDamageType="AOCDmgType_Blunt", iWorldHitLenience=6)
	AttackTypeInfo(2)=(fBaseDamage=70, fForce=20000, cDamageType="AOCDmgType_Pierce", iWorldHitLenience=6)
	AttackTypeInfo(3)=(fBaseDamage=0, fForce=22500, cDamageType="AOCDmgType_Pierce", iWorldHitLenience=6)
	AttackTypeInfo(4)=(fBaseDamage=0, fForce=22500, cDamageType="AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(5)=(fBaseDamage=5, fForce=45500, cDamageType="AOCDmgType_Shove", iWorldHitLenience=12)
}
