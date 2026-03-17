class BangModCustomizationContent extends AOCCustomizationContent;
static function int GetDefaultCharacterIDFor(int Team, int PawnClass)
{
    LogAlwaysInternal("GetDefaultCharacterIDFor"@Team@PawnClass);
    switch(PawnClass)
    {
    case ECLASS_Archer:
        return Team == EFAC_Agatha ? default.Characters.Find(class'BangModCharacterInfo_Agatha_Archer') : default.Characters.Find(class'BangModCharacterInfo_Mason_Archer');
        break;
    case ECLASS_ManAtArms:
        return Team == EFAC_Agatha ? default.Characters.Find(class'BangModCharacterInfo_Agatha_ManAtArms') : default.Characters.Find(class'BangModCharacterInfo_Mason_ManAtArms');
        break;
    case ECLASS_Vanguard:
        return Team == EFAC_Agatha ? default.Characters.Find(class'BangModCharacterInfo_Agatha_Vanguard') : default.Characters.Find(class'BangModCharacterInfo_Mason_Vanguard');
        break;
    case ECLASS_Knight:
        return Team == EFAC_Agatha ? default.Characters.Find(class'BangModCharacterInfo_Agatha_Knight') : default.Characters.Find(class'BangModCharacterInfo_Mason_Knight');
        break;
    case ECLASS_King:
        return Team == EFAC_Agatha ? default.Characters.Find(class'BangModCharacterInfo_Agatha_King') : default.Characters.Find(class'BangModCharacterInfo_Mason_King');
        break;
    case ECLASS_Peasant:
    default:
        return default.Characters.Find(class'AOCCharacterInfo_Peasant');
    };
}


