/**
* BangMod Buckler - Vanilla AOC behavior
*/

class BangModShield_Buckler extends BangModBaseShield;

DefaultProperties
{
	ShieldID = ESHIELD_Buckler
	AttachSocketName = BucklerPoint
	ShieldMesh(0)=SkeletalMesh'WP_shld_Buckler.WEP_Buckler_a'
	ShieldMesh(1)=SkeletalMesh'WP_shld_Buckler.WEP_Buckler_m'
	ShieldIdentifier="buckler"
	BlockSound = SoundCue'A_Phys_Mat_Impacts.Buckler_Blocking'
	PhysAsset(0)=PhysicsAsset'WP_shld_Buckler.WEP_Buckler_PKG_Physics'
	PhysAsset(1)=PhysicsAsset'WP_shld_Buckler.WEP_Buckler_PKG_Physics'

	CustomizationMaterial(0)=MaterialInstanceConstant'WP_shld_Buckler.M_BucklerCUST_A'
	CustomizationMaterial(1)=MaterialInstanceConstant'WP_shld_Buckler.M_BucklerCUST_A'

	PlainMaterial(0)=MaterialInstanceConstant'WP_shld_Buckler.M_Buckler_a'
	PlainMaterial(1)=MaterialInstanceConstant'WP_shld_Buckler.M_Buckler_m'
	
	InventoryAttachmentClass(EFAC_MASON)=class'AOCInventoryAttachment_Buckler_Mason'
	InventoryAttachmentClass(EFAC_AGATHA)=class'AOCInventoryAttachment_Buckler_Agatha'
	CorrespondingShieldWeapon=class'AOCWeapon_Buckler'

	Skins(0)={(
		SkeletalMeshPath="",
		StaticMeshPath="",
		MaterialPath="",
		StaticMeshScale=1.0,
		ImagePath="UI_CustWeaponImages_SWF.skin_bucklerDefault_png"
		)};
	Skins(1)={(
		SkeletalMeshPath="WP_shld_Buckler_Variant_01.WEP_Buckler_variant_01",
		StaticMeshPath="WP_shld_Buckler_Variant_01.SM_Buckler_variant_01",
		MaterialPath="",
		StaticMeshScale=1.0,
		ImagePath="UI_CustWeaponImages_SWF.skin_vicomte_buckler_png",
		ShieldPatterns=(
			(PatternName="Solid", TexturePath="WP_shld_Buckler_Variant_01.T_buckler_p03"),
			(PatternName="Quadrant", TexturePath="WP_shld_Buckler_Variant_01.T_buckler_p01"),
			(PatternName="Stripes", TexturePath="WP_shld_Buckler_Variant_01.T_buckler_p02"),
			(PatternName="Checkers", TexturePath="WP_shld_Buckler_Variant_01.T_buckler_p04"))
		)};
	Skins(2)={(
		SkeletalMeshPath="WP_shld_Buckler_Variant_02.WEP_Buckler_Variant_02",
		StaticMeshPath="WP_shld_Buckler_Variant_02.SM_Buckler_Variation_01",
		MaterialPath="",
		StaticMeshScale=1.0,
		ImagePath="UI_CustWeaponImages_SWF.skin_mercenaryBuckler_png",
		ShieldPatterns=(
			(PatternName="Solid", TexturePath="WP_shld_Buckler_Variant_02.T_Buckler_Var_p01"),
			(PatternName="Quadrant", TexturePath="WP_shld_Buckler_Variant_02.T_Buckler_Var_p02"),
			(PatternName="Stripes", TexturePath="WP_shld_Buckler_Variant_02.T_Buckler_Var_p04"),
			(PatternName="Bullseye", TexturePath="WP_shld_Buckler_Variant_02.T_Buckler_Var_p05"),			
			(PatternName="Checkers", TexturePath="WP_shld_Buckler_Variant_02.T_Buckler_Var_p03"))		
		)};
	Skins(3)={(
		SkeletalMeshPath="WP_shld_Buckler_Variant_03.WEP_Buckler_FarmsToArms",
		StaticMeshPath="WP_shld_Buckler_Variant_03.SM_Buckler_FarmsToArms",
		MaterialPath="",
		StaticMeshScale=1.0,
		ImagePath="UI_CustWeaponImages_SWF.skin_farms_shield_png",
		ShieldPatterns=(
			(PatternName="Solid", TexturePath="WP_shld_Buckler_Variant_02.T_Buckler_Var_p01"),
			(PatternName="Quadrant", TexturePath="WP_shld_Buckler_Variant_02.T_Buckler_Var_p02"),
			(PatternName="Stripes", TexturePath="WP_shld_Buckler_Variant_02.T_Buckler_Var_p04"),
			(PatternName="Bullseye", TexturePath="WP_shld_Buckler_Variant_02.T_Buckler_Var_p05"),			
			(PatternName="Checkers", TexturePath="WP_shld_Buckler_Variant_02.T_Buckler_Var_p03"))		
		)};
}
