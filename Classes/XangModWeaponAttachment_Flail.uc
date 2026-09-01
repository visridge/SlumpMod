/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
*
* Original Author: Michael Bao
*
* The weapon that is replicated to all clients: Flail.
*/
class XangModWeaponAttachment_Flail extends AOCWeaponAttachment_Flail;

var Vector PreviousBucklerLoc;

simulated state Release
{
	/** Perform Kick Tracers */
	simulated function PerformKickTracers(bool bAlt)
	{
		if (CurrentAttack == Attack_Shove)
		{
			super.PerformKickTracers(bAlt);
		}
		else
		{
			SpecialWeaponTracers();
		}
	}
}

DefaultProperties
{
	`include(XangMod/Include/XangModWeaponAttachment.uci);

	bUseWeaponPhysics = true
	Begin Object Name=SkeletalMeshComponent0
		Animations=none
		//Translation=(Z=1)
		//Rotation=(Roll=-400)
		Scale=1.4
		bUpdateSkelWhenNotRendered=true
		bForceRefPose=0
		bIgnoreControllersWhenNotRendered=false
		bOverrideAttachmentOwnerVisibility=false
		AnimTreeTemplate=AnimTree'ANIM_3p_WEP_flail.Flail_at'
		AnimSets(0)=AnimSet'ANIM_3p_WEP_flail.ANIM_3p_WEP_flail'
		PhysicsAsset=PhysicsAsset'WP_hbl_flail.WEP_flail_Physics'
		SkeletalMesh=SkeletalMesh'WP_hbl_flail.WEP_flail'
		bHasPhysicsAssetInstance=true
	End Object

	Begin Object Name=SkeletalMeshComponent2
		Animations=none
		//Translation=(Z=1)
		//Rotation=(Roll=-400)
		Scale=1.4
		bUpdateSkelWhenNotRendered=true
		bForceRefPose=0
		bIgnoreControllersWhenNotRendered=false
		bOverrideAttachmentOwnerVisibility=false
		AnimTreeTemplate=AnimTree'ANIM_3p_WEP_flail.Flail_at'
		AnimSets(0)=AnimSet'ANIM_3p_WEP_flail.ANIM_1p_WEP_flail'
		PhysicsAsset=PhysicsAsset'WP_hbl_flail.WEP_flail_Physics'
		bHasPhysicsAssetInstance=true
		SkeletalMesh=SkeletalMesh'WP_hbl_flail.WEP_flail'
	End Object

	WeaponID=EWEP_Flail
	WeaponClass=class'XangModWeapon_Flail'
	WeaponSocket = wep2hpoint

	WeaponNumTracers=1

	WeaponStaticMeshScale=1.4

	ParryBoxTranslation={(X=10.0f, Y=0.0f, Z=0.0f)}

	AttackTypeInfo(0)=(fBaseDamage=60.0, fForce=22500, cDamageType="AOC.AOCDmgType_PierceBlunt", iWorldHitLenience=6)
	AttackTypeInfo(1)=(fBaseDamage=70, fForce=22500, cDamageType="AOC.AOCDmgType_PierceBlunt", iWorldHitLenience=6)
	AttackTypeInfo(2)=(fBaseDamage=35, fForce=22500, cDamageType="AOC.AOCDmgType_Blunt", iWorldHitLenience=6)
	AttackTypeInfo(3)=(fBaseDamage=0.0, fForce=22500, cDamageType="AOC.AOCDmgType_Blunt", iWorldHitLenience=6)
	AttackTypeInfo(4)=(fBaseDamage=0.0, fForce=22500, cDamageType="AOC.AOCDmgType_Blunt", iWorldHitLenience=6)
	AttackTypeInfo(5)=(fBaseDamage=5.0, fForce=45500.0, cDamageType="AOC.AOCDmgType_Shove", iWorldHitLenience=12)

	Skins(0)={(
		SkeletalMeshPath="WP_hbl_flail.WEP_flail",
		StaticMeshPath="WP_hbl_flail.sm_Flail",
		MaterialPath="",
		StaticMeshScale=1.4,
		ImagePath="UI_CustWeaponImages_SWF.skin_bardiche_png"
		)};
}
