class BangModView_Frontend_Customization extends AOCView_Frontend_Customization
config(BangModCustomization);

function OnEscapeKeyPress()
{
		SaveAndExit();
}

function PopulateCustomizationInfoArrays()
{
	//local bool temp;
	local PlayerReplicationInfo repInfo;
	//
	local int i;

	repInfo = class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().PlayerReplicationInfo;
	LogAlwaysInternal("PopulateCustomizationInfoArrays"@repInfo.UniqueId.Uid.A@repInfo.UniqueId.Uid.B);
	//temp = class'BangModCustomization'.static.CheckMicroTxOwnership(1, repInfo);
	//class'WorldInfo'.static.GetWorldInfo().Spawn.
	for(i = 0; i < 4; ++i)
	{
		TeamCustomizationChoices[EFAC_Agatha].ClassCustomizationChoices[i] = class'BangModCustomization'.static.LocalGetCustomizationChoices(EFAC_Agatha, i);
		TeamCustomizationChoices[EFAC_Mason].ClassCustomizationChoices[i] = class'BangModCustomization'.static.LocalGetCustomizationChoices(EFAC_Mason, i);
		TeamCustomizationChoices[EFAC_FFA].ClassCustomizationChoices[i] = class'BangModCustomization'.static.LocalGetCustomizationChoices(EFAC_FFA, i);
	}

	for(i = 0; i < 4; ++i)
	{
		class'BangModCustomization'.static.LocalGetSelectedWeaponDrops(EFAC_MASON, i, TeamWeaponChoices[EFAC_MASON].Classes[i].Weapons, AOCPRI(repInfo));
		class'BangModCustomization'.static.LocalGetSelectedWeaponDrops(EFAC_AGATHA, i, TeamWeaponChoices[EFAC_AGATHA].Classes[i].Weapons, AOCPRI(repInfo));
		class'BangModCustomization'.static.LocalGetSelectedWeaponDrops(EFAC_FFA, i, TeamWeaponChoices[EFAC_FFA].Classes[i].Weapons, AOCPRI(repInfo));
	}

	FactionSupportFavIconId = class'BangModCustomization'.static.LocalGetFactionSupporterId();
}

function SaveChoices()
{
	local int i;
	local AOCPlayerController PC;
	local SCustomizationChoice Choices;
	for(i = 0; i < 4; ++i)
	{
		class'BangModCustomization'.static.LocalSetCustomizationChoices(TeamCustomizationChoices[EFAC_Agatha].ClassCustomizationChoices[i], EFAC_Agatha, i, TeamWeaponChoices[EFAC_AGATHA].Classes[i].Weapons, FactionSupportFavIconId);
		class'BangModCustomization'.static.LocalSetCustomizationChoices(TeamCustomizationChoices[EFAC_Mason].ClassCustomizationChoices[i], EFAC_Mason, i, TeamWeaponChoices[EFAC_Mason].Classes[i].Weapons, FactionSupportFavIconId);
		class'BangModCustomization'.static.LocalSetCustomizationChoices(TeamCustomizationChoices[EFAC_FFA].ClassCustomizationChoices[i], EFAC_FFA, i, TeamWeaponChoices[EFAC_FFA].Classes[i].Weapons, FactionSupportFavIconId);
	}

	AOCPlayerController(class'Worldinfo'.static.GetWorldInfo().GetALocalPlayerController()).ClientUpdateCurrentCustomizationInfo();

	// Also force a direct server update so the PRI is updated immediately
	// and respawn applies the new customization without requiring reconnect.
	PC = AOCPlayerController(class'Worldinfo'.static.GetWorldInfo().GetALocalPlayerController());
	if(PC != none && PC.CurrentFamilyInfo != none)
	{
		Choices = class'BangModCustomization'.static.LocalGetCustomizationChoices(PC.CurrentFamilyInfo.FamilyFaction, PC.CurrentFamilyInfo.ClassReference,
			PC.PrimaryWeapon.default.CurrentWeaponType, PC.SecondaryWeapon.default.CurrentWeaponType, PC.TertiaryWeapon.default.CurrentWeaponType);
		PC.ServerUpdateCurrentCustomizationInfo(Choices, PC.CurrentFamilyInfo.FamilyFaction, PC.CurrentFamilyInfo.ClassReference);
	}
}