defaultproperties
{
    Characters.Empty()
	//This ordering shouldn't change. Nothing terrible will happen as long (as the server and clients have the same ordering), but users' customization choices will be altered.
	Characters.Add(class'AOCCharacterInfo_Skeleton') //Placeholder invalid entry
	Characters.Add(class'AOCCharacterInfo_Skeleton')
	Characters.Add(class'BangModCharacterInfo_Agatha_Archer')
	Characters.Add(class'BangModCharacterInfo_Agatha_King')
	Characters.Add(class'BangModCharacterInfo_Agatha_Knight')
	Characters.Add(class'BangModCharacterInfo_Agatha_ManAtArms')
	Characters.Add(class'BangModCharacterInfo_Agatha_Vanguard')
	Characters.Add(class'BangModCharacterInfo_Mason_Archer')
	Characters.Add(class'BangModCharacterInfo_Mason_King')
	Characters.Add(class'BangModCharacterInfo_Mason_Knight')
	Characters.Add(class'BangModCharacterInfo_Mason_ManAtArms')
	Characters.Add(class'BangModCharacterInfo_Mason_Vanguard')
	Characters.Add(class'AOCCharacterInfo_Peasant')
	Characters.Add(class'AOCCharacterInfo_Playable_Peasant')
	Characters.Add(class'AOCCharacterInfo_Playable_Skeleton')

	Characters.Add(class'BangModCharacterInfo_Agatha_Knight_DLC1')
	Characters.Add(class'BangModCharacterInfo_Mason_Knight_DLC1')
	
	Characters.Add(class'BangModCharacterInfo_Mason_Vanguard_DLC1')
	Characters.Add(class'BangModCharacterInfo_Agatha_Vanguard_DLC1')
	
	Characters.Add(class'BangModCharacterInfo_BARB_Agatha_Archer')
	Characters.Add(class'BangModCharacterInfo_BARB_Agatha_Knight')
	Characters.Add(class'BangModCharacterInfo_BARB_Agatha_ManAtArms')
	Characters.Add(class'BangModCharacterInfo_BARB_Agatha_Vanguard')
	Characters.Add(class'BangModCharacterInfo_BARB_Mason_Archer')
	Characters.Add(class'BangModCharacterInfo_BARB_Mason_Knight')
	Characters.Add(class'BangModCharacterInfo_BARB_Mason_ManAtArms')
	Characters.Add(class'BangModCharacterInfo_BARB_Mason_Vanguard')
	Characters.Add(class'AOCCharacterInfo_Playable_PeasantRevolt')
	Characters.Add(class'BangModCharacterInfo_Agatha_Footman')
	Characters.Add(class'BangModCharacterInfo_Mason_Footman')
    

    Teams.Empty()
    Teams.Add(class'BangModCustomizationTeam_Agatha') //0
    Teams.Add(class'BangModCustomizationTeam_Mason') // 1
    Teams.Add(class'BangModCustomizationTeam_FFA') //5


	Drops(0)=()
	Drops(1)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Bardiche_Variant, GearStoreDescriptionID=Bardiche_Weapon_Variant, bVisibleInSelectorIfUnowned=true, MicroTxID=101027),
			WeaponItemIds=(1)
		)};
	Drops(2)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=GrandMace_Vairant, GearStoreDescriptionID=Agatha_Elite_Knight_Bundle_1, MicroTxID=101025, bPartOfBundle=true, BundleNameID=Agatha_Elite_Knight_Bundle_1), 
			WeaponItemIds=(2)
		)};
	Drops(3)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Javelin_Variant, GearStoreDescriptionID=Javelin_Weapon_Variant, bVisibleInSelectorIfUnowned=true, MicroTxID=101031),
			WeaponItemIds=(3)
		)};
	Drops(4)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Maul_Variant, GearStoreDescriptionID=Maul_Variant_Store_Description, bVisibleInSelectorIfUnowned=true, MicroTxID=101028),
			WeaponItemIds=(4)
		)};
	Drops(5)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Messer_Vairant, GearStoreDescriptionID=Mason_Elite_Knight_Bundle_1, MicroTxID=101026, bPartOfBundle=true, BundleNameID=Mason_Elite_Knight_Bundle_1),
			WeaponItemIds=(5)
		)};
	Drops(6)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=NorseSword_Variant, GearStoreDescriptionID=NorseSword_Variant_Store_Description, bVisibleInSelectorIfUnowned=true, MicroTxID=101029),
			WeaponItemIds=(6)
		)};
	Drops(7)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Spear_Variant, GearStoreDescriptionID=Spear_Weapon_Variant, bVisibleInSelectorIfUnowned=true, MicroTxID=101030),
			WeaponItemIds=(7)
		)};
	Drops(8)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Falchion_Variant, GearStoreDescriptionID=Assault_Set, bVisibleInSelectorIfUnowned=true, MicroTxID=102005, bPartOfBundle=true, BundleNameID=Assault_Set_Bundle),
			WeaponItemIds=(8)
		)};
	Drops(9)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Crossbow_Variant, GearStoreDescriptionID=Hawkeye_Set, bVisibleInSelectorIfUnowned=true, MicroTxID=102001, bPartOfBundle=true, BundleNameID=Hawkeye_Set_Bundle),
			WeaponItemIds=(9)
		)};
	Drops(10)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Longsword_Variant, GearStoreDescriptionID=Hound_Set, bVisibleInSelectorIfUnowned=true, MicroTxID=102012, bPartOfBundle=true, BundleNameID=Hound_Set_Bundle),
			WeaponItemIds=(10)
		)};
	Drops(11)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Messer_Variant2, GearStoreDescriptionID=Dark_Ornate_Set, bVisibleInSelectorIfUnowned=true, MicroTxID=102010, bPartOfBundle=true, BundleNameID=Dark_Ornate_Set_Bundle),
			WeaponItemIds=(11)
		)};
	Drops(12)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Broadsword_Variant, GearStoreDescriptionID=Oriental_Set, bVisibleInSelectorIfUnowned=true, MicroTxID=102004, bPartOfBundle=true, BundleNameID=Oriental_Set_Bundle),
			WeaponItemIds=(12)
		)};
	Drops(13)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Spear_Variant2, GearStoreDescriptionID=Honors_Guard_Set, bVisibleInSelectorIfUnowned=true, MicroTxID=102007, bPartOfBundle=true, BundleNameID=Honors_Guard_Set_Bundle),
			WeaponItemIds=(13)
		)};
	Drops(14)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Shortbow_Variant, GearStoreDescriptionID=Eurasian_Horsebow, bVisibleInSelectorIfUnowned=true, MicroTxID=102003),
			WeaponItemIds=(14)
		)};
	Drops(15)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Brandistock_Variant, GearStoreDescriptionID=Fist_OfThe_Burning_Sun_Set, bVisibleInSelectorIfUnowned=true, MicroTxID=102009, bPartOfBundle=true, BundleNameID=Fist_OfThe_Burning_Sun_Set_Bundle),
			WeaponItemIds=(15)
		)};
	Drops(16)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Bearded_Variant, GearStoreDescriptionID=Judgement_Set, bVisibleInSelectorIfUnowned=true, MicroTxID=102011, bPartOfBundle=true, BundleNameID=Judgement_Set_Bundle),
			WeaponItemIds=(16)
		)};
	Drops(17)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Broadsword_Variant_02, GearStoreDescriptionID=Temujins_Set, bVisibleInSelectorIfUnowned=true, MicroTxID=102006, bPartOfBundle=true, BundleNameID=Temujins_Set_Bundle),
			WeaponItemIds=(17)
		)};
	Drops(18)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Broadsword_Variant_03, GearStoreDescriptionID=the_kin_slayer, bVisibleInSelectorIfUnowned=true, MicroTxID=102018),
			WeaponItemIds=(18)
		)};
	Drops(19)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Greatsword_Variant_01, GearStoreDescriptionID=willbreaker, bVisibleInSelectorIfUnowned=true, MicroTxID=102020),
			WeaponItemIds=(19)
		)};
	Drops(20)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Bearded_Variant_02, GearStoreDescriptionID=Chicken_Set, bVisibleInSelectorIfUnowned=true, MicroTxID=102016, bPartOfBundle=true, BundleNameID=Chicken_Set_Bundle),
			WeaponItemIds=(20)
		)};	
	Drops(21)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=ShortSpear_Variant_01, GearStoreDescriptionID=SharkTooth, bVisibleInSelectorIfUnowned=true, MicroTxID=102013),
			WeaponItemIds=(21)
		)};	
	Drops(22)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Spear_Variant_03, GearStoreDescriptionID=ShatteredStar, bVisibleInSelectorIfUnowned=true, MicroTxID=102019),
			WeaponItemIds=(22)
		)};		
	Drops(23)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=NorseSword_Variant2, GearStoreDescriptionID=Renaissance_rapier, bVisibleInSelectorIfUnowned=true, MicroTxID=102017),
			WeaponItemIds=(23)
		)};	
	Drops(24)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Longsword_Variant_02, GearStoreDescriptionID=Styrian, bVisibleInSelectorIfUnowned=true, MicroTxID=102015),
			WeaponItemIds=(24)
		)};	
	Drops(25)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Longsword_Variant_03, GearStoreDescriptionID=Ornamental_Set, bVisibleInSelectorIfUnowned=true, MicroTxID=102014, bPartOfBundle=true, BundleNameID=Ornamental_Set_Bundle),
			WeaponItemIds=(25)
		)};		
	Drops(26)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Depth_MorningStar, GearStoreDescriptionID=Depth_Item_Set, bVisibleInSelectorIfUnowned=true/*, MicroTxID=101037*/, AppIdNoDLC=274940, bPartOfBundle=true, BundleNameID=Depth_Item_Set),
			WeaponItemIds=(26)
		)};	

	Drops(27)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=ThrustingDagger_Variant_01, GearStoreDescriptionID=RondelDagger, bVisibleInSelectorIfUnowned=true, MicroTxID=102021,bPartOfBundle=false),
			WeaponItemIds=(27)
		)};	

	Drops(28)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Shortsword_Variant_01, GearStoreDescriptionID=Seax, bVisibleInSelectorIfUnowned=true, MicroTxID=102022,bPartOfBundle=false),
			WeaponItemIds=(28)
		)};

	Drops(29)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Poleaxe_Variant_01, GearStoreDescriptionID=Leo_Set, bVisibleInSelectorIfUnowned=true, MicroTxID=102023,bPartOfBundle=true, BundleNameID=Leo_Set),
			WeaponItemIds=(29)
		)};

	Drops(30)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Doubleaxe_Variant_01, GearStoreDescriptionID=HengestHorsa, bVisibleInSelectorIfUnowned=true, MicroTxID=102024,bPartOfBundle=false),
			WeaponItemIds=(30)
		)};

	Drops(31)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=SwordofWar_Variant_01, GearStoreDescriptionID=FinalGuardSet, bVisibleInSelectorIfUnowned=true, MicroTxID=102025,bPartOfBundle=true, BundleNameID=FinalGuardSet),
			WeaponItemIds=(31)
		)};

	Drops(32)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Broadsword_Variant_04, GearStoreDescriptionID=CourtArmorSet, bVisibleInSelectorIfUnowned=true, MicroTxID=102026,bPartOfBundle=true, BundleNameID=CourtArmorSet),
			WeaponItemIds=(32)
		)};

	Drops(33)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Greatsword_Variant_02, GearStoreDescriptionID=BerserkerSet, bVisibleInSelectorIfUnowned=true, MicroTxID=102027,bPartOfBundle=true, BundleNameID=BerserkerSet),
			WeaponItemIds=(33)
		)};

	Drops(34)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Spear_Variant_04, GearStoreDescriptionID=AwlPike, bVisibleInSelectorIfUnowned=true, MicroTxID=102028,bPartOfBundle=false),
			WeaponItemIds=(34)
		)};

	Drops(35)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Zweihander_Variant_01, GearStoreDescriptionID=Flammenschwert, bVisibleInSelectorIfUnowned=true, MicroTxID=102029,bPartOfBundle=false),
			WeaponItemIds=(35)
		)};

	Drops(36)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=HFlail_Variant_01, GearStoreDescriptionID=RatSet, bVisibleInSelectorIfUnowned=true, MicroTxID=102031,bPartOfBundle=true, BundleNameID=RatSet),
			WeaponItemIds=(36)
		)};
	
	Drops(37)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Maul_Variant_02, GearStoreDescriptionID=Tenderizer, bVisibleInSelectorIfUnowned=true, MicroTxID=102032, bPartOfBundle=false),
			WeaponItemIds=(37)
		)};

	Drops(38)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Messer_Variant_03, GearStoreDescriptionID=InfidelsBane, bVisibleInSelectorIfUnowned=true, MicroTxID=102033, bPartOfBundle=false),
			WeaponItemIds=(38)
		)};

	Drops(39)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Messer_Variant_04, GearStoreDescriptionID=ChaosSet, bVisibleInSelectorIfUnowned=true, MicroTxID=102034, bPartOfBundle=true, BundleNameID=ChaosSet ),
			WeaponItemIds=(39)
		)};

	Drops(40)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=HolyWater_Variant_01, GearStoreDescriptionID=WingedWraith, bVisibleInSelectorIfUnowned=true, MicroTxID=102035, bPartOfBundle=false),
			WeaponItemIds=(40)
		)};

	Drops(41)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=NorseSword_Variant_03, GearStoreDescriptionID=BladeBrothersSunSword, bVisibleInSelectorIfUnowned=true, MicroTxID=102036, bPartOfBundle=false),
			WeaponItemIds=(41)
		)};
	
	Drops(42)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Billhook_Variant_01, GearStoreDescriptionID=Shark, bVisibleInSelectorIfUnowned=true, MicroTxID=102037, bPartOfBundle=false),
			WeaponItemIds=(42)
		)};

	Drops(43)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Halberd_Variant_01, GearStoreDescriptionID=KrakenSet, bVisibleInSelectorIfUnowned=true, MicroTxID=102038, bPartOfBundle=true, BundleNameID=KrakenSet),
			WeaponItemIds=(43)
		)};

	Drops(44)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Claymore_Variant_01, GearStoreDescriptionID=FiorCharaid, bVisibleInSelectorIfUnowned=true, MicroTxID=102039, bPartOfBundle=false),
			WeaponItemIds=(44)
		)};

	Drops(45)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=MorningStar_Variant_02, GearStoreDescriptionID=HeadBanger, bVisibleInSelectorIfUnowned=true, MicroTxID=102040, bPartOfBundle=false),
			WeaponItemIds=(45)
		)};

	Drops(46)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=WarAxe_Variant_01, GearStoreDescriptionID=Sunder, bVisibleInSelectorIfUnowned=true, MicroTxID=102041, bPartOfBundle=false),
			WeaponItemIds=(46)
		)};

	Drops(47)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Halberd_Variant_02, GearStoreDescriptionID=SwissRoyalHalberd, bVisibleInSelectorIfUnowned=true, MicroTxID=102042, bPartOfBundle=false),
			WeaponItemIds=(47)
		)};

	Drops(48)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Longbow_Variant_01, GearStoreDescriptionID=HeartPiercer, bVisibleInSelectorIfUnowned=true, MicroTxID=102043, bPartOfBundle=true, BundleNameID=HeartPiercer),
			WeaponItemIds=(48)
		)};

	Drops(50)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Longsword_Variant_04, GearStoreDescriptionID=TypeXIILongsword, bVisibleInSelectorIfUnowned=true, MicroTxID=102044, bPartOfBundle=false),
			WeaponItemIds=(50)
		)};

	Drops(49)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Poleaxe_Variant_02, GearStoreDescriptionID=WarmongerSet1, bVisibleInSelectorIfUnowned=true, MicroTxID=102045, bPartOfBundle=true, BundleNameID=WarmongerSet1),
			WeaponItemIds=(49)
		)};

	Drops(51)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Messer_Variant_05, GearStoreDescriptionID=WarmongerSet2, bVisibleInSelectorIfUnowned=true, MicroTxID=102046, bPartOfBundle=true, BundleNameID=WarmongerSet2),
			WeaponItemIds=(51)
		)};

	Drops(52)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=GrandMace_Variant_03, GearStoreDescriptionID=WreckerSet, bVisibleInSelectorIfUnowned=true, MicroTxID=102047, bPartOfBundle=true, BundleNameID=WreckerSet),
			WeaponItemIds=(52)
		)};

	Drops(53)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=ThrustingDagger_Variant_02, GearStoreDescriptionID=BlackOrchid, bVisibleInSelectorIfUnowned=true, MicroTxID=102048, bPartOfBundle=false),
			WeaponItemIds=(53)
		)};

	Drops(54)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=NorseSword_Variant_04, GearStoreDescriptionID=ChieftainsSpatha, bVisibleInSelectorIfUnowned=true, MicroTxID=102049, bPartOfBundle=false),
			WeaponItemIds=(54)
		)};

	Drops(55)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Halberd_Variant_03, GearStoreDescriptionID=ClassicVoulge, bVisibleInSelectorIfUnowned=true, MicroTxID=102050, bPartOfBundle=false),
			WeaponItemIds=(55)
		)};

	Drops(56)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=SwordOfWar_Variant_02, GearStoreDescriptionID=WinterSoldierSet, bVisibleInSelectorIfUnowned=true, MicroTxID=102051, bPartOfBundle=true, BundleNameID=WinterSoldierSet),
			WeaponItemIds=(56)
		)};

	Drops(57)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Maul_Variant_03, GearStoreDescriptionID=GuiltyGavel, bVisibleInSelectorIfUnowned=true, MicroTxID=102052, bPartOfBundle=false),
			WeaponItemIds=(57)
		)};

	Drops(58)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Bardiche_Variant_02, GearStoreDescriptionID=ReiverSet1, bVisibleInSelectorIfUnowned=true, MicroTxID=102053, bPartOfBundle=true, BundleNameID=ReiverSet1),
			WeaponItemIds=(58, 62)//62 is mason throwing axe
		)};

	Drops(59)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=WarAxe_Variant_02, GearStoreDescriptionID=ReiverSet2, bVisibleInSelectorIfUnowned=true, MicroTxID=102054, bPartOfBundle=true, BundleNameID=ReiverSet2),
			WeaponItemIds=(59, 100)//100 is mason throwing axe
		)};

	Drops(60)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Javelin_Variant_02, GearStoreDescriptionID=RoyalSquad, bVisibleInSelectorIfUnowned=true, MicroTxID=102055, bPartOfBundle=true, BundleNameID=RoyalSquad),
			WeaponItemIds=(60)
		)};

	Drops(61)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Cudgel_Variant_01, GearStoreDescriptionID=Skullcrusher, bVisibleInSelectorIfUnowned=true, MicroTxID=102056, bPartOfBundle=false),
			WeaponItemIds=(61)
		)};

	Drops(63)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=KF2ThrowingKnife_Variant_01, bVisibleInSelectorIfUnowned=true, AppIdNoDLC=232090, bPartOfBundle=true, BundleNameID=KF2_Item_Set_Name, GearStoreDescriptionID=KF2_Item_Set_Description),
			WeaponItemIds=(63)
		)};

	Drops(64)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=KF2QuarterStaff_Variant_01, bVisibleInSelectorIfUnowned=true, AppIdNoDLC=232090, bPartOfBundle=true, BundleNameID=KF2_Item_Set_Name, GearStoreDescriptionID=KF2_Item_Set_Description),
			WeaponItemIds=(64)
		)};

	Drops(65)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=KF2Longsword_Variant_01, bVisibleInSelectorIfUnowned=true, AppIdNoDLC=232090, bPartOfBundle=true, BundleNameID=KF2_Item_Set_Name, GearStoreDescriptionID=KF2_Item_Set_Description),
			WeaponItemIds=(65)
		)};

	Drops(66)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=KF2Maul_Variant_01, bVisibleInSelectorIfUnowned=true, AppIdNoDLC=232090, bPartOfBundle=true, BundleNameID=KF2_Item_Set_Name, GearStoreDescriptionID=KF2_Item_Set_Description),
			WeaponItemIds=(66)
		)};

	Drops(67)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Bearded_Variant_03, bVisibleInSelectorIfUnowned=true, MicroTxID=102057, GearStoreDescriptionID=BearAxeDesc),
			WeaponItemIds=(67)
		)};

	Drops(68)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=WarAxe_Variant_03, bVisibleInSelectorIfUnowned=true, MicroTxID=102058, GearStoreDescriptionID=CampaignerDesc),
			WeaponItemIds=(68)
		)};

	Drops(69)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Broadsword_Variant_05, bVisibleInSelectorIfUnowned=true, MicroTxID=102059, GearStoreDescriptionID=IceBreakerDesc),
			WeaponItemIds=(69)
		)};

	Drops(70)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Grandmace_Variant_03, bVisibleInSelectorIfUnowned=true, MicroTxID=102061, GearStoreDescriptionID=PathMakerDesc),
			WeaponItemIds=(70)
		)};

	Drops(71)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Zweihander_Variant_02, bVisibleInSelectorIfUnowned=true, MicroTxID=102062, GearStoreDescriptionID=SerpentSet, bPartOfBundle=true, BundleNameID=SerpentSet),
			WeaponItemIds=(71)
		)};

	Drops(72)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Brandistock_Variant_02, bVisibleInSelectorIfUnowned=true, MicroTxID=102063, GearStoreDescriptionID=SharpClawDesc),
			WeaponItemIds=(72)
		)};

	Drops(73)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Spear_Variant_05, bVisibleInSelectorIfUnowned=true, MicroTxID=102064, GearStoreDescriptionID=SpearFleurDeLysDesc),
			WeaponItemIds=(73)
		)};

	Drops(74)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Maul_Variant_05, bVisibleInSelectorIfUnowned=true, MicroTxID=102065, GearStoreDescriptionID=SpikedMaulDesc),
			WeaponItemIds=(74)
		)};

	Drops(75)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Longsword_Variant_06, bVisibleInSelectorIfUnowned=true, MicroTxID=102066, GearStoreDescriptionID=SwordOfDraculDesc),
			WeaponItemIds=(75)
		)};

	Drops(76)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=QuarterStaff_Variant_01, bVisibleInSelectorIfUnowned=true, MicroTxID=102067, GearStoreDescriptionID=ThornstaffDesc),
			WeaponItemIds=(76)
		)};

	Drops(77)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=SwordofWar_Variant_03, bVisibleInSelectorIfUnowned=true, MicroTxID=102068, GearStoreDescriptionID=WhiteKnightSwordDesc),
			WeaponItemIds=(77)
		)};

	Drops(78)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Mace_Variant_01, bVisibleInSelectorIfUnowned=true, MicroTxID=102069, GearStoreDescriptionID=WhiteKnightMaceDesc),
			WeaponItemIds=(78)
		)};

	Drops(79)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Warhammer_Variant_01, bVisibleInSelectorIfUnowned=true, MicroTxID=102070, GearStoreDescriptionID=YeOldSkullCrackerDesc),
			WeaponItemIds=(79)
		)};

	Drops(80)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Peasant_Fork, bVisibleInSelectorIfUnowned=true, GroupHexID="1700000003F72EC", GearStoreDescriptionID=PeasantRevoltDesc, MicroTxID=101038),
			WeaponItemIds=(80)
		)};

	Drops(81)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Peasant_Cudgel, bVisibleInSelectorIfUnowned=true, GroupHexID="1700000003F72EC", GearStoreDescriptionID=PeasantRevoltDesc, MicroTxID=101038),
			WeaponItemIds=(81)
		)};

	Drops(82)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Peasant_Broadsword, bVisibleInSelectorIfUnowned=true, GroupHexID="1700000003F72EC", GearStoreDescriptionID=PeasantRevoltDesc, MicroTxID=101038),
			WeaponItemIds=(82)
		)};

	Drops(83)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Peasant_DoubleAxe, bVisibleInSelectorIfUnowned=true, GroupHexID="1700000003F72EC", GearStoreDescriptionID=PeasantRevoltDesc, MicroTxID=101069),
			WeaponItemIds=(83)
		)};

	Drops(84)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=HolyWaterSprinkler_Variant_02, bVisibleInSelectorIfUnowned=true, MicroTxID=102072, GearStoreDescriptionID=BloodSprinklerDesc),
			WeaponItemIds=(84)
		)};

	Drops(85)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Billhook_Variant_03, bVisibleInSelectorIfUnowned=true, MicroTxID=102077, GearStoreDescriptionID=ReaperBillHookDesc),
			WeaponItemIds=(85)
		)};

	Drops(86)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Claymore_Variant_03, bVisibleInSelectorIfUnowned=true, MicroTxID=102086, GearStoreDescriptionID=HighlanderSet, bPartOfBundle=true, BundleNameID=HighlanderSet),
			WeaponItemIds=(86)
		)};

	Drops(87)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Poleaxe_Variant_03, bVisibleInSelectorIfUnowned=true, MicroTxID=102080, GearStoreDescriptionID=TulipPoleaxeDesc),
			WeaponItemIds=(87)
		)};

	Drops(88)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Mace_Variant_02, bVisibleInSelectorIfUnowned=true, MicroTxID=102079, GearStoreDescriptionID=RobberBaronSet, bPartOfBundle=true, BundleNameID=RobberBaronSet),
			WeaponItemIds=(88)
		)};

	Drops(89)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Warbow_Variant_01, bVisibleInSelectorIfUnowned=true, MicroTxID=102076, GearStoreDescriptionID=WilfulMurderWarbowDesc),
			WeaponItemIds=(89)
		)};
	//Drops(90)={(
	//		bInfoRetrieved=true,
	//		GearData=(GearNameID=Buckler_Variant_01, bVisibleInSelectorIfUnowned=true, GearStoreDescriptionID=VicomteSet, MicroTxID=102085, bPartOfBundle=true),
	//		WeaponItemIds=(90)
	//	)};

	Drops(91)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Saber_Variant_01, bVisibleInSelectorIfUnowned=true, GearStoreDescriptionID=OttomanSaberDesc, MicroTxID=102084),
			WeaponItemIds=(91)
		)};

	Drops(92)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Fork_Variant_01, bVisibleInSelectorIfUnowned=true, GearStoreDescriptionID=RoyalForkDesc, MicroTxID=102074),
			WeaponItemIds=(92)
		)};

	Drops(93)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=HeavyCrossbow_Variant_01, bVisibleInSelectorIfUnowned=true, GearStoreDescriptionID=OldBaronsSunbowDesc, MicroTxID=102081),
			WeaponItemIds=(93)
		)};

	Drops(94)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Halberd_Variant_04, bVisibleInSelectorIfUnowned=true, GearStoreDescriptionID=ButchersSet, MicroTxID=102087, bPartOfBundle=true),
			WeaponItemIds=(94)
		)};

	Drops(95)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Saber_Variant_02, bVisibleInSelectorIfUnowned=true, GearStoreDescriptionID=VicomteSet, MicroTxID=102085, bPartOfBundle=true),
			WeaponItemIds=(95, 90)
		)};

	Drops(96)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Maul_Variant_06, bVisibleInSelectorIfUnowned=true, GearStoreDescriptionID=GothicMaulDesc, MicroTxID=102083),
			WeaponItemIds=(96)
		)};

	Drops(97)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Buckler_Variant_02, bVisibleInSelectorIfUnowned=true, GearStoreDescriptionID=MercinaryRoundsheildDesc, MicroTxID=102078),
			WeaponItemIds=(97)
		)};
	
	Drops(98)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Zweihander_Variant_03, bVisibleInSelectorIfUnowned=true, GearStoreDescriptionID=MontanteDesc, MicroTxID=102073),
			WeaponItemIds=(98)
		)};

	Drops(99)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=SwordOfWar_Variant_04, bVisibleInSelectorIfUnowned=true, GearStoreDescriptionID=DurerSwordDesc, MicroTxID=102082),
			WeaponItemIds=(99)
		)};	

	Drops(101)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=HeavyJavelin_Variant_01, GearStoreDescriptionID=OilystoolFreeWeapons, GroupHexID="1700000003F72EC", bVisibleInSelectorIfUnowned=true),
			WeaponItemIds=(101)
		)};

	Drops(102)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=QuarterStaff_Variant_03, GearStoreDescriptionID=OilystoolFreeWeapons, GroupHexID="1700000003F72EC", bVisibleInSelectorIfUnowned=true),
			WeaponItemIds=(102)
		)};

	Drops(103)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Messer_Variant_06, GearStoreDescriptionID=OilystoolFreeWeapons, GroupHexID="1700000003F72EC", bVisibleInSelectorIfUnowned=true),
			WeaponItemIds=(103)
		)};
	Drops(104)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Greatsword_Variant_03, GearStoreDescriptionID=OilystoolFreeWeapons, GroupHexID="1700000003F72EC", bVisibleInSelectorIfUnowned=true),
			WeaponItemIds=(104)
		)};
	Drops(105)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Longsword_Variant_07, GearStoreDescriptionID=Longsword_Variant_07Desc, bVisibleInSelectorIfUnowned=true, MicroTxID=102109),
			WeaponItemIds=(105)
		)};
	Drops(106)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Messer_Variant_07, GearStoreDescriptionID=Messer_Variant_07Desc, bVisibleInSelectorIfUnowned=true, MicroTxID=102111),
			WeaponItemIds=(106)
		)};
	Drops(107)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=SwordOfWar_Variant_05, GearStoreDescriptionID=SwordOfWar_Variant_05Desc, bVisibleInSelectorIfUnowned=true, MicroTxID=102095),
			WeaponItemIds=(107)
		)};
	Drops(108)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=SwordOfWar_Variant_06, GearStoreDescriptionID=SwordOfWar_Variant_06Desc, bVisibleInSelectorIfUnowned=true, MicroTxID=102103),
			WeaponItemIds=(108)
		)};
	Drops(109)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=DaneAxe_Variant_01, GearStoreDescriptionID=DaneAxe_Variant_01Desc, bVisibleInSelectorIfUnowned=true, MicroTxID=102106),
			WeaponItemIds=(109)
		)};
	Drops(110)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Broadsword_Variant_07, GearStoreDescriptionID=Broadsword_Variant_07Desc, bVisibleInSelectorIfUnowned=true, MicroTxID=102097),
			WeaponItemIds=(110)
		)};
	Drops(111)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Doubleaxe_Variant_02, GearStoreDescriptionID=Doubleaxe_Variant_02Desc, bVisibleInSelectorIfUnowned=true, MicroTxID=102094),
			WeaponItemIds=(111)
		)};
	Drops(112)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Poleaxe_Variant_04, GearStoreDescriptionID=Poleaxe_Variant_03Desc, bVisibleInSelectorIfUnowned=true, MicroTxID=102093),
			WeaponItemIds=(112)
		)};
	Drops(113)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Greatsword_Variant_04, GearStoreDescriptionID=Greatsword_Variant_04Desc, bVisibleInSelectorIfUnowned=true, MicroTxID=102091),
			WeaponItemIds=(113)
		)};
	Drops(114)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Greatsword_Variant_05, GearStoreDescriptionID=Greatsword_Variant_05Desc, bVisibleInSelectorIfUnowned=true, MicroTxID=102092),
			WeaponItemIds=(114)
		)};
	Drops(115)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Zweihander_Variant_04, GearStoreDescriptionID=Zweihander_Variant_04Desc, bVisibleInSelectorIfUnowned=true, MicroTxID=102090),
			WeaponItemIds=(115)
		)};
	Drops(116)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Shortsword_Variant_02, GearStoreDescriptionID=Shortsword_Variant_02Desc, bVisibleInSelectorIfUnowned=true, MicroTxID=102105),
			WeaponItemIds=(116)
		)};
	Drops(117)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=ThrustingDagger_Variant_03, GearStoreDescriptionID=ThrustingDagger_Variant_03Desc, bVisibleInSelectorIfUnowned=true, MicroTxID=102104),
			WeaponItemIds=(117)
		)};
	Drops(118)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Polehammer_Variant_01, GearStoreDescriptionID=Polehammer_Variant_01Desc, bVisibleInSelectorIfUnowned=true, MicroTxID=102089),
			WeaponItemIds=(118)
		)};
	Drops(119)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Polehammer_Variant_02, GearStoreDescriptionID=Polehammer_Variant_02Desc, bVisibleInSelectorIfUnowned=true, MicroTxID=102100),
			WeaponItemIds=(119)
		)};
	Drops(120)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Brandistock_Variant_03, GearStoreDescriptionID=Brandistock_Variant_03Desc, bVisibleInSelectorIfUnowned=true, MicroTxID=102098),
			WeaponItemIds=(120)
		)};
	Drops(121)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Fork_Variant_03, GearStoreDescriptionID=Fork_Variant_03Desc, bVisibleInSelectorIfUnowned=true, MicroTxID=102099),
			WeaponItemIds=(121)
		)};
	Drops(122)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=LightCrossbow_Variant_01, GearStoreDescriptionID=LightCrossbow_Variant_01Desc, bVisibleInSelectorIfUnowned=true, MicroTxID=102088),
			WeaponItemIds=(122)
		)};
	Drops(123)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=ThrowingAxe_Variant_02, GearStoreDescriptionID=ThrowingAxe_Variant_02Desc, bVisibleInSelectorIfUnowned=true, MicroTxID=102107),
			WeaponItemIds=(123)
		)};
	Drops(124)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Saber_Variant_03, bVisibleInSelectorIfUnowned=true, GroupHexID="1700000017DF6E0", GearStoreDescriptionID=VYPRESS),
			WeaponItemIds=(124)
		)};
	Drops(125)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=HuntingKnife_Variant_01, bVisibleInSelectorIfUnowned=true, GroupHexID="1700000003F72EC", GearStoreDescriptionID=PeasantRevoltDesc, MicroTxID=101038),
			WeaponItemIds=(125)
		)};
	Drops(126)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=ShortSpear_Variant_02, bVisibleInSelectorIfUnowned=true, GroupHexID="1700000003F72EC", GearStoreDescriptionID=PeasantRevoltDesc, MicroTxID=101038),
			WeaponItemIds=(126)
		)};
	Drops(127)={(
			bInfoRetrieved=true,
			GearData=(GearNameID=Buckler_Variant_03, bVisibleInSelectorIfUnowned=true, GroupHexID="1700000003F72EC", GearStoreDescriptionID=PeasantRevoltDesc, MicroTxID=101038),
			WeaponItemIds=(127)
		)};
		
		
	Weapons(0)=()
	Weapons(1)={(
			WeaponType=EWEP_Bardiche,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Bardiche_Variant,
			bUseDefaultParameters=true
		)};

	//GMace
	Weapons(2)={(
			WeaponType=EWEP_GrandMace,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=GrandMace_Vairant,
			bUseDefaultParameters=true
		)};

	//Jav
	Weapons(3)={(
			WeaponType=EWEP_Javelin,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Javelin_Variant,
			bUseDefaultParameters=true
		)};
	
	//Maul
	Weapons(4)={(
			WeaponType=EWEP_Maul,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Maul_Variant,
			bUseDefaultParameters=true
		)};

	//Messer
	Weapons(5)={(
			WeaponType=EWEP_Messer,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Messer_Vairant,
			bUseDefaultParameters=true
		)};

	//Norse
	Weapons(6)={(
			WeaponType=EWEP_Norse,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=NorseSword_Variant,
			bUseDefaultParameters=true
		)};

	//Spear
	Weapons(7)={(
			WeaponType=EWEP_Spear,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Spear_Variant,
			bUseDefaultParameters=true
		)};
		
	//Falchion
	Weapons(8)={(
			WeaponType=EWEP_Falchion,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Falchion_Variant,
			bUseDefaultParameters=true
		)};
		
	//xbow
	Weapons(9)={(
			WeaponType=EWEP_Crossbow,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Crossbow_Variant,
			bUseDefaultParameters=true
		)};
		
	//Longsword
	Weapons(10)={(
			WeaponType=EWEP_Longsword,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Longsword_Variant,
			bUseDefaultParameters=true
		)};
		
	//Messer2
	Weapons(11)={(
			WeaponType=EWEP_Messer,
			SkinIndex=2,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Messer_Variant2,
			bUseDefaultParameters=true
		)};
		
	//Broadsword
	Weapons(12)={(
			WeaponType=EWEP_Broadsword,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Broadsword_Variant,
			bUseDefaultParameters=true
		)};

	//Spear
	Weapons(13)={(
			WeaponType=EWEP_Spear,
			SkinIndex=2,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Spear_Variant2,
			bUseDefaultParameters=true
		)};			

	//Shortbow
	Weapons(14)={(
			WeaponType=EWEP_Shortbow,
			SkinIndex=1,
			AllowedTeams=(EFAC_Agatha, EFAC_MASON),
			ItemName=Shortbow_Variant,
			bUseDefaultParameters=true
		)};			

	//Brandistock
	Weapons(15)={(
			WeaponType=EWEP_Brandistock,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Brandistock_Variant,
			bUseDefaultParameters=true
		)};			

	//Bearded
	Weapons(16)={(
			WeaponType=EWEP_Bearded,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Bearded_Variant,
			bUseDefaultParameters=true
		)};		
	//Broadsword2
	Weapons(17)={(
			WeaponType=EWEP_Broadsword,
			SkinIndex=2,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Broadsword_Variant_02,
			bUseDefaultParameters=true
		)};		
	//Broadsword3
	Weapons(18)={(
			WeaponType=EWEP_Broadsword,
			SkinIndex=3,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Broadsword_Variant_03,
			bUseDefaultParameters=true
		)};		
	//Greatsword
	Weapons(19)={(
			WeaponType=EWEP_Greatsword,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Greatsword_Variant_01,
			bUseDefaultParameters=true
		)};		
	//Bearded2
	Weapons(20)={(
			WeaponType=EWEP_Bearded,
			SkinIndex=2,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Bearded_Variant_02,
			bUseDefaultParameters=true
		)};		
	//Shortspear
	Weapons(21)={(
			WeaponType=EWEP_ShortSpear,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=ShortSpear_Variant_01,
			bUseDefaultParameters=true
		)};	
	//Spear
	Weapons(22)={(
			WeaponType=EWEP_Spear,
			SkinIndex=3,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Spear_Variant_03,
			bUseDefaultParameters=true
		)};			
	//Norse2
	Weapons(23)={(
			WeaponType=EWEP_Norse,
			SkinIndex=2,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=NorseSword_Variant2,
			bUseDefaultParameters=true
		)};		
	//Longsword2
	Weapons(24)={(
			WeaponType=EWEP_Longsword,
			SkinIndex=2,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Longsword_Variant_02,
			bUseDefaultParameters=true
		)};
	//Longsword3
	Weapons(25)={(
			WeaponType=EWEP_Longsword,
			SkinIndex=3,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Longsword_Variant_03,
			bUseDefaultParameters=true
		)};
	//depth morningstar
	Weapons(26)={(
			WeaponType=EWEP_MorningStar,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Depth_MorningStar,
			bUseDefaultParameters=true
		)};	
	//thrusting dagger - rondel dagger
	Weapons(27)={(
			WeaponType=EWEP_ThrustDagger,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=ThrustingDagger_Variant_01,
			bUseDefaultParameters=true
		)};	
	//short sword - seax
	Weapons(28)={(
			WeaponType=EWEP_Dagesse,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Shortsword_Variant_01,
			bUseDefaultParameters=true
		)};	
	//pole axe - leo set
	Weapons(29)={(
			WeaponType=EWEP_PoleArm,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Poleaxe_Variant_01,
			bUseDefaultParameters=true
		)};		
	//double axe - Hengest and Horsa
	Weapons(30)={(
			WeaponType=EWEP_DoubleAxe,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Doubleaxe_Variant_01,
			bUseDefaultParameters=true
		)};
	//sword of war - Final Guard Set
	Weapons(31)={(
			WeaponType=EWEP_SwordOfWar,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=SwordofWar_Variant_01,
			bUseDefaultParameters=true
		)};
	//broadsword - court armour Set
	Weapons(32)={(
			WeaponType=EWEP_Broadsword,
			SkinIndex=4,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Broadsword_Variant_04,
			bUseDefaultParameters=true
		)};
	//greatsword - Berzerker set
	Weapons(33)={(
			WeaponType=EWEP_Greatsword,
			SkinIndex=2,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Greatsword_Variant_02,
			bUseDefaultParameters=true
		)};
	//Spear - awlpike
	Weapons(34)={(
			WeaponType=EWEP_Spear,
			SkinIndex=4,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Spear_Variant_04,
			bUseDefaultParameters=true
		)};		
	//Zweihander - Flammenschwert
	Weapons(35)={(
			WeaponType=EWEP_Zweihander,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Zweihander_Variant_01,
			bUseDefaultParameters=true
		)};
	//heavy flail - Rat flail
	Weapons(36)={(
			WeaponType=EWEP_HFlail,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=HFlail_Variant_01,
			bUseDefaultParameters=true
		)};
	//maul - The Tenderizer
	Weapons(37)={(
			WeaponType=EWEP_Maul,
			SkinIndex=2,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Maul_Variant_02,
			bUseDefaultParameters=true
		)};
	//messer - Infidels Bane
	Weapons(38)={(
			WeaponType=EWEP_Messer,
			SkinIndex=3,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Messer_Variant_03,
			bUseDefaultParameters=true
		)};	
	//messer - chaos set
	Weapons(39)={(
			WeaponType=EWEP_Messer,
			SkinIndex=4,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Messer_Variant_04,
			bUseDefaultParameters=true
		)};
	//holy water sprinkler - WingedWraith
	Weapons(40)={(
			WeaponType=EWEP_HolyWaterSprinkler,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=HolyWater_Variant_01,
			bUseDefaultParameters=true
		)};
	//norse sword - Blade Brothers Sun Sword
	Weapons(41)={(
			WeaponType=EWEP_Norse,
			SkinIndex=3,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=NorseSword_Variant_03,
			bUseDefaultParameters=true
		)};
	//billhook - Shark
	Weapons(42)={(
			WeaponType=EWEP_Bill,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Billhook_Variant_01,
			bUseDefaultParameters=true
		)};
	//halberd - Kraken set
	Weapons(43)={(
			WeaponType=EWEP_Halberd,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Halberd_Variant_01,
			bUseDefaultParameters=true
		)};
	//Claymore - Fior Charaid
	Weapons(44)={(
			WeaponType=EWEP_Claymore,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Claymore_Variant_01,
			bUseDefaultParameters=true
		)};
	//Morning Star - Headbanger
	Weapons(45)={(
			WeaponType=EWEP_MorningStar,
			SkinIndex=2,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=MorningStar_Variant_02,
			bUseDefaultParameters=true
		)};
	//War Axe - Sunder
	Weapons(46)={(
			WeaponType=EWEP_WarAxe,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=WarAxe_Variant_01,
			bUseDefaultParameters=true
		)};
	////War Axe - Sunder
	//Weapons(47)={(
	//		WeaponType=EWEP_WarAxe,
	//		SkinIndex=1,
	//		AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
	//		ItemName=WarAxe_Variant_01,
	//		bUseDefaultParameters=true
	//	)};
	//halberd - Swiss Royal
	Weapons(47)={(
			WeaponType=EWEP_Halberd,
			SkinIndex=2,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Halberd_Variant_02,
			bUseDefaultParameters=true
		)};
	//Longbow - Heartpiercer
	Weapons(48)={(
			WeaponType=EWEP_Longbow,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Longbow_Variant_01,
			bUseDefaultParameters=true
		)};
	//Poleaxe - Warmonger Set 1
	Weapons(49)={(
			WeaponType=EWEP_PoleArm,
			SkinIndex=2,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Poleaxe_Variant_02,
			bUseDefaultParameters=true
		)};
	//Longsword - Type XII
	Weapons(50)={(
			WeaponType=EWEP_Longsword,
			SkinIndex=4,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Longsword_Variant_04,
			bUseDefaultParameters=true
		)};
	//Messer - Warmonger Set 2
	Weapons(51)={(
			WeaponType=EWEP_Messer,
			SkinIndex=5,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Messer_Variant_05,
			bUseDefaultParameters=true
		)};
	//Grand Mace - Wrecker Set
	Weapons(52)={(
			WeaponType=EWEP_GrandMace,
			SkinIndex=2,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=GrandMace_Variant_03,
			bUseDefaultParameters=true
		)};
	//Thrusting Dagger - Black Orchid
	Weapons(53)={(
			WeaponType=EWEP_ThrustDagger,
			SkinIndex=2,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=ThrustingDagger_Variant_02,
			bUseDefaultParameters=true
		)};
	//Norse Sword - Chieftain's Spatha
	Weapons(54)={(
			WeaponType=EWEP_Norse,
			SkinIndex=4,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=NorseSword_Variant_04,
			bUseDefaultParameters=true
		)};
	//Halberd - Classic XIV-XV century Voulge
	Weapons(55)={(
			WeaponType=EWEP_Halberd,
			SkinIndex=3,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Halberd_Variant_03,
			bUseDefaultParameters=true
		)};
	//Sword of War - Winter Soldier
	Weapons(56)={(
			WeaponType=EWEP_SwordOfWar,
			SkinIndex=2,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=SwordofWar_Variant_02,
			bUseDefaultParameters=true
		)};
	//Maul - Guilty Gavel
	Weapons(57)={(
			WeaponType=EWEP_Maul,
			SkinIndex=3,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Maul_Variant_03,
			bUseDefaultParameters=true
		)};
	//Bardiche - Reiver Set 1
	Weapons(58)={(
			WeaponType=EWEP_Bardiche,
			SkinIndex=2,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Bardiche_Variant_02,
			bUseDefaultParameters=true
		)};
	//War Axe - Reiver Set 2
	Weapons(59)={(
			WeaponType=EWEP_WarAxe,
			SkinIndex=2,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=WarAxe_Variant_02,
			bUseDefaultParameters=true
		)};
	//Javelin - Royal Squad
	Weapons(60)={(
			WeaponType=EWEP_Javelin,
			SkinIndex=2,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Javelin_Variant_02,
			bUseDefaultParameters=true
		)};
	//Cudgel - Skullcrusher
	Weapons(61)={(
			WeaponType=EWEP_Cudgel,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Cudgel_Variant_01,
			bUseDefaultParameters=true
		)};
	//Throwing Axe - Reiver set agatha
	Weapons(62)={(
			WeaponType=EWEP_ThrownAxe,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=ThrowingAxe_Variant_01_Agatha,
			bUseDefaultParameters=true
		)};
	//Throwing knife - KF2 promo
	Weapons(63)={(
			WeaponType=EWEP_ThrownKnife,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=KF2ThrowingKnife_Variant_01,
			bUseDefaultParameters=true
		)};
	//Quarter staff- KF2 promo
	Weapons(64)={(
			WeaponType=EWEP_QStaff,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=KF2QuarterStaff_Variant_01,
			bUseDefaultParameters=true
		)};
	//Longsword- KF2 promo
	Weapons(65)={(
			WeaponType=EWEP_Longsword,
			SkinIndex=5,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=KF2Longsword_Variant_01,
			bUseDefaultParameters=true
		)};
	//Maul- KF2 promo
	Weapons(66)={(
			WeaponType=EWEP_Maul,
			SkinIndex=4,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=KF2Maul_Variant_01,
			bUseDefaultParameters=true
		)};
	//Bearded axe - bear axe
	Weapons(67)={(
			WeaponType=EWEP_Bearded,
			SkinIndex=3,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Bearded_Variant_03,
			bUseDefaultParameters=true
		)};
	//War axe - Campaigner
	Weapons(68)={(
			WeaponType=EWEP_WarAxe,
			SkinIndex=3,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=WarAxe_Variant_03,
			bUseDefaultParameters=true
		)};
	//broadsword - ice breaker
	Weapons(69)={(
			WeaponType=EWEP_Broadsword,
			SkinIndex=5,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Broadsword_Variant_05,
			bUseDefaultParameters=true
		)};
	//grand mace - pathmaker
	Weapons(70)={(
			WeaponType=EWEP_GrandMace,
			SkinIndex=3,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Grandmace_Variant_04,
			bUseDefaultParameters=true
		)};
	//zweihander - serpent
	Weapons(71)={(
			WeaponType=EWEP_Zweihander,
			SkinIndex=2,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Zweihander_Variant_02,
			bUseDefaultParameters=true
		)};
	//brandistock - sharp claw
	Weapons(72)={(
			WeaponType=EWEP_Brandistock,
			SkinIndex=2,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Brandistock_Variant_02,
			bUseDefaultParameters=true
		)};
	//spear - fleur de lys
	Weapons(73)={(
			WeaponType=EWEP_Spear,
			SkinIndex=5,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Spear_Variant_05,
			bUseDefaultParameters=true
		)};
	//maul - spiked maul
	Weapons(74)={(
			WeaponType=EWEP_Maul,
			SkinIndex=5,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Maul_Variant_05,
			bUseDefaultParameters=true
		)};
	//longsword - sword of dracul
	Weapons(75)={(
			WeaponType=EWEP_Longsword,
			SkinIndex=6,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Longsword_Variant_06,
			bUseDefaultParameters=true
		)};
	//quarterstaff - thornstaff
	Weapons(76)={(
			WeaponType=EWEP_QStaff,
			SkinIndex=2,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=QuarterStaff_Variant_01,
			bUseDefaultParameters=true
		)};
	//sword of war - white knight sword of war
	Weapons(77)={(
			WeaponType=EWEP_SwordOfWar,
			SkinIndex=3,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=SwordofWar_Variant_03,
			bUseDefaultParameters=true
		)};
	//mace - white knight mace
	Weapons(78)={(
			WeaponType=EWEP_Mace,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Mace_Variant_01,
			bUseDefaultParameters=true
		)};
	//warhammer - white knight mace
	Weapons(79)={(
			WeaponType=EWEP_WarHammer,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Warhammer_Variant_01,
			bUseDefaultParameters=true
		)};
	//fork - peasant's revolt pitch fork
	Weapons(80)={(
			WeaponType=EWEP_Fork,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Peasant_Fork,
			bUseDefaultParameters=true
		)};
	//cudgel - peasant's revolt cudgel
	Weapons(81)={(
			WeaponType=EWEP_Cudgel,
			SkinIndex=2,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Peasant_Cudgel,
			bUseDefaultParameters=true
		)};
	//broadsword - peasant's revolt broadsword
	Weapons(82)={(
			WeaponType=EWEP_Broadsword,
			SkinIndex=6,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Peasant_Broadsword,
			bUseDefaultParameters=true
		)};
	//double axe - peasant's revolt pick axe
	Weapons(83)={(
			WeaponType=EWEP_DoubleAxe,
			SkinIndex=2,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Peasant_DoubleAxe,
			bUseDefaultParameters=true
		)};
	//holy water sprinkler - Blood Sprinkler
	Weapons(84)={(
			WeaponType=EWEP_HolyWaterSprinkler,
			SkinIndex=2,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=HolyWaterSprinkler_Variant_02,
			bUseDefaultParameters=true
		)};
	//billhook - reaper
	Weapons(85)={(
			WeaponType=EWEP_Bill,
			SkinIndex=2,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Billhook_Variant_02,
			bUseDefaultParameters=true
		)};
	//claymore - highlander claymore
	Weapons(86)={(
			WeaponType=EWEP_Claymore,
			SkinIndex=2,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Claymore_Variant_02,
			bUseDefaultParameters=true
		)};
	//poleaxe - tulip
	Weapons(87)={(
			WeaponType=EWEP_PoleArm,
			SkinIndex=3,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Poleaxe_Variant_03,
			bUseDefaultParameters=true
		)};
	//mace - Robber Baron mace
	Weapons(88)={(
			WeaponType=EWEP_Mace,
			SkinIndex=2,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Mace_Variant_02,
			bUseDefaultParameters=true
		)};
	//warbow - Wilful Murder Warbow
	Weapons(89)={(
			WeaponType=EWEP_Warbow,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Warbow_Variant_01,
			bUseDefaultParameters=true
		)};
	//buckler - Vicomte buckler
	Weapons(90)={(
			WeaponType=EWEP_Buckler,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Buckler_Variant_01,
			bUseDefaultParameters=true
		)};
	//saber - Ottoman Saber
	Weapons(91)={(
			WeaponType=EWEP_Saber,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Saber_Variant_01,
			bUseDefaultParameters=true
		)};
	//Fork - Royal Fork
	Weapons(92)={(
			WeaponType=EWEP_Fork,
			SkinIndex=2,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Fork_Variant_01,
			bUseDefaultParameters=true
		)};
	//heavy crossbow - old barons sunbow
	Weapons(93)={(
			WeaponType=EWEP_HeavyCrossbow,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=HeavyCrossbow_Variant_01,
			bUseDefaultParameters=true
		)};
	//halberd - butcher's halberd
	Weapons(94)={(
			WeaponType=EWEP_Halberd,
			SkinIndex=4,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Halberd_Variant_04,
			bUseDefaultParameters=true
		)};
	//saber - vicomte saber
	Weapons(95)={(
			WeaponType=EWEP_Saber,
			SkinIndex=2,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Saber_Variant_02,
			bUseDefaultParameters=true
		)};
	//maul - gothic maul
	Weapons(96)={(
			WeaponType=EWEP_Maul,
			SkinIndex=6,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Maul_Variant_06,
			bUseDefaultParameters=true
		)};
	//buckler - mercenary roundshield
	Weapons(97)={(
			WeaponType=EWEP_Buckler,
			SkinIndex=2,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Buckler_Variant_02,
			bUseDefaultParameters=true
		)};
	//zweihander - Montante
	Weapons(98)={(
			WeaponType=EWEP_Zweihander,
			SkinIndex=3,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Zweihander_Variant_03,
			bUseDefaultParameters=true
		)};
	//sword of war - durer sword
	Weapons(99)={(
			WeaponType=EWEP_SwordOfWar,
			SkinIndex=4,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=SwordOfWar_Variant_04,
			bUseDefaultParameters=true
		)};
	//Throwing Axe - Reiver set mason
	Weapons(100)={(
			WeaponType=EWEP_ThrownAxe,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=ThrowingAxe_Variant_01_Mason,
			bUseDefaultParameters=true
		)};	
	//Jav - Oilystool pack - Myrmidon
	Weapons(101)={(
			WeaponType=EWEP_HeavyJavelin,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Javelin_Variant_01,
			bUseDefaultParameters=true
		)};
	//Quarter staff - Oilystool pack - The Milanese
	Weapons(102)={(
			WeaponType=EWEP_QStaff,
			SkinIndex=3,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=QuarterStaff_Variant_03,
			bUseDefaultParameters=true
		)};
	//Messer - Oilystool pack - Oily Messer
	Weapons(103)={(
			WeaponType=EWEP_Messer,
			SkinIndex=6,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Messer_Variant_06,
			bUseDefaultParameters=true
		)};
	//Greatsword - Oilystool pack - Cold Spectre
	Weapons(104)={(
			WeaponType=EWEP_Greatsword,
			SkinIndex=3,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Greatsword_Variant_03,
			bUseDefaultParameters=true
		)};		
	Weapons(105)={(
			WeaponType=EWEP_Longsword,
			SkinIndex=7,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Longsword_Variant_07,
			bUseDefaultParameters=true
		)};
	Weapons(106)={(
			WeaponType=EWEP_Messer,
			SkinIndex=7,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Messer_Variant_07,
			bUseDefaultParameters=true
		)};
	Weapons(107)={(
			WeaponType=EWEP_SwordOfWar,
			SkinIndex=5,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=SwordOfWar_Variant_05,
			bUseDefaultParameters=true
		)};		
	Weapons(108)={(
			WeaponType=EWEP_SwordOfWar,
			SkinIndex=6,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=SwordOfWar_Variant_06,
			bUseDefaultParameters=true
		)};		
	Weapons(109)={(
			WeaponType=EWEP_Dane,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=DaneAxe_Variant_01,
			bUseDefaultParameters=true
		)};		
	Weapons(110)={(
			WeaponType=EWEP_Broadsword,
			SkinIndex=7,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Broadsword_Variant_07,
			bUseDefaultParameters=true
		)};		
	Weapons(111)={(
			WeaponType=EWEP_DoubleAxe,
			SkinIndex=3,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Doubleaxe_Variant_02,
			bUseDefaultParameters=true
		)};		
	Weapons(112)={(
			WeaponType=EWEP_PoleArm,
			SkinIndex=4,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Poleaxe_Variant_04,
			bUseDefaultParameters=true
		)};		
	Weapons(113)={(
			WeaponType=EWEP_Greatsword,
			SkinIndex=4,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Greatsword_Variant_04,
			bUseDefaultParameters=true
		)};		
	Weapons(114)={(
			WeaponType=EWEP_Greatsword,
			SkinIndex=5,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Greatsword_Variant_05,
			bUseDefaultParameters=true
		)};		
	Weapons(115)={(
			WeaponType=EWEP_Zweihander,
			SkinIndex=4,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Zweihander_Variant_04,
			bUseDefaultParameters=true
		)};		
	Weapons(116)={(
			WeaponType=EWEP_Dagesse,
			SkinIndex=2,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Shortsword_Variant_02,
			bUseDefaultParameters=true
		)};		
	Weapons(117)={(
			WeaponType=EWEP_ThrustDagger,
			SkinIndex=3,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=ThrustingDagger_Variant_03,
			bUseDefaultParameters=true
		)};		
	Weapons(118)={(
			WeaponType=EWEP_PoleHammer,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Polehammer_Variant_01,
			bUseDefaultParameters=true
		)};		
	Weapons(119)={(
			WeaponType=EWEP_PoleHammer,
			SkinIndex=2,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Polehammer_Variant_02,
			bUseDefaultParameters=true
		)};		
	Weapons(120)={(
			WeaponType=EWEP_Brandistock,
			SkinIndex=3,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Brandistock_Variant_03,
			bUseDefaultParameters=true
		)};		
	Weapons(121)={(
			WeaponType=EWEP_Fork,
			SkinIndex=3,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Fork_Variant_03,
			bUseDefaultParameters=true
		)};		
	Weapons(122)={(
			WeaponType=EWEP_LightCrossbow,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=LightCrossbow_Variant_01,
			bUseDefaultParameters=true
		)};			
	Weapons(123)={(
			WeaponType=EWEP_ThrownAxe,
			SkinIndex=2,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=ThrowingAxe_Variant_02,
			bUseDefaultParameters=true
		)};	

	//saber - Vypress' Scimitar
	Weapons(124)={(
			WeaponType=EWEP_Saber,
			SkinIndex=3,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Saber_Variant_03,
			bUseDefaultParameters=true
		)};		
	Weapons(125)={(
			WeaponType=EWEP_HuntingKnife,
			SkinIndex=1,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=HuntingKnife_Variant_01,
			bUseDefaultParameters=true
		)};	
	Weapons(126)={(
			WeaponType=EWEP_ShortSpear,
			SkinIndex=2,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=ShortSpear_Variant_02,
			bUseDefaultParameters=true
		)};	
	Weapons(127)={(
			WeaponType=EWEP_Buckler,
			SkinIndex=3,
			AllowedTeams=(EFAC_AGATHA, EFAC_MASON),
			ItemName=Buckler_Variant_03,
			bUseDefaultParameters=true
		)};
}

