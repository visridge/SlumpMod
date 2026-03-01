/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
* 
* Original Author: Michael Bao
* 
* Manages the different types of weapon hits we have:
* Blunt
* Pierce
* Swing
* Generic
*
* And combinations, projectile variations:
* PierceProj
* PierceBlunt
* SwingBlunt
*/
class BangModDamageType extends AOCDamageType;

DefaultProperties
{
	bOverrideImpactBlood=false
	StopAnimAfterDamageInterval=0.1f
	PhysicsTakeHitMomentumThreshold=10.0f
	bAnimateHipsForDeathAnim=false
	DeathAnimRate = 0.75f
	DeathAnim=CHV_Common_Left_Side_Death
	bCanDecap=false
	bCanHeadExplode=false
	bIsProjectile = false

	DamageType(EDMG_Swing)  = 0.0f
	DamageType(EDMG_Pierce) = 0.0f
	DamageType(EDMG_Blunt)  = 0.0f
	DamageType(EDMG_Generic)= 1.0f

	DirectionalDeathAnims(0)=3p_death_slashF
	DirectionalDeathAnims(1)=3p_death_slashF
	DirectionalDeathAnims(2)=3p_death_slashF
	DirectionalDeathAnims(3)=3p_death_slashF
	DirectionalDeathAnims(4)=3p_1hsharp_death01
	DirectionalDeathAnims(5)=3p_death_stabF
	DirectionalDeathAnims(6)=3p_death_stabB
	DirectionalDeathAnims(7)=3p_death_shovedeathF
	DirectionalDeathAnims(8)=3p_death_shovedeathB

	DecapDeathOverlays(0)=none
	DecapDeathOverlays(1)=3p_death_Rarmdecap
	DecapDeathOverlays(2)=3p_death_Larmdecap
	DecapDeathOverlays(3)=3p_death_Llegdecap
	DecapDeathOverlays(4)=3p_death_Rlegdecap
}
