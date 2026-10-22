/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
* 
* Original Author: Michael Bao
* 
* The weapon that is replicated to all clients: Broadsword
*/
class XangModWeaponAttachment_Broadsword extends AOCWeaponAttachment_Broadsword;

// Parry-box + netcode overrides. MUST be at class level - see the file header.
`include(XangMod/Include/XangModWeaponAttachmentCode.uci)

DefaultProperties
{
	`include(XangMod/Include/XangModWeaponAttachment.uci);	

KickOffset=(X=50, Y=0, Z=-65)
	KickSize=20.f

	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'WP_1hs_Broadsword.WEP_Broadsword'
	End Object

	Begin Object Name=SkeletalMeshComponent2
		SkeletalMesh=SkeletalMesh'WP_1hs_Broadsword.WEP_Broadsword'
	End Object

	WeaponID=EWEP_Broadsword
	WeaponClass=class'XangModWeapon_Broadsword'
	WeaponSocket = wep1hpoint

	AttackTypeInfo(0)=(fBaseDamage=60, fForce=15000, cDamageType="AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(1)=(fBaseDamage=70.0, fForce=15000, cDamageType="AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(2)=(fBaseDamage=55.0, fForce=22500, cDamageType="AOCDmgType_Pierce", iWorldHitLenience=6)
	AttackTypeInfo(3)=(fBaseDamage=0.0, fForce=30000, cDamageType="AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(4)=(fBaseDamage=0.0, fForce=22500, cDamageType="AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(5)=(fBaseDamage=5.0, fForce=45500.0, cDamageType="AOCDmgType_Shove", iWorldHitLenience=12)



	// Mercenaries 1.996 numeric weapon values (Workshop 705710406).
	ParryTracersLength=50
	WeaponWidth=4
	WeaponNumTracers=1
	ParryCheckTraceInc=1
}
