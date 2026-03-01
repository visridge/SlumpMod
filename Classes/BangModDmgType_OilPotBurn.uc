/**
* BangMod OilPot Burn Damage Type
* Custom damage type with 0 DamageOverTime so SetPawnOnFire only applies visual effects
* All actual damage is handled manually by the projectile
*/
class BangModDmgType_OilPotBurn extends AOCDmgType_Burn;

DefaultProperties
{
	bIsProjectile = false
	DamageType(EDMG_Swing)  = 0.0f
	DamageType(EDMG_Pierce) = 0.0f
	DamageType(EDMG_Blunt)  = 0.0f
	DamageType(EDMG_Generic)= 1.0f

	// Set to 0 so SetPawnOnFire doesn't add damage on top of our manual damage
	DamageOverTime = 0.0f
	DOTTime = 0.4f  // Visual effect duration (0.4 seconds)

	DirectionalDeathAnims(0)=3p_death_firedeath
	DirectionalDeathAnims(1)=3p_death_firedeath
	DirectionalDeathAnims(2)=3p_death_firedeath
	DirectionalDeathAnims(3)=3p_death_firedeath
	DirectionalDeathAnims(4)=3p_death_firedeath
	DirectionalDeathAnims(5)=3p_death_firedeath
	DirectionalDeathAnims(6)=3p_death_firedeath
	DirectionalDeathAnims(7)=3p_death_firedeath
	DirectionalDeathAnims(8)=3p_death_firedeath
}
