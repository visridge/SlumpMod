# BangMod Parry Rollback & Deferred Hit System

## Purpose

Compensates for network latency where a defender's parry RPC arrives at the server slightly after the attacker's hit RPC. All hit effects (damage, flinch, sound, blood) are deferred by a configurable rollback window (`fParryRollbackWindowSeconds`, default 60ms). If a parry arrives within that window, the hit is cancelled entirely. If the window expires without a parry, the hit is committed.

## Files Involved

| File | Role |
|------|------|
| `BangMod\Classes\BangModPawn.uc` | Struct def + array decl (`RecentHitEntry`, `RecentUnparriedHits`, `fParryRollbackWindowSeconds`) |
| `BangMod\Include\BangModPawn.uci` | Deferred variable decls, `AttackOtherPawn` deferral logic, `ApplyDeferredReplication()`, `RollbackRecentHits()` |
| `BangMod\Classes\BangModMeleeWeapon.uc` | Call to `RollbackRecentHits()` in `Parry.BeginState` |

## Data Structures

### `RecentHitEntry` struct (BangModPawn.uc)
```unrealscript
struct RecentHitEntry
{
    var float fHitTime;           // WorldInfo.TimeSeconds when hit was buffered
    var float fDamage;            // Actual damage dealt
    var AOCPawn InstigatorPawn;   // The attacker's pawn
};
var array<RecentHitEntry> RecentUnparriedHits;   // Per-pawn hit buffer
var float fParryRollbackWindowSeconds;            // 0.060 (60ms) — hit deferral delay
```

### Deferred state variables (BangModPawn.uci ~line 17-42)
```unrealscript
// Deferred hit audio
var float fPendingHitDamage;       // Damage for deferred PlayHitSounds
var bool bPendingHitFlinch;        // Flinch flag for deferred PlayHitSounds
var AOCPawn PendingHitAttacker;    // Attacker whose PlayMeleeHit is deferred

// Deferred flinch
var bool bPendingFlinchActive;     // Whether a flinch is waiting
var bool bPendingFlinchFullBody;
var bool bPendingFlinchGeneric;
var bool bPendingFlinchSpecial;
var bool bPendingFlinchTwoHander;
var EDirection bPendingFlinchDir;

// Deferred damage (lethal portion)
var float fDeferredDamage;
var class<DamageType> DeferredDamageType;
var vector DeferredHitLocation;
var vector DeferredHitForce;
var TraceHitInfo DeferredHitInfo;
var Actor DeferredDamageCauser;

// Deferred replication
var HitInfo PendingHitInfo;
var bool bHasPendingHitInfo;
```

## Flow

### Step 1 — Attacker hits defender (`AttackOtherPawn`)

#### A) Flinch is deferred
Instead of calling `AOCWeapon(...).ActivateFlinch(...)` immediately, flinch parameters are stored:
```unrealscript
BangModPawn(Info.HitActor).bPendingFlinchActive = true;
BangModPawn(Info.HitActor).bPendingFlinchFullBody = true;
BangModPawn(Info.HitActor).bPendingFlinchDir = Info.HitActor.GetHitDirection(Location);
// ... etc
```

#### B) Hit audio is deferred
`PlayMeleeHit` and `PlayHitSounds` are replaced with deferred storage:
```unrealscript
BangModPawn(Info.HitActor).fPendingHitDamage = ActualDamage;
BangModPawn(Info.HitActor).bPendingHitFlinch = bFlinch;
BangModPawn(Info.HitActor).PendingHitAttacker = self;
```

#### C) HitInfo replication is deferred
```unrealscript
BangModPawn(Info.HitActor).PendingHitInfo = Info;
BangModPawn(Info.HitActor).bHasPendingHitInfo = true;
```

#### D) Lethal damage is split and deferred
To prevent `PlayDying()` from making death irreversible before rollback can intervene:
```unrealscript
if (ActualDamage >= Info.HitActor.Health)
{
    ImmediateDamage = Max(Info.HitActor.Health - 1, 0);  // leaves 1 HP
    LethalPortion = ActualDamage - ImmediateDamage;
    Info.HitActor.TakeDamage(ImmediateDamage, ...);       // immediate non-lethal
    BangModPawn(Info.HitActor).fDeferredDamage = LethalPortion;  // deferred lethal
}
else
{
    Info.HitActor.TakeDamage(ActualDamage, ...);          // immediate full damage
}
```

#### E) Unified deferred timer
All deferrals are committed via a single timer:
```unrealscript
BangModPawn(Info.HitActor).SetTimer(fParryRollbackWindowSeconds, false, 'ApplyDeferredReplication');
```

#### F) Hit buffered for rollback
```unrealscript
RollbackEntry.fHitTime = WorldInfo.TimeSeconds;
RollbackEntry.fDamage = ActualDamage;
RollbackEntry.InstigatorPawn = self;
BangModPawn(Info.HitActor).RecentUnparriedHits.AddItem(RollbackEntry);
```

### Step 2 — Timer fires: `ApplyDeferredReplication()` (60ms later)

If no parry interrupted within the window:

