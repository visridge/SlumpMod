class XangModLTS extends AOCLTS;

`include(XangMod/Include/XangModLTS.uci)
`include(XangMod/Include/XangModGame.uci)

// ---- Ranked hooks (XangModRanked has the flow; spawned in Game/Match.uci) -----------------

function Logout(Controller Exiting)
{
	// Before super, while the PRI is intact.
	if (Ranked != none)
		Ranked.PlayerLeft(Exiting);

	super.Logout(Exiting);
}

function bool RequestJoinTeam(AOCPlayerController inController, EAOCFaction inTeam, optional bool bForce = false)
{
	if (Ranked != none && !Ranked.MayJoinTeam(inController, inTeam))
	{
		if (!bForce)
			inController.Response_JoinTeam(inTeam, false);
		return false;
	}

	return super.RequestJoinTeam(inController, inTeam, bForce);
}

function RequestJoinClass(AOCPlayerController inController, EAOCFaction inTeam, byte inClass, optional bool bForce = false, optional bool bSetClass = false)
{
	if (Ranked != none && !Ranked.MayJoinTeam(inController, inTeam))
	{
		if (!bForce)
			inController.Response_JoinClass(inClass, false);
		return;
	}

	super.RequestJoinClass(inController, inTeam, inClass, bForce, bSetClass);
}

/** admin RankedMode 1|0 */
exec function RankedMode(bool bEnable)
{
	SetRankedMode(bEnable);
}

/** Saved to UDKGame.ini; restarts the map. Turning off mid-match voids it. */
function SetRankedMode(bool bEnable)
{
	if (Ranked == none || Ranked.bRankedEnabled == bEnable)
		return;

	Ranked.bRankedEnabled = bEnable;
	Ranked.SaveSettings();
	Ranked.Broadcast(bEnable ? "Ranked mode is ON. Restarting the map -- pick a team and class to queue." : "Ranked mode is OFF. Restarting the map.");

	if (Ranked.IsLocked())
		Ranked.CancelMatch();
	else
		WorldInfo.ServerTravel("?restart", false);
}

/** voteranked / voteunranked, riding on the restart-map vote HUD with the text overridden. */
function InitiateVoteRanked(AOCPlayerController VoteInstigator, bool bEnable)
{
	local AOCPlayerController PC;
	local int FailReasonPMCode;

	if (Ranked == none || !Ranked.IsConfigured())
	{
		VoteInstigator.ClientDisplayConsoleMessage("Ranked is not set up on this server.");
		return;
	}

	if (Ranked.bRankedEnabled == bEnable)
	{
		Ranked.TellPlayerPC(VoteInstigator, bEnable ? "Ranked mode is already on." : "Ranked mode is already off.");
		return;
	}

	// A losing side must not be able to vote away its loss.
	if (!bEnable && Ranked.IsLocked())
	{
		Ranked.TellPlayerPC(VoteInstigator, "Ranked can only be voted off between matches. An admin can use adminterminatematch.");
		return;
	}

	if (!IsAllowedToInitiateVote(VoteInstigator, FailReasonPMCode))
	{
		LocalizedPrivateMessage(VoteInstigator, FailReasonPMCode);
		return;
	}

	Ranked.bVoteToEnable = bEnable;
	VoteCategory = EVOTECAT_RestartMap;
	fTimeVoteStarted = WorldInfo.TimeSeconds;
	SetTimer(fVoteDurationSeconds, false, 'EndCustomVote');

	foreach WorldInfo.AllControllers(class'AOCPlayerController', PC)
	{
		PC.BeginVote(EVOTECAT_RestartMap, "", fVoteDurationSeconds);
		if (XangModLTSPlayerController(PC) != none)
			XangModLTSPlayerController(PC).OverrideVoteText(bEnable ? "Enable?" : "Disable?", "Ranked mode");
	}

	AOCGRI(GameReplicationInfo).VotesNo = 0;
	AOCGRI(GameReplicationInfo).VotesYes = 0;

	InitiateNewVote(VoteInstigator);
	VoteInstigator.Vote = EVOTE_Yes;
	SetTimer(0.5f, true, 'CountVotes');

	Ranked.Broadcast(VoteInstigator.PlayerReplicationInfo.PlayerName @ "started a vote to turn ranked mode" @ (bEnable ? "on." : "off."));
}

