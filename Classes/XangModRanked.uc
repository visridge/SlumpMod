/**
 * Ranked LTS and Elo name tags. Server-only; spawned by Game/Match.uci PostBeginPlay on LTS
 * (ranked) and TO (tags only). Ported from MustMod (Love Norstrom), modelled on ImbaMod.
 * Backend: supabase/functions/ranked. Config: server UDKGame.ini [XangMod.XangModRanked] only;
 * the token must never go in DefaultXangMod.ini.
 */
class XangModRanked extends Info
	config(Game);

const CHAT_COLOUR = "#00BFFF";

var config bool bRankedEnabled;
var config string RankedEndpoint;       // https://<project-ref>.supabase.co/functions/v1/ranked
var config string RankedServerToken;
var config int RankedMinTeamSize;       // per side; 0 = 2
var config int RankedMaxTeamSize;       // per side; 0 = 16
var config float QueueCountdown;        // 0 = 30
var config float LeaverPauseSeconds;    // 0 = 120

enum ERankedState
{
	RS_Queue,
	RS_Requesting,
	RS_Locked,
	RS_Paused,
	RS_Closing,
	RS_Finished
};

var ERankedState RankedState;

/** Set by InitRanked on TO: Elo tags only, never queues or matchmakes. */
var bool bTagsOnly;

var float QueueStartTime;
var float NextQueueNotice;
var string MatchId;

/** Locked lineups by SteamID64. Team 1 = Agatha, team 2 = Mason. */
var array<string> Team1Ids;
var array<string> Team2Ids;

var array<string> MissingIds;
var array<string> MissingNames;

/** RealTimeSeconds: WorldInfo.TimeSeconds stops while paused. */
var float PauseDeadline;
var float NextPauseNotice;
var bool bPauseableForced;
var bool bPauseableWas;

/** Untagged names, so "[elo] " is never applied twice. */
var array<string> OriginalNameIds;
var array<string> OriginalNames;

var bool bResultRetried;

/** Stats JSON taken as lineup players disconnect. */
var array<string> SnapshotIds;
var array<string> SnapshotStats;

var bool bVoteToEnable;

/** Holding the reference keeps the request from being garbage collected mid-flight. */
var array<HttpRequestInterface> PendingRequests;
var array<string> PendingActions;

var bool bLoggedNotConfigured;

// ---- Lifecycle -------------------------------------------------------------------------

function InitRanked(bool bTagsOnlyMode)
{
	bTagsOnly = bTagsOnlyMode;

	if (!IsActive())
	{
		RankedState = RS_Finished;
		return;
	}

	RankedState = RS_Queue;
	SetTimer(1.0, true, 'QueueTick');
}

/** Runs while paused (bAlwaysTick); timers do not. */
event Tick(float DeltaTime)
{
	local float Remaining;

	super.Tick(DeltaTime);

	if (RankedState != RS_Paused)
		return;

	Remaining = PauseDeadline - WorldInfo.RealTimeSeconds;
	if (Remaining <= 0)
	{
		Broadcast(JoinNames(MissingNames) @ "did not return in time. The match is abandoned.");
		AbandonMatch();
		return;
	}

	if (WorldInfo.RealTimeSeconds >= NextPauseNotice)
	{
		Broadcast("Waiting for" @ JoinNames(MissingNames) @ "to reconnect:" @ int(Remaining) $ "s left.");
		NextPauseNotice = WorldInfo.RealTimeSeconds + 30.0;
	}
}

/** SaveConfig plus the class defaults, or the next map's actor reverts the change. */
function SaveSettings()
{
	SaveConfig();
	default.bRankedEnabled = bRankedEnabled;
	default.RankedMinTeamSize = RankedMinTeamSize;
	default.RankedMaxTeamSize = RankedMaxTeamSize;
}

function bool IsConfigured()
{
	return RankedEndpoint != "" && RankedServerToken != "";
}

function bool IsActive()
{
	return !bTagsOnly && bRankedEnabled && IsConfigured();
}