function OnFadeOutDone()
{
	local Rotator rot;
	local AOCPlayerController PC;
	local SCustomizationChoice Choices;

	PreviewController.UnPossess();
	PreviewController.Pawn = none;
	PreviewPawn.Controller = none;

	PreviewPawn.Destroy();
	
	if(PreviewController == none)
	{
		PreviewController = class'WorldInfo'.static.GetWorldInfo().Spawn(class'AOCAIController_NPC_Preview',,,PawnLocation);
	}

	PreviewPawn = class'WorldInfo'.static.GetWorldInfo().Spawn(class'BangModPreviewPawn',,,PawnLocation);
	PreviewPawn.bCollideWorld = false;
	PreviewPawn.SetLocation(PawnLocation);
	//class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().ClientAddTextureStreamingLoc(PreviewPawn.Location,100, false);
	PreviewPawn.SetPhysics(PHYS_None);	

	rot.Yaw = 32767;
	CaptureActor.SetRotation(rot);
	CaptureActor.FocusActor = PreviewPawn;

	PreviewController.myPawnClass = GetFamilyFromTeamAndClass(SelectedTeam, SelectedClass);

	switch(SelectedClass)
	{
	case(ECLASS_Archer):
		PreviewController.myPrimaryWeapon = class'AOCWeapon_JavelinMelee';
		PreviewController.myTertiaryWeapon = SelectedTeam == EFAC_Agatha ? class'AOCWeapon_Buckler_Agatha' : class'AOCWeapon_Buckler_Mason';
		break;
	case(ECLASS_ManAtArms):
		PreviewController.myPrimaryWeapon = class'AOCWeapon_MorningStar';
		PreviewController.myTertiaryWeapon = SelectedTeam == EFAC_Agatha ? class'AOCWeapon_Heater_Agatha' : class'AOCWeapon_Heater_Mason';
		break;
	case(ECLASS_Vanguard):
		PreviewController.myPrimaryWeapon = class'AOCWeapon_Halberd';
		PreviewController.myTertiaryWeapon = none;
		break;
	case(ECLASS_Knight):
		PreviewController.myPrimaryWeapon = class'AOCWeapon_Longsword1H';
		PreviewController.myTertiaryWeapon = SelectedTeam == EFAC_Agatha ? class'AOCWeapon_Kite_Agatha' : class'AOCWeapon_Kite_Mason';
		break;
	default:
		break;
	}

	ItemLoader.SetString("source", "img://"$PreviewController.myPrimaryWeapon.default.WeaponLargePortrait);

	if(SelectedTeam == EFAC_FFA)
	{
		if(PreviewController.FFAFamilies[SelectedClass] == none)
		{
			switch(SelectedClass)
			{
			case(ECLASS_Archer):
				PreviewController.FFAFamilies[SelectedClass] = class'Worldinfo'.static.GetWorldInfo().Spawn(class'AOCFamilyInfo_FFA_Mason_Archer');
				break;
			case(ECLASS_ManAtArms):
				PreviewController.FFAFamilies[SelectedClass] = class'Worldinfo'.static.GetWorldInfo().Spawn(class'AOCFamilyInfo_FFA_Mason_ManAtArms');
				break;
			case(ECLASS_Vanguard):
				PreviewController.FFAFamilies[SelectedClass] = class'Worldinfo'.static.GetWorldInfo().Spawn(class'AOCFamilyInfo_FFA_Mason_Vanguard');
				break;
			case(ECLASS_Knight):
				PreviewController.FFAFamilies[SelectedClass] = class'Worldinfo'.static.GetWorldInfo().Spawn(class'AOCFamilyInfo_FFA_Mason_Knight');
				break;
			default:
				break;
			}
		}

		PreviewController.myPawnClass = PreviewController.FFAFamilies[SelectedClass];
	}

	PreviewController.myCustomization = TeamCustomizationChoices[SelectedTeam].ClassCustomizationChoices[SelectedClass];

	if(SelectedWeapon != EWEP_MAX)
	{
		if(IsAShieldWeapon(SelectedWeapon))
		{
			PreviewController.myPrimaryWeapon = WeaponClasses[EWEP_Javelin];
			PreviewController.myTertiaryWeapon = WeaponClasses[SelectedWeapon];
			PreviewController.myCustomization.TertiaryWeaponDrop = TeamWeaponChoices[SelectedTeam].Classes[SelectedClass].Weapons[SelectedWeapon];
		}
		else
		{
			PreviewController.myPrimaryWeapon = WeaponClasses[SelectedWeapon];
			PreviewController.myCustomization.PrimaryWeaponDrop = TeamWeaponChoices[SelectedTeam].Classes[SelectedClass].Weapons[SelectedWeapon];
		}
	}

	

    // Existing client->server update (keeps original behavior)
    AOCPlayerController(class'Worldinfo'.static.GetWorldInfo().GetALocalPlayerController()).ClientUpdateCurrentCustomizationInfo();

    // Also call the server RPC directly to reduce race where the server hasn't applied
    // the new customization before an immediate respawn. This forces the server to
    // copy the saved customization into the PlayerReplicationInfo right away.
	PC = AOCPlayerController(class'Worldinfo'.static.GetWorldInfo().GetALocalPlayerController());
    if(PC != none)
    {
		Choices = class'BangModCustomization'.static.LocalGetCustomizationChoices(PC.CurrentFamilyInfo.FamilyFaction, PC.CurrentFamilyInfo.ClassReference,
			PC.PrimaryWeapon.default.CurrentWeaponType, PC.SecondaryWeapon.default.CurrentWeaponType, PC.TertiaryWeapon.default.CurrentWeaponType);
        PC.ServerUpdateCurrentCustomizationInfo(Choices, PC.CurrentFamilyInfo.FamilyFaction, PC.CurrentFamilyInfo.ClassReference);
    }
	PreviewController.Possess(PreviewPawn, false);
	PreviewPawn.SpawnCustomizationWeapons();
	PreviewPawn.ReplicatedEvent('PawnInfo');

	if(SelectedWeapon == EWEP_Buckler ||
		SelectedWeapon == EWEP_Tower || 
		SelectedWeapon == EWEP_Heater || 
		SelectedWeapon == EWEP_Kite)
	{
		PreviewPawn.EquipShield(true, true);
	}

	//AOCGame(class'WorldInfo'.static.GetWorldInfo().Game).AddDefaultInventory(PreviewPawn);

	CaptureActor.UICharTimerTrigger = OnTimerTriggerToStartFadeIn;
	CaptureActor.StartUICharTimer(0.01f);
	PreviewPawn.PrestreamTextures(10000000, true);
}


function GFxObject PopulatePatternList(int CharID, out float selectedIndex)
{
	local GFxObject ListDataProvider;
	local GFxObject IndvElement;
	local array<int> IDs;
	local int i, GearID;
	local bool bIsOwned;

	local byte bPromptToBuy;
	local string Price,PurchaseName, DiscountPercent;
	local int MicroTxID;

	if(RightTabMode == RTAB_Pattern)
	{
		ListDataProvider = Outer.CreateArray();

		IDs = class'BangModCustomization'.static.GetAllTabardsFor(CharID);
		i = 0;
		foreach IDs(GearID)
		{
			MicroTxID = 0;
			bPromptToBuy = 0;
			PurchaseName = "";
			Price = "";

			bIsOwned = class'BangModCustomization'.static.IsTabardOwnedBy(GearID, CharID, class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().PlayerReplicationInfo, SelectedClass);
			if(bIsOwned || class'BangModCustomization'.static.IsTabardVisibleIfUnowned(GearID, CharID))
			{
				IndvElement = CreateObject("Object");
				IndvElement.SetInt("tabardID", GearID);
				IndvElement.SetBool("isLocked", !bIsOwned);
				class'BangModCustomization'.static.GetTabardStoreDescription(GearID, CharID, bPromptToBuy, Price, MicroTxID, PurchaseName);
				IndvElement.SetBool("isPurchasable", Bool(bPromptToBuy) && !bIsOwned);
				IndvElement.SetString("price", Price);
				IndvElement.SetInt("microTxnId", MicroTxID);

				DiscountPercent = "";
				if(class'BangModCustomization'.static.IsMicroTxnItemOnSale(MicroTxID, Price, DiscountPercent))
				{
					IndvElement.SetBool("isItemOnSale", true);
					IndvElement.SetBool("isNewItem", false);
					AddItemToNotificationArray(MicroTxID);
					DiscountPercent = GetPriceColorFormatting(GetPriceColorFormatting(DiscountPercent$"%"));
				}
				else
				{
					IndvElement.SetBool("isItemOnSale", false);
					if(class'BangModCustomization'.static.IsMicroTxnItemNew(MicroTxID))
					{
						IndvElement.SetBool("isNewItem", true);
						AddItemToNotificationArray(MicroTxID);
					}
					else
						IndvElement.SetBool("isNewItem", false);
				}
				
				IndvElement.SetString("itemName", DiscountPercent@class'BangModCustomization'.static.GetTabardName(GearID, CharID));
				ListDataProvider.SetElementObject(i, IndvElement);

				if(GearID == TeamCustomizationChoices[SelectedTeam].ClassCustomizationChoices[SelectedClass].Tabard)
				{
					ShowBuyButton(Bool(bPromptToBuy) && !bIsOwned, Price);
					selectedIndex = i;
					SetItemNameLabel(class'BangModCustomization'.static.GetTabardName(GearID, CharID));
				}

				++i;
			}
		}
	}

	return ListDataProvider;
}

