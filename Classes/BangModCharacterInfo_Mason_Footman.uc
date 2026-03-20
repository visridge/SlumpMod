class BangModCharacterInfo_Mason_Footman extends AOCCharacterInfo;

defaultproperties
{
	MobileBattleCry=SoundCue'A_VO_Manual.Mason_Vanguard.Battlecry_Running_Mason_Vanguard'

	CharacterMeshPath="Mason_Footman.masonfootman_3p"
	DecapMeshPath="Mason_Footman.masonfootman_3p"
	OwnerMeshPath="Mason_Footman.masonfootman_1p"

	HeadMaterialPath="Mason_Footman.masonfootman_texture"
	BodyMaterialPath="Mason_Footman.masonfootman_texture"

	StandinMesh=SkeletalMesh'Mason_Footman.masonfootman_3p'
	StandinDecapMesh=SkeletalMesh'Mason_Footman.masonfootman_3p'
	StandinOwnerMesh=SkeletalMesh'Mason_Footman.masonfootman_1p'
	StandinHeadMaterial=MaterialInterface'Mason_Footman.masonfootman_texture'
	StandinBodyMaterial=MaterialInterface'Mason_Footman.masonfootman_texture'

	PhysAsset=PhysicsAsset'CH_AgathanMaa_PKG.SkeletalMesh.SK_CH_3P_AgathaMaa_Physics'

	GearData=(GearNameID=MasonFootman, bVisibleInSelectorIfUnowned=true)

	AllowedTeams.Add(1)
	AllowedClasses.Add(2)

	Helmets.Add((SkeletalMeshPath="", StaticMeshPath="", GearData=(GearNameID=NoHat)))

	Tabards=((GearData=(GearNameID=Default)))

	SoundGroupClassName="AOCAudioContent.AOCPawnSoundGroup_Vanguard"
	OverridePawnArmorType="ARMORTYPE_MEDIUM"
}