function int GetMinTeamSize()
{
	return Clamp(RankedMinTeamSize > 0 ? RankedMinTeamSize : 2, 1, GetMaxTeamSize());
}

function int GetMaxTeamSize()
{
	return Clamp(RankedMaxTeamSize > 0 ? RankedMaxTeamSize : 16, 1, 16);
}

function float GetLeaverPauseSeconds()
{
	return LeaverPauseSeconds > 0 ? LeaverPauseSeconds : 120.0;
}

function float GetQueueCountdown()
{
	return QueueCountdown > 0 ? QueueCountdown : 30.0;
}

/** ShouldCountDown gate: hold the match until teams are locked. */
function bool AllowsCountdown()
{
	return !IsActive() || RankedState == RS_Locked || RankedState == RS_Finished;
}

function bool IsLocked()
{
	return RankedState == RS_Locked || RankedState == RS_Paused;
}

function bool IsPaused()
{
	return RankedState == RS_Paused;
}

/** Matchmaking until the scheduled restart; manual map changes are refused in this window. */
function bool IsMatchLive()
{
	return RankedState == RS_Requesting || IsLocked() || RankedState == RS_Closing;
}

// ---- Queue / matchmaking ---------------------------------------------------------------

function QueueTick()
{
	local array<AOCPlayerController> Queue;
	local float Remaining;
	local int Needed;

	if (RankedState != RS_Queue)
		return;

	BuildQueue(Queue);
	Needed = GetMinTeamSize() * 2;

	if (Queue.Length < Needed)
	{
		if (QueueStartTime > 0)
		{
			QueueStartTime = 0;
			Broadcast("Ranked: not enough players any more, countdown stopped.");
		}
		if (Queue.Length > 0 && WorldInfo.TimeSeconds >= NextQueueNotice)
		{
			Broadcast("Ranked: need at least" @ Needed @ "players, have" @ Queue.Length $ ". Pick a team and class to queue.");
			NextQueueNotice = WorldInfo.TimeSeconds + 20.0;
		}
		return;
	}

	if (QueueStartTime == 0)
	{
		QueueStartTime = WorldInfo.TimeSeconds;
		NextQueueNotice = WorldInfo.TimeSeconds + 10.0;
		Broadcast("Ranked match starts in" @ int(GetQueueCountdown()) $ "s. Pick a team and class to join (" $ Queue.Length @ "queued).");
	}

	Remaining = QueueStartTime + GetQueueCountdown() - WorldInfo.TimeSeconds;
	if (Remaining > 0 && Queue.Length < GetMaxTeamSize() * 2)
	{
		if (WorldInfo.TimeSeconds >= NextQueueNotice)
		{
			Broadcast("Ranked match starts in" @ int(Remaining + 0.5) $ "s (" $ Queue.Length @ "queued).");
			NextQueueNotice = WorldInfo.TimeSeconds + 10.0;
		}
		return;
	}

	SendMatchmake(Queue);
}

/** Queued players, earliest joiner (PRI.StartTime) first. */
function BuildQueue(out array<AOCPlayerController> Queue)
{
	local AOCPlayerController PC;
	local int i;

	foreach WorldInfo.AllControllers(class'AOCPlayerController', PC)
	{
		if (!IsQueued(PC) || SteamIdOf(PC.PlayerReplicationInfo) == "")
			continue;

		for (i = 0; i < Queue.Length; i++)
		{
			if (PC.PlayerReplicationInfo.StartTime < Queue[i].PlayerReplicationInfo.StartTime)
				break;
		}
		Queue.InsertItem(i, PC);
	}
}

/** adminstartmatch. Returns why it cannot, or "". */
function string AdminStartMatch()
{
	local array<AOCPlayerController> Queue;

	if (!IsActive())
		return "Ranked mode is off.";
	if (RankedState != RS_Queue)
		return "A ranked match is already being made or played.";

	BuildQueue(Queue);
	if (Queue.Length < 2 || Queue.Length % 2 != 0)
		return "Need an even number of queued players (have" @ Queue.Length $ ").";

	SendMatchmake(Queue, 1);
	return "";
}

