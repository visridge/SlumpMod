/**
 * Mason Footman-Archer character (weapon-keyed mesh override).
 *
 * Presentation side of the Archer wearing the Footmen mesh. Extends the Mason
 * Archer CharacterInfo so it keeps the Archer's anim sets (including the ninja-roll
 * anims at slot 19) and helmet list, and only swaps the mesh/material/standin paths
 * to the Footmen package.
 *
 * Not selectable in the UI: AllowedTeams/AllowedClasses are emptied, so it only ever
 * appears when XangModPawn.LoadCharacterAssets swaps it in for a footman primary
 * (Spear / Brandistock / MasonFlag). Mirrors how the Assassin CharacterInfo is
 * hidden and forced by weapon.
 */
class XangModCharacterInfo_Mason_Footman_Archer extends XangModCharacterInfo_Mason_Archer;

defaultproperties
{
	CharacterMeshPath="Footmen.FootmenMason3p"
	DecapMeshPath="Footmen.FootmenMason3p"
	OwnerMeshPath="Footmen.FootmenMason1p"

	HeadMaterialPath="Footmen.Materials.FootmenHeadMat"
	BodyMaterialPath="Footmen.Materials.FootmenMasonMatInst"

	StandinMesh=SkeletalMesh'Footmen.FootmenMason3p'
	StandinDecapMesh=SkeletalMesh'Footmen.FootmenMason3p'
	StandinOwnerMesh=SkeletalMesh'Footmen.FootmenMason1p'
	StandinHeadMaterial=MaterialInterface'Footmen.Materials.FootmenHeadMat'
	StandinBodyMaterial=MaterialInterface'Footmen.Materials.FootmenMasonMatInst'

	GearData=(GearNameID=MasonFootmanArcher)

	// Index 0 is NoHat so the pawn's forced Helmet=0 (footman branch) renders no
	// helmet. The inherited Archer helmet list has a real hat at index 0.
	Helmets.Empty
	Helmets.Add((SkeletalMeshPath="", StaticMeshPath="", GearData=(GearNameID=NoHat)))

	AllowedTeams.Empty()
	AllowedClasses.Empty()
}
