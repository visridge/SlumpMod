# BangMod - GitHub Copilot Instructions

## Project Overview
**BangMod** is a competitive gameplay modification for **Chivalry: Medieval Warfare**. It extends the base game (AOC folder) with balance changes, netcode improvements, and quality-of-life features for tournament play.

## Architecture

### Folder Structure
```
Development/Src/
├── AOC/                    # Base game - vanilla Chivalry (DO NOT MODIFY)
│   └── classes/            # Parent classes that BangMod extends
└── BangMod/                # Our mod - extends/overrides AOC
    ├── Classes/            # UnrealScript class files (.uc)
    └── Include/            # Reusable code includes (.uci)
```

### Parent/Child Relationship
- **BangMod classes EXTEND AOC classes** using UnrealScript inheritance
- Example: `BangModPawn extends AOCPawn`
- Always check AOC parent class for inherited behavior before modifying
- Use `super.FunctionName()` to call parent implementation

### File Types
- `.uc` - UnrealScript class files (compiled into game)
- `.uci` - Include files (inserted at compile time via backtick includes)
- `.ini` - Configuration files (DefaultBangMod.ini)

## UnrealScript Language Quirks

### Syntax Rules
- **Case-insensitive** - `AOCPawn` == `aocpawn` (but use PascalCase for readability)
- **No method overloading** - function names must be unique
- **Semicolons required** - End statements with `;`
- **States** - Special UnrealScript concept for state machines (weapon states, pawn states)
- **Replication** - Network code uses `replication` blocks for client-server sync
- **Local variables MUST be declared at function start** - ALL `local` declarations must appear at the very beginning of the function, before any executable code. You cannot declare locals inside `if` blocks, loops, or anywhere else. This is a strict UnrealScript requirement.

### Variable Declaration Examples
```unrealscript
// ✅ CORRECT - All locals at function start
function MyFunction()
{
    local int MyVar;
    local Rotator MyRot;
    
    if (SomeCondition)
    {
        MyVar = 5;  // Use previously declared variable
    }
}

// ❌ WRONG - Local declared inside if block
function MyFunction()
{
    if (SomeCondition)
    {
        local int MyVar;  // ERROR: 'Local' is not allowed here
        MyVar = 5;
    }
}
```

### Common Patterns
```unrealscript
// Include files (backtick syntax)
`include(BangMod/Include/BangModPawn.uci)

// Parent class calls
super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType);

// State definitions
simulated state Recovery
{
    simulated event BeginState(Name PreviousStateName) { }
}

// Replication
replication
{
    if (bNetDirty && Role == ROLE_Authority)
        fLastParrySuccessTime, fRiposteGracePeriod;
}
```

## VS Code Linting - IGNORE WARNINGS

### Known False Positives
The UnrealScript VS Code extension **frequently reports incorrect errors**:

❌ **IGNORE THESE:**
- `'Attack_Parry' does not exist` - It does (enum defined in AOC)
- `Couldn't find operator '=='` - UnrealScript supports all standard operators
- `'Role' does not exist` - Core engine property, always exists
- `'GotoState' does not exist` - Built-in UnrealScript function
- Missing import/include errors - Extension doesn't understand backtick includes

✅ **TRUST THESE:**
- Actual syntax errors (missing semicolons, brackets)
- Real undefined variables (typos in variable names)
- Invalid function signatures

**Rule of thumb:** If the code compiles successfully with UDK, the linter is wrong, so encourage the player to manually try compiling before fixing "errors" that don't make sense. And if it doesn't compile, the error is real and should be fixed and should be reported back to the AI agent.

## Key Modifications in BangMod

### Netcode Improvements
- **Stamina desync fix** - Server-authoritative stamina validation in combo transitions
- **Riposte grace period** - 200ms flinch immunity after successful parry (network lag compensation)
- **Parry buffer system** - 100ms input buffering for responsive parrying

### Balance Changes
- **Stamina regen delay** - Increased from 1.5s to 2.5s
- **Weapon-specific tweaks** - Bardiche, Longsword, Halberd balance adjustments
- **Parry mechanics** - Can parry out of Recovery state (consistency with other states)

### Customization System
- **BangModCustomization** - Custom character/helmet/armor system
- **Uses vanilla config system** - Saves to `Customization.ini`
- **BangModView_Frontend_Customization** - UI hooks for saving choices

## Development Workflow

### Making Changes
1. **Find parent class in AOC/** - Understand vanilla behavior
2. **Create/modify child class in BangMod/** - Override specific functions
3. **Test changes** - Requires dedicated server for netcode testing
4. **Use `.uci` includes** - Share code between similar classes (weapons, pawns)

### Common Tasks

**Adding a new weapon:**
```unrealscript
class BangModWeapon_NewWeapon extends BangModMeleeWeapon;

// Weapon inherits all BangModMeleeWeapon fixes:
// - Parry buffer system
// - Stamina validation
// - Recovery parrying
// - Riposte grace period
```

**Modifying pawn behavior:**
```unrealscript
// Changes go in BangModPawn.uci (shared across all pawns)
// Or in specific pawn class if unique to one gamemode
```

**Changing weapon stats:**
```unrealscript
// Modify defaultproperties block at bottom of weapon file
DefaultProperties
{
    Damage=110
    HorizontalRotateSpeed=55000.0
    ParryDrain(1)=29  // Overhead parry drain
}
```

### Debugging Tips
- **Use `log()` statements** - Appears in server/client console
- **Check replication** - Client vs server behavior differs
- **Test with latency** - Netcode issues only appear with real network delay
- **Read AOC parent code** - Many "bugs" are vanilla behavior

## File Organization

### BangMod/Classes/
- `BangModMeleeWeapon.uc` - Base melee weapon (all weapons extend this)
- `BangModPawn.uc` - Base pawn class (all pawns extend this)
- `BangModWeapon_*.uc` - Individual weapon implementations
- `BangModCharacterInfo_*.uc` - Character customization data
- `BangModCustomization.uc` - Customization system override

### BangMod/Include/
- `BangModPawn.uci` - Shared pawn behavior (stats tracking, flinch logic)
- `BangModPlayerController.uci` - Shared controller behavior
- `BangModGame.uci` - Shared game mode behavior

## Testing Requirements

### Local Testing (Limited)
- **"Create Game"** - Listen server mode
- **Good for:** UI testing, weapon damage values, basic functionality
- **Cannot test:** Netcode, replication, client-server desyncs

### Proper Testing (Required)
- **Dedicated server** - Run with `-server` flag
- **Good for:** Netcode, stamina validation, riposte grace period
- **Required for:** Competitive balance verification

## Common Gotchas

1. **Client vs Server code** - Check `Role == ROLE_Authority` for server-only
2. **Simulated functions** - Run on both client and server
3. **State replication** - States replicate, but state transitions have latency
4. **Predicted values** - Client-side predictions (like `CurrentStamina`) can desync
5. **Config files** - Changes require game restart or `StaticSaveConfig()` call

## Resources

- **AOC source code** - Always check parent class first
- **Unreal Developer Network (UDN)** - Official UnrealScript documentation
- **BangMod changelog** - CHANGELOG.md in root for feature history

## Contributing Guidelines

- **Document changes** - Add comments explaining WHY, not just WHAT
- **Test on dedicated server** - Netcode changes must be verified
- **Preserve compatibility** - Don't break existing customization saves
- **Follow naming conventions** - BangMod prefix for all custom classes
- **Use includes for shared code** - Don't duplicate logic across files

---

**Remember:** The linter is often wrong. If it compiles and works in-game, trust the game over the extension.
