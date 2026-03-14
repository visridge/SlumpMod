class BangModFamilyInfo_Agatha_Vanguard extends AOCFamilyInfo_Agatha_Vanguard;

DefaultProperties
{
	ParryBoxScale=(X=0.18,Y=0.17,Z=0.35)
    ParryBoxTranslation=(X=10, Y=5, Z=-28)

	NewPrimaryWeapons.empty;
	NewPrimaryWeapons(0)=(CWeapon=class'BangModWeapon_Greatsword',CorrespondingDuelProp=EDUEL_GreatswordUse)
	NewPrimaryWeapons(1)=(CWeapon=class'BangModWeapon_Claymore',CorrespondingDuelProp=EDUEL_ClaymoreUse)
	NewPrimaryWeapons(2)=(CWeapon=class'BangModWeapon_Zweihander',CorrespondingDuelProp=EDUEL_ZweihanderUse)
	NewPrimaryWeapons(3)=(CWeapon=class'BangModWeapon_Bardiche',CorrespondingDuelProp=EDUEL_BardicheUse)
	NewPrimaryWeapons(4)=(CWeapon=class'BangModWeapon_Bill',CorrespondingDuelProp=EDUEL_BillUse)
	NewPrimaryWeapons(5)=(CWeapon=class'BangModWeapon_Halberd',CorrespondingDuelProp=EDUEL_HalberdUse)
	NewPrimaryWeapons(6)=(CWeapon=class'BangModWeapon_PoleHammer',CorrespondingDuelProp=EDUEL_PoleHammerUse)
	NewPrimaryWeapons(7)=(CWeapon=class'BangModWeapon_Fork',CorrespondingDuelProp=EDUEL_ForkUse)
	
	NewSecondaryWeapons.empty;

	NewSecondaryWeapons(0)=(CWeapon=class'BangModWeapon_Saber')
	NewSecondaryWeapons(1)=(CWeapon=class'BangModWeapon_Cudgel')
	NewSecondaryWeapons(3)=(CWeapon=class'BangModWeapon_WarAxe')
	NewSecondaryWeapons(4)=(CWeapon=class'BangModWeapon_Dane')
	NewSecondaryWeapons(5)=(CWeapon=class'BangModWeapon_Falchion')
	NewSecondaryWeapons(6)=(CWeapon=class'BangModWeapon_Dagesse')

	DamageResistances(EDMG_Swing) = 0.6
	DamageResistances(EDMG_Pierce) = 0.8
	DamageResistances(EDMG_Blunt) = 0.7


	NewTertiaryWeapons.empty;
	NewTertiaryWeapons(0)=(CWeapon=class'BangModWeapon_HuntingKnife',CorrespondingDuelProp=EDUEL_HuntingKnifeUse)


	bCanSprintAttack=false

	ProjectileLocationModifiers(EHIT_Head) = 1.5
	ProjectileLocationModifiers(EHIT_Torso) = 1
	ProjectileLocationModifiers(EHIT_Arm) = 1
	CrossbowLocationModifiers(EHIT_Head) = 2
	CrossbowLocationModifiers(EHIT_Torso) = 1
	CrossbowLocationModifiers(EHIT_Arm) = 1

	MaxSprintSpeedTime=3.5
	SprintModifier=1.64
	BACK_MODIFY=0.7
	// SprintTurnSpeed=999999

}
