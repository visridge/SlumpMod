/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
*
* Original Author: Michael Bao
*
* The inventory attachment for weapons: Grand Hammer.
*/
class BangModWeaponInventory_GrandHammer extends AOCInventoryAttachment;

DefaultProperties
{
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'CHV_DeadliestPorts.Meshes.WEP_GrandHammer'
		Scale=0.8
	End Object

	CarryType=ECARRY_LARGE
	LocationType=ELOC_BACK
	WeaponSocket=wep2hcarry
}