function SendMatchmake(array<AOCPlayerController> Queue, optional int MinTeamSize)
{
	local AOCPlayerController PC;
	local string Players;

	foreach Queue(PC)
	{
		if (Players != "")
			Players $= ",";
		Players $= "{" $ JsonField("steamId", SteamIdOf(PC.PlayerReplicationInfo)) $ "," $ JsonField("name", GetOriginalName(PC)) $ "}";
	}

	if (Send("matchmake", "{" $
		JsonField("map", WorldInfo.GetMapName()) $ "," $
		Quote("minTeamSize") $ ":" $ (MinTeamSize > 0 ? MinTeamSize : GetMinTeamSize()) $ "," $
		Quote("maxTeamSize") $ ":" $ GetMaxTeamSize() $ "," $
		Quote("players") $ ":[" $ Players $ "]}"))
	{
		RankedState = RS_Requesting;
	}
	else
	{
		QueueStartTime = 0;
	}
}

/** Same readiness test as GetActualPlayersCount. */
function bool IsQueued(AOCPlayerController PC)
{
	return PC != none && !PC.IsVoluntarySpectator() && PC.CurrentFamilyInfo != none && PC.bReady
		&& PC.PlayerReplicationInfo != none && !PC.PlayerReplicationInfo.bBot;
}

function HandleMatchmake(JsonObject Data)
{
	local JsonObject Team1, Team2, Player, Excluded;
	local AOCGRI GRI;
	local string Id;

	if (Data == none || !Data.GetBoolValue("ok"))
	{
		RankedState = RS_Queue;
		QueueStartTime = 0;
		if (Data != none && Data.GetStringValue("error") != "")
			Broadcast("Ranked: no match yet (" $ Data.GetStringValue("error") $ "). Trying again shortly.");
		return;
	}

	MatchId = Data.GetStringValue("matchId");
	Team1 = Data.GetObject("team1");
	Team2 = Data.GetObject("team2");
	if (MatchId == "" || Team1 == none || Team2 == none)
	{
		RankedState = RS_Queue;
		LogAlwaysInternal("[XangModRanked] matchmake response was missing matchId or teams");
		return;
	}

	ClearTimer('QueueTick');
	Team1Ids.Length = 0;
	Team2Ids.Length = 0;

	Broadcast("Ranked" @ Data.GetIntValue("teamSize") $ "v" $ Data.GetIntValue("teamSize") @ "match found!");
	Broadcast("Agatha [" $ Data.GetIntValue("team1Avg") $ "]:");
	foreach Team1.ObjectArray(Player)
	{
		Team1Ids.AddItem(Player.GetStringValue("steamId"));
		Broadcast("    [" $ Player.GetIntValue("elo") $ "]" @ Player.GetStringValue("name"));
		ShowElo(Player.GetStringValue("steamId"), Player.GetIntValue("elo"));
	}
	Broadcast("Mason [" $ Data.GetIntValue("team2Avg") $ "]:");
	foreach Team2.ObjectArray(Player)
	{
		Team2Ids.AddItem(Player.GetStringValue("steamId"));
		Broadcast("    [" $ Player.GetIntValue("elo") $ "]" @ Player.GetStringValue("name"));
		ShowElo(Player.GetStringValue("steamId"), Player.GetIntValue("elo"));
	}

	Excluded = Data.GetObject("excluded");
	if (Excluded != none)
	{
		foreach Excluded.ObjectArray(Player)
			TellPlayer(Player.GetStringValue("steamId"), "Ranked: " $ Player.GetStringValue("reason"));
	}

	GRI = AOCGRI(WorldInfo.GRI);
	if (GRI != none)
	{
		GRI.AgathaNameOverride = "Agatha [" $ Data.GetIntValue("team1Avg") $ "]";
		GRI.MasonNameOverride = "Mason [" $ Data.GetIntValue("team2Avg") $ "]";
	}

	RankedState = RS_Locked;
	ForceTeams();

	// Anyone who disconnected while the request was in flight never "left"; catch them here.
	foreach Team1.ObjectArray(Player)
	{
		Id = Player.GetStringValue("steamId");
		if (FindPlayer(Id) == none)
			MarkMissing(Id, Player.GetStringValue("name"));
	}
	foreach Team2.ObjectArray(Player)
	{
		Id = Player.GetStringValue("steamId");
		if (FindPlayer(Id) == none)
			MarkMissing(Id, Player.GetStringValue("name"));
	}
}

