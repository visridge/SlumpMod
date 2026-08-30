# BangMod RCON protocol

Server side: `Src\BangMod\Classes\BangModRCon.uc` (opcodes 23-61) (extends `AOCRCon`), spawned by the
`InitRemoteConsole` override in `Src\BangMod\Include\BangModGame.uci`.

**Status: limited testing in a development environment.** Tournament controls, loadout,
freeze, bans, map and the fun commands have been exercised on a live server; the fixes
made in response are noted per opcode below. Nothing has been load-tested.

## Why this exists

The ChivAdmin desktop client already speaks opcodes 0-28. Opcodes 0-22 match
`AOCRCon.uc`'s `MessageType` enum exactly, in order. **Opcodes 23-28 exist only in the
client** -- its Java classes for them are marked `implements CustomChivEvent`, whose
javadoc says "for non-vanilla CMW messages sent from the server. This is the case when
the 'ChivAdmin' mod is installed." That mutator was never published.

So implementing 23-28 makes an **unmodified ChivAdmin client** work against a BangMod
server. Every layout below was read off the client's own encoders/decoders, not guessed.

## Wire format (unchanged from vanilla)

Big-endian. `AOCRConPacket` provides:

    AddInt / GetInt        4-byte big-endian int
    AddString / GetString  4-byte length prefix, then UTF-8 bytes
    AddQWord / GetGUID     8-byte Steam ID
    SetMessageType(int)    takes a plain int, so custom opcodes need no enum change

Auth is untouched: challenge string, 50-byte password packet, `RCON_Connecting` ->
`RCON_Connected`. `BangModRCon.HandleMessage` checks `RCON_Connected` before dispatching
anything extended, so an unauthenticated peer reaches none of it.

## Opcodes

`in` = client to server. `out` = server to client.

### 0-22 -- vanilla, handled by AOCRCon, untouched

SERVER_CONNECT, SERVER_CONNECT_SUCCESS, PASSWORD, PLAYER_CHAT, PLAYER_CONNECT,
PLAYER_DISCONNECT, SAY_ALL, SAY_ALL_BIG, SAY, MAP_CHANGED, MAP_LIST, CHANGE_MAP,
ROTATE_MAP, TEAM_CHANGED, NAME_CHANGED, KILL, SUICIDE, KICK_PLAYER, TEMP_BAN_PLAYER,
BAN_PLAYER, UNBAN_PLAYER, ROUND_END, PING

