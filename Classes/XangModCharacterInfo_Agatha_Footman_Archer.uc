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

	HeadMaterialPath="Footmen.FootmenHeadMat"
	BodyMaterialPath="Footmen.FootmenMatInst"

	StandinMesh=SkeletalMesh'Footmen.FootmenAgatha3p'
	StandinDecapMesh=SkeletalMesh'Footmen.FootmenAgatha3p'
	StandinOwnerMesh=SkeletalMesh'Footmen.FootmenAgatha1p'
	StandinHeadMaterial=MaterialInterface'Footmen.FootmenHeadMat'
	StandinBodyMaterial=MaterialInterface'Footmen.FootmenMatInst'

	GearData=(GearNameID=AgathaFootmanArcher)

	AllowedTeams.Empty()
	AllowedClasses.Empty()
}
