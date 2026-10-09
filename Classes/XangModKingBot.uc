// The AI King on XangModAIKing maps. Spawned and owned by XangModTO; XangModBotBrain gives it
// the King combat profile. Leaves the game when it dies, so it never respawns as a footsoldier.
class XangModKingBot extends XangModAOCCombatBot;

event Possess(Pawn aPawn, bool bVehicleTransition)
{
	super.Possess(aPawn, bVehicleTransition);
	if (XangModTO(WorldInfo.Game) != none)
		XangModTO(WorldInfo.Game).XangModAIKingSpawned(self, AOCPawn(aPawn));
}

function PawnDied(Pawn P)
{
	super.PawnDied(P);
	SetTimer(0.5f, false, 'XangModLeave');
}

function XangModLeave()
{
	if (XangModTO(WorldInfo.Game) != none)
		XangModTO(WorldInfo.Game).XangModRemoveAIKing(self);
	else
		Destroy();
}

DefaultProperties
{
}
