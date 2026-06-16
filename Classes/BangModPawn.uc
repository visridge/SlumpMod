class BangModPawn extends AOCPawn;

// BANGMOD: Parry rollback buffer — stores recent unparried hits so we can undo them
// if a parry starts within the rollback window (80ms).
// Defined here in the base class (not the .uci include) so that subclasses share
// a single RecentHitEntry type rather than each getting their own copy.
struct RecentHitEntry
{
    var float fHitTime;
    var float fDamage;
    var AOCPawn InstigatorPawn;
};
var array<RecentHitEntry> RecentUnparriedHits;
var float fParryRollbackWindowSeconds;   // How far back to check for rollback eligibility

`include(BangMod/Include/BangModPawn.uci)
