/**
* XangMod Torch (Firebug) Burn Damage Type
* Lighter burn than vanilla torch throw - melee hit bonus, not a projectile.
* 4 damage/tick * 3 ticks (one per second) = up to 12 total fire damage.
*/
class XangModDmgType_TorchBurn extends AOCDmgType_Burn;

DefaultProperties
{
	bIsProjectile = false
	DamageType(EDMG_Swing)  = 0.0f
	DamageType(EDMG_Pierce) = 0.0f
	DamageType(EDMG_Blunt)  = 0.0f
	DamageType(EDMG_Generic)= 1.0f

	DamageOverTime = 1.0f  // 4 damage per tick (vs vanilla 6)
	DOTTime = 4.0f         // Burns for 3 seconds (vs vanilla 5)

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
