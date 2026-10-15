/**
 * Agatha Ninja character (selectable Man-At-Arms skin).
 *
 * Exposes the Assassin's ninja mesh as a normal character choice under the
 * Man-At-Arms class instead of being forced by a specific primary weapon.
 * Extends the Agatha Man-At-Arms CharacterInfo so it keeps the MAA helmet list
 * (and therefore the player's saved helmet index), tabards and shield patterns,
 * and only swaps the mesh/material/standin paths to the ninja package.
 *
 * The ninja-roll anim sets (slot 19) are inherited from the Man-At-Arms info, so
 * the weapon-keyed roll dodge still animates on this mesh.
 */
class XangModCharacterInfo_Agatha_Ninja extends XangModCharacterInfo_Agatha_ManAtArms;

defaultproperties
{
	CharacterMeshPath="SlumpCharacters.NinjaMeshAgatha3p"
	DecapMeshPath="SlumpCharacters.NinjaMeshAgatha3p"
	OwnerMeshPath="SlumpCharacters.NinjaMeshAgatha_1p"

	HeadMaterialPath="SlumpCharacters.Materials.NinjaBodyMat_Head"
	BodyMaterialPath="SlumpCharacters.Materials.NinjaBodyAgathaMat"

	StandinMesh=SkeletalMesh'SlumpCharacters.NinjaMeshAgatha3p'
	StandinDecapMesh=SkeletalMesh'SlumpCharacters.NinjaMeshAgatha3p'
	StandinOwnerMesh=SkeletalMesh'SlumpCharacters.NinjaMeshAgatha_1p'
	StandinHeadMaterial=MaterialInterface'SlumpCharacters.Materials.NinjaBodyMat_Head'
	StandinBodyMaterial=MaterialInterface'SlumpCharacters.Materials.NinjaBodyAgathaMat'

	GearData=(GearNameID=AgathaNinja, bVisibleInSelectorIfUnowned=true)

	AllowedTeams.Empty()
	AllowedTeams.Add(0)
	AllowedClasses.Empty()
	AllowedClasses.Add(1) // ECLASS_ManAtArms
}
