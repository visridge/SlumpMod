/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
*
* Weapon Attachment: Firebug (Throwing Mode).
* Uses the torch skeletal mesh for the throwing pose.
*/
class XangModWeaponAttachment_FirebugThrow extends AOCWeaponAttachment;

DefaultProperties
{
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'WP_Torches.Skelmeshes.torch01'
		Scale=1.1
	End Object

	Begin Object Name=SkeletalMeshComponent2
		SkeletalMesh=SkeletalMesh'WP_Torches.Skelmeshes.torch01'
		Scale=1.1
	End Object

	WeaponID=EWEP_Torch
	WeaponClass=class'XangModWeapon_FirebugThrow'

	WeaponSocket=wep1hpoint

	WeaponStaticMeshScale=1.1
		bUseAlternativeKick=false


}
