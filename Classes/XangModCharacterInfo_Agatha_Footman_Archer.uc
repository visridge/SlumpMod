/**
 * Agatha Footman-Archer character (weapon-keyed mesh override).
 *
 * Presentation side of the Archer wearing the Footmen mesh. Extends the Agatha
 * Archer CharacterInfo so it keeps the Archer's anim sets (including the ninja-roll
 * anims at slot 19) and helmet list, and only swaps the mesh/material/standin paths
 * to the Footmen package.
 *
 * Not selectable in the UI: AllowedTeams/AllowedClasses are emptied, so it only ever
 * appears when XangModPawn.LoadCharacterAssets swaps it in for a footman primary
 * (Spear / Brandistock / AgathaFlag). Mirrors how the Assassin CharacterInfo is
 * hidden and forced by weapon.
 */
class XangModCharacterInfo_Agatha_Footman_Archer extends XangModCharacterInfo_Agatha_Archer;

defaultproperties
{
	CharacterMeshPath="Footmen.FootmenAgatha3p"
	DecapMeshPath="Footmen.FootmenAgatha3p"
	OwnerMeshPath="Footmen.FootmenAgatha1p"

	HeadMaterialPath="Footmen.Materials.FootmenHeadMat"
	BodyMaterialPath="Footmen.Materials.FootmenMatInst"

	StandinMesh=SkeletalMesh'Footmen.FootmenAgatha3p'
	StandinDecapMesh=SkeletalMesh'Footmen.FootmenAgatha3p'
	StandinOwnerMesh=SkeletalMesh'Footmen.FootmenAgatha1p'
	StandinHeadMaterial=MaterialInterface'Footmen.Materials.FootmenHeadMat'
	StandinBodyMaterial=MaterialInterface'Footmen.Materials.FootmenMatInst'

	GearData=(GearNameID=AgathaFootmanArcher)

	// Index 0 is NoHat so the pawn's forced Helmet=0 (footman branch) renders no
	// helmet. The inherited Archer helmet list has a real hat at index 0.
	Helmets.Empty
	Helmets.Add((SkeletalMeshPath="", StaticMeshPath="", GearData=(GearNameID=NoHat)))

	AllowedTeams.Empty()
	AllowedClasses.Empty()
}