/** Locked players to their side, everyone else to spectator. */
function ForceTeams()
{
	local AOCPlayerController PC;
	local int Team;

	foreach WorldInfo.AllControllers(class'AOCPlayerController', PC)
	{
		Team = LockedTeamOf(SteamIdOf(PC.PlayerReplicationInfo));
		if (Team == 0)
		{
			if (!PC.IsVoluntarySpectator())
			{
				PC.JoinSpectatorTeam();
				TellPlayerPC(PC, "Ranked: you are not in this match. You can watch, and you will be queued for the next one.");
			}
			continue;
		}

		MoveToTeam(PC, Team == 1 ? EFAC_AGATHA : EFAC_MASON);
	}
}

/** Same family-swap as XangModRCon.XangModForceTeam. FamilyInfos: 0-4 Agatha, 5-9 Mason. */
function MoveToTeam(AOCPlayerController PC, EAOCFaction Target)
{
	local AOCGRI GRI;
	local AOCFamilyInfo NewFamily;
	local int Index;

	GRI = AOCGRI(WorldInfo.GRI);
	if (GRI == none || PC.CurrentFamilyInfo == none || PC.CurrentFamilyInfo.FamilyFaction == Target)
		return;

	Index = PC.CurrentFamilyInfo.default.ClassReference;
	if (Target == EFAC_MASON)
		Index += 5;
	if (Index < 0 || Index > 9 || GRI.FamilyInfos[Index] == none)
		return;

	NewFamily = GRI.FamilyInfos[Index];
	PC.ClientAutoBalance(NewFamily);
	PC.SetNewClass(NewFamily, false, true);
	AOCPRI(PC.PlayerReplicationInfo).MyFamilyInfo = none;
	PC.ServerChangeTeam(NewFamily.FamilyFaction);
}

/** 1 = Agatha, 2 = Mason, 0 = not in the lineup. */
function int LockedTeamOf(string SteamId)
{
	if (SteamId == "")
		return 0;
	if (Team1Ids.Find(SteamId) != INDEX_NONE)
		return 1;
	if (Team2Ids.Find(SteamId) != INDEX_NONE)
		return 2;
	return 0;
}

/** Team gate for RequestJoinTeam/RequestJoinClass. Spectating is always allowed. */
function bool MayJoinTeam(AOCPlayerController PC, EAOCFaction Team)
{
	local int Locked;

	if (!IsLocked() || (Team != EFAC_AGATHA && Team != EFAC_MASON))
		return true;

	Locked = LockedTeamOf(SteamIdOf(PC.PlayerReplicationInfo));
	return (Locked == 1 && Team == EFAC_AGATHA) || (Locked == 2 && Team == EFAC_MASON);
}

// ---- Joins and leaves ------------------------------------------------------------------

function PlayerJoined(Controller C)
{
	local AOCPlayerController PC;
	local string Id;
	local int i;

	PC = AOCPlayerController(C);
	if (!IsConfigured() || PC == none || PC.PlayerReplicationInfo == none || PC.PlayerReplicationInfo.bBot)
		return;

	Id = SteamIdOf(PC.PlayerReplicationInfo);
	if (Id == "")
		return;

	RememberOriginalName(Id, PC.PlayerReplicationInfo.PlayerName);
	Send("connect", "{" $ JsonField("steamId", Id) $ "," $ JsonField("name", GetOriginalName(PC)) $ "}");

	i = MissingIds.Find(Id);
	if (i == INDEX_NONE)
		return;

	Broadcast(MissingNames[i] @ "is back.");
	MissingIds.Remove(i, 1);
	MissingNames.Remove(i, 1);

	if (MissingIds.Length == 0 && RankedState == RS_Paused)
	{
		RankedState = RS_Locked;
		ResumeGame();
		Broadcast("Everyone is back -- resuming.");
	}
}

