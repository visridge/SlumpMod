/**
 * Admin actions wanted from both the chat commands in BangModGame.uci and the RCON handlers.
 * Statics on an Object rather than functions on the game, because the game class differs per
 * mode and BangModRCon has no single type to cast WorldInfo.Game to.
 */
class BangModAdminActions extends Object;

/** How far from the destination player we try to place someone, in unreal units. */
const TELEPORT_RADIUS = 120.0;

/** Vertical nudge, so an arrival is not clipped into the floor. */
const TELEPORT_LIFT = 40.0;

/**
 * Exactly one player by case-insensitive partial name. Reports the match count so a caller
 * can tell "no such player" from "three people match" -- guessing is how you slap the wrong one.
 */
static function AOCPlayerController FindByName(WorldInfo WI, string Partial, out int MatchCount)
{
	local AOCPlayerController PC, Found;
	local string Needle;

	MatchCount = 0;
	Needle = Locs(Partial);
	if (Needle == "" || WI == none)
		return none;

	foreach WI.AllControllers(class'AOCPlayerController', PC)
	{
		if (PC.PlayerReplicationInfo == none)
			continue;

		// Exact name wins outright, so "Bob" stays reachable next to "Bobby" and "Bobcat".
		if (Locs(PC.PlayerReplicationInfo.PlayerName) == Needle)
		{
			MatchCount = 1;
			return PC;
		}

		if (InStr(Locs(PC.PlayerReplicationInfo.PlayerName), Needle) != INDEX_NONE)
		{
			MatchCount++;
			Found = PC;
		}
	}

	return (MatchCount == 1) ? Found : none;
}

/**
 * Puts Mover next to Dest. SetLocation returns FALSE when the spot is blocked, so this rings
 * the destination rather than dropping someone inside them. Velocity is cleared on arrival.
 */
static function bool Teleport(Pawn Mover, Pawn Dest)
{
	local Vector Base, Try;
	local float Ang;
	local int i;

	if (Mover == none || Dest == none)
		return false;

	Base = Dest.Location;

	for (i = 0; i < 8; i++)
	{
		Ang = float(i) * 45.0 * Pi / 180.0;

		Try = Base;
		Try.X += Cos(Ang) * TELEPORT_RADIUS;
		Try.Y += Sin(Ang) * TELEPORT_RADIUS;
		Try.Z += TELEPORT_LIFT;

		if (Mover.SetLocation(Try))
		{
			Mover.Velocity = vect(0, 0, 0);
			return true;
		}
	}

	// All eight blocked; directly above is the last resort. A short drop beats a no-op.
	Try = Base;
	Try.Z += TELEPORT_RADIUS;
	if (Mover.SetLocation(Try))
	{
		Mover.Velocity = vect(0, 0, 0);
		return true;
	}

	return false;
}

/**
 * Launches a player. No damage -- an admin who wants them dead has Kill. Power is the upward
 * impulse; horizontal spread is randomised so repeated slaps do not follow a line.
 */
static function Slap(Pawn P, int Power)
{
	local Vector Push;

	if (P == none || Power <= 0)
		return;

	Push.X = (FRand() - 0.5) * float(Power) * 1.5;
	Push.Y = (FRand() - 0.5) * float(Power) * 1.5;
	Push.Z = float(Power);

	P.AddVelocity(Push, P.Location, class'AOCDmgType_Swing');
}
