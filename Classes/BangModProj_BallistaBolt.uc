/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
*
* Original Author: Richard Pragnell
*
* Bolt projectile for AOCSWPBallista.
*/

class BangModProj_BallistaBolt extends AOCProj_BallistaBolt;

var repnotify bool bCollidedWorld;
var int PawnPassThroughCount;

var SkeletalMeshComponent SKMesh;

var editinline export		RB_ConstraintInstance	LeftFootBoardConstraintInstance;
var editinline export		RB_ConstraintSetup		FootBoardConstraintSetup;

var float SplashRadius;
var float SplashDamage;


DefaultProperties
{
	Begin Object Name=StaticMeshComponent0
		StaticMesh=StaticMesh'CHV_Ballista.SM_ballistabolt'
	End Object
	
	//TickGroup=TG_PostAsyncWork
	/*Begin Object Class=SkeletalMeshComponent Name=SkelMeshComponent0
		RBChannel=RBCC_Vehicle
		RBCollideWithChannels=(Default=TRUE,BlockingVolume=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE,Vehicle=TRUE)
		BlockActors=true
		BlockZeroExtent=true
		BlockRigidBody=true
		BlockNonzeroExtent=true
		CollideActors=true
		bForceDiscardRootMotion=true
		bUseSingleBodyPhysics=1
		bNotifyRigidBodyCollision=true
		ScriptRigidBodyCollisionThreshold=250.0
		//SkeletalMesh=SkeletalMesh'CHV_Ballista.ballistabolt'
		SkeletalMesh=SkeletalMesh'VH_Hoverboard.Mesh.SK_VH_Hoverboard'
		PhysicsAsset=PhysicsAsset'VH_Hoverboard.Mesh.SK_VH_Hoverboard_Physics'
		bHasPhysicsAssetInstance=true
		RBDominanceGroup=16
	End Object
	SKMesh=SkelMeshComponent0
	Components.add(SkelMeshComponent0)*/

	ProjExplosionTemplate=ParticleSystem'CHV_EnvironmentParticles.blist.P_BallistaImpact_world'
	ProjFlightTemplate=ParticleSystem'CHV_Particles_01.Particles.P_ArrowTrail'
	speed=8000.0f
	MaxSpeed=8500.0f
	Damage=300.0
	DamageRadius=30.0
	MomentumTransfer=0
	LifeSpan=15.0f
	bCollideWorld=true
	Physics=PHYS_Falling
	CheckRadius=36.0
	CustomGravityScaling=0.25f
	TerminalVelocity=4500
	fProjectileAttachCompensation=9.0f

	SplashRadius=1.f
	SplashDamage=1.f

	MyDamageType=class'AOCDmgType_BallistaBolt'

	AmbientSound=SoundCue'A_Projectile_Flight.Flight_Ballista'
	ImpactSounds= {(
		Light=SoundCue'A_Impacts_Missile.Ballista_Light',
		Medium=SoundCue'A_Impacts_Missile.Ballista_Medium',
		Heavy=SoundCue'A_Impacts_Missile.Ballista_Heavy',
		Stone=SoundCue'A_Phys_Mat_Impacts.Ballista_Stone',
		Dirt=SoundCue'A_Phys_Mat_Impacts.Ballista_Dirt',
		Wood=SoundCue'A_Phys_Mat_Impacts.Ballista_Wood',
		Gravel=SoundCue'A_Phys_Mat_Impacts.Ballista_Dirt',
		Foliage=SoundCue'A_Phys_Mat_Impacts.Ballista_Dirt',
		Sand=SoundCue'A_Phys_Mat_Impacts.Ballista_Dirt',
		Water=SoundCue'A_Phys_Mat_Impacts.Ballista_water',
		ShallowWater=SoundCue'A_Phys_Mat_Impacts.Ballista_water',
		Metal=SoundCue'A_Phys_Mat_Impacts.Ballista_Metal',
		Snow=SoundCue'A_Phys_Mat_Impacts.Ballista_Dirt',
		Ice=SoundCue'A_Phys_Mat_Impacts.Ballista_Dirt',
		Mud=SoundCue'A_Phys_Mat_Impacts.Ballista_Dirt',
		Tile=SoundCue'A_Phys_Mat_Impacts.Ballista_Dirt')
	}

	bNetTemporary=False
	bWaitForEffects=false
	YawRate = 0.0f
	PitchRate = 0.0f
	RollRate = 0.0f
	bCanPickupProj=false
	bBounce=false

	ProjCamPosModX=-50
	ProjCamPosModZ=25
	PawnPassThroughCount=0
	TraceRadius = 8.f

	bOverrideDefaultExplosionDeffect=true
	PhysBasedParticleExplosions={(
		Stone=ParticleSystem'CHV_EnvironmentParticles.blist.P_BallistaImpact_world',
		Dirt=ParticleSystem'CHV_EnvironmentParticles.blist.P_BallistaImpact_world',
		Gravel=ParticleSystem'CHV_EnvironmentParticles.blist.P_BallistaImpact_world',
		Foliage=ParticleSystem'CHV_EnvironmentParticles.blist.P_BallistaImpact_world',
		Sand=ParticleSystem'CHV_EnvironmentParticles.blist.P_BallistaImpact_world',
		Water=ParticleSystem'CHV_EnvironmentParticles.blist.P_BallistaImpact_water',
		Metal=ParticleSystem'CHV_EnvironmentParticles.blist.P_BallistaImpact_world',
		Snow=ParticleSystem'CHV_EnvironmentParticles.Snow.P_LargeImpact_Snow',
		Wood=ParticleSystem'CHV_EnvironmentParticles.blist.P_BallistaImpact_world',
		Ice=ParticleSystem'CHV_EnvironmentParticles.Snow.P_LargeImpact_Snow',
		Mud=ParticleSystem'CHV_EnvironmentParticles.blist.P_BallistaImpact_world',
		Tile=ParticleSystem'CHV_EnvironmentParticles.blist.P_BallistaImpact_world')
	}

	bLimitImpactSound=true
}