/** From XangModLTS.Logout, before the controller goes away. */
function PlayerLeft(Controller C)
{
	local string Id;
	local int i;

	// RS_Closing too: quitting in the 3s before the result goes out keeps their stats.
	if ((!IsLocked() && RankedState != RS_Closing) || C == none || AOCPRI(C.PlayerReplicationInfo) == none)
		return;

	Id = SteamIdOf(C.PlayerReplicationInfo);
	if (LockedTeamOf(Id) == 0)
		return;

	i = SnapshotIds.Find(Id);
	if (i == INDEX_NONE)
	{
		i = SnapshotIds.Length;
		SnapshotIds.AddItem(Id);
		SnapshotStats.AddItem("");
	}
	SnapshotStats[i] = PlayerStatsJson(AOCPRI(C.PlayerReplicationInfo), Id);

	if (IsLocked())
		MarkMissing(Id, GetOriginalNameById(Id, C.PlayerReplicationInfo.PlayerName));
}

function MarkMissing(string Id, string PlayerName)
{
	if (MissingIds.Find(Id) != INDEX_NONE)
		return;

	MissingIds.AddItem(Id);
	MissingNames.AddItem(PlayerName);

	if (RankedState == RS_Paused)
	{
		Broadcast(PlayerName @ "also left.");
		return;
	}

	RankedState = RS_Paused;
	PauseDeadline = WorldInfo.RealTimeSeconds + GetLeaverPauseSeconds();
	NextPauseNotice = WorldInfo.RealTimeSeconds + 30.0;
	PauseGame();
	Broadcast(PlayerName @ "left the ranked match. Paused for up to" @ int(GetLeaverPauseSeconds()) $ "s.");
	Broadcast("Admins: 'admin RankedExtend <seconds>' to wait longer, 'admin RankedAbandon' to end it now (leavers lose Elo).");
}

// ---- Pause -----------------------------------------------------------------------------

/** Same as XangModRCon.HandleSetPause: force bPauseable, a connected controller owns the pause. */
function PauseGame()
{
	local AOCPlayerController PC, PauseOwner;
	local AOCGame Game;

	Game = AOCGame(WorldInfo.Game);
	if (Game == none || WorldInfo.Pauser != none)
		return;

	foreach WorldInfo.AllControllers(class'AOCPlayerController', PC)
	{
		PauseOwner = PC;
		break;
	}
	if (PauseOwner == none)
		return;

	if (!bPauseableForced)
	{
		bPauseableWas = Game.bPauseable;
		bPauseableForced = true;
	}
	Game.bPauseable = true;

	if (!Game.SetPause(PauseOwner))
		RestorePauseable();
}

function ResumeGame()
{
	if (WorldInfo.Game != none && WorldInfo.Pauser != none)
		WorldInfo.Game.ClearPause();

	RestorePauseable();
}

function RestorePauseable()
{
	if (bPauseableForced && WorldInfo.Game != none)
		WorldInfo.Game.bPauseable = bPauseableWas;

	bPauseableForced = false;
}

/** Seconds <= 0 means another full LeaverPauseSeconds. */
function ExtendPause(int Seconds)
{
	if (RankedState != RS_Paused)
		return;

	if (Seconds <= 0)
		Seconds = int(GetLeaverPauseSeconds());

	PauseDeadline += Seconds;
	NextPauseNotice = WorldInfo.RealTimeSeconds;
	Broadcast("An admin extended the wait by" @ Seconds $ "s.");
}

// ---- Ending a match --------------------------------------------------------------------

/** Leavers lose Elo, everyone else void, map restarts. */
function AbandonMatch()
{
	if (!IsLocked())
		return;

	RankedState = RS_Closing;
	ResumeGame();
	Send("abandon", "{" $ JsonField("matchId", MatchId) $ "," $
		Quote("leavers") $ ":" $ JsonStringArray(MissingIds) $ "," $
		Quote("players") $ ":[" $ CollectPlayerStats() $ "]}");

	SetTimer(10.0, false, 'RestartMap');
}