function GFxObject PopulateShieldList(int CharID, out float selectedIndex)
{
	local GFxObject ListDataProvider;
	local GFxObject IndvElement;
	local array<int> IDs;
	local int i, GearID;
	local bool bIsOwned;

	local byte bPromptToBuy;
	local string Price,PurchaseName, DiscountPercent;
	local int MicroTxID;

	local string SkeletalMeshPath, StaticMeshPath, MaterialPath;
	local SWeaponParameterSet WeaponParameterSets[3];
	local byte bUseDefaultParameters;
	local byte AllowedTeams[EAOCFaction];
	local array<String> ShieldPatternNames, ShieldPatternPaths;

	if(RightTabMode == RTAB_Shield)
	{
		ListDataProvider = Outer.CreateArray();

		if(IsAShieldWeapon(SelectedWeapon) && TeamWeaponChoices[SelectedTeam].Classes[SelectedClass].Weapons[SelectedWeapon] != 0)
		{
			class'BangModCustomization'.static.GetShieldDisplayInfo(TeamWeaponChoices[SelectedTeam].Classes[SelectedClass].Weapons[SelectedWeapon], class<AOCWeapon_Shield>(WeaponClasses[SelectedWeapon]).default.Shield, AllowedTeams, SkeletalMeshPath, StaticMeshPath, MaterialPath, bUseDefaultParameters, WeaponParameterSets, ShieldPatternNames, ShieldPatternPaths);

			for(i = 0; i < ShieldPatternPaths.Length; ++i)
			{
				IndvElement = CreateObject("Object");
				IndvElement.SetInt("shieldID", i);
				IndvElement.SetBool("isLocked", false);
				IndvElement.SetString("itemName", Localize("Items", ShieldPatternNames[i], "AOCCustomization"));
				ListDataProvider.SetElementObject(i, IndvElement);
			}

			selectedIndex = TeamCustomizationChoices[SelectedTeam].ClassCustomizationChoices[SelectedClass].Shield;
			SetItemNameLabel(ShieldPatternNames[selectedIndex]);
		}
		else
		{
			IDs = class'BangModCustomization'.static.GetAllShieldPatternsFor(CharID);
			i = 0;
			foreach IDs(GearID)
			{
				MicroTxID = 0;
				bPromptToBuy = 0;
				PurchaseName = "";
				Price = "";

				bIsOwned = class'BangModCustomization'.static.IsShieldPatternOwnedBy(GearID, CharID, class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().PlayerReplicationInfo, SelectedClass);
				if(bIsOwned || class'BangModCustomization'.static.IsShieldPatternVisibleIfUnowned(GearID, CharID))
				{
					IndvElement = CreateObject("Object");
					IndvElement.SetInt("shieldID", GearID);
					IndvElement.SetBool("isLocked", !bIsOwned);
					class'BangModCustomization'.static.GetShieldStoreDescription(GearID, CharID, bPromptToBuy, Price, MicroTxID, PurchaseName);

					DiscountPercent = "";
					if(class'BangModCustomization'.static.IsMicroTxnItemOnSale(MicroTxID, Price, DiscountPercent))
					{
						IndvElement.SetBool("isItemOnSale", true);
						IndvElement.SetBool("isNewItem", false);
						AddItemToNotificationArray(MicroTxID);
						DiscountPercent = GetPriceColorFormatting(DiscountPercent$"%");
					}
					else
					{
						IndvElement.SetBool("isItemOnSale", false);
						if(class'BangModCustomization'.static.IsMicroTxnItemNew(MicroTxID))
							{
								IndvElement.SetBool("isNewItem", true);
								AddItemToNotificationArray(MicroTxID);
							}
							else
								IndvElement.SetBool("isNewItem", false);
					}

					IndvElement.SetBool("isPurchasable", Bool(bPromptToBuy) && !bIsOwned);
					IndvElement.SetString("price", Price);
					IndvElement.SetString("itemName", DiscountPercent@class'BangModCustomization'.static.GetShieldPatternName(GearID, CharID));
					IndvElement.SetInt("microTxnId", MicroTxID);
					ListDataProvider.SetElementObject(i, IndvElement);

					if(GearID == TeamCustomizationChoices[SelectedTeam].ClassCustomizationChoices[SelectedClass].Shield)
					{
						ShowBuyButton(Bool(bPromptToBuy) && !bIsOwned, Price);
						selectedIndex = i;
						SetItemNameLabel(class'BangModCustomization'.static.GetShieldPatternName(GearID, CharID));
					}

					++i;
				}
			}
		}
	}

	return ListDataProvider;
}

