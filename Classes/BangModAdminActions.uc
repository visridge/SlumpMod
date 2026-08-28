/**
 * Admin actions that are wanted from two places at once: the in-game chat commands in
 * BangModGame.uci, and the RCON handlers in BangModRCon.
 *
 * A static helper class rather than functions on the game, because the game class differs
 * per mode (BangModTO, BangModTD, BangModLTS...) and BangModRCon has no single type to cast
 * WorldInfo.Game to. Statics on an Object subclass are reachable from both without a cast.
 */
class BangModAdminActions extends Object;

/** How far from the destination player we try to place someone, in unreal units. */
const TELEPORT_RADIUS = 120.0;

/** Vertical nudge, so an arrival is not clipped into the floor. */
const TELEPORT_LIFT = 40.0;

/**
 * Finds exactly one player by a case-insensitive partial name.
 *
 * Reports the match count rather than just returning none, so a caller can tell "no such
 * player" from "you typed something three people match" -- getting the wrong one of those
 * silently is how an admin ends up slapping the wrong person.
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

		// An exact name wins outright, so someone called "Bob" is still reachable when
		// "Bobby" and "Bobcat" are also on the server.
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
 * Puts Mover next to Dest.
 *
 * SetLocation is native(267) and returns FALSE when the destination is blocked, so this
 * walks a ring of candidate spots rather than assuming the first one is free -- dropping a
 * player inside the one they were sent to would either fail silently or telefrag.
 * Velocity is cleared so nobody arrives still carrying a sprint.
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

	// Everything around them was blocked. Directly above is the last resort -- a short
	// drop is better than the command appearing to do nothing.
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
 * Launches a player. No damage -- this is for getting attention, and an admin who wants
 * them dead has Kill.
 *
 * Power is the upward impulse; horizontal spread is randomised so repeated slaps do not
 * send someone along a predictable line.
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
