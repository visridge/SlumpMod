/**
* BangMod Tower Shield - Vanilla AOC behavior
*/

class BangModShield_TowerShield extends BangModBaseShield;

DefaultProperties
{
	ShieldID = ESHIELD_Tower
	AttachSocketName = HeaterPoint
	ShieldMesh(0)=SkeletalMesh'WP_shld_TowerShield.Materials.WEP_towershield_a'
	ShieldMesh(1)=SkeletalMesh'WP_shld_TowerShield.Materials.WEP_towershield_m'
	ShieldIdentifier="heatshield"
	BlockSound = SoundCue'A_Phys_Mat_Impacts.Tower_Blocking'
	PhysAsset(0)=PhysicsAsset'WP_shld_TowerShield.Meshes.WP_towershield_skel_Physics'
	PhysAsset(1)=PhysicsAsset'WP_shld_TowerShield.Meshes.WP_towershield_skel_Physics'

	CustomizationMaterial(0)=MaterialInstanceConstant'WP_shld_TowerShield.M_TowerCUST_A'
	CustomizationMaterial(1)=MaterialInstanceConstant'WP_shld_TowerShield.M_TowerCUST_A'

	PlainMaterial(0)=MaterialInstanceConstant'WP_shld_TowerShield.Materials.M_TowerShield_a'
	PlainMaterial(1)=MaterialInstanceConstant'WP_shld_TowerShield.Materials.M_TowerShield_m'
	
	InventoryAttachmentClass(EFAC_MASON)=class'AOCInventoryAttachment_TowerShield_Mason'
	InventoryAttachmentClass(EFAC_AGATHA)=class'AOCInventoryAttachment_TowerShield_Agatha'
	CorrespondingShieldWeapon=class'AOCWeapon_TowerShield'
}
