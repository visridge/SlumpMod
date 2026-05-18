/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
*
* Original Author: Michael Bao
*
* The weapon that is replicated to all clients: War Hammer.
*/
class BangModWeaponAttachment_WarHammer extends AOCWeaponAttachment_WarHammer;

var SkeletalMeshComponent LeftHandMesh;
var SkeletalMeshComponent LeftHandOverlayMesh;
var bool bLeftOverlayAttached;
var name LeftHandSocket;
var vector LeftHandTranslation;

simulated function EnsureLeftHandComponents()
{
	if (LeftHandMesh == none)
	{
		LeftHandMesh = new(self) class'SkeletalMeshComponent';
		LeftHandMesh.SetSkeletalMesh(SkeletalMesh'WP_dag_HuntingKnife_Variant_01.WEP_FarmsToArmsSickle');
		LeftHandMesh.SetScale(1.0);
	}

	if (LeftHandOverlayMesh == none)
	{
		LeftHandOverlayMesh = new(self) class'SkeletalMeshComponent';
		LeftHandOverlayMesh.SetSkeletalMesh(SkeletalMesh'WP_dag_HuntingKnife_Variant_01.WEP_FarmsToArmsSickle');
		LeftHandOverlayMesh.SetScale(1.0);
		LeftHandOverlayMesh.SetHidden(true);
	}
}

simulated function AttachTo(UTPawn OwnerPawn)
{
	local bool bBehindView;

	super.AttachTo(OwnerPawn);

	AOCOwner = AOCPawn(OwnerPawn);
	EnsureLeftHandComponents();

	if (AOCOwner != none && OwnerPawn.Mesh != none)
	{
		LeftHandMesh.SetShadowParent(OwnerPawn.Mesh);
		LeftHandMesh.SetLightEnvironment(OwnerPawn.LightEnvironment);
		AOCOwner.HandleSocketAttachment(false, LeftHandMesh, LeftHandSocket, self);
		LeftHandMesh.SetTranslation(LeftHandTranslation);
	}

	if (OwnerPawn.IsLocallyControlled())
	{
		bBehindView = AOCPlayerController(OwnerPawn.Controller).bBehindView;
		UpdateLeftHandVisibility(bBehindView);
		if (!bBehindView)
		{
			ForceAttachOverlay();
		}
		ChangeOverlayMeshVisibility(bBehindView);
	}
	else if (AOCPawn(OwnerPawn).bIsBeingFPObserved)
	{
		bBehindView = AOCPlayerController(GetALocalPlayerController()).bBehindView;
		UpdateLeftHandVisibility(bBehindView);
		if (!bBehindView)
		{
			ForceAttachOverlay();
		}
		ChangeOverlayMeshVisibility(bBehindView);
	}
	else
	{
		UpdateLeftHandVisibility(true);
	}
}

simulated function ForceAttachOverlay()
{
	super.ForceAttachOverlay();

	EnsureLeftHandComponents();

	if (!bLeftOverlayAttached)
	{
		LeftHandOverlayMesh.SetLightEnvironment(AOCOwner.LightEnvironment);
		LeftHandOverlayMesh.SetHidden(false);
		LeftHandOverlayMesh.SetIgnoreOwnerHidden(true);
		AOCOwner.HandleSocketAttachment(true, LeftHandOverlayMesh, LeftHandSocket, self);
		LeftHandOverlayMesh.SetTranslation(LeftHandTranslation);
		bLeftOverlayAttached = true;
	}
}

simulated function ChangeOverlayMeshVisibility(bool bVis)
{
	super.ChangeOverlayMeshVisibility(bVis);

	if (LeftHandOverlayMesh != none)
		LeftHandOverlayMesh.SetHidden(bVis);
}

simulated function UpdateLeftHandVisibility(bool bBehindView)
{
	if (LeftHandMesh != none)
		LeftHandMesh.SetOwnerNoSee(!bBehindView);
}

