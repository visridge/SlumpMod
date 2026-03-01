/**
 * Copyright 2013, Torn Banner Studios, All rights reserved
 *
 * Author: Brady Brenot
 * 
 * The presentation side of characters. FamilyInfo is the gameplay side.
 */
class BangModCharacterInfo extends AOCCharacterInfo
	abstract
	dependson(AOCPawn);

var array<byte> AllowedTeams;
var array<byte> AllowedClasses;

//Ownership information
var AOCGearData GearData;

/** Customizations */

var array<AOCShieldPatternData> ShieldPatterns;
var array<AOCTabardData> Tabards;
var array<AOCHelmetData> Helmets;
//var array<AOCVoiceData> Voices;

/* Character presentation */

/************************************************************************/
/*  3P Character Info                                                   */
/************************************************************************/

var bool bCanDecap;

/** Path to the mesh for this character */
var string CharacterMeshPath;

/** Material applied to the character head/body in team games */
var string BodyMaterialPath;
var string HeadMaterialPath;

var string DecapMeshPath;


/************************************************************************/
/*  1P Character Info                                                   */
/************************************************************************/

/** 1p mesh */
var string OwnerMeshPath;

/************************************************************************/
/*  Stand-in assets used when character assets have not yet loaded      */
/*  Be mindful that you keep the overall number of different standin    */
/*  assets (across all CharacterInfos) low, since each one increases    */
/*  the permanent memory load. Currently we only do the main characters */
/************************************************************************/
var SkeletalMesh StandinMesh;
var SkeletalMesh StandinOwnerMesh;
var SkeletalMesh StandinDecapMesh;
var MaterialInterface StandinBodyMaterial;
var MaterialInterface StandinHeadMaterial;

/************************************************************************/
/*  Animations                                                          */
/************************************************************************/

// Anim Sets
var array<AnimSet> FirstPersonAnimSets;
var array<AnimSet> ThirdPersonAnimSets;
var AnimTree OverrideMeshAnimTree;
var AnimTree OverrideOwnerMeshAnimTree;


/************************************************************************/
/*  Sounds (move out into AOCVoiceData)                                 */
/************************************************************************/

// Mobile Battle Cry
var SoundCue MobileBattleCry;

var String SoundGroupClassName;
//TODO: bbrenot: this
var class<UTPawnSoundGroup> SoundGroupClass;

var string OverridePawnArmorType;

/************************************************************************/
/*  Misc.                                                               */
/************************************************************************/

var float DefaultMeshScale;
var float BaseTranslationOffset;

/** Physics Asset to use  */
var PhysicsAsset		PhysAsset;
var class<UTEmit_HitEffect> BloodEmitterClass;

// bone hierarchy array
var array<BoneInfo> BoneHierarchy;
/** Animation sets to use for a character in this 'family' */
var	array<AnimSet>		AnimSets;
/** Names for specific bones in the skeleton */
var name			LeftFootBone;
var name			RightFootBone;
var array<name>		TakeHitPhysicsFixedBones;

/************************************************************************/
/*  Functions                                                           */
/************************************************************************/

static function bool IsValidFor(byte TeamID, byte ClassID)
{
	local int i;
	local bool bFoundTeam;

	

	bFoundTeam = false;
	for(i = 0; i < default.AllowedTeams.Length; ++i)
	{
		if(default.AllowedTeams[i] == TeamID)
		{
			bFoundTeam = true;
			break;
		}
	}

	if(bFoundTeam)
	{
		for(i = 0; i < default.AllowedClasses.Length; ++i)
		{
			if(default.AllowedClasses[i] == ClassID)
			{
				return true;
			}
		}
	}

	

	return false;
}

defaultproperties
{
	BloodEmitterClass=class'UTGame.UTEmit_BloodSpray'

	BoneHierarchy(0)=(BoneName=b_pelvis,BoneLocation=EHIT_Torso,BoneTreeHeight=0)
	BoneHierarchy(1)=(BoneName=b_spine_A,BoneLocation=EHIT_Torso,BoneTreeHeight=1)
	BoneHierarchy(2)=(BoneName=b_spine_B,BoneLocation=EHIT_Torso,BoneTreeHeight=2)
	BoneHierarchy(3)=(BoneName=b_spine_C,BoneLocation=EHIT_Torso,BoneTreeHeight=3)
	BoneHierarchy(4)=(BoneName=b_spine_D,BoneLocation=EHIT_Torso,BoneTreeHeight=4)
	BoneHierarchy(5)=(BoneName=b_Neck,BoneLocation=EHIT_Head,BoneTreeHeight=5)
	BoneHierarchy(6)=(BoneName=b_Head,BoneLocation=EHIT_Head,BoneTreeHeight=6)
	BoneHierarchy(7)=(BoneName=b_l_clavicle,BoneLocation=EHIT_Torso,BoneTreeHeight=5)
	BoneHierarchy(8)=(BoneName=b_l_shoulder,BoneLocation=EHIT_Arm,BoneTreeHeight=6)
	BoneHierarchy(9)=(BoneName=b_l_elbow,BoneLocation=EHIT_Arm,BoneTreeHeight=7)
	BoneHierarchy(10)=(BoneName=b_l_wrist,BoneLocation=EHIT_Arm,BoneTreeHeight=8)
	BoneHierarchy(11)=(BoneName=b_r_clavicle,BoneLocation=EHIT_Torso,BoneTreeHeight=5)
	BoneHierarchy(12)=(BoneName=b_r_shoulder,BoneLocation=EHIT_Arm,BoneTreeHeight=6)
	BoneHierarchy(13)=(BoneName=b_r_elbow,BoneLocation=EHIT_Arm,BoneTreeHeight=7)
	BoneHierarchy(14)=(BoneName=b_r_wrist,BoneLocation=EHIT_Arm,BoneTreeHeight=8)
	BoneHierarchy(15)=(BoneName=b_l_leg,BoneLocation=EHIT_Legs,BoneTreeHeight=1)
	BoneHierarchy(16)=(BoneName=b_l_knee,BoneLocation=EHIT_Legs,BoneTreeHeight=2)
	BoneHierarchy(17)=(BoneName=b_l_ankle,BoneLocation=EHIT_Legs,BoneTreeHeight=3)
	BoneHierarchy(18)=(BoneName=b_r_leg,BoneLocation=EHIT_Legs,BoneTreeHeight=1)
	BoneHierarchy(19)=(BoneName=b_r_knee,BoneLocation=EHIT_Legs,BoneTreeHeight=2)
	BoneHierarchy(20)=(BoneName=b_r_ankle,BoneLocation=EHIT_Legs,BoneTreeHeight=3)

	LeftFootBone=b_l_ankle
	RightFootBone=b_r_ankle

	DefaultMeshScale=1.5
	BaseTranslationOffset=14.0

	bCanDecap = true

	ShieldPatterns(0)=(GearData=(GearNameID=Disabled))

	/*
	StandinMesh=SkeletalMesh''
	StandinDecapMesh=SkeletalMesh''
	StandinOwnerMesh=SkeletalMesh''
	StandinHeadMaterial=SkeletalMesh''
	StandinBodyMaterial=SkeletalMesh''
	*/
}
