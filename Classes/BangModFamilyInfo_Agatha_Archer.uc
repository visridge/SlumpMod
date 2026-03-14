class BangModFamilyInfo_Agatha_Archer extends AOCFamilyInfo_Agatha_Archer;

DefaultProperties
{
	ParryBoxScale=(X=0.18,Y=0.17,Z=0.35)
    ParryBoxTranslation=(X=10, Y=5, Z=-28)

	NewPrimaryWeapons.empty;
	NewPrimaryWeapons(0)=(CWeapon=class'BangModWeapon_Brandistock',CorrespondingDuelProp=EDUEL_BrandistockUse)
	NewPrimaryWeapons(1)=(CWeapon=class'BangModWeapon_Spear',CorrespondingDuelProp=EDUEL_SpearUse)
	NewPrimaryWeapons(2)=(CWeapon=class'BangModWeapon_Fork',CorrespondingDuelProp=EDUEL_ForkUse)
	NewPrimaryWeapons(3)=(CWeapon=class'BangModWeapon_Longbow',CForceTertiary=(class'AOCWeapon_ProjBodkin', class'AOCWeapon_ProjBroadhead'))
	NewPrimaryWeapons(4)=(CWeapon=class'BangModWeapon_Shortbow',CForceTertiary=(class'AOCWeapon_ProjBodkin', class'AOCWeapon_ProjBroadhead'))
	NewPrimaryWeapons(5)=(CWeapon=class'BangModWeapon_Warbow',CForceTertiary=(class'AOCWeapon_ProjBodkin', class'AOCWeapon_ProjBroadhead'))

	NewSecondaryWeapons.empty;
	NewSecondaryWeapons(0)=(CWeapon=class'BangModWeapon_Saber')
	NewSecondaryWeapons(1)=(CWeapon=class'BangModWeapon_Cudgel')
	NewSecondaryWeapons(2)=(CWeapon=class'BangModWeapon_Hatchet')
	NewSecondaryWeapons(3)=(CWeapon=class'BangModWeapon_Dagesse')

	NewTertiaryWeapons.empty;
	NewTertiaryWeapons(0)=(CWeapon=class'AOCWeapon_ProjBodkin'bEnabledDefault=false)
	NewTertiaryWeapons(1)=(CWeapon=class'AOCWeapon_ProjBroadhead'bEnabledDefault=false)


	ProjectileLocationModifiers(EHIT_Head) = 2.5
	ProjectileLocationModifiers(EHIT_Torso) = 2.0
	ProjectileLocationModifiers(EHIT_Arm) = 2.0
	ProjectileLocationModifiers(EHIT_Legs) = 1.75
	CrossbowLocationModifiers(EHIT_Head) = 2.5
	CrossbowLocationModifiers(EHIT_Torso) = 2.25
	CrossbowLocationModifiers(EHIT_Arm) = 2.25


	DamageResistances(EDMG_Swing) = 0.85
	DamageResistances(EDMG_Pierce) = 0.85
	DamageResistances(EDMG_Blunt) = 0.65

	AirSpeed=440.0
	WaterSpeed=220.0
	AirControl=0.35
	GroundSpeed=190.0
	AccelRate=500.0
	SprintAccelRate=100.0
	JumpZ=380.0
	SprintModifier=1.65
	SprintTime=10.0
	DodgeSpeed=400.0
	DodgeSpeedZ=200.0
	Health=100
	BACK_MODIFY=0.7
	STRAFE_MODIFY=0.85
	FORWARD_MODIFY=1.0
	CROUCH_MODIFY=0.65
	MaxSprintSpeedTime=3.5
	bCanDodge=false
	iKickCost=25
	iDodgeCost=40
	fComboAggressionBonus=1.0
	fBackstabModifier=1.0
	iMissMeleeStrikePenalty=10
	iMissMeleeStrikePenaltyBonus=0
	bCanSprintAttack=false
	fStandingSpread=0.05f
	fCrouchingSpread=0.0f
	fWalkingSpread=0.1
	fSprintingSpread=0.25
	fFallingSpread=0.25
	fSpreadPenaltyPerSecond=0.5
	fSpreadRecoveryPerSecond=0.3
	// SprintTurnSpeed=999999

}
