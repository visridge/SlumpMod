class BangModView_HUD_Scoreboard extends AOCView_HUD_Scoreboard;

event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	local bool bResult;

	bResult = super.WidgetInitialized(WidgetName, WidgetPath, Widget);

	if (WidgetName == 'score_title')
	{
		Widget.SetText("Dmg");
		bResult = true;
	}

	if (WidgetName == 'rank_title')
	{
		Widget.SetText("Ping");
		bResult = true;
	}

	if (WidgetName == 'ping_title')
	{
		Widget.SetText("TDmg");
		bResult = true;
	}

	return bResult;
}

delegate int PRISortDamage(PlayerReplicationInfo A, PlayerReplicationInfo B)
{
	if (AOCPRI(A).EnemyDamageDealt == AOCPRI(B).EnemyDamageDealt)
	{
		return AOCPRI(A).NumKills < AOCPRI(B).NumKills ? -1 : 0;
	}

	return AOCPRI(A).EnemyDamageDealt < AOCPRI(B).EnemyDamageDealt ? -1 : 0;
}

delegate int PRISortELO(PlayerReplicationInfo A, PlayerReplicationInfo B)
{
	local float EloA, EloB;

	EloA = (100.0 * AOCPRI(A).NumKills + 33.0 * AOCPRI(A).NumAssists + 0.2 * AOCPRI(A).EnemyDamageDealt) / FMax(float(AOCPRI(A).Deaths), 1.0);
	EloB = (100.0 * AOCPRI(B).NumKills + 33.0 * AOCPRI(B).NumAssists + 0.2 * AOCPRI(B).EnemyDamageDealt) / FMax(float(AOCPRI(B).Deaths), 1.0);

	if (EloA == EloB)
		return 0;

	return EloA < EloB ? -1 : 1;
}

