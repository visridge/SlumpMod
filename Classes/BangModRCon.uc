/**
 * BangMod remote console. Extends AOCRCon with ChivAdmin's command set plus our own.
 *
 * 0-22 are vanilla, in AOCRCon's MessageType order. 23-28 exist only in the ChivAdmin
 * client (its mutator was never published); implementing them means an unmodified
 * ChivAdmin client works here. 29+ are ours -- unknown opcodes are ignored, so adding
 * them cannot break that client. Full table and payloads: RCON_PROTOCOL.md.
 *
 * Every state-changing command calls BangModAudit: logged, and echoed as
 * RCONX_ADMIN_AUDIT. RCON is password-authenticated but otherwise unrestricted, and
 * opcode 28 is arbitrary execution, so that power should be visible rather than quiet.
 */
class BangModRCon extends AOCRCon;

// ---- ChivAdmin mutator parity ------------------------------------------------
const RCONX_PING_EXTENDED        = 23;
const RCONX_CHANGE_SCORE         = 24;
const RCONX_KILL_PLAYER          = 25;
const RCONX_INEBRIATE            = 26;
const RCONX_CHANGE_GAME_PASSWORD = 27;
const RCONX_CONSOLE_COMMAND      = 28;

// ---- BangMod additions -------------------------------------------------------
const RCONX_PLAYER_LIST_REQUEST  = 29;  // in : (no body)
const RCONX_PLAYER_INFO          = 30;  // out: one per player, see SendPlayerInfo
const RCONX_PLAYER_LIST_END      = 31;  // out: marks the end of a list burst
const RCONX_SET_TEAM             = 32;  // in : QWord uid, int team
const RCONX_FORCE_SPECTATE       = 33;  // in : QWord uid
const RCONX_SET_TEAM_SCORE       = 34;  // in : int team, int score
const RCONX_ADMIN_AUDIT          = 35;  // out: string action, string detail
const RCONX_SERVER_INFO_REQUEST  = 36;  // in : (no body)
const RCONX_SERVER_INFO          = 37;  // out: see SendServerInfo
const RCONX_CONSOLE_RESULT       = 38;  // out: string command, string result
const RCONX_BAN_LIST_REQUEST     = 39;  // in : (no body)
const RCONX_BAN_INFO             = 40;  // out: one per ban, see SendBanInfo
const RCONX_BAN_LIST_END         = 41;  // out: int count
const RCONX_MUTE_PLAYER          = 42;  // in : QWord uid, int mute
const RCONX_SET_PAUSE            = 43;  // in : int paused
const RCONX_END_MATCH            = 44;  // in : int winningTeam, string reason
const RCONX_SET_AUTOBALANCE      = 45;  // in : int enabled
const RCONX_SET_GAME_SPEED       = 46;  // in : int speedPercent (100 = normal)
const RCONX_RESTART_MATCH        = 47;  // in : (no body)
const RCONX_SOBER_PLAYER         = 48;  // in : QWord uid
const RCONX_SET_TOURNAMENT       = 49;  // in : int enabled, int thresholdPercent (0 = leave)
const RCONX_READY_ALL            = 50;  // in : int ready (1 = ready all, 0 = clear all)
const RCONX_SET_FROZEN           = 51;  // in : QWord uid, int frozen
const RCONX_SET_CLASS            = 52;  // in : QWord uid, int classIndex, int immediate
const RCONX_LOADOUT_REQUEST      = 53;  // in : QWord uid
const RCONX_LOADOUT_OPTION       = 54;  // out: QWord uid, int slot, int index, string weapon
const RCONX_LOADOUT_END          = 55;  // out: QWord uid, int prim, int sec, int tert
const RCONX_SET_LOADOUT          = 56;  // in : QWord uid, int prim, int sec, int tert (-1 = leave)
const RCONX_PLAYER_POS_REQUEST   = 57;  // in : (no body)
const RCONX_PLAYER_POS           = 58;  // out: see SendPlayerPositions
const RCONX_PLAYER_POS_END       = 59;  // out: int count
const RCONX_TELEPORT             = 60;  // in : QWord who, QWord toWhom
const RCONX_SLAP                 = 61;  // in : QWord uid, int power

const SLOT_PRIMARY   = 0;
const SLOT_SECONDARY = 1;
const SLOT_TERTIARY  = 2;

const SCOPE_GAME        = 0;
const SCOPE_PLAYER      = 1;
const SCOPE_ALL_PLAYERS = 2;

/**
 * Console verbs RCON refuses to run, matched case-insensitively on the first token.
 * Scope 1 runs on the SERVER-side controller, so "quit" on a player kills the server
 * (confirmed in testing). config(Game) is inherited, so admins can extend this in
 * UDKGame.ini under [BangMod.BangModRCon].
 */
var config array<string> BangModBlockedConsoleCommands;

/** Set while opcode 43 has forced GameInfo.bPauseable on, with the value to put back. */
var bool bBangModPauseForced;
var bool bBangModPauseableWas;


/**
 * One place for "an admin did something". Logs it and puts it on the wire.
 * LogAlwaysInternal rather than the log macro: FINAL_RELEASE builds make LogInternal
 * private and the macro stops compiling.
 */
function BangModAudit(string Action, string Detail)
{
	local AOCRConPacket Packet;

	LogAlwaysInternal("[BangModRCon]" @ Action @ "|" @ Detail);

	Packet = new class'AOCRConPacket';
	Packet.SetMessageType(RCONX_ADMIN_AUDIT);
	Packet.AddString(Action);
	Packet.AddString(Detail);
	SendPacket(Packet);
}

/** Name for a uid we may or may not still have a controller for. */
/**
 * Bots have no Steam ID, so stamp {A=0, B=PlayerID} like vanilla does at AOCRCon.uc:352 --
 * except that block is inside a notdefined(FINAL_RELEASE) guard, so shipped builds lose it.
 * Real SteamID64s never have a zero high half, so there is no collision.
 */
function EnsureUniqueId(PlayerReplicationInfo PRI)
{
	if (PRI == none)
		return;

	if (PRI.UniqueId.Uid.A == 0 && PRI.UniqueId.Uid.B == 0)
	{
		PRI.UniqueId.Uid.A = 0;
		PRI.UniqueId.Uid.B = PRI.PlayerID;
	}
}

/**
 * GetPlayerControllerFromGUID that also finds bots. Use for anything needing only a Pawn;
 * anything that talks to a client must keep using the PlayerController version.
 */
function Controller GetControllerFromGUID(QWord UniqueId)
{
	local Controller C;

	foreach WorldInfo.AllControllers(class'Controller', C)
	{
		if (C.PlayerReplicationInfo == none)
			continue;

		if (C.PlayerReplicationInfo.UniqueId.Uid == UniqueId)
			return C;
	}

	return none;
}

/** Stamp bots before the connect event goes out, so the client sees them from the start. */
function GameEvent_PlayerConnect(PlayerReplicationInfo PRI)
{
	EnsureUniqueId(PRI);
	super.GameEvent_PlayerConnect(PRI);
}

function string DescribePlayer(QWord PlayerId)
{
	local AOCPlayerController PC;

	PC = GetPlayerControllerFromGUID(PlayerId);
	if (PC != none && PC.PlayerReplicationInfo != none)
		return PC.PlayerReplicationInfo.PlayerName;

	return "<unknown uid>";
}

