class XangModCharacterInfo_Agatha_Turtle extends AOCCharacterInfo_Agatha_Knight;
defaultproperties
{
	MobileBattleCry=SoundCue'A_VO_Manual.Agatha_Knight.Battlecry_Running_Agatha_Knight'

	CharacterMeshPath="TurtleFFA.TurtleFFA"
	DecapMeshPath="TurtleFFA.TurtleFFA"
	OwnerMeshPath="TurtleFFA.TurtleFFA_1p"

	HeadMaterialPath="CH_AgathanKnight_PKG.Materials.MI_CH_3P_AgathaKnight_Head"
	BodyMaterialPath="CH_AgathanKnight_PKG.Materials.MI_CH_3P_AgathaKnight_Body"

	StandinMesh=SkeletalMesh'TurtleFFA.TurtleFFA'
	StandinDecapMesh=SkeletalMesh'TurtleFFA.TurtleFFA'
	StandinOwnerMesh=SkeletalMesh'TurtleFFA.TurtleFFA_1p'
	StandinHeadMaterial=MaterialInterface'TurtleFFA.TurtleFFAHead'
	StandinBodyMaterial=MaterialInterface'TurtleFFA.TurtleFFABody'

	PhysAsset=PhysicsAsset'CH_AgathanMaa_PKG.SkeletalMesh.SK_CH_3P_AgathaMaa_Physics'

	/** Ownership info **/

	GearData=(GearNameID=AgathaKnight, GroupHexID="170000002C14009", bVisibleInSelectorIfUnowned=false)

	AllowedTeams.Empty()
	AllowedTeams.Add(5)
	AllowedClasses.Empty()
	AllowedClasses.Add(3)
}
