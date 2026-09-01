/**
* BangMod Heater Shield - Vanilla AOC behavior
*/

class BangModShield_Heater extends BangModBaseShield;

DefaultProperties
{
	ShieldID = ESHIELD_Heater
	AttachSocketName = HeaterPoint
	ShieldMesh(0)=SkeletalMesh'WP_shld_Heatshield.WEP_agatha_Heatshield'
	ShieldMesh(1)=SkeletalMesh'WP_shld_Heatshield.wep_mason_heatshield'
	ShieldIdentifier="heatshield"
	BlockSound = SoundCue'A_Phys_Mat_Impacts.Heater_Blocking'
	PhysAsset(0)=PhysicsAsset'WP_shld_Heatshield.WEP_agatha_Heatshield_Physics'
	PhysAsset(1)=PhysicsAsset'WP_shld_Heatshield.wep_mason_heatshield_Physics'

	CustomizationMaterial(0)=MaterialInstanceConstant'WP_shld_Heatshield.M_HeaterCUST_A'
	CustomizationMaterial(1)=MaterialInstanceConstant'WP_shld_Heatshield.M_HeaterCUST_A'

	PlainMaterial(0)=MaterialInstanceConstant'WP_shld_Heatshield.Material.M_Heater-agatha'
	PlainMaterial(1)=MaterialInstanceConstant'WP_shld_Heatshield.Material.M_Heater-mason'
	
	InventoryAttachmentClass(EFAC_MASON)=class'AOCInventoryAttachment_Heater_Mason'
	InventoryAttachmentClass(EFAC_AGATHA)=class'AOCInventoryAttachment_Heater_Agatha'
	CorrespondingShieldWeapon=class'AOCWeapon_Heater'
}