function GFxObject PopulateEmblemList(out float selectedIndex)
{
	local GFxObject ListDataProvider;
	local GFxObject IndvElement;
	local array<int> IDs;
	local int i, GearID;
	local bool bIsOwned, bIsMicoTxnVisible;

	local byte bPromptToBuy;
	local string Price,PurchaseName, DiscountPercent;
	local int MicroTxID;

	if(RightTabMode == RTAB_Emblem)
	{
		ListDataProvider = Outer.CreateArray();

		IDs = class'BangModCustomization'.static.GetAllEmblemsFor(SelectedTeam);
		i = 0;
		foreach IDs(GearID)
		{
			MicroTxID = 0;
			bPromptToBuy = 0;
			PurchaseName = "";
			Price = "";
			bIsMicoTxnVisible = class'BangModCustomization'.static.IsMicroTxnEmblemVisible(GearID, SelectedTeam, class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().PlayerReplicationInfo);

			if(bIsMicoTxnVisible)
			{
				bIsOwned = class'BangModCustomization'.static.IsEmblemOwnedBy(GearID, SelectedTeam, class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().PlayerReplicationInfo, SelectedClass);
				if(bIsOwned || class'BangModCustomization'.static.IsEmblemVisibleIfUnowned(GearID, SelectedTeam))
				{
					IndvElement = CreateObject("Object");
					IndvElement.SetInt("emblemID", GearID);
					IndvElement.SetBool("isLocked", !bIsOwned);
					class'BangModCustomization'.static.GetEmblemStoreDescription(GearID, SelectedTeam, bPromptToBuy, Price, MicroTxID, PurchaseName);

					DiscountPercent = "";
					if(class'BangModCustomization'.static.IsMicroTxnItemOnSale(MicroTxID, Price, DiscountPercent))
					{
						IndvElement.SetBool("isItemOnSale", true);
						IndvElement.SetBool("isNewItem", false);
						AddItemToNotificationArray(MicroTxID);
						DiscountPercent = GetPriceColorFormatting(DiscountPercent$"%");
					}
					else
					{
						IndvElement.SetBool("isItemOnSale", false);
						if(class'BangModCustomization'.static.IsMicroTxnItemNew(MicroTxID))
						{
							IndvElement.SetBool("isNewItem", true);
							AddItemToNotificationArray(MicroTxID);
						}
						else
							IndvElement.SetBool("isNewItem", false);
					}

					IndvElement.SetBool("isPurchasable", Bool(bPromptToBuy) && !bIsOwned);
					IndvElement.SetInt("microTxnId", MicroTxID);
					IndvElement.SetString("itemName", DiscountPercent@class'BangModCustomization'.static.GetEmblemName(GearID, SelectedTeam));
					ListDataProvider.SetElementObject(i, IndvElement);

					IndvElement.SetString("price", Price);

					if(GearID == TeamCustomizationChoices[SelectedTeam].ClassCustomizationChoices[SelectedClass].Emblem)
					{
						ShowBuyButton(Bool(bPromptToBuy) && !bIsOwned, Price);
						selectedIndex = i;
						SetItemNameLabel(class'BangModCustomization'.static.GetEmblemName(GearID, SelectedTeam));
					}

					++i;
				}
			}
		}
	}

	return ListDataProvider;
}

function GFXObject PopulateWeaponList(int CharID, out float selectedIndex)
{
	local SWeaponChoiceInfo WeaponChoiceInfo;
	local class<AOCWeapon> WeaponClass;
	local array<class<AOCWeapon> > ClassWeapons;
	local SItem WeaponItem;
	local string Price, DiscountPercent;
	local bool IsNew, IsOnSale;

	local GFxObject ListDataProvider;
	local GFxObject IndvElement;
	local int i;

	if(RightTabMode == RTAB_Weapon)
	{
		ListDataProvider = Outer.CreateArray();

		foreach GetFamilyFromTeamAndClass(SelectedTeam, SelectedClass).NewPrimaryWeapons(WeaponChoiceInfo)
		{
			ClassWeapons.AddItem(WeaponChoiceInfo.CWeapon);
		}
		foreach GetFamilyFromTeamAndClass(SelectedTeam, SelectedClass).NewSecondaryWeapons(WeaponChoiceInfo)
		{
			ClassWeapons.AddItem(WeaponChoiceInfo.CWeapon);
		}
		foreach GetFamilyFromTeamAndClass(SelectedTeam, SelectedClass).NewTertiaryWeapons(WeaponChoiceInfo)
		{
			ClassWeapons.AddItem(WeaponChoiceInfo.CWeapon);
		}

		i = 0;
		foreach ClassWeapons(WeaponClass)
		{
			IsOnSale = false;
			IsNew = false;
			if(AllOwnedOrPurchasableWeaponDrops[WeaponClass.default.CurrentWeaponType].Items.Length > 0)
			{
				IndvElement = CreateObject("Object");
				IndvElement.SetBool("isLocked", false);
				IndvElement.SetInt("weaponType", WeaponClass.default.CurrentWeaponType);
				//class'BangModCustomization'.static.GetWeaponSkinStoreDescription(GearID, CharacterID, bPromptToBuy, Price, MicroTxID, PurchaseName);
				IndvElement.SetBool("isPurchasable", false);
				IndvElement.SetString("itemName", WeaponClass.default.WeaponName);
				ListDataProvider.SetElementObject(i, IndvElement);

				foreach AllOwnedOrPurchasableWeaponDrops[WeaponClass.default.CurrentWeaponType].Items(WeaponItem)
				{
					if(class'BangModCustomization'.static.IsMicroTxnItemOnSale(WeaponItem.GearData.MicroTxID, Price, DiscountPercent))
					{
						IsOnSale = true;
					}
					else if(class'BangModCustomization'.static.IsMicroTxnItemNew(WeaponItem.GearData.MicroTxID))
					{
						IsNew = true;
					}

					if(WeaponItem.GearData.MicroTxID > 0 && (IsOnSale || IsNew))
						AddItemToNotificationArray(WeaponItem.GearData.MicroTxID);
				}

				IndvElement.SetBool("isNewItem", IsNew);
				IndvElement.SetBool("isItemOnSale", IsOnSale);

				if(SelectedWeapon == EWEP_MAX && i == 0)
				{
					ItemList.SetFloat("selectedIndex", i);
					SelectedWeapon = WeaponClass.default.CurrentWeaponType;
				}

				if(SelectedWeapon == WeaponClass.default.CurrentWeaponType)
				{
					ItemList.SetFloat("selectedIndex", i);
				}

				++i;
			}
		}
	}

	return ListDataProvider;
}

