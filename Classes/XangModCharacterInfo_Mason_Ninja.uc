/**
 * Mason Ninja character (selectable Man-At-Arms skin).
 *
 * Exposes the Assassin's ninja mesh as a normal character choice under the
 * Man-At-Arms class instead of being forced by a specific primary weapon.
 * Extends the Mason Man-At-Arms CharacterInfo so it keeps the MAA helmet list
 * (and therefore the player's saved helmet index), tabards and shield patterns,
 * and only swaps the mesh/material/standin paths to the ninja package.
 *
 * The ninja-roll anim sets (slot 19) are inherited from the Man-At-Arms info, so
 * the weapon-keyed roll dodge still animates on this mesh.
 */
class XangModCharacterInfo_Mason_Ninja extends XangModCharacterInfo_Mason_ManAtArms;

defaultproperties
{
	CharacterMeshPath="SlumpCharacters.NinjaMeshMason3p"
	DecapMeshPath="SlumpCharacters.NinjaMeshMason3p"
	OwnerMeshPath="SlumpCharacters.NinjaMeshMason_1p"

	HeadMaterialPath="SlumpCharacters.Materials.NinjaBodyMat_Head"
	BodyMaterialPath="SlumpCharacters.Materials.NinjaBodyMasonMat"

	StandinMesh=SkeletalMesh'SlumpCharacters.NinjaMeshMason3p'
	StandinDecapMesh=SkeletalMesh'SlumpCharacters.NinjaMeshMason3p'
	StandinOwnerMesh=SkeletalMesh'SlumpCharacters.NinjaMeshMason_1p'
	StandinHeadMaterial=MaterialInterface'SlumpCharacters.Materials.NinjaBodyMat_Head'
	StandinBodyMaterial=MaterialInterface'SlumpCharacters.Materials.NinjaBodyMasonMat'

	GearData=(GearNameID=MasonNinja, bVisibleInSelectorIfUnowned=true)

	AllowedTeams.Empty()
	AllowedTeams.Add(1)
	AllowedClasses.Empty()
	AllowedClasses.Add(1) // ECLASS_ManAtArms
}
