# BangMod Parry Rollback System

## Purpose

Compensates for network latency where a defender's parry RPC arrives at the server slightly after the attacker's hit RPC. If the parry was already in-flight from the defender's client when the hit landed (a "crossed wires" scenario), the system undoes the hit damage and treats it as a successful parry.

## Files Involved

| File | Role |
|------|------|
| `BangMod\Classes\BangModPawn.uc` | Struct def + array decl (`RecentHitEntry`, `RecentUnparriedHits`) |
| `BangMod\Include\BangModPawn.uci` | Hit buffer code in `AttackOtherPawn` + `RollbackRecentHits()` function |
| `BangMod\Classes\BangModMeleeWeapon.uc` | Call to `RollbackRecentHits()` in `Parry.BeginState` |

## Data Structures

### `RecentHitEntry` struct (BangModPawn.uc lines ~4-9)
```unrealscript
struct RecentHitEntry
{
    var float fHitTime;        // WorldInfo.TimeSeconds when hit was processed
    var float fDamage;         // Actual damage dealt
    var AOCPawn InstigatorPawn; // The attacker's pawn
};
```

### Variables (BangModPawn.uc lines ~11-12)
```unrealscript
var array<RecentHitEntry> RecentUnparriedHits;  // Hit buffer (per-pawn)
var float fParryRollbackWindowSeconds;           // Max rollback window (unused currently, use fParryGracePeriod)
```

## Flow

### Step 1 — Buffer hits (`AttackOtherPawn` in BangModPawn.uci ~line 1550)

Every time an unparried hit deals damage, the hit is pushed into the defender's buffer:

```unrealscript
if (!bParry && ActualDamage > 0.0f && BangModPawn(Info.HitActor) != none)
{
    RollbackEntry.fHitTime = WorldInfo.TimeSeconds;
    RollbackEntry.fDamage = ActualDamage;
    RollbackEntry.InstigatorPawn = self;
    BangModPawn(Info.HitActor).RecentUnparriedHits.AddItem(RollbackEntry);
}
```

### Step 2 — Check buffer on parry (`Parry.BeginState` in BangModMeleeWeapon.uc ~line 585)

When a parry starts on the server, the hit buffer is checked for recent hits that should be rolled back:

```unrealscript
if (Role == ROLE_Authority)
{
    fServerParryStartTime = WorldInfo.TimeSeconds;
    if (AOCOwner != none && BangModPawn(AOCOwner) != none)
        BangModPawn(AOCOwner).RollbackRecentHits(fParryGracePeriod);
}
```

### Step 3 — `RollbackRecentHits()` (BangModPawn.uci ~line 1660)

This function runs on the **server** (called from `Role == ROLE_Authority`).

#### Ping-gated gap check

The defender's ping is used to compute a maximum allowable hit-to-parry time gap:

```unrealscript
// UE3 stores ping as Min(Round(PingMs / 4), 255)
// Convert: Ping * 0.004 = seconds
fPingSec = float(PlayerReplicationInfo.Ping) * 0.004;
fMaxGapSec = FClamp(fPingSec + 0.015, 0.015, RollbackWindowSeconds);
```

| Defender Ping | fMaxGapSec | Behavior |
|---------------|-----------|----------|
| 0 ms (LAN/bots) | 0.015s (15ms floor) | Effectively **disabled** — human reactions always exceed 15ms |
| 50 ms | ~0.065s (65ms) | Rolls back genuine network crossings |
| 100 ms | ~0.115s (115ms) | Rolls back crossings ≤ fParryGracePeriod |
| 150+ ms | Capped at `RollbackWindowSeconds` (~100ms) | Limited by grace period |

#### Iteration logic

```unrealscript
for (i = RecentUnparriedHits.Length - 1; i >= 0; i--)
{
    // 1. Remove hits outside the absolute rollback window (>RollbackWindowSeconds)
    if (fNow - Entry.fHitTime > RollbackWindowSeconds)
        { Remove & continue; }

    // 2. Skip hits where gap exceeds defender's ping window
    //    (these are human reactions, not network crossings)
    if (fNow - Entry.fHitTime > fMaxGapSec)
        { Remove & continue; }

    // 3. Hit is within both windows → ROLL BACK
    //    - Restore health
    //    - Cancel flinch state
    //    - Put attacker into deflect state
    //    - Play parried sound
    //    - Increment scoreboard parry counter
}
```

#### Cleanup

After the main loop, any remaining entries older than 0.3s are purged:

```unrealscript
for (i = RecentUnparriedHits.Length - 1; i >= 0; i--)
{
    if (fNow - RecentUnparriedHits[i].fHitTime > 0.3)
        RecentUnparriedHits.Remove(i, 1);
}
```

## Configuration

### Key variables

| Variable | Class | Default | Purpose |
|----------|-------|---------|---------|
| `fParryGracePeriod` | `BangModMeleeWeapon` | **0.100** (100ms) | Passed as `RollbackWindowSeconds` — max hit age for rollback |
| `fParryRollbackWindowSeconds` | `BangModPawn` | N/A | Declared but unused currently |
| `PlayerReplicationInfo.Ping` | UE3 built-in | Varies | Defender's ping (stored as `PingMs/4`, max 255) |

### To adjust the rollback window

Change `fParryGracePeriod` in `BangModMeleeWeapon` DefaultProperties:

```unrealscript
fParryGracePeriod = 0.100;  // 100ms (current)
// fParryGracePeriod = 0.075;  // 75ms (tighter)
// fParryGracePeriod = 0.150;  // 150ms (looser, more forgiving for high ping)
```

### To disable the entire system

Three pieces must be commented out:

1. **Hit buffer** in `BangModPawn.uci` `AttackOtherPawn` (~line 1550): wrap the `if (!bParry...AddItem)` block in `/* */`
2. **Rollback call** in `BangModMeleeWeapon.uc` `Parry.BeginState` (~line 585): comment out the `RollbackRecentHits` call
3. **Function body** in `BangModPawn.uci` (~line 1660): wrap the `function RollbackRecentHits(...) { ... }` in `/* */`

## Diagram

```
┌──────────────────────────────────────────────────────────┐
│                     ATTACK FLOW                           │
│                                                          │
│  Attacker hits Defender                                   │
│       │                                                   │
│       ▼                                                   │
│  AttackOtherPawn() on Defender                            │
│       │                                                   │
│       ├─ Damage applied                                   │
│       │                                                   │
│       └─ Hit buffered:                                    │
│          RecentUnparriedHits.AddItem(hitTime, dmg, atkr)  │
│                                                          │
└──────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│                     PARRY FLOW                            │
│                                                          │
│  Defender parries                                         │
│       │                                                   │
│       ▼                                                   │
│  Parry.BeginState() on Server                             │
│       │                                                   │
│       ├─ fServerParryStartTime = now                      │
│       │                                                   │
│       └─ RollbackRecentHits(fParryGracePeriod)            │
│            │                                              │
│            ├─ Compute fMaxGapSec from defender ping       │
│            │                                              │
│            └─ For each buffered hit:                      │
│                 │                                         │
│                 ├─ Is gap > RollbackWindowSeconds?        │
│                 │  └─ YES → remove (too old)              │
│                 │                                         │
│                 ├─ Is gap > fMaxGapSec?                   │
│                 │  └─ YES → remove (human reaction)       │
│                 │                                         │
│                 └─ NO → ROLLBACK:                         │
│                      • Restore health                     │
│                      • Cancel flinch                      │
│                      • Deflect attacker                   │
│                      • Scoreboard credit                  │
│                                                          │
└──────────────────────────────────────────────────────────┘
```
