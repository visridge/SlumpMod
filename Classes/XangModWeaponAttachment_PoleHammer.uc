/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
*
* Original Author: Michael Bao
*
* Pole Hammer Weapon Attachment.
*/
class BangModWeaponAttachment_PoleHammer extends AOCWeaponAttachment_PoleHammer;

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

    return (HandleLength / WeaponLength);
}

defaultproperties
{
	`include(BangMod/Include/BangModWeaponAttachment.uci);

KickOffset=(X=50, Y=0, Z=-65)
	KickSize=20.f

	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'WP_pol_Bardiche.WEP_bardiche'
	End Object

	Begin Object Name=SkeletalMeshComponent2
		SkeletalMesh=SkeletalMesh'WP_pol_Bardiche.WEP_bardiche'
	End Object

	WeaponID=EWEP_PoleHammer
	WeaponClass=class'BangModWeapon_PoleHammer'

	WeaponSocket=wepPolePoint
	bUseAlternativeKick=true

	WeaponStaticMeshScale=1

	AttackTypeInfo(0)=(fBaseDamage=80, fForce=24000, cDamageType="AOC.AOCDmgType_Blunt", iWorldHitLenience=6)
	AttackTypeInfo(1)=(fBaseDamage=113, fForce=25600, cDamageType="AOC.AOCDmgType_Blunt", iWorldHitLenience=6)
	AttackTypeInfo(2)=(fBaseDamage=65, fForce=25600, cDamageType="AOC.AOCDmgType_Pierce", iWorldHitLenience=6)
	AttackTypeInfo(3)=(fBaseDamage=100.0, fForce=65000, cDamageType="AOC.AOCDmgType_Pierce", iWorldHitLenience=6)
	AttackTypeInfo(4)=(fBaseDamage=0.0, fForce=22500, cDamageType="AOC.AOCDmgType_Pierce", iWorldHitLenience=6)
	AttackTypeInfo(5)=(fBaseDamage=5.0, fForce=45500.0, cDamageType="AOC.AOCDmgType_Shove", iWorldHitLenience=12)

}