function EndCustomVote()
{
	local AOCPlayerController PC;
	local bool bSuccess;

	ClearTimer('CountVotes');
	bSuccess = DidVoteSucceed();
	EndVoting();

	foreach WorldInfo.AllControllers(class'AOCPlayerController', PC)
		PC.FinishVote(bSuccess, fVoteEnactDelaySeconds);

	if (bSuccess)
		SetTimer(fVoteEnactDelaySeconds, false, 'EnactRankedVote');
}

function EnactRankedVote()
{
	// A match may have locked in while the vote ran.
	if (!Ranked.bVoteToEnable && Ranked.IsLocked())
	{
		Ranked.Broadcast("A ranked match started during the vote, so ranked stays on. Vote again after it.");
		return;
	}

	SetRankedMode(Ranked.bVoteToEnable);
}

/** AOCGame.CancelVote only knows the vanilla vote timers. */
function CancelVote()
{
	ClearTimer('EndCustomVote');
	super.CancelVote();
}

/** True (and the player told why) while a ranked match is live. */
function bool RankedBlocksMapChange(PlayerController PC)
{
	if (Ranked == none || !Ranked.IsMatchLive())
		return false;

	if (AOCPlayerController(PC) != none)
		Ranked.TellPlayerPC(AOCPlayerController(PC), "Not during a ranked match. The map restarts by itself when it ends (admins: adminterminatematch).");
	return true;
}

function InitiateVoteRestartMap(AOCPlayerController VoteInstigator)
{
	if (!RankedBlocksMapChange(VoteInstigator))
		super.InitiateVoteRestartMap(VoteInstigator);
}

function InitiateVoteChangeMap(AOCPlayerController VoteInstigator, string MapName)
{
	if (!RankedBlocksMapChange(VoteInstigator))
		super.InitiateVoteChangeMap(VoteInstigator, MapName);
}

/** adminstartmatch. Returns why not, or "". */
function string AdminStartRankedMatch()
{
	if (Ranked == none)
		return "Ranked mode is only available on LTS maps.";
	return Ranked.AdminStartMatch();
}

/** adminterminatematch: void the live match, no Elo changes. */
function bool TerminateRankedMatch()
{
	if (Ranked == none || !Ranked.IsLocked())
		return false;

	Ranked.CancelMatch();
	return true;
}

exec function RankedMinTeamSize(int Size)
{
	if (Ranked == none || Size < 1 || Size > 16)
		return;

	Ranked.RankedMinTeamSize = Size;
	Ranked.SaveSettings();
	Ranked.Broadcast("Admin RankedMinTeamSize" @ Size);
}

exec function RankedMaxTeamSize(int Size)
{
	if (Ranked == none || Size < 1 || Size > 16)
		return;

	Ranked.RankedMaxTeamSize = Size;
	Ranked.SaveSettings();
	Ranked.Broadcast("Admin RankedMaxTeamSize" @ Size);
}

/** No argument = another full LeaverPauseSeconds. */
exec function RankedExtend(optional int Seconds)
{
	if (Ranked != none)
		Ranked.ExtendPause(Seconds);
}

/** End a paused match now: leavers lose Elo, the rest is void. */
exec function RankedAbandon()
{
	if (Ranked != none && Ranked.IsPaused())
	{
		Ranked.Broadcast("An admin ended the match.");
		Ranked.AbandonMatch();
	}
}

/** Backend connectivity check; result in Launch.log. */
exec function RankedPing()
{
	if (Ranked != none)
		Ranked.Ping();
}
