class BangModFamilyInfo_Mason_Knight extends AOCFamilyInfo_Mason_Knight;

DefaultProperties
{
	ParryBoxScale=(X=0.18,Y=0.17,Z=0.35)
    ParryBoxTranslation=(X=10, Y=5, Z=-28)

	NewPrimaryWeapons.empty;
	NewPrimaryWeapons(0)=(CWeapon=class'BangModWeapon_DoubleAxe',CForceTertiary=(class'BangModWeapon_HuntingKnife', class'BangModWeapon_Kite_Agatha', class'BangModWeapon_TowerShield_Agatha'))
	NewPrimaryWeapons(1)=(CWeapon=class'BangModWeapon_PoleAxe',CForceTertiary=(class'BangModWeapon_HuntingKnife', class'BangModWeapon_Kite_Agatha', class'BangModWeapon_TowerShield_Agatha'))
	NewPrimaryWeapons(2)=(CWeapon=class'BangModWeapon_Bearded',CForceTertiary=(class'BangModWeapon_HuntingKnife', class'BangModWeapon_Kite_Agatha', class'BangModWeapon_TowerShield_Agatha'))
	NewPrimaryWeapons(3)=(CWeapon=class'BangModWeapon_WarHammer',CForceTertiary=(class'BangModWeapon_HuntingKnife', class'BangModWeapon_Kite_Agatha', class'BangModWeapon_TowerShield_Agatha'))
	NewPrimaryWeapons(4)=(CWeapon=class'BangModWeapon_Maul',CForceTertiary=(class'BangModWeapon_HuntingKnife', class'BangModWeapon_Kite_Agatha', class'BangModWeapon_TowerShield_Agatha'))
	NewPrimaryWeapons(5)=(CWeapon=class'BangModWeapon_GrandMace',CForceTertiary=(class'BangModWeapon_HuntingKnife', class'BangModWeapon_Kite_Agatha', class'BangModWeapon_TowerShield_Agatha'))
	NewPrimaryWeapons(6)=(CWeapon=class'BangModWeapon_Longsword',CForceTertiary=(class'BangModWeapon_HuntingKnife', class'BangModWeapon_Kite_Agatha', class'BangModWeapon_TowerShield_Agatha'))
	NewPrimaryWeapons(7)=(CWeapon=class'BangModWeapon_SwordOfWar',CForceTertiary=(class'BangModWeapon_HuntingKnife', class'BangModWeapon_Kite_Agatha', class'BangModWeapon_TowerShield_Agatha'))
	NewPrimaryWeapons(8)=(CWeapon=class'BangModWeapon_Messer',CForceTertiary=(class'BangModWeapon_HuntingKnife', class'BangModWeapon_Kite_Agatha', class'BangModWeapon_TowerShield_Agatha'))
	NewPrimaryWeapons(9)=(CWeapon=class'BangModWeapon_Flail',CForceTertiary=(class'BangModWeapon_Kite_Agatha', class'BangModWeapon_TowerShield_Agatha'))
	NewPrimaryWeapons(10)=(CWeapon=class'BangModWeapon_GrandHammer')


	NewSecondaryWeapons.empty;
	NewSecondaryWeapons(0)=(CWeapon=class'BangModWeapon_Mace')
	NewSecondaryWeapons(1)=(CWeapon=class'BangModWeapon_MorningStar')
	NewSecondaryWeapons(2)=(CWeapon=class'BangModWeapon_HolyWaterSprinkler')
	NewSecondaryWeapons(3)=(CWeapon=class'BangModWeapon_Saber')
	NewSecondaryWeapons(4)=(CWeapon=class'BangModWeapon_Falchion')
	NewSecondaryWeapons(6)=(CWeapon=class'BangModWeapon_WarAxe')
	NewSecondaryWeapons(7)=(CWeapon=class'BangModWeapon_Dane')
	NewSecondaryWeapons(8)=(CWeapon=class'BangModWeapon_Cudgel')

	NewTertiaryWeapons.empty;
	NewTertiaryWeapons(0)=(CWeapon=class'BangModWeapon_HuntingKnife',CorrespondingDuelProp=EDUEL_HuntingKnifeUse)
	NewTertiaryWeapons(1)=(CWeapon=class'BangModWeapon_Kite_Agatha',bEnabledDefault=true)
	NewTertiaryWeapons(2)=(CWeapon=class'BangModWeapon_TowerShield_Agatha',bEnabledDefault=true)

	
	DamageResistances(EDMG_Swing) = 0.4
	DamageResistances(EDMG_Pierce) = 0.5
	DamageResistances(EDMG_Blunt) = 0.61

	ProjectileLocationModifiers(EHIT_Head) = 1.5
	ProjectileLocationModifiers(EHIT_Torso) = 1
	ProjectileLocationModifiers(EHIT_Arm) = 1


	CrossbowLocationModifiers(EHIT_Head) = 2
	CrossbowLocationModifiers(EHIT_Torso) = 1.2
	CrossbowLocationModifiers(EHIT_Arm) = 1.2

	MaxSprintSpeedTime=4.0
	SprintModifier=1.7
	BACK_MODIFY=0.7
	// SprintTurnSpeed=999999

}