function GFxObject PopulateHelmetList(int CharID, out float selectedIndex)
{
	local GFxObject ListDataProvider;
	local GFxObject IndvElement;
	local array<int> IDs;
	local int i, GearID;
	local bool bIsOwned;

	local byte bPromptToBuy;
	local string Price,PurchaseName, DiscountPercent;
	local int MicroTxID;

	LogAlwaysInternal("BangMod PopulateHelmetList CharID="@CharID@" team="@SelectedTeam@" class="@SelectedClass);
	AOCPlayerController(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController()).ClientDisplayConsoleMessage("BangMod PopulateHelmetList team=" $ SelectedTeam $ " class=" $ SelectedClass);

	if(RightTabMode == RTAB_Helmet)
	{
		ListDataProvider = Outer.CreateArray();

		IDs = class'BangModCustomization'.static.GetAllHelmetsFor(CharID);
        LogAlwaysInternal("BangMod GetAllHelmetsFor count="@IDs.Length);
		AOCPlayerController(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController()).ClientDisplayConsoleMessage("BangMod HelmetList count=" $ IDs.Length);
		i = 0;
		foreach IDs(GearID)
		{
            LogAlwaysInternal("BangMod Helmet ID="@GearID);
			AOCPlayerController(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController()).ClientDisplayConsoleMessage("BangMod Helmet ID=" $ GearID);
			// Treat all helmets as visible and owned in UI
			bIsOwned = true;
			IndvElement = CreateObject("Object");
			IndvElement.SetInt("helmetID", GearID);
			IndvElement.SetBool("isLocked", false);
			IndvElement.SetBool("isItemOnSale", false);
			IndvElement.SetBool("isNewItem", false);
			IndvElement.SetBool("isPurchasable", false);
			IndvElement.SetInt("microTxnId", 0);
			IndvElement.SetString("itemName", class'BangModCustomization'.static.GetHelmetName(GearID,TeamCustomizationChoices[SelectedTeam].ClassCustomizationChoices[SelectedClass].Character));
            LogAlwaysInternal("BangMod Helmet Name="@class'BangModCustomization'.static.GetHelmetName(GearID,TeamCustomizationChoices[SelectedTeam].ClassCustomizationChoices[SelectedClass].Character));
			AOCPlayerController(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController()).ClientDisplayConsoleMessage("BangMod Helmet Name=" $ class'BangModCustomization'.static.GetHelmetName(GearID,TeamCustomizationChoices[SelectedTeam].ClassCustomizationChoices[SelectedClass].Character));
			IndvElement.SetString("price", "");
			ListDataProvider.SetElementObject(i, IndvElement);

			if(GearID == TeamCustomizationChoices[SelectedTeam].ClassCustomizationChoices[SelectedClass].Helmet)
			{
                LogAlwaysInternal("BangMod Helmet Selected match id="@GearID);
				AOCPlayerController(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController()).ClientDisplayConsoleMessage("BangMod Helmet Selected=" $ GearID);
				ShowBuyButton(false, "");
				selectedIndex = i;
				SetItemNameLabel(class'BangModCustomization'.static.GetHelmetName(GearID,TeamCustomizationChoices[SelectedTeam].ClassCustomizationChoices[SelectedClass].Character));
			}

			++i;
		}
	}

	return ListDataProvider;
}

function GFxObject PopulateArmourList(out float selectedIndex)
{
	local GFxObject ListDataProvider;
	local GFxObject IndvElement;
	local array<int> IDs;
	local int i, GearID, ValidSelection;
	local bool bIsOwned, bIsMicoTxnVisible;

	local byte bPromptToBuy;
	local string Price,PurchaseName, DiscountPercent;
	local int MicroTxID;

	if(RightTabMode == RTAB_Armour)
	{
		ListDataProvider = Outer.CreateArray();

		IDs = class'BangModCustomization'.static.GetAllCharactersFor(SelectedTeam, SelectedClass);
		i = 0;
		foreach IDs(GearID)
		{
			MicroTxID = 0;
			bPromptToBuy = 0;
			PurchaseName = "";
			Price = "";

			bIsOwned = class'BangModCustomization'.static.IsCharacterOwnedBy(GearID, SelectedTeam, SelectedClass, class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().PlayerReplicationInfo);
			bIsMicoTxnVisible = class'BangModCustomization'.static.IsMicroTxnCharacterVisible(GearID, SelectedTeam, SelectedClass, class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().PlayerReplicationInfo);

			if(bIsMicoTxnVisible)
			{
				if(bIsOwned || class'BangModCustomization'.static.IsCharacterVisibleIfUnowned(GearID, SelectedTeam, SelectedClass))
				{
					IndvElement = CreateObject("Object");
					IndvElement.SetInt("characterID", GearID);
					IndvElement.SetBool("isLocked", !bIsOwned);
					class'BangModCustomization'.static.GetCharacterStoreDescription(GearID, bPromptToBuy, Price, MicroTxID, PurchaseName);

					DiscountPercent = "";
					if(class'BangModCustomization'.static.IsMicroTxnItemOnSale(MicroTxID, Price, DiscountPercent))
					{
						IndvElement.SetBool("isItemOnSale", true);
						IndvElement.SetBool("isNewItem", false);
						AddItemToNotificationArray(MicroTxID);
						DiscountPercent = GetPriceColorFormatting(DiscountPercent$"%");
					}
					else
					{
						IndvElement.SetBool("isItemOnSale", false);

						if(class'BangModCustomization'.static.IsMicroTxnItemNew(MicroTxID))
						{
							IndvElement.SetBool("isNewItem", true);
							AddItemToNotificationArray(MicroTxID);
						}
						else
							IndvElement.SetBool("isNewItem", false);
					}

					IndvElement.SetBool("isPurchasable", Bool(bPromptToBuy) && !bIsOwned);
					IndvElement.SetInt("microTxnId", MicroTxID);
					IndvElement.SetString("itemName", DiscountPercent@class'BangModCustomization'.static.GetCharacterName(GearID));
					ListDataProvider.SetElementObject(i, IndvElement);

					IndvElement.SetString("price", Price);
					
					if(GearID == TeamCustomizationChoices[SelectedTeam].ClassCustomizationChoices[SelectedClass].Character)
					{
						ShowBuyButton(Bool(bPromptToBuy) && !bIsOwned, Price);
						selectedIndex = i;
						SetItemNameLabel(class'BangModCustomization'.static.GetCharacterName(GearID));
					}		

					//only increment the list if the armour is visible
					++i;
				}
			}
			//character is invalid(not visible) and if the character has it selected, need to reset the player's customization reference to a valid character
			else if(GearID == TeamCustomizationChoices[SelectedTeam].ClassCustomizationChoices[SelectedClass].Character)
			{
				ValidSelection = 0;
				while(IDs[ValidSelection] == GearID && ValidSelection < IDs.Length - 1)
				{
					ValidSelection++;
				}
				
				if(ValidSelection > IDs.Length - 1)
					ValidSelection = 0;
				TeamCustomizationChoices[SelectedTeam].ClassCustomizationChoices[SelectedClass].Character = IDs[ValidSelection];
			}	
		}
	}

	return ListDataProvider;
}