/**
 * Extended opcodes are handled here; everything else falls through to vanilla.
 *
 * Deliberately checks RCON_Connected first. Vanilla's HandleMessage closes the
 * connection on any non-PASSWORD packet while still authenticating, and that behaviour
 * must survive -- an unauthenticated peer must not reach any of this.
 */
function HandleMessage(AOCRConPacket Packet)
{
	// Vanilla opcode 20 is intercepted rather than extended: AOCAccessControl.UnbanByUID
	// removes the entry from the in-memory array and never calls SaveConfig(), so the ban
	// is still in the ini and returns on the next server start. See HandleUnbanFixed.
	if (RConState == RCON_Connected && Packet.MessageType == MessageType.UNBAN_PLAYER)
	{
		HandleUnbanFixed(Packet);
		return;
	}

	if (RConState == RCON_Connected && Packet.MessageType >= RCONX_PING_EXTENDED)
	{
		switch (Packet.MessageType)
		{
			case RCONX_CHANGE_SCORE:          HandleChangeScore(Packet);        return;
			case RCONX_KILL_PLAYER:           HandleKillPlayer(Packet);         return;
			case RCONX_INEBRIATE:             HandleInebriate(Packet);          return;
			case RCONX_CHANGE_GAME_PASSWORD:  HandleChangeGamePassword(Packet); return;
			case RCONX_CONSOLE_COMMAND:       HandleConsoleCommand(Packet);     return;
			case RCONX_PLAYER_LIST_REQUEST:   HandlePlayerListRequest();        return;
			case RCONX_SET_TEAM:              HandleSetTeam(Packet);            return;
			case RCONX_FORCE_SPECTATE:        HandleForceSpectate(Packet);      return;
			case RCONX_SET_TEAM_SCORE:        HandleSetTeamScore(Packet);       return;
			case RCONX_SERVER_INFO_REQUEST:   SendServerInfo();                 return;
			case RCONX_BAN_LIST_REQUEST:      HandleBanListRequest();           return;
			case RCONX_MUTE_PLAYER:           HandleMutePlayer(Packet);         return;
			case RCONX_SET_PAUSE:             HandleSetPause(Packet);           return;
			case RCONX_END_MATCH:             HandleEndMatch(Packet);           return;
			case RCONX_SET_AUTOBALANCE:       HandleSetAutoBalance(Packet);     return;
			case RCONX_SET_GAME_SPEED:        HandleSetGameSpeed(Packet);       return;
			case RCONX_RESTART_MATCH:         HandleRestartMatch();             return;
			case RCONX_SOBER_PLAYER:          HandleSober(Packet);              return;
			case RCONX_SET_TOURNAMENT:        HandleSetTournament(Packet);      return;
			case RCONX_READY_ALL:             HandleReadyAll(Packet);           return;
			case RCONX_SET_FROZEN:            HandleSetFrozen(Packet);          return;
			case RCONX_SET_CLASS:             HandleSetClass(Packet);           return;
			case RCONX_LOADOUT_REQUEST:       HandleLoadoutRequest(Packet);     return;
			case RCONX_SET_LOADOUT:           HandleSetLoadout(Packet);         return;
			case RCONX_PLAYER_POS_REQUEST:    SendPlayerPositions();            return;
			case RCONX_TELEPORT:              HandleTeleport(Packet);           return;
			case RCONX_SLAP:                  HandleSlap(Packet);               return;
			default:
				// Unknown opcode from a client newer than this server. Ignore it
				// rather than dropping the connection.
				LogAlwaysInternal("[BangModRCon] ignoring unknown opcode" @ Packet.MessageType);
				return;
		}
	}

	super.HandleMessage(Packet);
}

/* ============================ ChivAdmin parity ============================== */

/** 24: set a player's score. */
function HandleChangeScore(AOCRConPacket Packet)
{
	local QWord PlayerId;
	local int NewScore;
	local AOCPlayerController PC;

	PlayerId = Packet.GetGUID();
	NewScore = Packet.GetInt();

	PC = GetPlayerControllerFromGUID(PlayerId);
	if (PC == none || PC.PlayerReplicationInfo == none)
		return;

	PC.PlayerReplicationInfo.Score = NewScore;
	PC.PlayerReplicationInfo.bNetDirty = true;
	BangModAudit("CHANGE_SCORE", PC.PlayerReplicationInfo.PlayerName @ "->" @ NewScore);
}

/** 25: kill a player where they stand. */
function HandleKillPlayer(AOCRConPacket Packet)
{
	local QWord PlayerId;
	local Controller C;

	PlayerId = Packet.GetGUID();

	C = GetControllerFromGUID(PlayerId);   // Controller-level so bots can be slain.

	if (C == none || C.Pawn == none)
		return;

	BangModAudit("KILL_PLAYER", DescribeController(C));
	C.Pawn.Died(C, class'AOCDmgType_Generic', C.Pawn.Location);
}

/** 26: the drunk screen effect. AOCPlayerController.ClientInebriate drives the HUD. */
function HandleInebriate(AOCRConPacket Packet)
{
	local QWord PlayerId;
	local AOCPlayerController PC;

	PlayerId = Packet.GetGUID();
	PC = GetPlayerControllerFromGUID(PlayerId);
	if (PC == none)
		return;

	BangModAudit("INEBRIATE", PC.PlayerReplicationInfo.PlayerName);

	// ClientInebriate is the whole job. EnableDrunkSoundMode must NOT be called from here:
	// it is a plain function, so on an RCON command it runs on the SERVER's copy of the
	// controller, where it sets a 1s repeating timer that reaches for an audio device the
	// dedicated server does not have. AOCBaseHUD already drives the sound mode on the
	// player's own machine, from its fade in UpdateDrunkEffect.
	//
	// BangMod's ClientInebriate override also adds the drunk post-process chain when the
	// map has none, which is what lifts this off TO2 maps.
	PC.ClientInebriate(true);
}

/**
 * 48: undo 26. ChivAdmin never had this -- its Inebriate command carries only a UID and
 * is one-way, so the effect lasted until the player respawned. Kept as its own opcode
 * rather than adding a flag to 26, so 26 stays wire-compatible with a ChivAdmin client.
 */
function HandleSober(AOCRConPacket Packet)
{
	local QWord PlayerId;
	local AOCPlayerController PC;

	PlayerId = Packet.GetGUID();
	PC = GetPlayerControllerFromGUID(PlayerId);
	if (PC == none)
	{
		BangModAudit("SOBER_FAILED", DescribePlayer(PlayerId) @ "- no player controller with that id");
		return;
	}

	BangModAudit("SOBER", PC.PlayerReplicationInfo.PlayerName);

	// As with 26: client-side only. ToggleDrunkPostEffects(false) turns the sound mode off
	// on the player's machine as part of the same call.
	PC.ClientInebriate(false);
}

/** 27: set (or clear, with an empty string) the server's join password. */
function HandleChangeGamePassword(AOCRConPacket Packet)
{
	local string NewPassword;

	NewPassword = Packet.GetString();

	if (WorldInfo.Game == none || WorldInfo.Game.AccessControl == none)
		return;

	WorldInfo.Game.AccessControl.SetGamePassword(NewPassword);

	// Never log the password itself.
	BangModAudit("CHANGE_GAME_PASSWORD", (NewPassword == "") ? "cleared" : "set");
}

