/**
* BangMod Custom OilPot Projectile
* Implements delayed fire damage - 1 second grace period, then 10 damage/sec for 6 seconds
* Direct hit damage: 1 (inherited from base class)
* 
* Vanilla comparison:
* - Vanilla: 6 damage per tick via SetPawnOnFire for 5 seconds (varies by tick interval)
* - BangMod: 1 sec grace, then 10 damage/sec for 6 seconds (70 total max damage)
*/

class BangModProj_ThrownOilPot extends AOCProj_ThrownOilPot;

var float fGracePeriod;        // Time before damage starts (1 second)
var float fDamagePerSecond;    // Damage dealt per second after grace period
var float fActiveDamageTime;   // How long the fire actively damages (6 seconds)
var float fBurnStartTime;      // When the fire was lit
var bool bGracePeriodActive;   // Whether we're in the grace period

/**
 * Override to track when fire starts and set custom fire duration
 */
simulated function Burn(bool bHitWorld, optional vector HitLocation, optional Vector HitNormal)
{
	super.Burn(bHitWorld, HitLocation, HitNormal);
	
	if (Role == ROLE_Authority)
	{
		bGracePeriodActive = true;
		fBurnStartTime = WorldInfo.TimeSeconds;
		
		// Clear the default timer and set our custom duration
		// Fire will last exactly: grace period + active damage time
		ClearTimer('Shutdown');
		SetTimer(fGracePeriod + fActiveDamageTime, false, 'Shutdown');
	}
}

/**
 * Override damage check to implement grace period and custom damage
 */
function checkNearPlayersToBurn()
{
	local AOCPawn P;
	local AOCStaticMeshActor_PaviseShield Pavise;
	local float distFromPawn;
	local float timeSinceBurnStart;
	local float damageAmount;
	
	timeSinceBurnStart = WorldInfo.TimeSeconds - fBurnStartTime;
	
	// Check if we're still in grace period
	if (timeSinceBurnStart < fGracePeriod)
	{
		// Don't damage anyone during grace period
		bBurnFirstTick = false;
		return;
	}
	
	// Check if we've exceeded active damage time
	if (timeSinceBurnStart > (fGracePeriod + fActiveDamageTime))
	{
		// Stop damaging, but keep the fire effect burning
		bBurnFirstTick = false;
		return;
	}
	
	// Calculate damage for this tick (called every 0.2 seconds)
	// 10 damage per second = 2 damage per 0.2 second tick
	damageAmount = fDamagePerSecond * 0.2;
	
	foreach WorldInfo.AllPawns(class'AOCPawn', P)
	{
		if (P.IsAliveAndWell() && !P.bInfiniteHealth && P.RealityID == RealityID)
		{
			distFromPawn = VSizeSq(BurnLocation - P.Location);
			
			if (distFromPawn <= fFireRadius)
			{
				// Only set on fire if not already burning (avoids resetting the duration)
				if (!P.bIsBurning)
				{
					// Set visual fire effect (1 second duration) only when we damage
					P.SetPawnOnFire(FirePS, OwnerPawn.Controller, OwnerPawn, class'BangModDmgType_OilPotBurn', 1.0);
				}
				
				// Deal our custom damage every tick
				P.TakeDamage(damageAmount, OwnerPawn.Controller, P.Location, vect(0,0,0), class'BangModDmgType_OilPotBurn');
			}
		}
	}

	// Check for nearby pavise shields
	foreach WorldInfo.AllActors(class'AOCStaticMeshActor_PaviseShield', Pavise)
	{
		if (Pavise.Health > 0)
		{
			Pavise.AOCTakeDamage(9999, Pavise.Location, Vect(0.f, 0.f, 0.f), none, class'AOCDmgType_Burn');
		}
	}

	bBurnFirstTick = false;
}