function GrabCurrentUpdatedValues(optional bool bInitialView = true)
{
	local PlayerReplicationInfo TempPRI;
	local GFxObject TeamDataProviders[2];
	local GFxObject TmpObj;
	local int i;
	local ASValue asval;
	local array<ASValue> args;
	local int NumTeams;
	local int TeamIndexToAddTo;
	local array<TeamInfo> AllTeams;
	local GameReplicationInfo GRI;
	local bool bIsFFAMode;
	local string PlayerCountString;
	local array<GFxObject> Spectators;

	GRI = class'WorldInfo'.static.GetWorldInfo().GRI;

	asval.Type = AS_Null;
    args[0] = asval;

	for(i = 0; i < class'WorldInfo'.static.GetWorldInfo().GRI.Teams.Length; ++i)
	{
		if(class'WorldInfo'.static.GetWorldInfo().GRI.Teams[i] != none)
		{
			++NumTeams;
		}
	}

	if(NumTeams == 0 || GRI == none)
	{
		return;
	}

	bIsFFAMode = AOCFFAGRI(GRI) != none || CDWDuelGRI(GRI) != none || AOCDuelGRI(GRI) != none;

	AOCBaseHUD(Manager.PlayerOwner.myHUD).AllPRI = Manager.PlayerOwner.WorldInfo.GRI.PRIArray;

	if (bInitialView)
		AOCPlayerController(Manager.PlayerOwner).ClientRequestSyncTimer();
	AOCPlayerController(Manager.PlayerOwner).ForceUpdateTimerToHUD();

	for(i = 0; i < ArrayCount(TeamDataProviders); ++i)
	{
		TeamPlayerCounts[i] = 0;
		TeamDataProviders[i] = Outer.CreateArray();
	}

	if(bIsFFAMode)
		AOCBaseHUD(Manager.PlayerOwner.myHUD).AllPRI.Sort(PRISortELO);
	else
		AOCBaseHUD(Manager.PlayerOwner.myHUD).AllPRI.Sort(PRISortELO);

	foreach AOCBaseHUD(Manager.PlayerOwner.myHUD).AllPRI(TempPRI)
	{
		if (!AOCPRI(TempPRI).bDisplayOnScoreboard)
			continue;

		TmpObj = CreateObject("Object");
		TmpObj.SetInt("uniqueidA", TempPRI.UniqueId.Uid.A);
		TmpObj.SetInt("uniqueidB", TempPRI.UniqueId.Uid.B);

		if(AOCGRI(class'Worldinfo'.static.GetWorldInfo().GRI).bTournamentModeWaiting)
		{
			if(AOCPRI(TempPRI).bTournamentReady)
			{
				TmpObj.SetString("this_name", "[ready]"@TempPRI.GetPlayerNameForMarkup());
			}
			else
			{
				TmpObj.SetString("this_name", "[NOT ready]"@TempPRI.GetPlayerNameForMarkup());
			}
		}
		else
		{
			TmpObj.SetString("this_name", TempPRI.GetPlayerNameForMarkup());
		}
		TmpObj.SetInt("classIndex", AOCPRI(TempPRI).GetCurrentClass());
		TmpObj.SetString("score", string(AOCPRI(TempPRI).EnemyDamageDealt));
		TmpObj.SetString("ping", string(AOCPRI(TempPRI).TeamDamageDealt));
		TmpObj.SetBool("dead", AOCPRI(TempPRI).CurrentHealth <= 0);
		TmpObj.SetString("kill", string(AOCPRI(TempPRI).NumKills));
		TmpObj.SetString("death", string(AOCPRI(TempPRI).Deaths));
		TmpObj.SetString("assist", string(AOCPRI(TempPRI).NumAssists));
		TmpObj.SetBool("muted", AOCPlayerController(Manager.PlayerOwner).AllMutePlayerList.Find('Uid', TempPRI.UniqueId.Uid) != INDEX_NONE);

			TmpObj.SetString("rank", string(Round(TempPRI.Ping * 4.f)));
		if(AOCPRI(TempPRI).GetCurrentTeam() == EFAC_NONE)
		{
			TmpObj.SetInt("teamIndex", EFAC_None);
			TmpObj.SetBool("isSpectator", true);
		}
		else
		{
			TmpObj.SetInt("teamIndex", bIsFFAMode ? EFAC_FFA : TempPRI.Team.TeamIndex);
			TmpObj.SetBool("isSpectator", false);
		}

		TmpObj.SetBool("isOwner", TempPRI == Manager.PlayerOwner.PlayerReplicationInfo);
		TmpObj.SetBool("isFriend", AOCPlayerController(Manager.PlayerOwner).SteamFriendPRI.Find(TempPRI) != INDEX_NONE);

		if(AOCPRI(TempPRI).GetCurrentTeam() == EFAC_NONE)
		{
			Spectators.AddItem(TmpObj);
		}
		else
		{
			if(bIsFFAMode)
			{
				TeamIndexToAddTo = TeamPlayerCounts[0] < 17 ? 0 : 1;
			}
			else
			{
				TeamIndexToAddTo = FClamp(TempPRI.Team.TeamIndex, 0, 1);
			}
			TeamDataProviders[TeamIndexToAddTo].SetElementObject(TeamPlayerCounts[TeamIndexToAddTo]++, TmpObj);
		}
	}

	for(i = 0; i < Spectators.Length; ++i)
	{
		TeamIndexToAddTo = TeamPlayerCounts[EFAC_Agatha] < TeamPlayerCounts[EFAC_Mason] ? EFAC_Agatha : EFAC_Mason;
		TeamDataProviders[TeamIndexToAddTo].SetElementObject(TeamPlayerCounts[TeamIndexToAddTo]++, Spectators[i]);
	}

	for(i = 0; i < class'WorldInfo'.static.GetWorldInfo().GRI.Teams.Length; ++i)
	{
		AllTeams.AddItem(class'WorldInfo'.static.GetWorldInfo().GRI.Teams[i]);
	}

	if(bIsFFAMode)
	{
		for(i = 0; i < ArrayCount(TeamNameWidgets); ++i)
		{
			PlayerCountString = AOCGRI(GRI).GetPlayerCountString(EAOCFaction(i));
			PlayerCountWidgets[i].SetString("htmlText", PlayerCountString);

			TeamNameWidgets[i].SetVisible(false);
			TeamProgressBarWidgets[i].SetVisible(false);
			TeamScoreTextfields[i].SetString("text", "");

			TeamPlayerLists[i].SetObject("dataProvider", TeamDataProviders[i]);
			TeamPlayerLists[i].Invoke("invalidateData", args);
		}
	}
	else
	{
		for(i = 0; i < ArrayCount(TeamNameWidgets) && i < AllTeams.Length; ++i)
		{
			PlayerCountString = AOCGRI(GRI).GetPlayerCountString(EAOCFaction(i));
			PlayerCountWidgets[i].SetString("htmlText", PlayerCountString);

			TeamPlayerLists[i].SetObject("dataProvider", TeamDataProviders[i]);
			TeamPlayerLists[i].Invoke("invalidateData", args);

			TeamProgressBarWidgets[i].SetFloat("minimum", 0.0f);
			TeamProgressBarWidgets[i].SetFloat("maximum", 1.0f);
			TeamProgressBarWidgets[i].SetFloat("value", AOCGRI(GRI).GetTeamProgress(EAOCFaction(i)));
			TeamScoreTextfields[i].SetString("text", String(Round(AOCGRI(GRI).GetTeamScore(EAOCFaction(i)))));
		}
	}

	if(bInitialView)
	{
		if (Manager.PlayerOwner.WorldInfo.NetMode != NM_Standalone)
		{
			ServerNameWidget.SetText(Manager.PlayerOwner.WorldInfo.GRI.ServerName);
		}
		else
		{
			ServerNameWidget.SetText("");
		}

		MapNameWidget.SetText(AOCPlayerController(Manager.PlayerOwner).GetFriendlyMapName());
	}

	if(AOCGRI(GRI).AgathaNameOverride != "")
	{
		TeamNameWidgets[EFAC_AGATHA].SetText(AOCGRI(GRI).AgathaNameOverride);
	}

	if(AOCGRI(GRI).MasonNameOverride != "")
	{
		TeamNameWidgets[EFAC_MASON].SetText(AOCGRI(GRI).MasonNameOverride);
	}

	if(!bIsPostGame)
	{
		UpdateObjectives(bInitialView);
	}
}