/** Void for everyone, no Elo changes. */
function CancelMatch()
{
	if (!IsLocked())
		return;

	RankedState = RS_Closing;
	ResumeGame();
	Send("cancel", "{" $ JsonField("matchId", MatchId) $ "}");
	Broadcast("The ranked match was terminated. No Elo changes. Restarting the map.");
	SetTimer(5.0, false, 'RestartMap');
}

function RestartMap()
{
	WorldInfo.ServerTravel("?restart", false);
}

/** From Match.uci EndGame. 3s lets the last kill's stats land; 20s is the no-reply fallback. */
function MatchEnded()
{
	if (!IsLocked())
		return;

	RankedState = RS_Closing;
	SetTimer(3.0, false, 'SubmitResult');
	SetTimer(20.0, false, 'RestartMap');
}

function SubmitResult()
{
	local int Winner;
	local EAOCFaction WinningTeam;

	WinningTeam = AOCGame(WorldInfo.Game).GetWinningTeam();
	if (WinningTeam == EFAC_AGATHA)
		Winner = 1;
	else if (WinningTeam == EFAC_MASON)
		Winner = 2;

	// Anyone still missing was unpaused past by an admin; they count as leavers.
	Send("result", "{" $
		JsonField("matchId", MatchId) $ "," $
		Quote("winner") $ ":" $ Winner $ "," $
		Quote("team1Score") $ ":" $ int(AOCGRI(WorldInfo.GRI).GetTeamScore(EFAC_AGATHA)) $ "," $
		Quote("team2Score") $ ":" $ int(AOCGRI(WorldInfo.GRI).GetTeamScore(EFAC_MASON)) $ "," $
		Quote("leavers") $ ":" $ JsonStringArray(MissingIds) $ "," $
		Quote("players") $ ":[" $ CollectPlayerStats() $ "]}");
}

function string PlayerStatsJson(AOCPRI PRI, string Id)
{
	return "{" $ JsonField("steamId", Id) $ "," $
		Quote("score") $ ":" $ int(PRI.Score) $ "," $
		Quote("kills") $ ":" $ PRI.NumKills $ "," $
		Quote("deaths") $ ":" $ PRI.Deaths $ "," $
		Quote("assists") $ ":" $ PRI.NumAssists $ "," $
		Quote("enemyDamage") $ ":" $ PRI.EnemyDamageDealt $ "}";
}

/** Live stats for connected lineup players, disconnect snapshot for the rest. */
function string CollectPlayerStats()
{
	local AOCPlayerController PC;
	local AOCPRI PRI;
	local array<string> Seen;
	local string Result, Id;
	local int i;

	foreach WorldInfo.AllControllers(class'AOCPlayerController', PC)
	{
		PRI = AOCPRI(PC.PlayerReplicationInfo);
		if (PRI == none)
			continue;

		Id = SteamIdOf(PRI);
		if (LockedTeamOf(Id) == 0 || Seen.Find(Id) != INDEX_NONE)
			continue;

		Seen.AddItem(Id);
		Result $= (Result != "" ? "," : "") $ PlayerStatsJson(PRI, Id);
	}

	for (i = 0; i < SnapshotIds.Length; i++)
	{
		if (Seen.Find(SnapshotIds[i]) == INDEX_NONE)
			Result $= (Result != "" ? "," : "") $ SnapshotStats[i];
	}

	return Result;
}

function HandleEloChanges(JsonObject Data)
{
	local JsonObject Changes, Change;
	local int Before, After;

	if (Data == none || !Data.GetBoolValue("ok"))
		return;

	Changes = Data.GetObject("changes");
	if (Changes == none)
		return;

	foreach Changes.ObjectArray(Change)
	{
		Before = Change.GetIntValue("before");
		After = Change.GetIntValue("after");
		if (Before == After)
			continue;

		Broadcast((After > Before ? "+" : "") $ (After - Before) @ Change.GetStringValue("name") @ "(" $ After $ ")");
		ShowElo(Change.GetStringValue("steamId"), After);
	}
}