/**
 * Override to spawn fire particle effect upright instead of rotated with surface
 * Fixes invisible fire bug when oil pot hits moving objects (carts, etc)
 * The fire volume (AOE damage) position is correct, but the particle effect
 * was rotating/moving with the hit surface, causing visual desync
 */
simulated function SpawnExplosionEffects(vector HitLocation, vector HitNormal)
{
	local vector LightLoc, LightHitLocation, LightHitNormal;
	local MaterialInstanceTimeVarying MITV_Decal;
	 
	if (WorldInfo.NetMode != NM_DedicatedServer && !bSuppressExplosionFX)
	{
		bSuppressExplosionFX = true;
		
		if (ProjectileLight != None)
		{
			DetachComponent(ProjectileLight);
			ProjectileLight = None;
		}
		
		if (ProjExplosionTemplate != None)
		{
			// Spawn fire effect UPRIGHT (Rot(0,0,0)) instead of rotated with surface
			// This prevents the particle from rotating/moving with dynamic objects like carts
			ProjExplosion = WorldInfo.MyEmitterPool.SpawnEmitter(ProjExplosionTemplate, HitLocation, Rot(0,0,0), none);
			SetExplosionEffectParameters(ProjExplosion);

			if (!WorldInfo.bDropDetail && ((ExplosionLightClass != None) || (ExplosionDecal != none)) && ShouldSpawnExplosionLight(HitLocation, HitNormal))
			{
				if (ExplosionLightClass != None)
				{
					if (AOCTrace(LightHitLocation, LightHitNormal, HitLocation + (0.25 * ExplosionLightClass.default.TimeShift[0].Radius * HitNormal), HitLocation, false) == None)
					{
						LightLoc = HitLocation + (0.25 * ExplosionLightClass.default.TimeShift[0].Radius * (vect(1,0,0) >> ProjExplosion.Rotation));
					}
					else
					{
						LightLoc = HitLocation + (0.5 * VSize(HitLocation - LightHitLocation) * (vect(1,0,0) >> ProjExplosion.Rotation));
					}

					UDKEmitterPool(WorldInfo.MyEmitterPool).SpawnExplosionLight(ExplosionLightClass, LightLoc, none);
				}

				// Spawn decal
				if (ExplosionDecal != None && Pawn(ImpactedActor) == None)
				{
					if (MaterialInstanceTimeVarying(ExplosionDecal) != None)
					{
						// hack, since they don't show up on terrain anyway
						if (Terrain(ImpactedActor) == None)
						{
							MITV_Decal = new(self) class'MaterialInstanceTimeVarying';
							MITV_Decal.SetParent(ExplosionDecal);
							WorldInfo.MyDecalManager.SpawnDecal(MITV_Decal, HitLocation, rotator(-HitNormal), DecalWidth, DecalHeight, 10.0, false);
							MITV_Decal.SetScalarStartTime(DecalDissolveParamName, DurationOfDecal);
						}
					}
					else
					{
						WorldInfo.MyDecalManager.SpawnDecal(ExplosionDecal, HitLocation, rotator(-HitNormal), DecalWidth, DecalHeight, 10.0, true);
					}
				}
			}
		}

		if (ExplosionSound != None && !bSuppressSounds)
		{
			PlaySound(ExplosionSound, true);
		}
		
		// Stop flying sound
		if (AmbientComponent != none)
		{
			AmbientComponent.bShouldRemainActiveIfDropped = false;
			AmbientComponent.Stop();
			AmbientComponent.SoundCue = none;
		}
		
		// Set timer to clean up particle effect (client-side)
		SetTimer(fGracePeriod + fActiveDamageTime, false, 'Shutdown');
		
		bSuppressSounds = true;
	}
}

DefaultProperties
{
	fGracePeriod=1.0           // 1 second grace period before damage starts
	fDamagePerSecond=10.0      // 10 damage per second
	fActiveDamageTime=7.0      // Deal damage for 7 seconds (after grace period)
	bGracePeriodActive=false
	fBurnStartTime=0.0
}
