/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
*
* Original Author: Michael Bao
*
* Weapon attachment: Gladius - Bastard Sword behavior with scaled shortsword visuals
*/
class XangModWeaponAttachment_Gladius extends XangModWeaponAttachment_Messer;

simulated function float GetHandleTracerPercent(int i)
{
	local vector vStart, vMid, vEnd;
	local float HandleLength, WeaponLength;
	local float HandleTracerPercent;

	if (Mesh.GetSocketByName('TraceMid') == None)
	{
		return 0.40f;
	}
	Mesh.GetSocketWorldLocationAndRotation('TraceStart', vStart);
	Mesh.GetSocketWorldLocationAndRotation('TraceMid', vMid);
	Mesh.GetSocketWorldLocationAndRotation('TraceEnd', vEnd);

	WeaponLength = VSize(vEnd - vStart);
	HandleLength = VSize(vMid - vStart);
	HandleTracerPercent = (HandleLength / WeaponLength) * 3;

	if (HandleTracerPercent < 0.40f)
	{
		return 0.40f;
	}

	return HandleTracerPercent;
}

DefaultProperties
{
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'WP_aux_Shortsword.wep_shortsword'
		Scale=1.6
	End Object

	Begin Object Name=SkeletalMeshComponent2
		SkeletalMesh=SkeletalMesh'WP_aux_Shortsword.wep_shortsword'
		Scale=1.6
	End Object

	WeaponID=EWEP_Dagesse
	WeaponClass=class'XangModWeapon_Gladius'
	WeaponSocket=wep2hpoint
	WeaponStaticMeshScale=1.6

	Skins(0)={(
		SkeletalMeshPath="WP_aux_Shortsword.wep_shortsword",
		StaticMeshPath="WP_aux_Shortsword.SM_Short_Sword",
		MaterialPath="",
		StaticMeshScale=1.6,
		ImagePath="UI_CustWeaponImages_SWF.skin_shortsword_png"
		)};

	Skins(1)={(
		SkeletalMeshPath="WP_aux_Shortsword.wep_shortsword",
		StaticMeshPath="WP_aux_Shortsword.SM_Short_Sword",
		MaterialPath="",
		StaticMeshScale=1.6,
		ImagePath="UI_CustWeaponImages_SWF.skin_shortsword_png"
		)};

	Skins(2)={(
		SkeletalMeshPath="WP_aux_Shortsword.wep_shortsword",
		StaticMeshPath="WP_aux_Shortsword.SM_Short_Sword",
		MaterialPath="",
		StaticMeshScale=1.6,
		ImagePath="UI_CustWeaponImages_SWF.skin_shortsword_png"
		)};
}