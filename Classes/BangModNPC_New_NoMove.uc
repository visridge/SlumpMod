/**
* BangMod standing NPC (final-objective targets / stationary AI).
*
* Netcode optimization over AOCNPC_New_NoMove:
*  - bAlwaysRelevant=false + NetCullDistanceSquared: standing NPCs far from every player stop
*    replicating entirely (vanilla force-replicates all of them to everyone). This is the big
*    win for objectives that pack many standing NPCs — players at the objective are unaffected,
*    distant players simply don't receive them.
*  - NetUpdateFrequency reduced 3 -> 1Hz. Standing NPCs barely change, and TakeDamage (inherited
*    from AOCNPC_New_NoMove) already forces an immediate net update on hit, so the low idle rate
*    costs nothing in responsiveness.
*
* Usage: swap AOCNPC_New_NoMove spawns for BangModNPC_New_NoMove in map Kismet. Tune
* NetCullDistanceSquared up if an objective needs these visible/hittable from farther away.
*/
class BangModNPC_New_NoMove extends AOCNPC_New_NoMove;

DefaultProperties
{
	// Enable distance/visibility relevancy culling (vanilla forces these always-relevant).
	bAlwaysRelevant=false

	// Cull radius: 10000 uu (squared). NPCs beyond this from all viewers stop replicating.
	// Generous on purpose — only truly far (across-map) NPCs are culled. Increase if needed.
	NetCullDistanceSquared=100000000.0

	// Standing NPCs only need updates when hit (bForceNetUpdate in TakeDamage); 1Hz idle.
	NetUpdateFrequency=1.0
}