function PopulateWeaponModels()
{
	local ASValue asval;
	local array<ASValue> args;

	local SItemsContainer Weapons;
	local SItem Weapon;
		local int MicroTxID, i;
	local bool bIsOwned, bIsMicoTxnVisible;
	local byte bPromptToBuy;
	local string Price,PurchaseName, WeaponName, DiscountPercent;
	local class<AOCCustomization> CustomizationClass;
	local GFxObject IndvElement;
	local SWeaponItemInfo WeaponItemInfo;
		i = 0; // Initialize index for weapon list

	CustomizationClass = AOCPlayerController(GetPC()).CustomizationClass;

	WeaponsDataProvider = Outer.CreateArray();

	if(RightTabMode == RTAB_Weapon)
	{
		/* START DEFAULT WEAPON */
		IndvElement = CreateObject("Object");

		if(IsAShieldWeapon(SelectedWeapon))
		{
			IndvElement.SetString("weaponImageStr", class<AOCWeapon_Shield>(WeaponClasses[SelectedWeapon]).default.Shield.default.Skins[0].ImagePath);
		}
		else
		{
			IndvElement.SetString("weaponImageStr", class<AOCWeaponAttachment>(WeaponClasses[SelectedWeapon].default.AttachmentClass).default.Skins[0].ImagePath);
		}
		WeaponName = WeaponClasses[SelectedWeapon].default.WeaponName;
		IndvElement.SetString("weaponName", WeaponName);
		IndvElement.SetBool("isPurchasable", false);
		IndvElement.SetInt("microTxnId", 0);	
		IndvElement.SetInt("weaponId", 0);
		IndvElement.SetInt("dropId", 0);

		WeaponsDataProvider.SetElementObject(i, IndvElement);
		i++;
		/* END DEFAULT WEAPON */

		Weapons = AllOwnedOrPurchasableWeaponDrops[SelectedWeapon];

		if(TeamWeaponChoices[SelectedTeam].Classes[SelectedClass].Weapons[SelectedWeapon] == 0)
		{
			WeaponsList.SetInt("selectedIndex", 0);
			ShowBuyButton(false);
			SetItemNameLabel(WeaponName);
			FullRefreshDisplayedPawn();
		}

			foreach Weapons.Items(Weapon) // Iterate through each weapon
		{
			// BangMod: treat all weapon skins as owned and visible to mirror 2.2 working unlock behavior
			bIsOwned = true;
			bIsMicoTxnVisible = true;

			class'AOCCustomizationDropManager'.static.GetDropManager().GetWeaponInfoFor(Weapon.ItemId, WeaponItemInfo);

			if(bIsMicoTxnVisible && (SelectedTeam == EFAC_FFA || WeaponItemInfo.AllowedTeams.Find(SelectedTeam) != INDEX_NONE))
			{
				if(bIsOwned || Weapon.GearData.bVisibleInSelectorIfUnowned)
				{
					IndvElement = CreateObject("Object");
					class'BangModCustomization'.static.GetGearStoreDescription(Weapon.GearData, bPromptToBuy, Price, MicroTxID, PurchaseName);

					DiscountPercent = "";
					if(class'BangModCustomization'.static.IsMicroTxnItemOnSale(Weapon.GearData.MicroTxID, Price, DiscountPercent))
					{
						IndvElement.SetBool("isItemOnSale", true);
						IndvElement.SetBool("isNewItem", false);
						AddItemToNotificationArray(MicroTxID);
						DiscountPercent = GetPriceColorFormatting(DiscountPercent$"%");
					}
					else
					{
						IndvElement.SetBool("isItemOnSale", false);
						if(class'BangModCustomization'.static.IsMicroTxnItemNew(Weapon.GearData.MicroTxID))
						{
							IndvElement.SetBool("isNewItem", true);
							AddItemToNotificationArray(MicroTxID);
						}
						else
							IndvElement.SetBool("isNewItem", false);
					}

					WeaponName = DiscountPercent@Localize("Items", WeaponItemInfo.ItemName, "AOCCustomization");

					if(IsAShieldWeapon(WeaponItemInfo.WeaponType))
					{
						IndvElement.SetString("weaponImageStr", class<AOCWeapon_Shield>(WeaponClasses[WeaponItemInfo.WeaponType]).default.Shield.default.Skins[WeaponItemInfo.SkinIndex].ImagePath);
					}
					else
					{
						IndvElement.SetString("weaponImageStr", class<AOCWeaponAttachment>(WeaponClasses[WeaponItemInfo.WeaponType].default.AttachmentClass).default.Skins[WeaponItemInfo.SkinIndex].ImagePath);
					}

					IndvElement.SetString("weaponName", WeaponName);
					IndvElement.SetInt("weaponId", Weapon.ItemId);

					IndvElement.SetInt("dropId", Weapon.DropId);
					
					IndvElement.SetBool("isPurchasable", false);
					IndvElement.SetInt("microTxnId", 0);
					IndvElement.SetString("price", "");                

					WeaponsDataProvider.SetElementObject(i, IndvElement);

					if(Weapon.ItemId == TeamWeaponChoices[SelectedTeam].Classes[SelectedClass].Weapons[SelectedWeapon])
					{
						WeaponsList.SetInt("selectedIndex", i);
						SelectedDrop =  Weapon.DropId;
						ShowBuyButton(false, "");
						SetItemNameLabel(WeaponName);
						FullRefreshDisplayedPawn();
					}
					i++;
				}
			}
		}

		WeaponsList.SetObject("dataProvider", WeaponsDataProvider);
		asval.Type = AS_Null;
		args[0] = asval;
		WeaponsList.Invoke("invalidateData", args);
	}
}





