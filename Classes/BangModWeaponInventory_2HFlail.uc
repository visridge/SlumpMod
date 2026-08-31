/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
*
* Original Author: Michael Bao
*
* Inventory attachment for the 2-Handed Flail.
*
* Carries the purpose-built Flale mesh (held two-handed like a double axe
* while holstered) and spawns the matching static mesh when dropped.
*/
class BangModWeaponInventory_2HFlail extends AOCInventoryAttachment;

DefaultProperties
{
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'Flale.WEP_Flale'
	End Object

	StaticMeshSpawn=StaticMesh'Flale.Mesh_Flale'

	CarryType=ECARRY_LARGE
	CarryLocation=ELOC_HOLD
	CarrySocketName=wep2haCarry
}