/** True if Command's first token is on BangModBlockedConsoleCommands. */
function bool IsConsoleCommandBlocked(string Command)
{
	local string Verb;
	local int i, SpacePos;

	Verb = Locs(Command);

	while (Left(Verb, 1) == " " || Left(Verb, 1) == Chr(9))
		Verb = Mid(Verb, 1);

	SpacePos = InStr(Verb, " ");
	if (SpacePos != INDEX_NONE)
		Verb = Left(Verb, SpacePos);

	if (Verb == "")
		return false;

	for (i = 0; i < BangModBlockedConsoleCommands.Length; i++)
	{
		if (Locs(BangModBlockedConsoleCommands[i]) == Verb)
			return true;
	}

	return false;
}

/**
 * 28: run a console command. The most powerful thing here, hence the loudest audit.
 *
 * Scope 1 targets the SERVER-SIDE controller for that player, so it runs server
 * functions and admin execs against them. It does not execute on their machine.
 */
function HandleConsoleCommand(AOCRConPacket Packet)
{
	local QWord PlayerId;
	local int Scope;
	local string Command;
	local AOCPlayerController PC;
	local int Count;

	PlayerId = Packet.GetGUID();
	Scope    = Packet.GetInt();
	Command  = Packet.GetString();

	// All three scopes run in the server's process, so one check covers them.
	if (IsConsoleCommandBlocked(Command))
	{
		BangModAudit("CONSOLE_COMMAND(blocked)", Command);
		SendConsoleResult(Command, "Blocked: this command would take the server down."
			@ "Edit BangModBlockedConsoleCommands in UDKGame.ini to change the list.");
		return;
	}

	switch (Scope)
	{
		case SCOPE_GAME:
			BangModAudit("CONSOLE_COMMAND(game)", Command);
			if (WorldInfo.Game != none)
				SendConsoleResult(Command, WorldInfo.Game.ConsoleCommand(Command));
			break;

		case SCOPE_PLAYER:
			PC = GetPlayerControllerFromGUID(PlayerId);
			if (PC == none)
				return;
			BangModAudit("CONSOLE_COMMAND(player)", DescribePlayer(PlayerId) @ ":" @ Command);
			SendConsoleResult(Command, PC.ConsoleCommand(Command));
			break;

		case SCOPE_ALL_PLAYERS:
			foreach WorldInfo.AllControllers(class'AOCPlayerController', PC)
			{
				PC.ConsoleCommand(Command);
				Count++;
			}
			BangModAudit("CONSOLE_COMMAND(all)", Command @ "on" @ Count @ "players");
			break;
	}
}

/* ============================ BangMod additions ============================= */

/**
 * 29 -> a burst of 30s then a 31.
 * ChivAdmin's PING event only carries uid and ping; this is the whole scoreboard.
 * NumKills rather than Kills: AOCPRI comments that Kills is not replicated.
 */
function HandlePlayerListRequest()
{
	local PlayerReplicationInfo PRI;
	local AOCRConPacket Packet;
	local int i;

	if (WorldInfo.GRI == none)
	{
		BangModAudit("PLAYER_LIST_FAILED", "no GameReplicationInfo yet");
		Packet = new class'AOCRConPacket';
		Packet.SetMessageType(RCONX_PLAYER_LIST_END);
		SendPacket(Packet);
		return;
	}

	for (i = 0; i < WorldInfo.GRI.PRIArray.Length; i++)
	{
		PRI = WorldInfo.GRI.PRIArray[i];
		if (PRI == none)
			continue;

		// Bots present before RCON connected never fired the connect event.
		EnsureUniqueId(PRI);

		SendPlayerInfo(PRI);
	}

	Packet = new class'AOCRConPacket';
	Packet.SetMessageType(RCONX_PLAYER_LIST_END);
	Packet.AddInt(WorldInfo.GRI.PRIArray.Length);
	SendPacket(Packet);
}

/** 30: uid, name, team, score, deaths, kills, ping, health, teamDamage, class, spectator */
function SendPlayerInfo(PlayerReplicationInfo PRI)
{
	local AOCRConPacket Packet;
	local AOCPRI APRI;
	local string ClassName;

	APRI = AOCPRI(PRI);

	ClassName = "";
	if (APRI != none && APRI.MyFamilyInfo != none)
		ClassName = string(APRI.MyFamilyInfo.Name);

	Packet = new class'AOCRConPacket';
	Packet.SetMessageType(RCONX_PLAYER_INFO);
	Packet.AddQWord(PRI.UniqueId.Uid);
	Packet.AddString(PRI.PlayerName);
	Packet.AddInt((PRI.Team != none) ? PRI.Team.TeamIndex : -1);
	Packet.AddInt(int(PRI.Score));
	Packet.AddInt(PRI.Deaths);
	Packet.AddInt((APRI != none) ? APRI.NumKills : 0);
	// PRI.Ping is quarter-ms (PlayerController.ServerUpdatePing); opcode 23 sends raw ms.
	// Scale so both agree. Saturates at 1000ms.
	Packet.AddInt(PRI.Ping * 4);
	Packet.AddInt((APRI != none) ? APRI.CurrentHealth : 0);
	Packet.AddInt((APRI != none) ? APRI.TeamDamageDealt : 0);
	Packet.AddString(ClassName);
	Packet.AddInt((APRI != none && APRI.bIsVoluntarySpectator) ? 1 : 0);
	SendPacket(Packet);
}

/** 32: move a player to a team. */
function HandleSetTeam(AOCRConPacket Packet)
{
	local QWord PlayerId;
	local int NewTeam;
	local AOCPlayerController PC;

	PlayerId = Packet.GetGUID();
	NewTeam  = Packet.GetInt();

	PC = GetPlayerControllerFromGUID(PlayerId);
	if (PC == none || WorldInfo.Game == none)
		return;

	BangModForceTeam(PC, NewTeam);
}

/**
 * Move a player between Agatha and Mason.
 *
 * NOT WorldInfo.Game.ChangeTeam: AOCGame.ChangeTeam ignores its team argument and
 * re-resolves from CurrentFamilyInfo.FamilyFaction, so it always returns false. Changing
 * CurrentFamilyInfo first is the only thing that moves anyone -- same approach as
 * AOCGame.PerformDeathBasedAB. AOCGRI.FamilyInfos: 0-4 Agatha, 5-9 Mason.
 */
