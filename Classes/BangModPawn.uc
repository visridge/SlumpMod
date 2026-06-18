class BangModPawn extends AOCPawn;

// BANGMOD: Parry rollback — "decide once" netcode.
// An incoming melee swing is HELD on the defender for a latency-sized window (the time an
// in-flight parry could still take to reach the server). Nothing is applied during the hold,
// so a parry that lands inside the window suppresses the swing before any feedback plays —
// no commit-then-refund. At 0 ping the hold is 0 and the hit resolves instantly (vanilla).
// Defined here in the base class (not the .uci include) so every subclass shares one
// PendingHit type rather than each getting its own copy.
struct PendingHit
{
    var float fCommitTime;              // WorldInfo.TimeSeconds at which to commit the hit
    var BangModPawn Attacker;           // pawn that swung (resolves the hit / takes the deflect)
    var HitInfo Info;                   // captured hit info
    var string DamageString;
    var bool bBoxParrySuccess;
    var bool bHitShield;
    var SwingTypeImpactSound LastHit;
    var bool bQuickKick;
    var float fActionServerTime;        // attacker's hit moment (their client clock) mapped to server time
};
var array<PendingHit> PendingHits;       // swings held on this (defender) pawn awaiting resolution
var float fParryRollbackMaxHoldSeconds;  // cap on how long a swing may be held (s)
var float fParryRollbackMinHoldSeconds;  // holds shorter than this resolve immediately (s)

// BANGMOD: Client-timestamp hit-trade priority. Each client stamps the moment its hit landed
// (or its parry went active) in its own clock; the server maps those stamps onto its own
// timeline (ping reconstruction + a smoothed per-player offset) so it can tell who acted first
// and drop only clearly-staggered trades — near-simultaneous swings still trade. See the
// helpers and arbitration in BangMod/Include/BangModPawn.uci. Declared here (base class) so
// every subclass shares one struct type, matching PendingHit above.
struct RecentIncomingHit
{
    var float fActionServerTime;        // when the incoming hit landed (server timeline)
    var BangModPawn Attacker;           // who hit us
};
var array<RecentIncomingHit> RecentIncomingHits;  // hits we recently took, kept for fRecentHitTTL

`include(BangMod/Include/BangModPawn.uci)
