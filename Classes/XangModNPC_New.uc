/**
* BangMod moving NPC (patrols / combat AI).
*
* Netcode optimization over AOCNPC_New:
*  - bAlwaysRelevant=false + NetCullDistanceSquared: NPCs far from every player are no longer
*    replicated at all (vanilla force-replicates them to everyone regardless of distance). This
*    is a pure server-CPU/bandwidth win for crowded objectives on large maps — players fighting
*    near the NPCs are unaffected; only players across the map (beyond the cull radius) stop
*    receiving them.
*  - NetUpdateFrequency reduced 50 -> 30Hz (still smooth for AI; players keep 120Hz).
*
* Usage: swap AOCNPC_New spawns for BangModNPC_New in map Kismet. Tune NetCullDistanceSquared
* up if any objective requires seeing/hitting these NPCs from farther than the radius below.
*/
class BangModNPC_New extends AOCNPC_New;

// Always re-replicate immediately when hit so reduced frequency / relevancy never delays the
// hit reaction reaching nearby clients.
event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo myHitInfo, optional Actor DamageCauser)
{
	super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, myHitInfo, DamageCauser);
	bForceNetUpdate = true;
	bNetDirty = true;
}

DefaultProperties
{
	// Enable distance/visibility relevancy culling (vanilla forces these always-relevant).
	bAlwaysRelevant=false

	// Cull radius: 10000 uu (squared). NPCs beyond this from all viewers stop replicating.
	// Generous on purpose — only truly far (across-map) NPCs are culled. Increase if needed.
	NetCullDistanceSquared=100000000.0

	// 30Hz is plenty for AI movement; down from vanilla 50Hz.
	NetUpdateFrequency=30.0
}
