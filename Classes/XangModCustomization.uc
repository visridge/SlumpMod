class XangModCustomization extends AOCCustomization
    config(Customization);

// XangMod: Respect GroupHexID ownership for helmets. Group-locked helmets
// (Antlers, Crown, Cowboy, Oakland A's, Community Hat) are equippable only by
// members of the matching Steam group. All other helmets remain unlocked for
// everyone (DLC/microtxn/veteran/rank gating stays disabled).
//
// Exceptions: The Cowboy hat (GroupHexID "1700000027DC808") and baseball hat
// (Oakland A's, GroupHexID "170000002457482") are whitelisted so they stay
// available to everyone regardless of Steam group membership.
static function bool IsHelmetOwnedBy(int HelmetID, int CharacterID, PlayerReplicationInfo PRI, optional EAOCClass CheckClass)
{
	local AOCGearData GearData;

	if(!IsHelmetValidFor(HelmetID, CharacterID))
	{
		return false;
	}

	GearData = class<AOCCustomizationContentBase>(FindObject(default.CustomizationContentClassString, class'Class')).default.Characters[CharacterID].default.Helmets[HelmetID].GearData;

	// Cowboy hat and baseball hat are free for everyone.
	if(GearData.GroupHexID == "1700000027DC808"
		|| GearData.GroupHexID == "170000002457482")
	{
		return true;
	}

	if(GearData.GroupHexID != "")
	{
		return IsGearOwnedBy(GearData, PRI, CheckClass);
	}

	return true;
}

// Always treat all weapon skins as owned for XangMod
static function bool AreWeaponSkinsOwnedBy(int WeaponDrops[EWeaponType], PlayerReplicationInfo PRI)
{
	return true;
}

// Override microtransaction visibility locally for XangMod so the customization
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
    CustomizationContentClassString="XangMod.XangModCustomizationContent"
}

// Mod-local override: allow players on XangMod servers to select any helmet
// or weapon skin regardless of microtransaction ownership. This mirrors the
// desired SlumpMod behavior where players can pick any cosmetic without
// microtransaction gating. We keep the remaining validation (characters,
// emblems, tabards, colors) intact.
static function bool AreCustomizationChoicesValidFor(SCustomizationChoice CustomizationInfo, int FamilyID, int ClassID, PlayerReplicationInfo PRI, int WeaponDrops[EWeaponType])
{
	// XangMod: Always accept customization to prevent "saving with locked items" warnings.
	// This mirrors SlumpMod behavior where cosmetic ownership is ignored.
	return true;
}

// XangMod: Override ownership checks for all cosmetic types
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
	// Character IDs from XangModCustomizationContent:
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

// Fix-up stale character index that was saved from a previous mod version
// where the Characters array had different ordering. If the saved index now
// points to a class that doesn't match the requested faction/class, walk the
// array to find the correct index for the same character-info class.
// On success the INI is healed in-place so the correction persists.
static function int FixupCharacterIndex(int SavedIndex, int Faction, int PlayerClass)
{
	local class<AOCCharacterInfo> SavedCharClass;
	local class<AOCCharacterInfo> CurrCharClass;
	local int i, CorrectedIndex;
	local array<class<AOCCharacterInfo> > CharList;

	CharList = class'XangModCustomizationContent'.default.Characters;

	// In-range and still valid for this faction/class — nothing to fix.
	if (SavedIndex >= 0 && SavedIndex < CharList.Length
		&& CharList[SavedIndex] != none
		&& CharList[SavedIndex].static.IsValidFor(Faction, PlayerClass))
	{
		return SavedIndex;
	}

	// Out of range or mismatched. Walk current array by class reference.
	SavedCharClass = (SavedIndex >= 0 && SavedIndex < CharList.Length)
		? CharList[SavedIndex] : none;

	if (SavedCharClass != none)
	{
		for (i = 0; i < CharList.Length; i++)
		{
			if (CharList[i] == SavedCharClass
				&& CharList[i].static.IsValidFor(Faction, PlayerClass))
			{
				CorrectedIndex = i;
				break;
			}
		}
	}

	if (SavedCharClass == none || CorrectedIndex == INDEX_NONE)
	{
		// Can't correlate saved index to any known class — fall back to default.
		// Use the XangMod content resolver directly: AOCCustomization.GetDefaultCharacterID
		// would use the vanilla content list, which has no entry for ECLASS_SiegeEngineer
		// (class slot 4) and would fall through to the peasant.
		CorrectedIndex = class'XangModCustomizationContent'.static.GetDefaultCharacterIDFor(Faction, PlayerClass);
	}

	// Auto-heal the stale INI save so the fix persists on next session.
	class'AOCCustomization'.static.LocalSetSelectedCharacter(Faction, PlayerClass, CorrectedIndex, true);

	return CorrectedIndex;
}

