/**
 * XangMod - Voice command (VO) variation pinning.
 *
 * Vanilla AOCPawn replicates the same SoundCue to every client and lets each one
 * evaluate the cue's SoundNodeRandom independently, so the take a player hears and
 * the take everyone else hears diverge. These helpers find the first random node in
 * a cue and force it to select one specific variation; XangModPawn then replicates
 * that chosen index (see Include/Pawn/VO.uci) so every client plays the same take.
 *
 * Statics live on an Object rather than the pawn class because the pawn class differs
 * per game mode and there is no single type to cast WorldInfo.Game / the pawn to.
 */
class XangModVO extends Object;

/** Find the first SoundNodeRandom in a cue's node graph (depth-first). */
static simulated function SoundNodeRandom FindRandomNode(SoundNode Node)
{
	local SoundNodeRandom RandNode;
	local int i;
	local SoundNodeRandom Found;

	if (Node == none)
		return none;

	RandNode = SoundNodeRandom(Node);
	if (RandNode != none)
		return RandNode;

	for (i = 0; i < Node.ChildNodes.Length; i++)
	{
		Found = FindRandomNode(Node.ChildNodes[i]);
		if (Found != none)
			return Found;
	}

	return none;
}

/** Number of random variations available for a VO cue (0 = no usable random node). */
static simulated function int GetVariationCount(SoundCue Cue)
{
	local SoundNodeRandom RandNode;

	if (Cue == none)
		return 0;

	RandNode = FindRandomNode(Cue.FirstNode);
	if (RandNode == none || RandNode.ChildNodes.Length < 2 || !RandNode.bRandomizeWithoutReplacement)
		return 0;

	return RandNode.ChildNodes.Length;
}

/** Pin the first random node in Cue so the next playback selects VariationIndex. */
static simulated function bool ForceVOCueVariation(SoundCue Cue, int VariationIndex)
{
	local SoundNodeRandom RandNode;
	local int i;

	if (Cue == none)
		return false;

	RandNode = FindRandomNode(Cue.FirstNode);
	if (RandNode == none || RandNode.ChildNodes.Length < 2 || !RandNode.bRandomizeWithoutReplacement)
		return false;

	if (VariationIndex < 0)
		VariationIndex = 0;
	else if (VariationIndex >= RandNode.ChildNodes.Length)
		VariationIndex = RandNode.ChildNodes.Length - 1;

	RandNode.HasBeenUsed.Length = RandNode.ChildNodes.Length;
	for (i = 0; i < RandNode.ChildNodes.Length; i++)
		RandNode.HasBeenUsed[i] = (i != VariationIndex);

	RandNode.NumRandomUsed = RandNode.ChildNodes.Length - 1;
	return true;
}