function BangModForceTeam(AOCPlayerController PC, int NewTeam)
{
	local AOCFamilyInfo NewFamily;
	local AOCGRI GRI;
	local int Index;
	local EAOCFaction Target;

	GRI = AOCGRI(WorldInfo.GRI);
	if (GRI == none || PC.CurrentFamilyInfo == none)
	{
		BangModAudit("SET_TEAM_FAILED", DescribeController(PC) @ "- no GRI or player has not picked a class yet");
		return;
	}

	Target = (NewTeam == 1) ? EFAC_MASON : EFAC_AGATHA;

	if (PC.CurrentFamilyInfo.FamilyFaction == Target)
	{
		BangModAudit("SET_TEAM_NOOP", DescribeController(PC) @ "- already on" @ (Target == EFAC_MASON ? "Mason" : "Agatha"));
		return;
	}

	Index = PC.CurrentFamilyInfo.default.ClassReference;
	if (Target == EFAC_MASON)
		Index += 5;

	if (Index < 0 || Index > 9)
	{
		BangModAudit("SET_TEAM_FAILED", DescribeController(PC) @ "- bad family index" @ Index);
		return;
	}

	NewFamily = GRI.FamilyInfos[Index];
	if (NewFamily == none)
	{
		BangModAudit("SET_TEAM_FAILED", DescribeController(PC) @ "- FamilyInfos[" $ Index $ "] is none");
		return;
	}

	// Order matters and is taken from PerformDeathBasedAB: tell the client to drop any
	// pending team selection and update its HUD, then set the class server-side.
	PC.ClientAutoBalance(NewFamily);

	// bForceSwitch=true (rather than autobalance's false) is what sets bMarkNewTeam and
	// kills the current pawn, so the swap lands immediately instead of on next respawn.
	PC.SetNewClass(NewFamily, false, true);
	AOCPRI(PC.PlayerReplicationInfo).MyFamilyInfo = none;

	// CurrentFamilyInfo now points at the new faction, so ChangeTeam finally resolves
	// to the other team. ServerChangeTeam consumes bMarkNewTeam for the broadcast.
	PC.ServerChangeTeam(NewFamily.FamilyFaction);

	BangModAudit("SET_TEAM", DescribeController(PC) @ "->" @ (Target == EFAC_MASON ? "Mason" : "Agatha") @ "as" @ NewFamily);
}

/** Same idea as DescribePlayer, but when the controller is already resolved. */
// Controller rather than AOCPlayerController so bots (AOCBot) describe too.
function string DescribeController(Controller PC)
{
	if (PC != none && PC.PlayerReplicationInfo != none)
		return PC.PlayerReplicationInfo.PlayerName;

	return "<unknown player>";
}

/**
 * 20 (vanilla): unban by UID, but persisted.
 *
 * AOCAccessControl.UnbanByUID never calls SaveConfig (AddBan does), so the ban returns
 * on restart. Removing it here lets us save, and report whether anything was removed.
 */
function HandleUnbanFixed(AOCRConPacket Packet)
{
	local UniqueNetId NetID;
	local AOCAccessControl AC;
	local string Removed;
	local int i;

	NetID.Uid = Packet.GetGUID();

	if (WorldInfo.Game == none)
		return;

	AC = AOCAccessControl(WorldInfo.Game.AccessControl);
	if (AC == none)
	{
		BangModAudit("UNBAN_FAILED", "no AOCAccessControl");
		return;
	}

	// Find it first purely so the audit line can name who was unbanned; the removal
	// itself goes through the stock function rather than poking AC.Bans directly.
	for (i = 0; i < AC.Bans.Length; i++)
	{
		if (AC.Bans[i].NetID == NetID)
		{
			Removed = AC.Bans[i].PlayerName @ "(" $ AC.Bans[i].NetIDAsString $ ")";
			break;
		}
	}

	if (Removed == "")
	{
		BangModAudit("UNBAN_FAILED", "no ban matching uid" @ NetID.Uid.A @ NetID.Uid.B
			@ "- request the ban list (opcode 39) and unban with a uid from it");
		return;
	}

	AC.UnbanByUID(NetID);

	// The bit vanilla forgets. Without this the array is clean in memory but the ini
	// still lists the ban, so it comes straight back on the next server start.
	AC.SaveConfig();

	BangModAudit("UNBAN", Removed);
}

/** 33: force a player into spectate. Mirrors BangMod's AdminForceSpectate. */
function HandleForceSpectate(AOCRConPacket Packet)
{
	local QWord PlayerId;
	local AOCPlayerController PC;

	PlayerId = Packet.GetGUID();
	PC = GetPlayerControllerFromGUID(PlayerId);
	if (PC == none)
		return;

	BangModAudit("FORCE_SPECTATE", DescribePlayer(PlayerId));
	PC.JoinSpectatorTeam();
}

/**
 * 34: set a team's score.
 *
 * LTS is the odd one: AOCLTS.RoundScores is authoritative, AOCLTSGRI.RoundsWon is drawn,
 * and Teams[].Score is a mirror rewritten from RoundScores at every round boundary
 * (AOCLTS.uc:216-219, :316). Writing the mirror alone is silently discarded. All three here.
 */
function HandleSetTeamScore(AOCRConPacket Packet)
{
	local int TeamIndex, NewScore, Goal;
	local AOCLTS LTS;

	TeamIndex = Packet.GetInt();
	NewScore  = Packet.GetInt();

	if (WorldInfo.GRI == none || TeamIndex < 0 || TeamIndex >= WorldInfo.GRI.Teams.Length)
		return;
	if (WorldInfo.GRI.Teams[TeamIndex] == none)
		return;

	WorldInfo.GRI.Teams[TeamIndex].Score = NewScore;
	WorldInfo.GRI.Teams[TeamIndex].bForceNetUpdate = true;

	LTS = AOCLTS(WorldInfo.Game);
	if (LTS != none && TeamIndex < LTS.RoundScores.Length)
	{
		LTS.RoundScores[TeamIndex] = NewScore;

		if (AOCLTSGRI(LTS.GameReplicationInfo) != none)
		{
			AOCLTSGRI(LTS.GameReplicationInfo).RoundsWon[TeamIndex] = NewScore;
			LTS.GameReplicationInfo.bForceNetUpdate = true;
		}

		// AOCLTS.uc:331 tests RoundScores[winner] == GoalScore AFTER incrementing it, so a
		// team parked ON the goal steps over it and the match never ends. GoalScore - 1 is
		// what makes the next round decisive.
		Goal = LTS.GoalScore;
		if (Goal > 0 && NewScore >= Goal)
		{
			BangModAudit("SET_TEAM_SCORE_WARNING",
				"team" @ TeamIndex @ "is at or past the goal of" @ Goal
				$ " - the end-of-round check is an exact match, so set" @ (Goal - 1)
				@ "if the next round should decide it");
		}
	}

	BangModAudit("SET_TEAM_SCORE", "team" @ TeamIndex @ "->" @ NewScore
		@ (LTS != none ? "(rounds won)" : ""));
}

/** 37: map, player count, and match state. */
function SendServerInfo()
{
	local AOCRConPacket Packet;

	Packet = new class'AOCRConPacket';
	Packet.SetMessageType(RCONX_SERVER_INFO);
	Packet.AddString(WorldInfo.GetMapName(true));
	Packet.AddInt((WorldInfo.Game != none) ? WorldInfo.Game.NumPlayers : 0);
	Packet.AddInt((WorldInfo.Game != none) ? WorldInfo.Game.MaxPlayers : 0);
	Packet.AddInt((WorldInfo.GRI != none && WorldInfo.GRI.bMatchHasBegun) ? 1 : 0);
	Packet.AddInt((WorldInfo.Game != none) ? WorldInfo.Game.NumSpectators : 0);
	SendPacket(Packet);
}