// ---- Names -----------------------------------------------------------------------------

function RememberOriginalName(string SteamId, string PlayerName)
{
	if (OriginalNameIds.Find(SteamId) != INDEX_NONE)
		return;

	OriginalNameIds.AddItem(SteamId);
	OriginalNames.AddItem(StripEloTag(PlayerName));
}

/** "[2516] Name" -> "Name". Only an all-digit tag, so clan tags survive. */
static function string StripEloTag(string PlayerName)
{
	local int Close, i;
	local string C;

	if (Left(PlayerName, 1) != "[")
		return PlayerName;

	Close = InStr(PlayerName, "] ");
	if (Close < 2)
		return PlayerName;

	for (i = 1; i < Close; i++)
	{
		C = Mid(PlayerName, i, 1);
		if (C < "0" || C > "9")
			return PlayerName;
	}

	return Mid(PlayerName, Close + 2);
}

function string GetOriginalName(AOCPlayerController PC)
{
	return GetOriginalNameById(SteamIdOf(PC.PlayerReplicationInfo), PC.PlayerReplicationInfo.PlayerName);
}

function string GetOriginalNameById(string SteamId, string Fallback)
{
	local int i;

	i = OriginalNameIds.Find(SteamId);
	return i == INDEX_NONE ? StripEloTag(Fallback) : OriginalNames[i];
}

function ShowElo(string SteamId, int Elo)
{
	local AOCPlayerController PC;

	PC = FindPlayer(SteamId);
	if (PC == none)
		return;

	RememberOriginalName(SteamId, PC.PlayerReplicationInfo.PlayerName);
	WorldInfo.Game.ChangeName(PC, "[" $ Elo $ "]" @ GetOriginalName(PC), false);
}

// ---- HTTP ------------------------------------------------------------------------------

/** False if the request never left the server; later failures arrive in RequestComplete. */
function bool Send(string Action, string JsonBody)
{
	local HttpRequestInterface Request;

	if (!IsConfigured())
	{
		if (!bLoggedNotConfigured)
		{
			LogAlwaysInternal("[XangModRanked] not configured -- see [XangMod.XangModRanked] in UDKGame.ini");
			bLoggedNotConfigured = true;
		}
		return false;
	}

	Request = class'HttpFactory'.static.CreateRequest();
	if (Request == none)
	{
		LogAlwaysInternal("[XangModRanked] HttpFactory returned no request object; check HttpRequestClassName in UDKEngine.ini");
		return false;
	}

	Request.SetURL(RankedEndpoint $ "/" $ Action);
	Request.SetVerb("POST");
	Request.SetHeader("Content-Type", "application/json");
	Request.SetHeader("x-server-token", RankedServerToken);
	Request.SetContentAsString(JsonBody);
	Request.SetProcessRequestCompleteDelegate(RequestComplete);

	PendingRequests.AddItem(Request);
	PendingActions.AddItem(Action);

	if (!Request.ProcessRequest())
	{
		LogAlwaysInternal("[XangModRanked]" @ Action @ "could not be started");
		ForgetRequest(Request);
		return false;
	}

	return true;
}

