/**
* Firebug weapon attachment - Cudgel stats with torch skeletal mesh.
*/
class BangModWeaponAttachment_Firebug extends BangModWeaponAttachment_Cudgel;

DefaultProperties
{
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'WP_Torches.Skelmeshes.torch01'
	End Object

	Begin Object Name=SkeletalMeshComponent2
		SkeletalMesh=SkeletalMesh'WP_Torches.Skelmeshes.torch01'
	End Object

	WeaponClass=class'BangModWeapon_Firebug'
}