/** 23: the richer per-player ping event, sent at vanilla's own ping cadence. */
function GameEvent_UpdatePing(PlayerReplicationInfo PRI, int NewPing)
{
	local AOCRConPacket Packet;
	local AOCPRI APRI;

	APRI = AOCPRI(PRI);

	// Replaces vanilla opcode 22 rather than sitting alongside it, which is the same swap
	// the ChivAdmin mutator made, and the field order matches theirs so a ChivAdmin client
	// reads it unchanged.
	//
	// This overrides the vanilla hook deliberately: GameEvent_UpdatePing is the ONLY ping
	// entry point the game calls (AOCPlayerController.uc:8446). There is no separate
	// "extended" hook to add, so a new function here would simply never run.
	Packet = new class'AOCRConPacket';
	Packet.SetMessageType(RCONX_PING_EXTENDED);
	Packet.AddQWord(PRI.UniqueId.Uid);
	Packet.AddInt(NewPing);
	Packet.AddInt(int(PRI.Score));

	// AOCPRI.IdleTime is a byte holding quarter-scale seconds
	// (AOCPRI.uc:558 -- Min(Round(elapsed) / 4, 255)), so it is scaled back to seconds
	// here and saturates at 1020s / 17 minutes.
	Packet.AddInt((APRI != none) ? APRI.IdleTime * 4 : 0);
	Packet.AddInt((APRI != none) ? APRI.NumKills : 0);
	Packet.AddInt((APRI != none) ? APRI.TeamDamageDealt : 0);
	Packet.AddInt((APRI != none) ? APRI.MyRank : 0);
	SendPacket(Packet);
}

/* ============================ wave two ====================================== */

/**
 * 38: hand back whatever the command printed. Vanilla discards ConsoleCommand's return,
 * so query commands were invisible. Empty results are still sent, so every request pairs.
 */
function SendConsoleResult(string Command, string Result)
{
	local AOCRConPacket Packet;

	Packet = new class'AOCRConPacket';
	Packet.SetMessageType(RCONX_CONSOLE_RESULT);
	Packet.AddString(Command);
	Packet.AddString(Result);
	SendPacket(Packet);
}

/**
 * 39 -> a burst of 40s then a 41. Vanilla can unban but never shows the list, so you had
 * to know the uid. AOCAccessControl.Bans carries name, reason and duration.
 */
function HandleBanListRequest()
{
	local AOCAccessControl AC;
	local AOCRConPacket Packet;
	local int i;

	if (WorldInfo.Game == none)
		return;

	AC = AOCAccessControl(WorldInfo.Game.AccessControl);
	if (AC == none)
		return;

	for (i = 0; i < AC.Bans.Length; i++)
	{
		Packet = new class'AOCRConPacket';
		Packet.SetMessageType(RCONX_BAN_INFO);
		Packet.AddQWord(AC.Bans[i].NetID.Uid);
		Packet.AddString(AC.Bans[i].PlayerName);
		Packet.AddString(AC.Bans[i].Reason);
		Packet.AddInt(AC.Bans[i].DurationSeconds);
		Packet.AddString(AC.Bans[i].NetIDAsString);
		Packet.AddString(AC.Bans[i].IPPolicy);
		SendPacket(Packet);
	}

	Packet = new class'AOCRConPacket';
	Packet.SetMessageType(RCONX_BAN_LIST_END);
	Packet.AddInt(AC.Bans.Length);
	SendPacket(Packet);
}

/**
 * 42: admin text mute.
 *
 * Sets AOCPRI.bIsAdminMuted directly rather than calling ServerAdminMutePlayer, which
 * gates on the CALLER's PlayerReplicationInfo.bAdmin -- the remote console has no PRI,
 * so that path can never authorise it. Authorisation here is the RCON password.
 */
function HandleMutePlayer(AOCRConPacket Packet)
{
	local QWord PlayerId;
	local bool bMute;
	local AOCPlayerController PC;
	local AOCPRI APRI;

	PlayerId = Packet.GetGUID();
	bMute    = (Packet.GetInt() != 0);

	PC = GetPlayerControllerFromGUID(PlayerId);
	if (PC == none)
		return;

	APRI = AOCPRI(PC.PlayerReplicationInfo);
	if (APRI == none)
		return;

	// The flag alone is not enough. Vanilla only consults bIsAdminMuted client-side in
	// AOCPlayerController.ReceiveChatMessage, and that check is skipped for Steam friends
	// of the muted player and for the muted player's own copy of the message -- so a muted
	// player still sees themselves talking, which looks exactly like mute not working.
	// BangModGame.BroadcastMessage drops the message server-side instead.
	APRI.bIsAdminMuted = bMute;
	APRI.bForceNetUpdate = true;
	BangModAudit(bMute ? "MUTE_PLAYER" : "UNMUTE_PLAYER", APRI.PlayerName);
}

/* ======================= freeze, class, loadout, map ======================== */

/**
 * 60: send one player to another. Takes both ends because from here neither is "you".
 * Placement lives in BangModAdminActions: SetLocation returns false when the spot is
 * occupied, so it rings the destination rather than dropping someone inside them.
 */
function HandleTeleport(AOCRConPacket Packet)
{
	local QWord MoverId, DestId;
	local Controller Mover, Dest;   // Controller-level so bots work either end.

	MoverId = Packet.GetGUID();
	DestId  = Packet.GetGUID();

	Mover = GetControllerFromGUID(MoverId);
	Dest  = GetControllerFromGUID(DestId);

	if (Mover == none || Dest == none)
		return;

	if (Mover == Dest)
	{
		BangModAudit("TELEPORT_FAILED", DescribeController(Mover) @ "- cannot send a player to themselves");
		return;
	}

	if (Mover.Pawn == none || Dest.Pawn == none)
	{
		BangModAudit("TELEPORT_FAILED",
			DescribeController(Mover) @ "->" @ DescribeController(Dest) @ "- both must be alive");
		return;
	}

	if (class'BangModAdminActions'.static.Teleport(Mover.Pawn, Dest.Pawn))
		BangModAudit("TELEPORT", DescribeController(Mover) @ "->" @ DescribeController(Dest));
	else
		BangModAudit("TELEPORT_FAILED",
			DescribeController(Mover) @ "->" @ DescribeController(Dest) @ "- no free space there");
}

/** 61: launch a player. No damage -- Kill (25) is there for that. */
function HandleSlap(AOCRConPacket Packet)
{
	local QWord PlayerId;
	local Controller PC;    // Controller-level: a slap only needs a Pawn.
	local int Power;

	PlayerId = Packet.GetGUID();
	Power    = Packet.GetInt();

	PC = GetControllerFromGUID(PlayerId);
	if (PC == none)
		return;

	if (PC.Pawn == none)
	{
		BangModAudit("SLAP_FAILED", DescribeController(PC) @ "- not alive");
		return;
	}

	Power = Clamp(Power, 50, 2000);
	class'BangModAdminActions'.static.Slap(PC.Pawn, Power);
	BangModAudit("SLAP", DescribeController(PC) @ "power" @ Power);
}

/**
 * 51: freeze or release a player, via TB's tutorial input blocking
 * (ScriptToggleInput -> ClientScriptToggleInput, already a reliable client function :7572).
 *
 * NOT anti-cheat. TB's own comment there: "This isn't a safe way of preventing a player
 * from performing some action. It's intended for SP/Tutorials." Enforcement is
 * client-side, so a modified client ignores it. Talk is left unblocked on purpose.
 */
