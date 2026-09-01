/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
*
* Original Author: Michael Bao
*
* 2-Handed Flail weapon attachment.
*
* Extends the XangMod heavy flail attachment so it inherits:
*   - bUseWeaponPhysics=true and a weapon AnimTree (Flale.FlaleAnimTree).
*     The chain and flail head are PhysX-simulated and whip in response to
*     camera/body movement, just like the vanilla flail.
*   - The XangModWeaponAttachment netcode include (120 Hz priority).
*   - Heavy-flail blunt damage values (70 / 75 / 35).
*
* Overrides the vanilla flail mesh/physics with the purpose-built 2H flail
* from the Flale package:
*   - Skeletal mesh:  Flale.WEP_Flale
*   - Physics asset:  Flale.WEP_Flale_Physics
*   - Static mesh:    Flale.Mesh_Flale
*
* WeaponSocket is the two-handed grip socket (wep2haxepoint) so the whole
* flail is held like a grand mace / double axe while the pawn plays the
* doubleaxe animation set.
*
* Tracers: the stock flail traces a single line from the handle socket
* (TraceStart) out to the head socket (TraceEnd) through the physics-driven
* mesh, with the shaft portion (TraceStart->TraceMid) flagged parry-only via
* GetHandleTracerPercent.  Because the head socket is on the simulated chain,
* the damage tracer follows the wobbling head automatically.
*/
class XangModWeaponAttachment_2HFlail extends XangModWeaponAttachment_HFlail;

/** Stab should thrust with the haft only, not the chain/head, so route the
 *  stab tracer from the grip (TraceStart) to the end of the handle
 *  (TraceMid) instead of the flail head (TraceEnd).  Slashes and overheads
 *  keep the full grip->head line so the chain/head still whip through them.
 *  Requires the Flale mesh to have TraceStart/TraceMid/TraceEnd sockets
 *  (the same set the vanilla flail uses). */
simulated function GetTracerSocketNames(out name beginSocketName, out name endSocketName, int i)
{
	if (CurrentAttack == Attack_Stab)
	{
		beginSocketName = 'TraceStart';
		endSocketName = 'TraceMid';
	}
	else
	{
		super.GetTracerSocketNames(beginSocketName, endSocketName, i);
	}
}

/** The shortened stab line is all haft, so none of it should be treated as
 *  the parry-only handle portion -- otherwise the stab would never damage. */
simulated function float GetHandleTracerPercent(int i)
{
	if (CurrentAttack == Attack_Stab)
		return 0.0f;

	return super.GetHandleTracerPercent(i);
}

DefaultProperties
{
	
	//
	// PHYSICS: the flail's dangling chain is PhysX full-anim-weight physics,
	// which only runs when the component has an AnimTree to drive the
	// per-bone blend (SetFullAnimWeightBonesFixed in ToggleWeaponPhysics).
	// A plain ref-pose component (like the DoubleAxe) has no AnimTree and
	// therefore no flappy physics -- the chain renders as one rigid line.
	// So we keep a weapon AnimTree here.
	//
	// GRIP: the vanilla flail AnimTree referenced the 1H flail weapon
	// animations (ANIM_3p_WEP_flail), which posed the weapon out of the
	// hands.  We instead use the user-authored FlaleAnimTree + FlaleAnimSet,
	// which retarget those sequences onto the Flale weapon skeleton.  The
	// animset animates all six weapon bones, so the physics blend has a full
	// rest pose to blend against while the chain stays PhysX-driven.

	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'Flale.WEP_Flale'
		PhysicsAsset=PhysicsAsset'Flale.WEP_Flale_Physics'
		bHasPhysicsAssetInstance=true
		AnimTreeTemplate=AnimTree'Flale.FlaleAnimTree'
		Animations=None
		AnimSets(0)=AnimSet'Flale.FlaleAnimSet'
		Scale=1.0
	End Object

	Begin Object Name=SkeletalMeshComponent2
		SkeletalMesh=SkeletalMesh'Flale.WEP_Flale'
		PhysicsAsset=PhysicsAsset'Flale.WEP_Flale_Physics'
		bHasPhysicsAssetInstance=true
		AnimTreeTemplate=AnimTree'Flale.FlaleAnimTree'
		Animations=None
		AnimSets(0)=AnimSet'Flale.FlaleAnimSet'
		Scale=1.0
	End Object

	WeaponClass=class'XangModWeapon_2HFlail'
	WeaponSocket=wep2haxepoint
	WeaponStaticMeshScale=1.0

	AttackTypeInfo(0)=(fBaseDamage=75.0, fForce=16000, cDamageType="AOC.AOCDmgType_Blunt", iWorldHitLenience=6)
    AttackTypeInfo(1)=(fBaseDamage=82.0, fForce=16000, cDamageType="AOC.AOCDmgType_Blunt", iWorldHitLenience=6)
    AttackTypeInfo(2)=(fBaseDamage=25.0, fForce=18000, cDamageType="AOC.AOCDmgType_PierceBlunt", iWorldHitLenience=6)
    AttackTypeInfo(3)=(fBaseDamage=0.0, fForce=22500, cDamageType="AOC.AOCDmgType_Blunt", iWorldHitLenience=6)
    AttackTypeInfo(4)=(fBaseDamage=0.0, fForce=32500, cDamageType="AOC.AOCDmgType_Blunt", iWorldHitLenience=6)
    AttackTypeInfo(5)=(fBaseDamage=5.0, fForce=45500.0, cDamageType="AOC.AOCDmgType_Shove", iWorldHitLenience=12)


	Skins(0)={(
		SkeletalMeshPath="Flale.WEP_Flale",
		StaticMeshPath="Flale.Mesh_Flale",
		MaterialPath="",
		StaticMeshScale=1.0,
		ImagePath="ui_custweaponimages_swf.skin_flail_png"
		)};

	Skins(1)={(
		SkeletalMeshPath="Flale.WEP_Flale",
		StaticMeshPath="Flale.Mesh_Flale",
		MaterialPath="",
		StaticMeshScale=1.0,
		ImagePath="ui_custweaponimages_swf.skin_flail_png"
		)};
}