function RequestComplete(HttpRequestInterface Request, HttpResponseInterface Response, bool bDidSucceed)
{
	local string Action, Body;
	local int Code;
	local JsonObject Data;

	Action = ForgetRequest(Request);

	// bDidSucceed is transport only; a 401 or 500 still arrives here as success.
	if (!bDidSucceed || Response == none)
	{
		LogAlwaysInternal("[XangModRanked]" @ Action @ "failed in transport (DNS, connection or TLS)");
	}
	else
	{
		Code = Response.GetResponseCode();
		Body = Response.GetContentAsString();
		LogAlwaysInternal("[XangModRanked]" @ Action @ "->" @ Code @ "|" @ Left(Body, 300));
		if (Code >= 200 && Code < 300)
			Data = class'JsonObject'.static.DecodeJson(Body);
	}

	// if/else, not switch: switch on strings does not work (XANGMOD.md 4.6).
	if (Action ~= "matchmake")
	{
		if (Data == none)
		{
			RankedState = RS_Queue;
			QueueStartTime = 0;
			Broadcast("Ranked: the ranked service did not answer. Trying again shortly.");
		}
		else
			HandleMatchmake(Data);
	}
	else if (Action ~= "connect")
	{
		if (Data != none && Data.GetBoolValue("ok"))
			ShowElo(Data.GetStringValue("steamId"), Data.GetIntValue("elo"));
	}
	else if (Action ~= "result")
	{
		// 409 = already recorded, a retry would be pointless.
		if (Data == none && !bResultRetried && Code != 409)
		{
			bResultRetried = true;
			SetTimer(5.0, false, 'SubmitResult');
			SetTimer(20.0, false, 'RestartMap');
			return;
		}

		if (Data == none && Code != 409)
			Broadcast("Ranked: could not record the match result.");
		else
			HandleEloChanges(Data);

		Broadcast("Restarting the map in 10s.");
		SetTimer(10.0, false, 'RestartMap');
	}
	else if (Action ~= "abandon")
	{
		HandleEloChanges(Data);
	}
}

/** Drop a finished request and return its action. */
function string ForgetRequest(HttpRequestInterface Request)
{
	local int i;
	local string Action;

	i = PendingRequests.Find(Request);
	if (i == INDEX_NONE)
		return "?";

	Action = PendingActions[i];
	PendingRequests.Remove(i, 1);
	PendingActions.Remove(i, 1);
	return Action;
}

/** Proves DNS, TLS, token and function. Result lands in Launch.log. */
function Ping()
{
	Send("ping", "{" $ JsonField("map", WorldInfo.GetMapName()) $ "}");
}

// ---- Helpers ---------------------------------------------------------------------------

function string SteamIdOf(PlayerReplicationInfo PRI)
{
	local OnlineSubsystemSteamworks Steam;

	if (PRI == none || WorldInfo.Game == none)
		return "";

	Steam = OnlineSubsystemSteamworks(WorldInfo.Game.OnlineSub);
	if (Steam == none)
		return "";

	return Steam.UniqueNetIdToInt64(PRI.UniqueId);
}

function AOCPlayerController FindPlayer(string SteamId)
{
	local AOCPlayerController PC;

	foreach WorldInfo.AllControllers(class'AOCPlayerController', PC)
	{
		if (SteamIdOf(PC.PlayerReplicationInfo) == SteamId)
			return PC;
	}
	return none;
}

function Broadcast(string Message)
{
	local AOCPlayerController PC;

	foreach WorldInfo.AllControllers(class'AOCPlayerController', PC)
		PC.ReceiveChatMessage(Message, EFAC_ALL, false, true, CHAT_COLOUR, false);
}

function TellPlayer(string SteamId, string Message)
{
	TellPlayerPC(FindPlayer(SteamId), Message);
}

function TellPlayerPC(AOCPlayerController PC, string Message)
{
	if (PC != none)
		PC.ReceiveChatMessage(Message, EFAC_ALL, false, true, CHAT_COLOUR, false);
}

function string JoinNames(array<string> Names)
{
	local string Result;
	local int i;

	for (i = 0; i < Names.Length; i++)
		Result $= (i > 0 ? ", " : "") $ Names[i];
	return Result;
}

function string Quote(string S)
{
	return Chr(34) $ S $ Chr(34);
}

/** "key":"value" with the value escaped. */
function string JsonField(string Key, string Value)
{
	Value = Repl(Value, "\\", "\\\\");
	Value = Repl(Value, Chr(34), "\\" $ Chr(34));
	return Quote(Key) $ ":" $ Quote(Value);
}

/** SteamIDs only, no escaping needed. */
function string JsonStringArray(array<string> Values)
{
	local string Result;
	local int i;

	for (i = 0; i < Values.Length; i++)
		Result $= (i > 0 ? "," : "") $ Quote(Values[i]);
	return "[" $ Result $ "]";
}

DefaultProperties
{
	bAlwaysTick=true
}