function BangModSetFrozen(AOCPlayerController PC, bool bFrozen)
{
	// bEnable == true means ALLOWED (ClientScriptToggleInput stores the negation), so
	// freezing passes false.
	local bool bAllow;
	bAllow = !bFrozen;

	PC.ScriptToggleInput(EINBLOCK_MoveForward,   bAllow);
	PC.ScriptToggleInput(EINBLOCK_MoveBackward,  bAllow);
	PC.ScriptToggleInput(EINBLOCK_MoveLeft,      bAllow);
	PC.ScriptToggleInput(EINBLOCK_MoveRight,     bAllow);
	PC.ScriptToggleInput(EINBLOCK_Jump,          bAllow);
	PC.ScriptToggleInput(EINBLOCK_Crouch,        bAllow);
	PC.ScriptToggleInput(EINBLOCK_Sprint,        bAllow);
	PC.ScriptToggleInput(EINBLOCK_Dodge,         bAllow);
	PC.ScriptToggleInput(EINBLOCK_AttackSlash,   bAllow);
	PC.ScriptToggleInput(EINBLOCK_AttackStab,    bAllow);
	PC.ScriptToggleInput(EINBLOCK_AttackOverhead,bAllow);
	PC.ScriptToggleInput(EINBLOCK_AttackShove,   bAllow);
	PC.ScriptToggleInput(EINBLOCK_AttackSprint,  bAllow);
	PC.ScriptToggleInput(EINBLOCK_Block,         bAllow);
	PC.ScriptToggleInput(EINBLOCK_Feint,         bAllow);
}

function HandleSetFrozen(AOCRConPacket Packet)
{
	local QWord PlayerId;
	local AOCPlayerController PC;
	local bool bFrozen;

	PlayerId = Packet.GetGUID();
	bFrozen  = (Packet.GetInt() != 0);

	PC = GetPlayerControllerFromGUID(PlayerId);
	if (PC == none)
		return;

	BangModSetFrozen(PC, bFrozen);
	BangModAudit(bFrozen ? "FREEZE" : "UNFREEZE",
		DescribeController(PC) @ "- client-side block, not cheat-proof");
}

/**
 * 52: change class, keeping the team. FamilyInfos as above, indexed by EAOCClass
 * (0 Archer, 1 ManAtArms, 2 Vanguard, 3 Knight, 4 SiegeEngineer).
 *
 * bForceSwitch=true so SetNewClass picks a loadout legal for the new class. Vanilla applies
 * on next spawn; immediate=1 kills the pawn so it lands now -- a flag, not the default,
 * because killing someone mid-fight to change their class is a rude surprise.
 */
function HandleSetClass(AOCRConPacket Packet)
{
	local QWord PlayerId;
	local AOCPlayerController PC;
	local AOCGRI GRI;
	local AOCFamilyInfo NewFamily;
	local int ClassIndex, bImmediate, Index;

	PlayerId   = Packet.GetGUID();
	ClassIndex = Packet.GetInt();
	bImmediate = Packet.GetInt();

	PC = GetPlayerControllerFromGUID(PlayerId);
	GRI = AOCGRI(WorldInfo.GRI);
	if (PC == none || GRI == none)
		return;

	if (PC.CurrentFamilyInfo == none)
	{
		BangModAudit("SET_CLASS_FAILED", DescribeController(PC) @ "- has not picked a class yet");
		return;
	}
	if (ClassIndex < 0 || ClassIndex > 4)
	{
		BangModAudit("SET_CLASS_FAILED", DescribeController(PC) @ "- bad class index" @ ClassIndex);
		return;
	}

	Index = ClassIndex;
	if (PC.CurrentFamilyInfo.FamilyFaction == EFAC_MASON)
		Index += 5;

	NewFamily = GRI.FamilyInfos[Index];
	if (NewFamily == none)
	{
		BangModAudit("SET_CLASS_FAILED", DescribeController(PC) @ "- FamilyInfos[" $ Index $ "] is none");
		return;
	}

	PC.SetNewClass(NewFamily, false, true);

	if (bImmediate != 0 && PC.Pawn != none)
		PC.Pawn.Died(none, class'AOCDmgType_Swing', vect(0, 0, 0));

	BangModAudit("SET_CLASS", DescribeController(PC) @ "->" @ NewFamily
		@ (bImmediate != 0 ? "(respawned now)" : "(applies on next spawn)"));
}

/**
 * 53: list the weapons this class may take, as indices into AOCFamilyInfo.New*Weapons.
 * Opcode 56 sets by the same index, so no class paths on the wire and no strings to trust.
 */
function HandleLoadoutRequest(AOCRConPacket Packet)
{
	local QWord PlayerId;
	local AOCPlayerController PC;
	local AOCRConPacket Reply;
	local AOCFamilyInfo Fam;
	local int i;

	PlayerId = Packet.GetGUID();
	PC = GetPlayerControllerFromGUID(PlayerId);
	if (PC == none || PC.CurrentFamilyInfo == none)
		return;

	Fam = PC.CurrentFamilyInfo;

	for (i = 0; i < Fam.NewPrimaryWeapons.Length; i++)
		SendLoadoutOption(PlayerId, SLOT_PRIMARY, i, Fam.NewPrimaryWeapons[i].CWeapon);
	for (i = 0; i < Fam.NewSecondaryWeapons.Length; i++)
		SendLoadoutOption(PlayerId, SLOT_SECONDARY, i, Fam.NewSecondaryWeapons[i].CWeapon);
	for (i = 0; i < Fam.NewTertiaryWeapons.Length; i++)
		SendLoadoutOption(PlayerId, SLOT_TERTIARY, i, Fam.NewTertiaryWeapons[i].CWeapon);

	Reply = new class'AOCRConPacket';
	Reply.SetMessageType(RCONX_LOADOUT_END);
	Reply.AddQWord(PlayerId);
	Reply.AddInt(Fam.NewPrimaryWeapons.Length);
	Reply.AddInt(Fam.NewSecondaryWeapons.Length);
	Reply.AddInt(Fam.NewTertiaryWeapons.Length);
	SendPacket(Reply);
}

function SendLoadoutOption(QWord PlayerId, int Slot, int Index, class<AOCWeapon> W)
{
	local AOCRConPacket Reply;

	Reply = new class'AOCRConPacket';
	Reply.SetMessageType(RCONX_LOADOUT_OPTION);
	Reply.AddQWord(PlayerId);
	Reply.AddInt(Slot);
	Reply.AddInt(Index);
	Reply.AddString((W != none) ? string(W.Name) : "(none)");
	SendPacket(Reply);
}

/**
 * 56: set loadout by index; -1 leaves a slot alone. Server-side only on purpose -- this is
 * what they spawn with. Their own class menu will not show it until it next refreshes.
 */
