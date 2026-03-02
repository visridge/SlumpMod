/**
* BangMod Base Shield - Reverted to vanilla AOC behavior
*/

class BangModBaseShield extends AOCBaseShield;

DefaultProperties
{
	// BANGMOD: Zero shield raise cost - shields are free to activate
	fShieldRaiseCost = 0.0
	// Zero passive stamina drain while shield is up (shouldn't matter with timed parry,
	// but set to 0 as safety since shields auto-drop after the parry window)
	fStaminaDrain = 0.0
}
