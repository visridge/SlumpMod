class BangModCharacterInfo_Agatha_Footman extends AOCCharacterInfo_Vanguard;

defaultproperties
{
	MobileBattleCry=SoundCue'A_VO_Manual.Agatha_Vanguard.Battlecry_Running_Agatha_Vanguard'

	CharacterMeshPath="AgathaFoot.agathafoot3p"
	DecapMeshPath="AgathaFoot.agathafoot3p"
	OwnerMeshPath="AgathaFoot.agathafoot1p"

	HeadMaterialPath="AgathaFoot.AgathaFoot_Mat"
	BodyMaterialPath="AgathaFoot.AgathaFoot_Mat"

	StandinMesh=SkeletalMesh'AgathaFoot.agathafoot3p'
	StandinDecapMesh=SkeletalMesh'AgathaFoot.agathafoot3p'
	StandinOwnerMesh=SkeletalMesh'AgathaFoot.agathafoot1p'
	StandinHeadMaterial=MaterialInterface'AgathaFoot.AgathaFoot_Mat'
	StandinBodyMaterial=MaterialInterface'AgathaFoot.AgathaFoot_Mat'

	PhysAsset=PhysicsAsset'CH_AgathanMaa_PKG.SkeletalMesh.SK_CH_3P_AgathaMaa_Physics'

	GearData=(GearNameID=AgathaFootman, bVisibleInSelectorIfUnowned=true)

	AllowedTeams.Add(0)
	AllowedClasses.Add(2)

	Helmets.Add((SkeletalMeshPath="", StaticMeshPath="", GearData=(GearNameID=NoHat)))

	Tabards=((GearData=(GearNameID=Default)))

	SoundGroupClassName="AOCAudioContent.AOCPawnSoundGroup_Vanguard"
	OverridePawnArmorType="ARMORTYPE_MEDIUM"
}