```unrealscript
function ApplyDeferredReplication()
{
    // 1. Apply deferred lethal damage
    if (fDeferredDamage > 0.0f)
    {
        TakeDamage(fDeferredDamage, ...);
        fDeferredDamage = 0.0f;
    }

    // 2. Replicate HitInfo to clients (triggers HandlePawnGetHit → blood, impact sound)
    if (!bHasPendingHitInfo) return;
    StoredInfo = PendingHitInfo;
    bHasPendingHitInfo = false;
    ReplicatedHitInfo = StoredInfo;
    if (WorldInfo.NetMode == NM_Standalone || Worldinfo.NetMode == NM_ListenServer)
        HandlePawnGetHit();

    // 3. Apply deferred Firebug ignition
    if (BangModWeapon_Firebug(Weapon) != none && ...)
        StoredInfo.HitActor.SetPawnOnFire(...);
}
```

### Step 3 — Defender parries: `RollbackRecentHits()` (called from `Parry.BeginState`)

#### Ping-gated gap check
The defender's ping determines the allowable hit-to-parry gap. Only hits that arrived within the defender's ping window are eligible for rollback (preventing LAN/0-ping rollback of legitimate reactions):

```unrealscript
fPingSec = float(PlayerReplicationInfo.Ping) * 0.004;  // UE3 stores Ping/4
fMaxGapSec = FClamp(fPingSec + 0.015, 0.015, RollbackWindowSeconds);
```

| Defender Ping | fMaxGapSec | Behavior |
|---------------|-----------|----------|
| 0 ms (LAN/bots) | 15ms | Effectively **disabled** |
| 50 ms | ~65ms | Rolls back network crossings |
| 100 ms | ~115ms | Rolls back crossings ≤ window |
| 150+ ms | Capped at fParryGracePeriod | Limited by grace period |

#### Cancellation of deferred effects
When a parry fires (and buffer is non-empty), ALL deferred timers and state are cleared:
```unrealscript
ClearTimer('ApplyDeferredReplication');
bHasPendingHitInfo = false;
fPendingHitDamage = 0.0f;
PendingHitAttacker = none;
bPendingFlinchActive = false;
fDeferredDamage = 0.0f;
```

#### Per-hit rollback
```unrealscript
for each buffered hit:
    if (too old OR gap exceeds ping window):
        remove from buffer
    else:
        Health += fDamage  (restore health, capped at HealthMax)
        cancel flinch state
        put attacker into deflect
        play parried sound
        increment scoreboard parry count
```

### Step 4 — Firebug rollback extinguishing
If the attacker used Firebug and the defender was burning, the fire is extinguished on rollback:
```unrealscript
if (bIsBurning && Entry.InstigatorPawn != none
    && BangModWeapon_Firebug(Entry.InstigatorPawn.Weapon) != none)
{
    bIsBurning = false;
    StopFireOnPawn();
}
```

## Configuration

| Variable | Class | Default | Purpose |
|----------|-------|---------|---------|
| `fParryRollbackWindowSeconds` | `BangModPawn` | **0.060** (60ms) | Hit deferral delay and max rollback window |
| `fParryGracePeriod` | `BangModMeleeWeapon` | **0.100** (100ms) | Server-side parry startup grace, passed as `RollbackWindowSeconds` |
| `PlayerReplicationInfo.Ping` | UE3 built-in | Varies | Defender's ping (stored as `PingMs/4`, max 255) |

### To adjust the rollback window
Change `fParryRollbackWindowSeconds` in `BangModPawn.uci` DefaultProperties:
```unrealscript
fParryRollbackWindowSeconds=0.060  // 60ms (current)
// fParryRollbackWindowSeconds=0.080  // 80ms (looser)
// fParryRollbackWindowSeconds=0.040  // 40ms (tighter)
```

## Diagram

```
┌──────────────────────────────────────────────────────────────────┐
│                        ATTACK FLOW                                │
│                                                                  │
│  Attacker hits Defender                                           │
│       │                                                           │
│       ▼                                                           │
│  AttackOtherPawn() on Server                                      │
│       │                                                           │
│       ├─ Flinch params stored (bPendingFlinch*)                   │
│       ├─ Sound params stored (fPendingHitDamage, PendingHitAtkr)  │
│       ├─ HitInfo stored (PendingHitInfo, bHasPendingHitInfo)      │
│       ├─ Non-lethal damage applied immediately                    │
│       ├─ Lethal damage split: 1 HP now, rest deferred             │
│       ├─ Hit buffered for rollback                                │
│       │                                                           │
│       └─ SetTimer(60ms, 'ApplyDeferredReplication')              │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│                     WINDOW (0-60ms)                               │
│                                                                  │
│  ┌─ Defender parries?                                            │
│  │   YES → RollbackRecentHits()                                  │
│  │          • Cancel ApplyDeferredReplication timer              │
│  │          • Clear all deferred state                           │
│  │          • Restore health (undo non-lethal damage)            │
│  │          • Deflect attacker                                   │
│  │          • Extinguish Firebug burn                            │
│  │   NO (60ms passes) → ApplyDeferredReplication()              │
│  │          • Apply deferred lethal damage                       │
│  │          • Replicate HitInfo to clients                       │
│  │          • HandlePawnGetHit (blood, impact sound)             │
│  │          • Firebug ignition                                   │
│  │                                                               │
└──────────────────────────────────────────────────────────────────┘
```