function HandleSetLoadout(AOCRConPacket Packet)
{
	local QWord PlayerId;
	local AOCPlayerController PC;
	local AOCFamilyInfo Fam;
	local class<AOCWeapon> Prim, Sec, Tert;
	local int iPrim, iSec, iTert;

	PlayerId = Packet.GetGUID();
	iPrim    = Packet.GetInt();
	iSec     = Packet.GetInt();
	iTert    = Packet.GetInt();

	PC = GetPlayerControllerFromGUID(PlayerId);
	if (PC == none || PC.CurrentFamilyInfo == none)
		return;

	Fam  = PC.CurrentFamilyInfo;
	Prim = PC.PrimaryWeapon;
	Sec  = PC.SecondaryWeapon;
	Tert = PC.TertiaryWeapon;

	if (iPrim >= 0 && iPrim < Fam.NewPrimaryWeapons.Length)
		Prim = Fam.NewPrimaryWeapons[iPrim].CWeapon;
	if (iSec >= 0 && iSec < Fam.NewSecondaryWeapons.Length)
		Sec = Fam.NewSecondaryWeapons[iSec].CWeapon;
	if (iTert >= 0 && iTert < Fam.NewTertiaryWeapons.Length)
		Tert = Fam.NewTertiaryWeapons[iTert].CWeapon;

	// AltPrimaryWeapon is carried through untouched -- it is not part of the choice lists
	// and clobbering it would drop the alternate mode of whatever they are holding.
	PC.SetWeapons(Prim, PC.AltPrimaryWeapon, Sec, Tert);

	BangModAudit("SET_LOADOUT", DescribeController(PC) @ "->" @ Prim @ "/" @ Sec @ "/" @ Tert
		@ "(applies on next spawn)");
}

/**
 * 57: one snapshot of where everyone is.
 *
 * Reads Pawn.Location, not the replicated AOCPRI.PawnLocation -- that only refreshes on a 2s
 * timer (AOCPRI.uc:192) and we already run server-side. PawnLocation is the fallback for a
 * dead pawn. Yaw in degrees so the client need not know UE3 rotator units.
 */
function SendPlayerPositions()
{
	local AOCRConPacket Reply;
	local PlayerReplicationInfo PRI;
	local AOCPRI APRI;
	local Controller C;
	local Vector Loc;
	local int Count, Yaw, bAlive;

	// Bail out through the terminator, never by returning. The client swaps in a frame on
	// PLAYER_POS_END; a bare return leaves it waiting and the map simply never updates,
	// which is indistinguishable from the opcode not being implemented at all.
	if (WorldInfo.GRI == none)
	{
		BangModAudit("PLAYER_POS_FAILED", "no GameReplicationInfo yet");
		Reply = new class'AOCRConPacket';
		Reply.SetMessageType(RCONX_PLAYER_POS_END);
		Reply.AddInt(0);
		SendPacket(Reply);
		return;
	}

	foreach WorldInfo.GRI.PRIArray(PRI)
	{
		if (PRI == none || PRI.bOnlySpectator)
			continue;

		EnsureUniqueId(PRI);

		APRI = AOCPRI(PRI);
		C = Controller(PRI.Owner);

		bAlive = 0;
		Yaw = 0;

		if (C != none && C.Pawn != none)
		{
			Loc = C.Pawn.Location;
			Yaw = (C.Pawn.Rotation.Yaw & 65535) * 360 / 65536;
			bAlive = 1;
		}
		else if (APRI != none)
		{
			Loc = APRI.PawnLocation;   // last known, from the 2s timer
		}
		else
		{
			continue;
		}

		Reply = new class'AOCRConPacket';
		Reply.SetMessageType(RCONX_PLAYER_POS);
		Reply.AddQWord(PRI.UniqueId.Uid);
		Reply.AddString(PRI.PlayerName);
		Reply.AddInt((PRI.Team != none) ? PRI.Team.TeamIndex : -1);
		Reply.AddInt(int(Loc.X));
		Reply.AddInt(int(Loc.Y));
		Reply.AddInt(int(Loc.Z));
		Reply.AddInt(Yaw);
		Reply.AddInt(bAlive);
		Reply.AddInt((APRI != none) ? APRI.CurrentHealth : 0);
		SendPacket(Reply);
		Count++;
	}

	Reply = new class'AOCRConPacket';
	Reply.SetMessageType(RCONX_PLAYER_POS_END);
	Reply.AddInt(Count);
	SendPacket(Reply);
}

/**
 * 49: turn tournament mode on or off, and optionally set the ready threshold.
 *
 * bTournamentMode only gates the pre-round (AOCGame.ShouldStartRound, :3062) and StartRound
 * clears it (:3099), so it is one-shot per round start -- vanilla behaviour, not a bug.
 * The InitGame side effects (:3344) are reapplied here since a mid-match toggle skips
 * InitGame; they are not reverted on disable, because we cannot know the original config.
 */
function HandleSetTournament(AOCRConPacket Packet)
{
	local AOCGame Game;
	local int bEnabled, ThresholdPercent;

	bEnabled         = Packet.GetInt();
	ThresholdPercent = Packet.GetInt();

	Game = AOCGame(WorldInfo.Game);
	if (Game == none || Game.GameReplicationInfo == none)
	{
		BangModAudit("TOURNAMENT_FAILED", (Game == none)
			? "the game is not an AOCGame"
			: "no GameReplicationInfo yet");
		return;
	}

	Game.bTournamentMode = (bEnabled != 0);
	AOCGRI(Game.GameReplicationInfo).bTournamentModeWaiting = Game.bTournamentMode;

	if (ThresholdPercent > 0)
	{
		Game.TournamentTeamReadyThreshold = float(ThresholdPercent) / 100.0f;
		AOCGRI(Game.GameReplicationInfo).fTournamentReadyThreshold = Game.TournamentTeamReadyThreshold;
	}

	if (Game.bTournamentMode)
	{
		Game.bAutoBalance = false;
		Game.bDeathBasedAutoBalance = false;
		AOCGRI(Game.GameReplicationInfo).bBalanceTeams = false;
		Game.bUseMaxPingLimit = false;
		Game.bDisableTeamDamagePenalty = true;
		// Vanilla's InitGame block also grants these (:3351); without bAdminCanPause an
		// in-game admin's console pause is refused by AllowPausing even in tournament mode.
		Game.bAdminCanPause = true;
		Game.bAnyUserCanGetSteamID = true;
	}
	else
	{
		// bTournamentMode is globalconfig (AOCGame.uc:399) and InitGame re-reads it every
		// map (:3337), so clearing only the live value lets it come back. Enable stays
		// runtime-only on purpose; disable is the escape hatch for a stuck server.
		class'AOCGame'.default.bTournamentMode = false;
		class'AOCGame'.static.StaticSaveConfig();
		Game.SaveConfig();
	}

	Game.GameReplicationInfo.bForceNetUpdate = true;

	BangModAudit(Game.bTournamentMode ? "TOURNAMENT_ON" : "TOURNAMENT_OFF",
		"ready threshold" @ int(Game.TournamentTeamReadyThreshold * 100) $ "%"
		@ (Game.bTournamentMode
			? "- applies in the pre-round, clears when the round starts"
			: "- also cleared from the ini so it cannot return on map change"));
}

/**
 * 50: force everyone ready (vanilla AdminReadyAll, :5235), or clear every ready flag.
 * ready=0 has no vanilla equivalent and also drops bAdminForcedTournamentReady, so
 * ShouldStartRound goes back to counting instead of staying latched from last round.
 */
