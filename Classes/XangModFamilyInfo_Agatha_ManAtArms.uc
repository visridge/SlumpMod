class XangModFamilyInfo_Agatha_ManAtArms extends XangModFamilyInfo_ManAtArms
	dependson(AOCPawn);

DefaultProperties
{
	FamilyID="Man-At-Arms"
	Faction="Agatha"
	FamilyFaction=EFAC_AGATHA
	// ParryBoxScale=(X=0.20,Y=0.17,Z=0.35)
    // ParryBoxTranslation=(X=10, Z=-28)

	NewPrimaryWeapons.empty;
	NewPrimaryWeapons(0)=(CWeapon=class'XangModWeapon_Broadsword')
	NewPrimaryWeapons(1)=(CWeapon=class'XangModWeapon_NorseSword')
	NewPrimaryWeapons(2)=(CWeapon=class'XangModWeapon_Falchion',CorrespondingDuelProp=EDUEL_FalchionUse)
	NewPrimaryWeapons(3)=(CWeapon=class'XangModWeapon_Hatchet',CorrespondingDuelProp=EDUEL_HatchetUse)
	NewPrimaryWeapons(4)=(CWeapon=class'XangModWeapon_WarAxe',CorrespondingDuelProp=EDUEL_WarAxeUse)
	NewPrimaryWeapons(5)=(CWeapon=class'XangModWeapon_Dane',CorrespondingDuelProp=EDUEL_DaneUse)
	NewPrimaryWeapons(6)=(CWeapon=class'XangModWeapon_Mace',CorrespondingDuelProp=EDUEL_MaceUse)
	NewPrimaryWeapons(7)=(CWeapon=class'XangModWeapon_MorningStar',CorrespondingDuelProp=EDUEL_MorningStarUse)
	NewPrimaryWeapons(8)=(CWeapon=class'XangModWeapon_HolyWaterSprinkler',CorrespondingDuelProp=EDUEL_HolyWaterSprinklerUse)
	NewPrimaryWeapons(9)=(CWeapon=class'XangModWeapon_QuarterStaff',CorrespondingDuelProp=EDUEL_QStaffUse)
	NewPrimaryWeapons(10)=(CWeapon=class'XangModWeapon_DualBucklers')
	NewPrimaryWeapons(11)=(CWeapon=class'XangModWeapon_Firebug')
	
	NewSecondaryWeapons.empty;
	NewSecondaryWeapons(0)=(CWeapon=class'XangModWeapon_Saber')
	NewSecondaryWeapons(1)=(CWeapon=class'XangModWeapon_Cudgel')
	NewSecondaryWeapons(2)=(CWeapon=class'XangModWeapon_Dagesse')

	NewTertiaryWeapons.empty;
	NewTertiaryWeapons(0)=(CWeapon=class'XangModWeapon_ThrowingKnife')
	NewTertiaryWeapons(1)=(CWeapon=class'XangModWeapon_ThrowingAxe')
	NewTertiaryWeapons(2)=(CWeapon=class'XangModWeapon_OilPot')
	NewTertiaryWeapons(3)=(CWeapon=class'XangModWeapon_Heater_Agatha',bEnabledDefault=true)
	bCanDodge=true

	ProjectileLocationModifiers(EHIT_Head) = 1.5
	ProjectileLocationModifiers(EHIT_Torso) = 1
	ProjectileLocationModifiers(EHIT_Arm) = 1
	CrossbowLocationModifiers(EHIT_Head) = 2
	CrossbowLocationModifiers(EHIT_Torso) = 1
	CrossbowLocationModifiers(EHIT_Arm) = 1
	
	// damage modifiers
	DamageResistances(EDMG_Swing) = 0.8
	DamageResistances(EDMG_Pierce) = 0.85
	DamageResistances(EDMG_Blunt) = 0.65

	LocationModifiers(EHIT_Head) = 1.125 // was inherited 1.25
	

	BACK_MODIFY=0.7

	AccelRate=600.0
	iDodgeCost=25
	MaxSprintSpeedTime=2.0
	// SprintTurnSpeed=999999

}
