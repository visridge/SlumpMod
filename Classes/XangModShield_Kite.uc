/**
* BangMod Kite Shield - Vanilla AOC behavior
*/

class BangModShield_Kite extends BangModBaseShield;

DefaultProperties
{
	ShieldID = ESHIELD_Kite
	AttachSocketName = HeaterPoint
	ShieldMesh(0)=SkeletalMesh'WP_shld_Kite.WEP_ag_kite'
	ShieldMesh(1)=SkeletalMesh'WP_shld_Kite.wep_ma_kite'
	ShieldIdentifier="heatshield"
	BlockSound = SoundCue'A_Phys_Mat_Impacts.Heater_Blocking'
	PhysAsset(0)=PhysicsAsset'WP_shld_Kite.phys_kite'
	PhysAsset(1)=PhysicsAsset'WP_shld_Kite.phys_kite'

	CustomizationMaterial(0)=MaterialInstanceConstant'WP_shld_Kite.M_KiteCUST_A'
	CustomizationMaterial(1)=MaterialInstanceConstant'WP_shld_Kite.M_KiteCUST_M'

	PlainMaterial(0)=MaterialInstanceConstant'WP_shld_Kite.M_kite'
	PlainMaterial(1)=MaterialInstanceConstant'WP_shld_Kite.M_kitem'
	
	InventoryAttachmentClass(EFAC_MASON)=class'AOCInventoryAttachment_Kite_Mason'
	InventoryAttachmentClass(EFAC_AGATHA)=class'AOCInventoryAttachment_Kite_Agatha'
	CorrespondingShieldWeapon=class'AOCWeapon_Kite'
}
