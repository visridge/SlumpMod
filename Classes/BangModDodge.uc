/**
 * BangModDodge - Custom dodge class that remaps WeaponIdentifier for weapons
 * that have no dodge animations for MaA (e.g. doubleaxe is a Vanguard weapon type).
 *
 * Overrides GetWeaponIdentifier() to substitute identifiers that lack dodge anims
 * with ones that have them, while keeping the original WeaponIdentifier on the weapon
 * class so the AnimTree selects the correct idle/stance pose.
 */
class BangModDodge extends AOCDodge;

simulated function string GetWeaponIdentifier()
{
	local string Identifier;

	Identifier = super.GetWeaponIdentifier();

	// Remap Vanguard weapon identifiers that lack MaA dodge animations
	// doubleaxe (GrandMace/Kanabo) -> qstaff (QuarterStaff, a 2H MaA weapon with dodge anims)
	if (Identifier == "doubleaxe")
	{
		return "qstaff";
	}

	return Identifier;
}

defaultproperties
{
}
