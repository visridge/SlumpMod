class BangModCustomization extends AOCCustomization
    config(Customization);

// Always treat all helmets as owned for BangMod
static function bool IsHelmetOwnedBy(int HelmetID, int CharacterID, PlayerReplicationInfo PRI, optional EAOCClass CheckClass)
{
	return true;
}

// Always treat all weapon skins as owned for BangMod
static function bool AreWeaponSkinsOwnedBy(int WeaponDrops[EWeaponType], PlayerReplicationInfo PRI)
{
	return true;
}

// Override microtransaction visibility locally for BangMod so the customization
// UI shows microtxn-backed items until the client's localized microtxn list
// has been received. This prevents helmets/items from disappearing while
// the client is still fetching microtransaction metadata.
static function bool CheckMicroTxVisible(int MicroTxID, PlayerReplicationInfo Inf)
{
	local bool found;
	local int i;
	local array<AOCMicroTxnLocalizedList> itemList;
	local GameEngine Engine;

	if( MicroTxID > 0 )
	{
		Engine = GameEngine(Class'Engine'.static.GetEngine());

		if( Engine.bLocalizedItemListReceived == true)
		{
			itemList = class'AOCPlayerController'.default.MicroTxnLocalizedCachedList;

			for(i = 0; i < itemList.Length; i++)
			{
				if(itemList[i].ItemId == MicroTxID)
					found = true;
			}
		}
		else
		{
			// If the localized list hasn't arrived yet, assume visible so UI
			// doesn't hide the item prematurely.
			found = true;
		}
	}
	else
		found = true;

	return found;
}

defaultproperties
{
    CustomizationContentClassString="BangMod.BangModCustomizationContent"
}

// Mod-local override: allow players on BangMod servers to select any helmet
// or weapon skin regardless of microtransaction ownership. This mirrors the
// desired SlumpMod behavior where players can pick any cosmetic without
// microtransaction gating. We keep the remaining validation (characters,
// emblems, tabards, colors) intact.
static function bool AreCustomizationChoicesValidFor(SCustomizationChoice CustomizationInfo, int FamilyID, int ClassID, PlayerReplicationInfo PRI, int WeaponDrops[EWeaponType])
{
	// BangMod: Always accept customization to prevent "saving with locked items" warnings.
	// This mirrors SlumpMod behavior where cosmetic ownership is ignored.
	return true;
}

// BangMod: Override ownership checks for all cosmetic types
static function bool IsTabardOwnedBy(int TabardID, int CharacterID, PlayerReplicationInfo PRI, optional int CheckClass)
{
    return true;
}

static function bool IsEmblemOwnedBy(int EmblemID, int Faction, PlayerReplicationInfo PRI, optional int CheckClass)
{
    return true;
}

static function bool IsCharacterOwnedBy(int CharacterID, int FactionID, int ClassID, PlayerReplicationInfo PRI)
{
	// Character IDs from BangModCustomizationContent:
	// 0 = Skeleton (placeholder), 1 = Skeleton, 12 = Peasant, 13 = Playable_Peasant, 14 = Playable_Skeleton

	// Keep skeletons blocked for all classes
	if (CharacterID == 0 || CharacterID == 1 || CharacterID == 14)
	{
		return false;
	}

	// Allow peasant only for Archer
	if (CharacterID == 12 || CharacterID == 13)
	{
		return EAOCClass(ClassID) == ECLASS_Archer;
	}

	return true;
}

static function bool IsShieldPatternOwnedBy(int ShieldPatternID, int CharacterID, PlayerReplicationInfo PRI, optional int CheckClass)
{
    return true;
}