One exception: **UNBAN_PLAYER (20) is intercepted** by `BangModRCon.HandleUnbanFixed`
before it reaches `super`. Vanilla's `AOCAccessControl.UnbanByUID` removes the entry
from the in-memory `Bans` array and stops -- it never calls `SaveConfig()`, while
`AddBan` does, so the ban is still sitting in the ini and comes back on the next server
start. The interception does the same removal, calls `SaveConfig()`, and audits whether
anything actually matched (vanilla's version was silent either way).

### 23-28 -- ChivAdmin parity, implemented here

Opcode **23 overrides `GameEvent_UpdatePing`**, it does not add a new hook. That is the
only ping entry point the game calls (`AOCPlayerController.uc:8446`); `AOCRCon` is native
and exposes nothing else, so a separately-named "extended" function would never run. It
replaces vanilla opcode 22 rather than sitting alongside it, matching what the ChivAdmin
mutator did, and the field order is theirs: uid, ping, score, idleTime, kills,
teamDamageDealt, rank. `AOCPRI.IdleTime` is a byte of quarter-scale seconds
(`AOCPRI.uc:558`), so it is multiplied by 4 on the way out and saturates at 1020s.

Opcode **48 (SOBER_PLAYER)** is BangMod-only and undoes 26. ChivAdmin's Inebriate carries
only a UID and is one-way; 26 is left wire-compatible with that rather than growing a flag.

### 49-50 -- tournament control

  * **49 SET_TOURNAMENT** `int enabled, int thresholdPercent (0 = leave)`
    Disable also clears `class'AOCGame'.default.bTournamentMode` and saves. `bTournamentMode`
    is globalconfig and InitGame re-reads it every map (AOCGame.uc:3337), so a runtime-only
    clear lets the mode come back after a map change and re-brick the pre-round. Enable is
    runtime-only on purpose.
  * **50 READY_ALL** `int ready (1 = ready all, 0 = clear all)`

**BangMod deliberately disabled vanilla's own tournament command.** `BangModGame.uci:137`
carries `// Deprecated` and an empty `function AdminTournamentMode(bool bEnable){}`, which
neuters `AOCGame.AdminTournamentMode` -- and that is no loss, because the vanilla version
writes the flag to config with `SaveConfig` and then calls
`WorldInfo.ServerTravel("?restart")`. In other words the in-game `AdminTournamentMode`
command does nothing on a BangMod server, and opcode 49 is not a duplicate of it but the
only working way to toggle the mode. Do not "restore" the vanilla behaviour without asking:
a map restart per toggle is exactly what was removed.

`bTournamentMode` gates `AOCGame.ShouldStartRound` (AOCGame.uc:3062), holding the pre-round
until each team reaches `TournamentTeamReadyThreshold` or `bAdminForcedTournamentReady` is
set. Two things the client has to state rather than hide:

  * It only bites during the pre-round.
  * **`StartRound` clears it** (AOCGame.uc:3099). TB's comment there says it "can't persist
    (since LTS reenters preround)", so it is one-shot per round start. Vanilla behaviour,
    not a bug to work around.

Opcode 49 also applies the side effects vanilla applies at InitGame when the mode is on
(AOCGame.uc:3344): autobalance off, ping limit off, team damage penalty disabled. A mid-match
toggle never ran InitGame, so without this "tournament mode over RCON" would quietly mean
something weaker than `?Tournament` on the command line. They are **not** reverted on
disable -- the server cannot know what it was originally configured with, and guessing would
silently rewrite an admin's settings.

Opcode 50 with `ready=1` is vanilla's `AdminReadyAll` (:5235), previously reachable only by
typing `!adminreadyall` in chat. `ready=0` has no vanilla equivalent and clears
`bAdminForcedTournamentReady` as well, which is what makes a re-match work -- otherwise the
gate stays latched open from the previous round.

### 60-61 -- teleport and slap

  * **60 TELEPORT** `QWord mover, QWord destination`
  * **61 SLAP** `QWord uid, int power` (clamped 50-2000 server-side, no damage)

Both share `BangModAdminActions` with the in-game chat commands, so the placement logic
exists once. `Actor.SetLocation` is `native(267)` and returns FALSE when the spot is taken,
so `Teleport` walks a ring of eight positions around the destination before giving up --
dropping a player inside another would otherwise fail silently or telefrag. Velocity is
cleared so nobody arrives still carrying a sprint. Both players must be alive, and the
failure reason is in the audit line.

**In-game equivalents** are parsed out of chat in `BangModGame.BroadcastMessage`, the same
way vanilla handles `!ready` / `!adminreadyall` (AOCGame.uc:727-755):

    !bring <name>          pull a player to you
    !goto <name>           go to a player
    !slap <name> [power]   default power 400

Admin-gated, partial names, and an ambiguous name reports the match count rather than
guessing. The message is consumed rather than broadcast, so the command never appears in
everyone's chat. A non-admin typing one gets it broadcast as ordinary chat, which is the
right outcome -- silently eating it would be confusing.

### 51-59 -- freeze, class, loadout, map

  * **51 SET_FROZEN** `QWord uid, int frozen`
  * **52 SET_CLASS** `QWord uid, int classIndex, int immediate`
  * **53 LOADOUT_REQUEST** `QWord uid` -> a burst of 54, then 55
  * **54 LOADOUT_OPTION** out `QWord uid, int slot, int index, string weapon`
  * **55 LOADOUT_END** out `QWord uid, int prim, int sec, int tert`
  * **56 SET_LOADOUT** `QWord uid, int prim, int sec, int tert` (-1 = leave that slot)
  * **57 PLAYER_POS_REQUEST** -> a burst of 58, then 59
  * **58 PLAYER_POS** out `QWord uid, string name, int team, int x, int y, int z, int yawDeg, int alive, int health`
  * **59 PLAYER_POS_END** out `int count`

**Freeze needs no new replication.** `AOCPlayerController.ScriptToggleInput` ->
`ClientScriptToggleInput` (:7572) is already a `reliable client function`; the
`ScriptBlockedInputs` array is not replicated but the RPC that writes it is. Read TB's
comment beside it before trusting this for anything: *"This isn't a safe way of preventing a
player from performing some action. It's intended for SP/Tutorials."* Enforcement is
client-side. Talk is deliberately left unblocked.

**Loadout is exchanged as indices, not names.** 53 walks
`AOCFamilyInfo.NewPrimaryWeapons/NewSecondaryWeapons/NewTertiaryWeapons` and sends each
entry's index; 56 sets by that index. No weapon class path crosses the wire, so the client
needs no content knowledge and the server never resolves a string it was handed.
`AltPrimaryWeapon` is carried through untouched -- it is not in the choice lists and
clobbering it would drop the alternate mode of whatever they hold. Server-side only:
`SetWeapons` is simulated and the normal flow is client-then-`S_SetWeapons`, so this sets
what the server will spawn them with, not what their own class menu shows.

**Positions are read live, not from the replicated copy.** `AOCPRI.PawnLocation` is only
refreshed on a 2s server timer (AOCPRI.uc:192); the handler already runs on the server, so
it takes `Pawn.Location` directly and falls back to `PawnLocation` for a player whose pawn is
gone. Yaw is converted to degrees on the way out so the client needs to know nothing about
UE3 rotator units.

**Inebriate is not TO2-only, and neither 26 nor 48 touches the sound mode.** Two things had
to be right:

  * `EnableDrunkSoundMode` is a plain function, so calling it from an RCON handler runs it on
    the *server's* copy of the controller, where its 1s repeating timer reaches for an audio
    device a dedicated server does not have. Both handlers now call only `ClientInebriate`;
    `AOCBaseHUD` drives the sound mode on the player's own machine from its fade.
  * The drunk effect is gated by the active post-process chain, not the map.
    `AOCBaseHUD.NotifyBindPostProcessEffects` looks up `'drunkeffect'` in
    `LocalPlayer.PlayerPostProcess`, and Torn Banner's comment beside it says "if the PPC
    doesn't have a drunk effect, this does nothing". The default chain is
    `CHV_PPC_Pack.ChivPostProcess_noToneMap`; the drunk nodes live in the sibling chain
    `ChivPostProcess_drunk` in the same base-game package. BangMod's `ClientInebriate`
    override **swaps the whole chain** and re-binds when the map has none of its own, using
    the engine's own idiom from `GameInfo.uc:1585-1592`:

        LP.RemoveAllPostProcessingChains();
        LP.InsertPostProcessingChain(<chain>, INDEX_NONE, true);
        PC.myHUD.NotifyBindPostProcessEffects();

    Appending instead of replacing is what the first attempt did, and it renders as heavy
    blocky smearing: `ChivPostProcess_drunk` is a *complete* chain, a sibling of
    `ChivPostProcess_noToneMap`, so leaving the map's chain in place runs two full chains
    back to back and uber-post-processes (tone map, bloom, motion blur) the scene twice.
    Sober-up restores `Engine.static.GetWorldPostProcessChain()` the same way, and only when
    BangMod was the one that swapped it.


| # | Name | Dir | Payload |
|---|------|-----|---------|
| 23 | PING_EXTENDED | out | qword uid, int ping, score, idleTime, kills, teamDamageDealt, rank |
| 24 | CHANGE_SCORE | in | qword uid, int score |
| 25 | KILL_PLAYER | in | qword uid |
| 26 | INEBRIATE | in | qword uid |
| 27 | CHANGE_GAME_PASSWORD | in | string password |
| 28 | CONSOLE_COMMAND | in | qword uid, int scope, string command |

Scope: `0` = game, `1` = that player, `2` = all players.

**23 is written but not wired.** Vanilla drives plain PING from
`GameEvent_UpdatePing`; hooking the extended one needs a decision on how often to emit a
packet per player. `idleTime` and `rank` are sent as 0 -- nothing in `AOCPRI` or
`PlayerReplicationInfo` tracks either, and inventing values would be worse than the gap.

### 29-37 -- BangMod additions

ChivAdmin ignores opcodes it does not know, so these cannot break it.

| # | Name | Dir | Payload |
|---|------|-----|---------|
| 29 | PLAYER_LIST_REQUEST | in | (empty) |
| 30 | PLAYER_INFO | out | qword uid, string name, int team, score, deaths, kills, ping, health, teamDamage, string class, int isSpectator |
| | | | ping is milliseconds (`PRI.Ping * 4`), matching opcode 23. Bots carry a synthetic uid: `{A=0, B=PlayerID}`. |
| 31 | PLAYER_LIST_END | out | int count |
| 32 | SET_TEAM | in | qword uid, int team |
| 33 | FORCE_SPECTATE | in | qword uid |
| 34 | SET_TEAM_SCORE | in | int team, int score |
| | | | LTS keeps the real score in `AOCLTS.RoundScores` and draws `AOCLTSGRI.RoundsWon`; `Teams[].Score` is a mirror rewritten from `RoundScores` at every round boundary (`AOCLTS.uc:216-219`, `:316`). All three are written. `AOCLTS.uc:331` tests `== GoalScore` after the increment, so a team set to the goal steps over it and never triggers the end. |
| 35 | ADMIN_AUDIT | out | string action, string detail |
| 36 | SERVER_INFO_REQUEST | in | (empty) |
| 37 | SERVER_INFO | out | string map, int numPlayers, maxPlayers, matchBegun, numSpectators |
| 38 | CONSOLE_RESULT | out | string command, string result |
| 39 | BAN_LIST_REQUEST | in | (empty) |
| 40 | BAN_INFO | out | qword uid, string name, string reason, int durationSeconds, string netIdString, string ipPolicy |
| 41 | BAN_LIST_END | out | int count |
| 42 | MUTE_PLAYER | in | qword uid, int mute |
| 43 | SET_PAUSE | in | int paused |
| | | | Goes to `AOCGame.SetPause`/`ClearPause`, not `PlayerController.SetPause` (BangMod's override there is admin-gated). `bPauseable` is forced on around the call: AOCGame inherits `bPauseable=False` from `UTGame.uc:3396`, and `bAdminCanPause=false` in UDKGame.ini, so `AllowPausing` refused every pause until this. In-game `unpause` only clears a pause the same controller set, so it cannot undo this -- use RCON or `!unpause`. |
| 44 | END_MATCH | in | int winningTeam, string reason |
| 45 | SET_AUTOBALANCE | in | int enabled |
| 46 | SET_GAME_SPEED | in | int speedPercent (100 = normal, clamped 10-400) |
| 47 | RESTART_MATCH | in | (empty) |

**46 exists rather than routing through 28** because `AOCGame.SetGameSpeed` notifies
every client via `NotifySpeedChanged` and republishes `AOCGRI.Speed`, which a bare
`GameInfo.ConsoleCommand` does not do. That is exactly why the old relay carried its own
SLOMO verb. Clamped 10-400%: a speed of zero stops the match with no way to type the
command that would restore it.

**38 is the one that changes how RCON feels.** `Actor.ConsoleCommand` returns the
command's output as a string and vanilla throws it away, so every *query* command was
invisible to an admin. Opcode 28 now captures it and replies with 38, which makes RCON
a real console rather than a fire-and-forget pipe. Empty results are still sent so a
client can always pair a response to its request.

**39-41 fixes a genuine vanilla gap:** RCON could unban but had no way to *see* the ban
list, so unbanning meant already knowing the uid. `AOCAccessControl.Bans` carries name,
reason and duration for exactly this reason.

**42** sets `AOCPRI.bIsAdminMuted` directly rather than calling
`ServerAdminMutePlayer`, which gates on the *caller's* `bAdmin` -- the console has no
PRI, so that path could never authorise it. The RCON password is the authorisation.

**43** borrows a PlayerController to own the pause (an admin if one is connected),
because `GameInfo.SetPause` requires one and the console has none.

**44** converts a team index into the winning PRI via
`AOCGame.GetHighestScoreFromTeam`, since `EndGame` wants a PRI. An empty team ends the
match with no winner rather than failing silently.

29 replies with a burst of 30s then a 31. Kills come from `AOCPRI.NumKills`, not
`PlayerReplicationInfo.Kills` -- AOCPRI's own comment says `Kills` is not replicated.

## CONSOLE_COMMAND is the important one

Scope 1 runs against the **server-side** controller for that player, so it reaches
server functions and admin execs. It does not execute on their machine.

That single opcode exposes everything BangMod already has without a per-command opcode:
`AdminKick`, `AdminKickBan`, `AdminUnban`, `AdminBanNetID`, `AdminChangeTeam`,
`AdminCoinFlip`, `AdminReadyAll`, `AdminCancelVote`, `AdminTournamentMode`,
`AdminToggleParryBox`, `AdminEnableSkeletalParry`, `AdminDisableButtParries`,
`AdminForceSpectate`, `AdminForceSpectateAll`, `ce`, and anything added later.

It is also arbitrary execution against a live server, gated only by the RCON password.

Because scope 1 runs in the server's process, `quit` on a player quits the **server** --
confirmed in testing. `BangModBlockedConsoleCommands` (config, `[BangMod.BangModRCon]` in
UDKGame.ini) refuses the first token of a command; defaults are `quit`, `exit`, `debug`.

## Auditing

Every state-changing command calls `BangModAudit(Action, Detail)`, which:

  * logs via `LogAlwaysInternal` (not the log macro -- FINAL_RELEASE makes `LogInternal`
    private and the macro stops compiling), and
  * emits opcode 35 so any connected client sees it too.

Passwords are never logged; opcode 27 records only "set" or "cleared". This is
deliberate: admin power on this server should be visible rather than quiet.

Not yet done: an in-game notification for destructive actions. `22603c3` already added
admin command logging in-game, so there is a pattern to extend.

## Client (C:\Projects\ChivRcon)

.NET 8, three projects. `ChivRcon.Core` speaks the protocol; `ChivRcon.App` is the
WinForms UI; `ChivRcon.Tests` is a self-contained runner.

Its opcode table already matched 0-28 exactly, so the parity work needed no client
changes at all. Added since: opcodes 29-47 in `RconMessageType`, the matching send
methods and parse cases in `RconClient`, and event records in `RconEvents`.

**The relay is gone.** `RelayClient.cs` spoke a separate text protocol on its own port,
served by a `ChivRelay` ServerActor, and existed solely to reach three things native
RCON could not: console commands, text mute, and game speed. Those are now opcodes 28,
42 and 46, so the whole second connection -- port field, status label, reconnect timer,
connect/disconnect lifecycle -- was removed along with its integration tests. Old
settings files carrying `RelayPort` still load; unknown JSON properties are ignored.

One naming fix worth knowing: the client's `ConsoleCommandScope` used to read
`Server / Client / All`. Scope 1 does **not** run on the player's machine -- it runs on
their server-side controller -- so it now reads `Game / Player / AllPlayers`, matching
ChivAdmin's own naming and the server.

## Adding an opcode

1. `const RCONX_YOURTHING = 38;` in `BangModRCon.uc`.
2. A `case` in `HandleMessage`'s extended switch.
3. A handler that reads with `GetGUID`/`GetInt`/`GetString` **in the order the client
   writes them** and calls `BangModAudit` if it changes state.
4. Document it in the table above.

Unknown opcodes are logged and ignored, never fatal -- a newer client cannot drop the
connection.

## Three vanilla traps, found the hard way

These are worth reading before adding anything that moves players or silences them.

### `WorldInfo.Game.ChangeTeam(PC, num, ...)` does not change teams

`AOCGame.ChangeTeam` (AOCGame.uc:1618) ignores `num` completely apart from a `< 255`
test:

    NewTeam = (num < 255) ? Teams[AOCPlayerController(Other).CurrentFamilyInfo.FamilyFaction] : ObserverTeam;

The team is read back off the player's own `CurrentFamilyInfo`, so it always resolves to
the team they are already on, hits the "check if already on this team" branch, and
returns false. `ServerChangeTeam(N)` is no better -- `AOCPlayerController.ChangeToNewTeam`
calls it with `CurrentFamilyInfo.FamilyFaction` anyway.

The only thing that moves a player is changing `CurrentFamilyInfo` first. The one place
in the stock game that force-swaps a live player is `AOCGame.PerformDeathBasedAB`
(AOCGame.uc:4962), and `BangModForceTeam` follows it:

  1. `NewFamily = AOCGRI.FamilyInfos[ClassReference]`, `+5` for Mason. The array is
     laid out 0-4 Agatha, 5-9 Mason, indexed by `ClassReference`.
  2. `PC.ClientAutoBalance(NewFamily)` -- clears the client's pending team selection and
     updates its HUD.
  3. `PC.SetNewClass(NewFamily, false, true)` -- `bForceSwitch = true` (autobalance passes
     false) is what sets `bMarkNewTeam` and kills the current pawn, so the swap lands now
     instead of on next respawn.
  4. `AOCPRI.MyFamilyInfo = none`.
  5. `PC.ServerChangeTeam(NewFamily.FamilyFaction)` -- only now does `ChangeTeam` resolve
     to the other team.

A player who has not picked a class yet has no `CurrentFamilyInfo` and cannot be swapped;
opcode 32 audits `SET_TEAM_FAILED` in that case rather than failing silently.

### `bIsAdminMuted` alone does not mute anyone

The flag replicates fine (`AOCPRI.uc:128`, on `bNetDirty`), but the only chat-side
consumer is `AOCPlayerController.ReceiveChatMessage` (:3502) -- i.e. **on each receiving
client**, and it is skipped in two cases:

  * the receiver has the sender on their Steam friends list (`SteamFriendPRI`), and
  * the message is the sender's own copy (`PRI != PlayerReplicationInfo`).

So a muted player still watches their own chat go through, which is exactly what mute
looking broken looks like when testing. `ServerAdminMutePlayer` (:7304) sets the flag and
has its `UpdateGameplayMuteList` follow-up commented out, so nothing else covers it.

`BangModGame.BroadcastMessage` now drops the message server-side before it reaches the
wire, and tells the sender they are muted. VOIP was already covered -- `AOCGame.uc:2198`
checks the flag when building voice channels.

### The ban list is server-side, and that is fine

`AOCAccessControl.Bans` is `globalconfig array<BanInfo>`, so it only exists in the
server's ini and no client can read it directly. Opcodes 39-41 walk the array **on the
server** and send one `BAN_INFO` per entry, so exposing it is entirely feasible -- the
client just never had a way to ask before. `ChivRcon.App/BanManagerDialog.cs` is the UI:
refresh, select, unban, with the server's audit line reported back in the dialog.

Note `KickBanGlobal` -> `AddBan` stores both the NetID **and** an IP policy
(`DENY,<addr>`) in the same `BanInfo`, so removing the entry lifts both. An IP-only ban
with no UID cannot be lifted by opcode 20; the dialog greys that case out.

## Untested, in rough risk order

  * The C# client changes have not been compiled -- no .NET SDK was reachable from this
    session. `BanManagerDialog.cs` is a new file in `ChivRcon.App`.
  * `BangModForceTeam` against a player who is mid-respawn, in a vehicle, or a King class
    (`FamilyInfos` only covers the five standard classes).
  * `AC.Bans.Remove(i, 1)` + `SaveConfig()` from outside `AOCAccessControl` -- legal
    UnrealScript, but the write happens on whatever ini `AOCAccessControl` is configured
    to, not necessarily the one being edited by hand.
  * Opcode 30's field order against the client's parse (now read by the player list).
  * `Pawn.Died` for opcode 25 -- taken from an existing `AOCGame` call site, but not
    exercised from an RCON context.