// XangMod: Override LocalGetCustomizationChoices to use our unlocked logic and read from vanilla config
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
	CustomizationInfo.EmblemColor1 = class'XangModCustomization'.static.IsEmblemColorValid(ColIndex, Faction) ? ColIndex : 0;
	ColIndex = class'AOCCustomization'.static.LocalGetSelectedEmblemColor(Faction, PlayerClass, 1);
	CustomizationInfo.EmblemColor2 = class'XangModCustomization'.static.IsEmblemColorValid(ColIndex, Faction) ? ColIndex : 0;
	ColIndex = class'AOCCustomization'.static.LocalGetSelectedEmblemColor(Faction, PlayerClass, 2);
	CustomizationInfo.EmblemColor3 = class'XangModCustomization'.static.IsEmblemColorValid(ColIndex, Faction) ? ColIndex : 0;

	//Tabard colors
	ColIndex = class'AOCCustomization'.static.LocalGetSelectedTabardColor(Faction, PlayerClass, 0);
	CustomizationInfo.TabardColor1 = class'XangModCustomization'.static.IsTabardColorValid(ColIndex, Faction, 0) ? ColIndex : 0;
	ColIndex = class'AOCCustomization'.static.LocalGetSelectedTabardColor(Faction, PlayerClass, 1);
	CustomizationInfo.TabardColor2 = class'XangModCustomization'.static.IsTabardColorValid(ColIndex, Faction, 1) ? ColIndex : 0;
	ColIndex = class'AOCCustomization'.static.LocalGetSelectedTabardColor(Faction, PlayerClass, 2);
	CustomizationInfo.TabardColor3 = class'XangModCustomization'.static.IsTabardColorValid(ColIndex, Faction, 2) ? ColIndex : 0;

	//Shield colors
	ColIndex = class'AOCCustomization'.static.LocalGetSelectedShieldColor(Faction, PlayerClass, 0);
	CustomizationInfo.ShieldColor1 = class'XangModCustomization'.static.IsTabardColorValid(ColIndex, Faction, 0) ? ColIndex : 0;
	ColIndex = class'AOCCustomization'.static.LocalGetSelectedShieldColor(Faction, PlayerClass, 1);
	CustomizationInfo.ShieldColor2 = class'XangModCustomization'.static.IsTabardColorValid(ColIndex, Faction, 1) ? ColIndex : 0;
	ColIndex = class'AOCCustomization'.static.LocalGetSelectedShieldColor(Faction, PlayerClass, 2);
	CustomizationInfo.ShieldColor3 = class'XangModCustomization'.static.IsTabardColorValid(ColIndex, Faction, 2) ? ColIndex : 0;

	CustomizationInfo.Shield = class'AOCCustomization'.static.LocalGetSelectedShieldPattern(Faction, PlayerClass);

	//Character
	CustomizationInfo.Character = class'AOCCustomization'.static.LocalGetSelectedCharacter(Faction, PlayerClass);
	// XangMod: Fix-up stale character index saved from a previous mod version.
	// The Characters array is append-only; if an old index now points to the
	// wrong class, walk the array by class reference to find the correct slot.
	CustomizationInfo.Character = FixupCharacterIndex(CustomizationInfo.Character, Faction, PlayerClass);
	// XangMod: Allow all characters except skeleton/peasant restrictions.
	// Fall back to GetDefaultCharacterID (not 0) so the player gets their
	// class-appropriate default skin instead of the skeleton placeholder.
	// Use the XangMod content resolver directly: AOCCustomization.GetDefaultCharacterID
	// would use the vanilla content list, which has no entry for ECLASS_SiegeEngineer
	// (class slot 4) and would fall through to the peasant.
	if(!IsCharacterOwnedBy(CustomizationInfo.Character, Faction, PlayerClass, PRI))
		CustomizationInfo.Character = class'XangModCustomizationContent'.static.GetDefaultCharacterIDFor(Faction, PlayerClass);

	//Helmet
	TempID = class'AOCCustomization'.static.LocalGetSelectedHelmet(Faction, PlayerClass);
    // XangMod: Use local IsHelmetOwnedBy (always true)
	CustomizationInfo.Helmet = byte(IsHelmetOwnedBy(TempID, CustomizationInfo.Character, PRI, EAOCClass(PlayerClass)) ? TempID : 0);

	//Tabard
	TempID = class'AOCCustomization'.static.LocalGetSelectedTabard(Faction, PlayerClass);
    // XangMod: Use local IsTabardOwnedBy (always true)
	CustomizationInfo.Tabard = byte(IsTabardOwnedBy(TempID, CustomizationInfo.Character, PRI, EAOCClass(PlayerClass)) ? TempID : 0);

	//Emblem
	TempID = class'AOCCustomization'.static.LocalGetSelectedEmblem(Faction, PlayerClass);
    // XangMod: Use local IsEmblemOwnedBy (always true)
	CustomizationInfo.Emblem = byte(IsEmblemOwnedBy(TempID, Faction, PRI, EAOCClass(PlayerClass)) ? TempID : 0);

	//Weapon drops
    // XangMod: Call local LocalGetSelectedWeaponDrops
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

// XangMod: Override to skip ownership checks and read from vanilla config
static function bool LocalGetSelectedWeaponDrops(int Faction, int PlayerClass, out int WeaponSkinArray[EWeaponType.EWEP_MAX], AOCPRI PRI)
{
	local int TeamIndex, PlayerClassIndex;
	local int WeaponType;
	
    // XangMod: Use AOCCustomization config
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
        // XangMod: Ownership checks removed
	}

	return true;
}

// XangMod: Override to write to AOCCustomization config
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

// XangMod: Override to write to AOCCustomization config
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

// XangMod: Localize the 5th class name for the customization screen. The vanilla
// GetClassName has no ECLASS_SiegeEngineer case, so it returns an empty string and
// the class label renders blank.
static function string GetClassName(EAOCClass ClassID)
{
	if (ClassID == ECLASS_SiegeEngineer)
		return "Assassin";

	return super.GetClassName(ClassID);
}