// BangMod: Override LocalGetCustomizationChoices to use our unlocked logic and read from vanilla config
static function SCustomizationChoice LocalGetCustomizationChoices(int Faction, int PlayerClass,
	optional EWeaponType PrimaryWeaponType = EWEP_MAX,
	optional EWeaponType SecondaryWeaponType = EWEP_MAX,
	optional EWeaponType TertiaryWeaponType = EWEP_MAX)
{
	local SCustomizationChoice CustomizationInfo;
	local int TempID;
	local byte ColIndex;
	local PlayerReplicationInfo PRI;
	local int WeaponsArray[EWeaponType.EWEP_Max];

	PRI = class'Worldinfo'.static.GetWorldInfo().GetALocalPlayerController().PlayerReplicationInfo;

	//Emblem colors - Read from AOCCustomization config
	ColIndex = class'AOCCustomization'.static.LocalGetSelectedEmblemColor(Faction, PlayerClass, 0);
	CustomizationInfo.EmblemColor1 = class'AOCCustomization'.static.IsEmblemColorValid(ColIndex, Faction) ? ColIndex : 0;
	ColIndex = class'AOCCustomization'.static.LocalGetSelectedEmblemColor(Faction, PlayerClass, 1);
	CustomizationInfo.EmblemColor2 = class'AOCCustomization'.static.IsEmblemColorValid(ColIndex, Faction) ? ColIndex : 0;
	ColIndex = class'AOCCustomization'.static.LocalGetSelectedEmblemColor(Faction, PlayerClass, 2);
	CustomizationInfo.EmblemColor3 = class'AOCCustomization'.static.IsEmblemColorValid(ColIndex, Faction) ? ColIndex : 0;

	//Tabard colors
	ColIndex = class'AOCCustomization'.static.LocalGetSelectedTabardColor(Faction, PlayerClass, 0);
	CustomizationInfo.TabardColor1 = class'AOCCustomization'.static.IsTabardColorValid(ColIndex, Faction, 0) ? ColIndex : 0;
	ColIndex = class'AOCCustomization'.static.LocalGetSelectedTabardColor(Faction, PlayerClass, 1);
	CustomizationInfo.TabardColor2 = class'AOCCustomization'.static.IsTabardColorValid(ColIndex, Faction, 1) ? ColIndex : 0;
	ColIndex = class'AOCCustomization'.static.LocalGetSelectedTabardColor(Faction, PlayerClass, 2);
	CustomizationInfo.TabardColor3 = class'AOCCustomization'.static.IsTabardColorValid(ColIndex, Faction, 2) ? ColIndex : 0;

	//Shield colors
	ColIndex = class'AOCCustomization'.static.LocalGetSelectedShieldColor(Faction, PlayerClass, 0);
	CustomizationInfo.ShieldColor1 = class'AOCCustomization'.static.IsTabardColorValid(ColIndex, Faction, 0) ? ColIndex : 0;
	ColIndex = class'AOCCustomization'.static.LocalGetSelectedShieldColor(Faction, PlayerClass, 1);
	CustomizationInfo.ShieldColor2 = class'AOCCustomization'.static.IsTabardColorValid(ColIndex, Faction, 1) ? ColIndex : 0;
	ColIndex = class'AOCCustomization'.static.LocalGetSelectedShieldColor(Faction, PlayerClass, 2);
	CustomizationInfo.ShieldColor3 = class'AOCCustomization'.static.IsTabardColorValid(ColIndex, Faction, 2) ? ColIndex : 0;

	CustomizationInfo.Shield = class'AOCCustomization'.static.LocalGetSelectedShieldPattern(Faction, PlayerClass);

	//Character
	CustomizationInfo.Character = class'AOCCustomization'.static.LocalGetSelectedCharacter(Faction, PlayerClass);
	// BangMod: Allow all characters except skeleton/peasant restrictions
	if(!IsCharacterOwnedBy(CustomizationInfo.Character, Faction, PlayerClass, PRI))
		CustomizationInfo.Character = 0;

	//Helmet
	TempID = class'AOCCustomization'.static.LocalGetSelectedHelmet(Faction, PlayerClass);
    // BangMod: Use local IsHelmetOwnedBy (always true)
	CustomizationInfo.Helmet = byte(IsHelmetOwnedBy(TempID, CustomizationInfo.Character, PRI, EAOCClass(PlayerClass)) ? TempID : 0);

	//Tabard
	TempID = class'AOCCustomization'.static.LocalGetSelectedTabard(Faction, PlayerClass);
    // BangMod: Use local IsTabardOwnedBy (always true)
	CustomizationInfo.Tabard = byte(IsTabardOwnedBy(TempID, CustomizationInfo.Character, PRI, EAOCClass(PlayerClass)) ? TempID : 0);

	//Emblem
	TempID = class'AOCCustomization'.static.LocalGetSelectedEmblem(Faction, PlayerClass);
    // BangMod: Use local IsEmblemOwnedBy (always true)
	CustomizationInfo.Emblem = byte(IsEmblemOwnedBy(TempID, Faction, PRI, EAOCClass(PlayerClass)) ? TempID : 0);

	//Weapon drops
    // BangMod: Call local LocalGetSelectedWeaponDrops
	if(LocalGetSelectedWeaponDrops(Faction, PlayerClass, WeaponsArray, AOCPRI(PRI)))
	{
		if(PrimaryWeaponType != EWEP_MAX)
		{
			CustomizationInfo.PrimaryWeaponDrop = WeaponsArray[PrimaryWeaponType];
		}
		if(SecondaryWeaponType != EWEP_MAX)
		{
			CustomizationInfo.SecondaryWeaponDrop = WeaponsArray[SecondaryWeaponType];
		}
		if(TertiaryWeaponType != EWEP_MAX)
		{
			CustomizationInfo.TertiaryWeaponDrop = WeaponsArray[TertiaryWeaponType];
		}
	}

	if(class'AOCCustomization'.static.IsFactionSupporterIdValid(PRI))
		CustomizationInfo.FactionSupporterId = class'AOCCustomization'.static.LocalGetFactionSupporterId();
	else
		CustomizationInfo.FactionSupporterId = (EFAC_NONE);

	return CustomizationInfo;
}