function HandleReadyAll(AOCRConPacket Packet)
{
	local AOCGame Game;
	local AOCPlayerController PC;
	local int bReady, Count;

	bReady = Packet.GetInt();

	Game = AOCGame(WorldInfo.Game);
	if (Game == none)
		return;

	if (bReady != 0)
	{
		Game.AdminReadyAll();

		foreach WorldInfo.AllControllers(class'AOCPlayerController', PC)
		{
			// AdminReadyAll sets the flag but never nudges replication or announces it.
			if (PC.PlayerReplicationInfo != none)
				PC.PlayerReplicationInfo.bForceNetUpdate = true;
			PC.NotifyReady(true);
			Count++;
		}

		Game.BroadcastMessage(none, "An admin marked all players ready.", EFAC_ALL, true, true, "#4CC964");
		BangModAudit("READY_ALL", "forced" @ Count @ "player(s) ready");
		return;
	}

	foreach WorldInfo.AllControllers(class'AOCPlayerController', PC)
	{
		PC.bTournamentReady = false;
		if (AOCPRI(PC.PlayerReplicationInfo) != none)
		{
			AOCPRI(PC.PlayerReplicationInfo).bTournamentReady = false;
			PC.PlayerReplicationInfo.bForceNetUpdate = true;
		}
		PC.NotifyReady(false);
		Count++;
	}
	Game.bAdminForcedTournamentReady = false;

	Game.BroadcastMessage(none, "An admin cleared all ready flags.", EFAC_ALL, true, true, "#D1A04A");
	BangModAudit("UNREADY_ALL", "cleared" @ Count @ "player(s) and the admin ready override");
}

/**
 * 43: pause / unpause. Borrows a controller to own the pause -- an admin if one is
 * connected, otherwise the first.
 *
 * Calls AOCGame.SetPause (:4801), not PlayerController.SetPause: BangMod's override of the
 * latter is admin-gated, and AOCGame's is what sets AOCGRI.Speed and calls NotifyPaused.
 *
 * bPauseable is forced on around the call and restored after. AOCGame inherits
 * bPauseable=False from UTGame.uc:3396, so AllowPausing (:2794) falls through to
 * bAdminCanPause && IsAdmin -- false in the ini, and the borrowed controller is no admin.
 * Without the flip SetPause just returns false.
 *
 * bIsPaused lives on the BangMod PC subclasses and is not set here, so in-game "unpause"
 * (which checks the caller's own flag) cannot clear an RCON pause -- unpause over RCON.
 */
function HandleSetPause(AOCRConPacket Packet)
{
	local bool bPause;
	local AOCPlayerController PC, Chosen;
	local AOCGame Game;

	bPause = (Packet.GetInt() != 0);

	Game = AOCGame(WorldInfo.Game);
	if (Game == none)
		return;

	foreach WorldInfo.AllControllers(class'AOCPlayerController', PC)
	{
		if (Chosen == none)
			Chosen = PC;

		if (PC.PlayerReplicationInfo != none && PC.PlayerReplicationInfo.bAdmin)
		{
			Chosen = PC;
			break;
		}
	}

	if (Chosen == none)
	{
		BangModAudit("SET_PAUSE_FAILED", "nobody connected to own the pause");
		return;
	}

	if (bPause)
	{
		if (WorldInfo.Pauser != none)
			return;

		Chosen.bFire = 0;

		if (!bBangModPauseForced)
		{
			bBangModPauseableWas = Game.bPauseable;
			bBangModPauseForced = true;
		}
		Game.bPauseable = true;

		if (!Game.SetPause(Chosen))
		{
			Game.bPauseable = bBangModPauseableWas;
			bBangModPauseForced = false;
			BangModAudit("SET_PAUSE_FAILED", "the game refused the pause");
			return;
		}
		Chosen.PauseRumbleForAllPlayers();
	}
	else
	{
		// While ClearPause runs: AllowPausing() false takes the wipe-the-list branch, which
		// also unpauses, but keep the flag on so the normal delegate path is used instead.
		Game.ClearPause();
		Chosen.PauseRumbleForAllPlayers(false);

		if (bBangModPauseForced)
		{
			Game.bPauseable = bBangModPauseableWas;
			bBangModPauseForced = false;
		}
	}

	// AOCGame.SetPause already broadcasts its own "paused the game" system message (naming
	// the borrowed controller), but ClearPause announces nothing -- so only unpause needs one.
	if (!bPause)
		Game.BroadcastMessage(none, "An admin unpaused the match.", EFAC_ALL, true, true, "#4CC964");

	BangModAudit("SET_PAUSE", (bPause ? "paused" : "unpaused") @ "via" @ DescribeController(Chosen));
}

/**
 * 44: end the match now, awarding it to a team.
 *
 * EndGame wants a winning PRI rather than a team index, so the team's top scorer
 * stands in for it -- that is what AOCGame.GetHighestScoreFromTeam is for. A team with
 * nobody on it ends the match with no winner rather than failing silently.
 */
function HandleEndMatch(AOCRConPacket Packet)
{
	local int WinningTeam;
	local string Reason;
	local PlayerReplicationInfo WinnerPRI;
	local AOCGame Game;

	WinningTeam = Packet.GetInt();
	Reason      = Packet.GetString();

	Game = AOCGame(WorldInfo.Game);
	if (Game == none)
		return;

	if (WinningTeam >= 0)
		WinnerPRI = Game.GetHighestScoreFromTeam(WinningTeam);

	// EndGame's Reason is a match-end CONDITION string ("TimeLimit", "Triggered"), not
	// anything a player ever sees -- which is why the reason never reached chat. Announce it
	// separately first, while there is still a round to announce it into.
	if (Reason != "")
		Game.BroadcastMessage(none, "Match ended by admin:" @ Reason, EFAC_ALL, true, true, "#D1A04A");

	BangModAudit("END_MATCH", "team" @ WinningTeam @ "|" @ Reason);
	Game.EndGame(WinnerPRI, "Triggered");
}

/** 45: toggle auto team balance. */
function HandleSetAutoBalance(AOCRConPacket Packet)
{
	local bool bEnable;

	bEnable = (Packet.GetInt() != 0);

	if (AOCGRI(WorldInfo.GRI) == none)
		return;

	AOCGRI(WorldInfo.GRI).bBalanceTeams = bEnable;
	BangModAudit("SET_AUTOBALANCE", bEnable ? "on" : "off");
}

/**
 * 46: game speed as an integer percent (no float on the wire); 100 is normal.
 * AOCGame.SetGameSpeed rather than a slomo console command: it calls NotifySpeedChanged and
 * republishes AOCGRI.Speed, which the bare command does not. Clamped 10-400 -- zero stops
 * the match with no way to type the command that would restore it.
 */
function HandleSetGameSpeed(AOCRConPacket Packet)
{
	local int SpeedPercent;
	local float NewSpeed;

	SpeedPercent = Packet.GetInt();
	SpeedPercent = Clamp(SpeedPercent, 10, 400);
	NewSpeed = float(SpeedPercent) / 100.0;

	if (WorldInfo.Game == none)
		return;

	BangModAudit("SET_GAME_SPEED", SpeedPercent $ "%");
	WorldInfo.Game.SetGameSpeed(NewSpeed);
}

/** 47: restart the current match. */
function HandleRestartMatch()
{
	if (WorldInfo.Game == none)
		return;

	// NOT RestartGame(): with bChangeLevels set it calls GetNextMap() and travels there, so
	// it cycles the rotation instead of restarting -- and the map change clears tournament
	// mode on the way. "?restart" is what BangMod's own AdminRestartMap uses.
	BangModAudit("RESTART_MATCH", "reloading the current map");
	WorldInfo.ServerTravel("?restart", false);
}

DefaultProperties
{
	BangModBlockedConsoleCommands(0)="quit"
	BangModBlockedConsoleCommands(1)="exit"
	BangModBlockedConsoleCommands(2)="debug"
}
