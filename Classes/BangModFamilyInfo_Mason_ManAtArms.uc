class BangModFamilyInfo_Mason_ManAtArms extends AOCFamilyInfo_Mason_ManAtArms;

DefaultProperties
{
	ParryBoxScale=(X=0.11,Y=0.17,Z=0.35)
	ParryBoxTranslation=(X=10, Y=1, Z=-28)

	NewPrimaryWeapons.empty;
	NewPrimaryWeapons(0)=(CWeapon=class'BangModWeapon_Broadsword')
	NewPrimaryWeapons(1)=(CWeapon=class'BangModWeapon_NorseSword')
	NewPrimaryWeapons(2)=(CWeapon=class'BangModWeapon_Falchion',CorrespondingDuelProp=EDUEL_FalchionUse)
	NewPrimaryWeapons(3)=(CWeapon=class'BangModWeapon_Hatchet',CorrespondingDuelProp=EDUEL_HatchetUse)
	NewPrimaryWeapons(4)=(CWeapon=class'BangModWeapon_WarAxe',CorrespondingDuelProp=EDUEL_WarAxeUse)
	NewPrimaryWeapons(5)=(CWeapon=class'BangModWeapon_Dane',CorrespondingDuelProp=EDUEL_DaneUse)
	NewPrimaryWeapons(6)=(CWeapon=class'BangModWeapon_Mace',CorrespondingDuelProp=EDUEL_MaceUse)
	NewPrimaryWeapons(7)=(CWeapon=class'BangModWeapon_MorningStar',CorrespondingDuelProp=EDUEL_MorningStarUse)
	NewPrimaryWeapons(8)=(CWeapon=class'BangModWeapon_HolyWaterSprinkler',CorrespondingDuelProp=EDUEL_HolyWaterSprinklerUse)
	NewPrimaryWeapons(9)=(CWeapon=class'BangModWeapon_QuarterStaff',CorrespondingDuelProp=EDUEL_QStaffUse)
	
	
	NewSecondaryWeapons.empty;
	NewSecondaryWeapons(0)=(CWeapon=class'BangModWeapon_Saber')
	NewSecondaryWeapons(1)=(CWeapon=class'BangModWeapon_Cudgel')
	NewSecondaryWeapons(2)=(CWeapon=class'BangModWeapon_Dagesse')

	NewTertiaryWeapons.empty;
	NewTertiaryWeapons(0)=(CWeapon=class'BangModWeapon_ThrowingKnife')
	NewTertiaryWeapons(1)=(CWeapon=class'BangModWeapon_ThrowingAxe')
	NewTertiaryWeapons(2)=(CWeapon=class'BangModWeapon_OilPot')
	NewTertiaryWeapons(3)=(CWeapon=class'BangModWeapon_Heater_Mason',bEnabledDefault=true)

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
	

	BACK_MODIFY=0.7
	AccelRate=600.0
	iDodgeCost=25
	MaxSprintSpeedTime=2.0
	// SprintTurnSpeed=999999
}