// BangMod: Override to skip ownership checks and read from vanilla config
static function bool LocalGetSelectedWeaponDrops(int Faction, int PlayerClass, out int WeaponSkinArray[EWeaponType.EWEP_MAX], AOCPRI PRI)
{
	local int TeamIndex, PlayerClassIndex;
	local int WeaponType;
	
    // BangMod: Use AOCCustomization config
	TeamIndex = class'AOCCustomization'.default.SelectedWeaponDrops.Teams.Find('TeamID', Faction);
	if(TeamIndex == INDEX_NONE)
	{
		return false;
	}
	PlayerClassIndex = class'AOCCustomization'.default.SelectedWeaponDrops.Teams[TeamIndex].Classes.Find('ClassID', PlayerClass);
	if(PlayerClassIndex == INDEX_NONE)
	{
		return false;
	}

	for(WeaponType = 0; WeaponType < EWEP_MAX; ++WeaponType)
	{
		WeaponSkinArray[WeaponType] = class'AOCCustomization'.default.SelectedWeaponDrops.Teams[TeamIndex].Classes[PlayerClassIndex].Weapons[WeaponType];
        // BangMod: Ownership checks removed
	}

	return true;
}

// BangMod: Override to write to AOCCustomization config
static function LocalSetCustomizationChoices(SCustomizationChoice CustomizationInfo, int Faction, int PlayerClass, int WeaponDrops[EWeaponType], byte FactionSupporterFavIcon)
{
	class'AOCCustomization'.static.LocalSetSelectedEmblem(Faction, PlayerClass, CustomizationInfo.Emblem);
	class'AOCCustomization'.static.LocalSetSelectedEmblemColor(Faction, PlayerClass, 0, CustomizationInfo.EmblemColor1);
	class'AOCCustomization'.static.LocalSetSelectedEmblemColor(Faction, PlayerClass, 1, CustomizationInfo.EmblemColor2);
	class'AOCCustomization'.static.LocalSetSelectedEmblemColor(Faction, PlayerClass, 2, CustomizationInfo.EmblemColor3);
	class'AOCCustomization'.static.LocalSetSelectedHelmet(CustomizationInfo.Helmet, Faction, PlayerClass);
	class'AOCCustomization'.static.LocalSetSelectedTabard(Faction, PlayerClass, CustomizationInfo.Tabard);
	class'AOCCustomization'.static.LocalSetSelectedTabardColor(Faction, PlayerClass, 0, CustomizationInfo.TabardColor1);
	class'AOCCustomization'.static.LocalSetSelectedTabardColor(Faction, PlayerClass, 1, CustomizationInfo.TabardColor2);
	class'AOCCustomization'.static.LocalSetSelectedTabardColor(Faction, PlayerClass, 2, CustomizationInfo.TabardColor3);
	class'AOCCustomization'.static.LocalSetSelectedShieldColor(Faction, PlayerClass, 0, CustomizationInfo.ShieldColor1);
	class'AOCCustomization'.static.LocalSetSelectedShieldColor(Faction, PlayerClass, 1, CustomizationInfo.ShieldColor2);
	class'AOCCustomization'.static.LocalSetSelectedShieldColor(Faction, PlayerClass, 2, CustomizationInfo.ShieldColor3);
	class'AOCCustomization'.static.LocalSetSelectedShieldPattern(Faction, PlayerClass, CustomizationInfo.Shield);
	class'AOCCustomization'.static.LocalSetSelectedCharacter(Faction, PlayerClass, CustomizationInfo.Character);

	LocalSetSelectWeaponSkinChoices(Faction, PlayerClass, WeaponDrops);

	class'AOCCustomization'.static.LocalSetFactionSupporterId(FactionSupporterFavIcon);

	class'AOCCustomization'.static.StaticSaveConfig();
}

// BangMod: Override to write to AOCCustomization config
static function LocalSetSelectWeaponSkinChoices(int Faction, int PlayerClass, int WeaponDrops[EWeaponType], optional bool SaveConfig)
{
	local int TeamIndex, PlayerClassIndex;
	local int i;
	local TeamClassesWeaponPair TCWP;
	local ClassWeaponSettingPair CWSP;

	TeamIndex = class'AOCCustomization'.default.SelectedWeaponDrops.Teams.Find('TeamID', Faction);
	if(TeamIndex == INDEX_NONE)
	{
		TCWP.TeamID = Faction;
		TeamIndex = class'AOCCustomization'.default.SelectedWeaponDrops.Teams.Length;
		class'AOCCustomization'.default.SelectedWeaponDrops.Teams.AddItem(TCWP);
	}

	PlayerClassIndex = class'AOCCustomization'.default.SelectedWeaponDrops.Teams[TeamIndex].Classes.Find('ClassID', PlayerClass);
	if(PlayerClassIndex == INDEX_NONE)
	{
		CWSP.ClassID = PlayerClass;
		PlayerClassIndex = class'AOCCustomization'.default.SelectedWeaponDrops.Teams[TeamIndex].Classes.Length;
		class'AOCCustomization'.default.SelectedWeaponDrops.Teams[TeamIndex].Classes.AddItem(CWSP);
	}

	for(i = 0; i < EWEP_MAX; ++i)
	{
		class'AOCCustomization'.default.SelectedWeaponDrops.Teams[TeamIndex].Classes[PlayerClassIndex].Weapons[i] = WeaponDrops[i];
	}

	if(SaveConfig)
		class'AOCCustomization'.static.StaticSaveConfig();
}
