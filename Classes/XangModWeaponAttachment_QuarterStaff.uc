/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
* 
* Original Author: Michael Bao
* 
* Quarter Staff Weapon Attachment.
*/
class XangModWeaponAttachment_QuarterStaff extends AOCWeaponAttachment_QuarterStaff;

// Parry-box + netcode overrides. MUST be at class level - see the file header.
`include(XangMod/Include/XangModWeaponAttachmentCode.uci)

defaultproperties
{
	`include(XangMod/Include/XangModWeaponAttachment.uci);

KickOffset=(X=50, Y=0, Z=-65)
	KickSize=20.f

	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'WP_DL1_quarterstaff.WEP_quarterstaff'
	End Object

	Begin Object Name=SkeletalMeshComponent2
		SkeletalMesh=SkeletalMesh'WP_DL1_quarterstaff.WEP_quarterstaff'
	End Object

	WeaponID=EWEP_QStaff
	WeaponClass=class'XangModWeapon_QuarterStaff'

	WeaponSocket=wepQstaffpoint
	bUseAlternativeKick=true

	WeaponStaticMeshScale=1

	AttackTypeInfo(0)=(fBaseDamage=45, fForce=22500, cDamageType="AOCDmgType_Blunt", iWorldHitLenience=6)
	AttackTypeInfo(1)=(fBaseDamage=50.0, fForce=22500, cDamageType="AOCDmgType_Blunt", iWorldHitLenience=6)
	AttackTypeInfo(2)=(fBaseDamage=45.0, fForce=22500, cDamageType="AOCDmgType_Blunt", iWorldHitLenience=6)
	AttackTypeInfo(3)=(fBaseDamage=0.0, fForce=22500, cDamageType="AOCDmgType_Blunt", iWorldHitLenience=6)
	AttackTypeInfo(4)=(fBaseDamage=0.0, fForce=22500, cDamageType="AOCDmgType_Blunt", iWorldHitLenience=6)
	AttackTypeInfo(5)=(fBaseDamage=5.0, fForce=45500.0, cDamageType="AOCDmgType_Shove", iWorldHitLenience=12)



	// Mercenaries 1.996 numeric weapon values (Workshop 705710406).
	ParryTracersLength=50
	WeaponWidth=4
	WeaponNumTracers=1
	ParryCheckTraceInc=1
}