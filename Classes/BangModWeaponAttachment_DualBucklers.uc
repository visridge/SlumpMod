/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
*
* Original Author: Michael Bao
*
* The Weapon Attachment for Dual Bucklers.
*/
class BangModWeaponAttachment_DualBucklers extends AOCWeaponAttachment_Fists;

var SkeletalMeshComponent LeftHandMesh;
var SkeletalMeshComponent LeftHandOverlayMesh;
var bool bLeftOverlayAttached;
var name LeftHandSocket;
var vector RightHandTranslation;
var vector LeftHandTranslation;

simulated function EnsureLeftHandComponents()
{
	if (LeftHandMesh == none)
	{
		LeftHandMesh = new(self) class'SkeletalMeshComponent';
		LeftHandMesh.SetSkeletalMesh(Mesh.SkeletalMesh);
		LeftHandMesh.Scale = Mesh.Scale;
	}

	if (LeftHandOverlayMesh == none)
	{
		LeftHandOverlayMesh = new(self) class'SkeletalMeshComponent';
		LeftHandOverlayMesh.SetSkeletalMesh(OverlayMesh.SkeletalMesh);
		LeftHandOverlayMesh.Scale = OverlayMesh.Scale;
		LeftHandOverlayMesh.SetHidden(true);
	}
}

simulated function AttachTo(UTPawn OwnerPawn)
{
	AOCOwner = AOCPawn(OwnerPawn);
	EnsureLeftHandComponents();

	if (OwnerPawn.Mesh != none)
	{
		Mesh.SetShadowParent(OwnerPawn.Mesh);
		Mesh.SetLightEnvironment(OwnerPawn.LightEnvironment);
		AOCOwner.HandleSocketAttachment(false, Mesh, WeaponSocket, self);
		Mesh.SetTranslation(RightHandTranslation);
		SetBase(OwnerPawn,, OwnerPawn.Mesh, WeaponSocket);

		LeftHandMesh.SetShadowParent(OwnerPawn.Mesh);
		LeftHandMesh.SetLightEnvironment(OwnerPawn.LightEnvironment);
		AOCOwner.HandleSocketAttachment(false, LeftHandMesh, LeftHandSocket, self);
		LeftHandMesh.SetTranslation(LeftHandTranslation);
	}

	OwnerPawn.SetWeapAnimType(WeapAnimType);
	if (!AOCPawn(OwnerPawn).bQuickfire)
		AOCPawn(OwnerPawn).SetWeaponSequence(class<AOCWeapon>(WeaponClass), class'AOCShield_None');

	if (OwnerPawn.IsLocallyControlled())
	{
		OwnerPawn.SetThirdPersonCamera(AOCPlayerController(OwnerPawn.Controller).bBehindView);
		UpdateLeftHandVisibility(AOCPlayerController(OwnerPawn.Controller).bBehindView);
	}
	else if (AOCPawn(OwnerPawn).bIsBeingFPObserved)
	{
		OwnerPawn.SetThirdPersonCamera(AOCPlayerController(GetALocalPlayerController()).bBehindView);
		UpdateLeftHandVisibility(AOCPlayerController(GetALocalPlayerController()).bBehindView);
	}
	else
	{
		UpdateLeftHandVisibility(true);
	}

	AOCOwner.ParryComponent.SetTranslation(AOCOwner.PawnFamily.ParryBoxTranslation + ParryBoxTranslation);

	GotoState('CurrentlyAttached');
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
	super.DetachFrom(MeshCpnt);

	if (AOCOwner != none)
	{
		if (LeftHandMesh != none)
			AOCOwner.Mesh.DetachComponent(LeftHandMesh);

		if (LeftHandOverlayMesh != none && ((AOCOwner.IsLocallyControlled() && !AOCOwner.bIsBot) || AOCOwner.bIsBeingFPObserved))
			AOCOwner.OwnerMesh.DetachComponent(LeftHandOverlayMesh);
	}

	bLeftOverlayAttached = false;
}

simulated function SetSkin(Material NewMaterial)
{
	super.SetSkin(NewMaterial);

	if (LeftHandMesh != none)
		LeftHandMesh.CreateAndSetMaterialInstanceConstant(0);

	if (LeftHandOverlayMesh != none && AOCOwner != none && ((AOCOwner.IsLocallyControlled() && !AOCOwner.bIsBot) || AOCOwner.bIsBeingFPObserved))
		LeftHandOverlayMesh.CreateAndSetMaterialInstanceConstant(0);
}

defaultproperties
{
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'WP_shld_Buckler_Variant_01.WEP_Buckler_variant_01'
		Scale=0.7
	End Object

	Begin Object Name=SkeletalMeshComponent2
		SkeletalMesh=SkeletalMesh'WP_shld_Buckler_Variant_01.WEP_Buckler_variant_01'
		Scale=0.7
	End Object

	WeaponID=EWEP_Fists
	WeaponClass=class'BangModWeapon_DualBucklers'
	WeaponSocket=RightHand
	LeftHandSocket=LeftHand
	WeaponWidth=5.0
	FistExtention=42.0

	WeaponStaticMesh=StaticMesh'WP_shld_Buckler_Variant_01.SM_Buckler_variant_01'
	WeaponStaticMeshScale=0.7

	RightHandTranslation=(X=0.0,Y=0.0,Z=0.0)
	LeftHandTranslation=(X=0.0,Y=0.0,Z=0.0)

	AttackTypeInfo(0)=(fBaseDamage=30, fForce=22500, cDamageType="AOC.AOCDmgType_Fists", iWorldHitLenience=6)
	AttackTypeInfo(1)=(fBaseDamage=35, fForce=22500, cDamageType="AOC.AOCDmgType_Fists", iWorldHitLenience=6)
	AttackTypeInfo(2)=(fBaseDamage=20, fForce=22500, cDamageType="AOC.AOCDmgType_Fists", iWorldHitLenience=6)
	AttackTypeInfo(3)=(fBaseDamage=50.0, fForce=33000, cDamageType="AOC.AOCDmgType_Fists", iWorldHitLenience=6)
	AttackTypeInfo(4)=(fBaseDamage=0.0, fForce=22500, cDamageType="AOC.AOCDmgType_Fists", iWorldHitLenience=6)
	AttackTypeInfo(5)=(fBaseDamage=5.0, fForce=45500.0, cDamageType="AOC.AOCDmgType_Shove", iWorldHitLenience=12)

	Skins(0)={(
		SkeletalMeshPath="WP_shld_Buckler_Variant_01.WEP_Buckler_variant_01",
		StaticMeshPath="WP_shld_Buckler_Variant_01.SM_Buckler_variant_01",
		MaterialPath="",
		StaticMeshScale=0.7,
		ImagePath="UI_CustWeaponImages_SWF.skin_vicomte_buckler_png",
		ShieldPatterns=(
			(PatternName="Solid", TexturePath="WP_shld_Buckler_Variant_01.T_buckler_p03"),
			(PatternName="Quadrant", TexturePath="WP_shld_Buckler_Variant_01.T_buckler_p01"),
			(PatternName="Stripes", TexturePath="WP_shld_Buckler_Variant_01.T_buckler_p02"),
			(PatternName="Checkers", TexturePath="WP_shld_Buckler_Variant_01.T_buckler_p04"))
		)};
}