simulated function DetachFrom(SkeletalMeshComponent MeshCpnt)
{
	if (AOCOwner != none && LeftHandMesh != none)
	{
		AOCOwner.Mesh.DetachComponent(LeftHandMesh);
	}

	if (AOCOwner != none && LeftHandOverlayMesh != none && ((AOCOwner.IsLocallyControlled() && !AOCOwner.bIsBot) || AOCOwner.bIsBeingFPObserved))
	{
		AOCOwner.OwnerMesh.DetachComponent(LeftHandOverlayMesh);
	}

	bLeftOverlayAttached = false;

	super.DetachFrom(MeshCpnt);
}

simulated function SetSkin(Material NewMaterial)
{
	super.SetSkin(NewMaterial);

	if (LeftHandMesh != none)
		LeftHandMesh.CreateAndSetMaterialInstanceConstant(0);

	if (LeftHandOverlayMesh != none && AOCOwner != none && ((AOCOwner.IsLocallyControlled() && !AOCOwner.bIsBot) || AOCOwner.bIsBeingFPObserved))
		LeftHandOverlayMesh.CreateAndSetMaterialInstanceConstant(0);
}

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

    return (HandleLength / WeaponLength)/2;
}

DefaultProperties
{
	`include(BangMod/Include/BangModWeaponAttachment.uci);

KickOffset=(X=50, Y=0, Z=-65)
	KickSize=20.f

	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'Warham.WEP_Warham'
	End Object

	Begin Object Name=SkeletalMeshComponent2
		SkeletalMesh=SkeletalMesh'Warham.WEP_Warham'
	End Object

	WeaponID=EWEP_WarHammer
	WeaponClass=class'BangModWeapon_WarHammer'
	WeaponSocket=wep1hpoint
	LeftHandSocket=LeftHand

	WeaponStaticMeshScale=1
	LeftHandTranslation=(X=0.0,Y=0.0,Z=0.0)

	AttackTypeInfo(0)=(fBaseDamage=75.0, fForce=18000, cDamageType="AOC.AOCDmgType_Blunt", iWorldHitLenience=6)
	AttackTypeInfo(1)=(fBaseDamage=82.0, fForce=18000, cDamageType="AOC.AOCDmgType_Blunt", iWorldHitLenience=6)
	AttackTypeInfo(2)=(fBaseDamage=40.0, fForce=18000, cDamageType="AOC.AOCDmgType_Blunt", iWorldHitLenience=6)
	AttackTypeInfo(3)=(fBaseDamage=0.0, fForce=22500, cDamageType="AOC.AOCDmgType_Blunt", iWorldHitLenience=6)
	AttackTypeInfo(4)=(fBaseDamage=0.0, fForce=25500, cDamageType="AOC.AOCDmgType_Blunt", iWorldHitLenience=6)
	AttackTypeInfo(5)=(fBaseDamage=5.0, fForce=45500.0, cDamageType="AOC.AOCDmgType_Shove", iWorldHitLenience=12)

	Skins(0)={(
		SkeletalMeshPath="Warham.WEP_Warham",
		StaticMeshPath="Warham.mesh_Warham",
		MaterialPath="",
		StaticMeshScale=1.0,
		ImagePath="UI_CustWeaponImages_SWF.skin_warhammer_png"
		)};
	Skins(1)={(
		SkeletalMeshPath="Warham.WEP_Warham",
		StaticMeshPath="Warham.mesh_Warham",
		MaterialPath="",
		StaticMeshScale=1.0,
		ImagePath="UI_CustWeaponImages_SWF.skin_skullcracker_png"
		)};
	Skins(2)={(
		SkeletalMeshPath="Warham.WEP_Warham",
		StaticMeshPath="Warham.mesh_Warham",
		MaterialPath="",
		StaticMeshScale=1.0,
		ImagePath="UI_CustWeaponImages_SWF.skin_warhammer_png"
		)};
	Skins(3)={(
		SkeletalMeshPath="Warham.WEP_Warham",
		StaticMeshPath="Warham.mesh_Warham",
		MaterialPath="",
		StaticMeshScale=1.0,
		ImagePath="UI_CustWeaponImages_SWF.skin_warhammer_png"
		)};
}