function SetupColors(optional bool UpdateSwatch1 = true, optional bool UpdateSwatch2 = true, optional bool UpdateSwatch3 = true)
{
	local int j, ColourSwatchIndex, NumberOfEmblemColours, NumberOfTabardColours;
	local GFXObject NumberOfObjects, ColourObj;
	local Color swatchColour;

	NumberOfObjects = CreateObject("Object");

	ClearColourSwatches();

	for(ColourSwatchIndex = 0; ColourSwatchIndex < 2; ColourSwatchIndex++)
	{		
		NumberOfEmblemColours = class'BangModCustomization'.static.GetNumberOfEmblemColours(SelectedTeam);
		NumberOfTabardColours = class'BangModCustomization'.static.GetNumberOfTabardColours(ColourSwatchIndex, SelectedTeam);

		NumberOfObjects.SetInt("NumberOfSwatches", (RightTabMode == RTAB_Emblem) ? NumberOfEmblemColours : NumberOfTabardColours);

		for(j = 0; j < (RightTabMode == RTAB_Emblem) ? NumberOfEmblemColours : NumberOfTabardColours; ++j)
		{
			ColourObj = CreateObject("Object");

			if(RightTabMode == RTAB_Emblem)
			{
				swatchColour = class'BangModCustomization'.static.ConvertEmblemColorIndexToColor(j, SelectedTeam);
				ColourObj.SetInt("ra", swatchColour.R);
				ColourObj.SetInt("ba", swatchColour.B);
				ColourObj.SetInt("ga", swatchColour.G);
				SwatchPopup[ColourSwatchIndex].AddColour(ColourObj);
			}
			else
			{
				swatchColour = class'BangModCustomization'.static.ConvertTabardColorIndexToColor(j, SelectedTeam, ColourSwatchIndex);
				ColourObj.SetInt("ra", swatchColour.R);
				ColourObj.SetInt("ba", swatchColour.B);
				ColourObj.SetInt("ga", swatchColour.G);
				SwatchPopup[ColourSwatchIndex].AddColour(ColourObj);
			}
		}

		if(UpdateSwatch1 && ColourSwatchIndex == 0 ||
		   UpdateSwatch2 && ColourSwatchIndex == 1)
		{
			//once you set the number of swatches, it draws all of the swatches
			SwatchPopup[ColourSwatchIndex].SetNumberOfSwatches(NumberOfObjects);
		}
	}

	if(UpdateSwatch3)
	{
		//the third swatch is always fully populated
		for(j = 0; j < 30; ++j)
		{
			swatchColour = class'BangModCustomization'.static.ConvertEmblemColorIndexToColor(j, SelectedTeam);

			ColourObj = CreateObject("Object");
			ColourObj.SetInt("ra", swatchColour.R);
			ColourObj.SetInt("ba", swatchColour.B);
			ColourObj.SetInt("ga", swatchColour.G);

			SwatchPopup[2].AddColour(ColourObj);
		}
	}

	NumberOfObjects.SetInt("NumberOfSwatches", 30);

	//once you set the number of swatches, it draws all of the swatches
	SwatchPopup[2].SetNumberOfSwatches(NumberOfObjects);

	UpdateSwatchSelection();
}


function OnRightListItemClicked(GFxClikWidget.EventData Params)
{
	local int SelectedIndex;
	local int GearID;
	local int CharacterID;
	local bool FullPawnRefresh;
	local GfxObject Element;

	CharacterID = TeamCustomizationChoices[SelectedTeam].ClassCustomizationChoices[SelectedClass].Character;
	SelectedIndex = ItemList.GetFloat("selectedIndex");

	Element = RightListDataProvider.GetElementObject(SelectedIndex);
	ShowBuyButton(Element.GetBool("isPurchasable"), Element.GetString("price"));

	if(RightTabMode == RTAB_Pattern)
	{
		GearID = RightListDataProvider.GetElementObject(SelectedIndex).GetInt("tabardID");
		TeamCustomizationChoices[SelectedTeam].ClassCustomizationChoices[SelectedClass].Tabard = GearID;

		SetItemNameLabel(class'BangModCustomization'.static.GetTabardName(GearID, CharacterID));
	}
	else if(RightTabMode == RTAB_Emblem)
	{
		GearID = RightListDataProvider.GetElementObject(SelectedIndex).GetInt("emblemID");
		TeamCustomizationChoices[SelectedTeam].ClassCustomizationChoices[SelectedClass].Emblem = GearID;
		SetItemNameLabel(class'BangModCustomization'.static.GetEmblemName(GearID, SelectedTeam));
	}
	else if(RightTabMode == RTAB_Shield)
	{
		GearID = RightListDataProvider.GetElementObject(SelectedIndex).GetInt("shieldID");
		TeamCustomizationChoices[SelectedTeam].ClassCustomizationChoices[SelectedClass].Shield = GearID;
		SetItemNameLabel(class'BangModCustomization'.static.GetShieldPatternName(GearID, CharacterID));
	}
	else if(RightTabMode == RTAB_Weapon)
	{
		SelectedWeapon = EWeaponType(RightListDataProvider.GetElementObject(SelectedIndex).GetInt("weaponType"));
		SetItemNameLabel(WeaponClasses[SelectedWeapon].default.WeaponName);

		FullRefreshDisplayedPawn();
		PopulateWeaponModels();
		FullPawnRefresh = true;
	}
	else if(RightTabMode == RTAB_Helmet)
	{
		GearID = RightListDataProvider.GetElementObject(SelectedIndex).GetInt("helmetID");
		TeamCustomizationChoices[SelectedTeam].ClassCustomizationChoices[SelectedClass].Helmet = GearID;
		SetItemNameLabel(class'BangModCustomization'.static.GetHelmetName(GearID,CharacterID));
		FullPawnRefresh = true;
		FullRefreshDisplayedPawn();
	}
	else if(RightTabMode == RTAB_Armour)
	{
		GearID = RightListDataProvider.GetElementObject(SelectedIndex).GetInt("characterID");
		TeamCustomizationChoices[SelectedTeam].ClassCustomizationChoices[SelectedClass].Character = GearID;

		SetItemNameLabel(class'BangModCustomization'.static.GetCharacterName(GearID));

		//Reset the helmet, tabard, etc.; these aren't necessarily "equivalent" between characters
		TeamCustomizationChoices[SelectedTeam].ClassCustomizationChoices[SelectedClass].Helmet = 0;
		TeamCustomizationChoices[SelectedTeam].ClassCustomizationChoices[SelectedClass].Tabard = 0;
		TeamCustomizationChoices[SelectedTeam].ClassCustomizationChoices[SelectedClass].Shield = 0;

		//Repopulate the right tab to correspond to new character
		PopulateRightTab();
		PopulateWeaponModels();
		SetupColors();

		FullPawnRefresh = true;
		FullRefreshDisplayedPawn();
	}

	if(!FullPawnRefresh)
		LightRefreshDisplayedPawn();

	//ShowBuyButton(Bool(bPromptToBuy) && !bIsOwned);
}


