/**
* Firebug weapon attachment - Cudgel stats with torch skeletal mesh and fire particle effect.
*/
class BangModWeaponAttachment_Firebug extends BangModWeaponAttachment_Cudgel;

simulated function AttachTo(UTPawn OwnerPawn)
{
	super.AttachTo(OwnerPawn);
	LightTorch();
}

simulated function LightTorch()
{
	if (WeaponPSSocket != '' && WeaponPS != none)
	{
		WeaponPSComp = new(self) class'UTParticleSystemComponent';
		WeaponPSComp.bAutoActivate = true;
		WeaponPSComp.SetOwnerNoSee(true);
		WeaponPSComp.SetTemplate(WeaponPS);
		WeaponPSComp.ActivateSystem(true);
		Mesh.AttachComponentToSocket(WeaponPSComp, WeaponPSSocket);

		if ( ((AOCOwner.IsLocallyControlled() && !AOCOwner.bIsBot) || AOCOwner.bIsBeingFPObserved) && !AOCPlayerController(AOCOwner.Controller).bBehindView)
		{
			AttachOverlayEffect();
		}
		else
		{
			WeaponPSComp.SetOwnerNoSee(false);
		}
	}
}

simulated function AttachOverlayEffect()
{
	if (OverlayWeaponPSComp == none)
	{
		OverlayWeaponPSComp = new(self) class'UTParticleSystemComponent';
		OverlayWeaponPSComp.bAutoActivate = true;
		OverlayWeaponPSComp.SetOwnerNoSee(false);
		OverlayWeaponPSComp.SetTemplate(WeaponPS);
		OverlayWeaponPSComp.ActivateSystem(true);
		OverlayMesh.AttachComponentToSocket(OverlayWeaponPSComp, WeaponPSSocket);
	}
}

simulated function ChangeOverlayMeshVisibility(bool bVis)
{
	super.ChangeOverlayMeshVisibility(bVis);

	OverlayWeaponPSComp.SetHidden(bVis);
	WeaponPSComp.SetOwnerNoSee(!bVis);
}

simulated function ForceAttachOverlay()
{
	super.ForceAttachOverlay();

	AttachOverlayEffect();
}

DefaultProperties
{
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'WP_Torches.Skelmeshes.torch01'
	End Object

	Begin Object Name=SkeletalMeshComponent2
		SkeletalMesh=SkeletalMesh'WP_Torches.Skelmeshes.torch01'
	End Object

	WeaponClass=class'BangModWeapon_Firebug'

	WeaponPSSocket=Flame
	WeaponPS=ParticleSystem'CHV_PartiPack.Particles.P_torchfire2'

	Skins(0)={(
		SkeletalMeshPath="WP_Torches.Skelmeshes.torch01",
		StaticMeshPath="WP_Torches.Meshes.torch01_static",
		MaterialPath="",
		StaticMeshScale=1.0,
		ImagePath="UI_CustWeaponImages_SWF.skin_bardiche_png"
		)};
	Skins(1)={(
		SkeletalMeshPath="WP_Torches.Skelmeshes.torch01",
		StaticMeshPath="WP_Torches.Meshes.torch01_static",
		MaterialPath="",
		StaticMeshScale=1.0,
		ImagePath="UI_CustWeaponImages_SWF.skin_bardiche_png"
		)};
	Skins(2)={(
		SkeletalMeshPath="WP_Torches.Skelmeshes.torch01",
		StaticMeshPath="WP_Torches.Meshes.torch01_static",
		MaterialPath="",
		StaticMeshScale=1.0,
		ImagePath="UI_CustWeaponImages_SWF.skin_bardiche_png"
		)};
}