function CheckLocks()
{
	//local int LeftSelectedIndex, RightSelectedIndex;
	local bool bLocked;
	//local GFxClikWidget Tab;
	local String LockText;
	local byte bPromptToBuy;
	local int CharacterID;
	local SDropInfo DropInfo;

	CharacterID = TeamCustomizationChoices[SelectedTeam].ClassCustomizationChoices[SelectedClass].Character;

	//LeftSelectedIndex = LeftList.GetFloat("selectedIndex");
	//RightSelectedIndex = ItemList.GetFloat("selectedIndex");

	// BangMod: global unlock, never show lock panel
	bLocked = false;

	if(RightTabMode == RTAB_Emblem && !class'BangModCustomization'.static.IsEmblemOwnedBy(TeamCustomizationChoices[SelectedTeam].ClassCustomizationChoices[SelectedClass].Emblem, SelectedTeam, class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().PlayerReplicationInfo, SelectedClass))
	{
		LockText = class'BangModCustomization'.static.GetEmblemStoreDescription(TeamCustomizationChoices[SelectedTeam].ClassCustomizationChoices[SelectedClass].Emblem, SelectedTeam, bPromptToBuy, DisplayedMicroTxPurchasePrice, DisplayedMicroTxID, DisplayedMicroTxPurchaseName); 
	}
	else if(RightTabMode == RTAB_Armour && !class'BangModCustomization'.static.IsCharacterOwnedBy(CharacterID, SelectedTeam, SelectedClass, class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().PlayerReplicationInfo))
	{
		LockText = class'BangModCustomization'.static.GetCharacterStoreDescription(CharacterID, bPromptToBuy, DisplayedMicroTxPurchasePrice, DisplayedMicroTxID, DisplayedMicroTxPurchaseName); 
	}
	else if(RightTabMode == RTAB_Pattern && !class'BangModCustomization'.static.IsTabardOwnedBy(TeamCustomizationChoices[SelectedTeam].ClassCustomizationChoices[SelectedClass].Tabard, TeamCustomizationChoices[SelectedTeam].ClassCustomizationChoices[SelectedClass].Character, class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().PlayerReplicationInfo, SelectedClass))
	{
		LockText = class'BangModCustomization'.static.GetTabardStoreDescription(TeamCustomizationChoices[SelectedTeam].ClassCustomizationChoices[SelectedClass].Tabard, CharacterID, bPromptToBuy, DisplayedMicroTxPurchasePrice, DisplayedMicroTxID, DisplayedMicroTxPurchaseName);
	}
	else if(RightTabMode == RTAB_Shield && !class'BangModCustomization'.static.IsShieldPatternOwnedBy(TeamCustomizationChoices[SelectedTeam].ClassCustomizationChoices[SelectedClass].Shield, CharacterID, class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().PlayerReplicationInfo, SelectedClass))
	{
		LockText = class'BangModCustomization'.static.GetShieldStoreDescription(TeamCustomizationChoices[SelectedTeam].ClassCustomizationChoices[SelectedClass].Shield, CharacterID, bPromptToBuy, DisplayedMicroTxPurchasePrice, DisplayedMicroTxID, DisplayedMicroTxPurchaseName);
	}
	else if(RightTabMode == RTAB_Helmet && !class'BangModCustomization'.static.IsHelmetOwnedBy(TeamCustomizationChoices[SelectedTeam].ClassCustomizationChoices[SelectedClass].Helmet, CharacterID, class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().PlayerReplicationInfo, SelectedClass))
	{
		LockText = class'BangModCustomization'.static.GetHelmetStoreDescription(TeamCustomizationChoices[SelectedTeam].ClassCustomizationChoices[SelectedClass].Helmet, CharacterID, bPromptToBuy, DisplayedMicroTxPurchasePrice, DisplayedMicroTxID, DisplayedMicroTxPurchaseName); 
	}
	else if(RightTabMode == RTAB_Weapon)
	{
		// Global unlock: allow all weapon selections regardless of ownership.
		// This makes weapon skins selectable like helmets.
		bLocked = false; // BangMod: global unlock, never show lock panel
	}
	else
	{
		bLocked = false;
	}

	if(bLocked)
	{
		fLockPanelAlpha = GetObject("container").GetObject("LockPanel").GetFloat("_alpha");
		bIsLockedPanelShowing = true;
        
		GetObject("container").GetObject("LockPanel").SetVisible(true);
		LockedText.SetString("htmlText",LockText);
		CaptureActor.UITimerTrigger = OnTrackMousePosition;
		CaptureActor.StartUITimer(0.1f);
	}
	else
	{
		// Unlocked: hide lock panel
		bIsLockedPanelShowing = false;
		GetObject("container").GetObject("LockPanel").SetVisible(false);
	}
	// Removed legacy tab-disabling iterators

}
