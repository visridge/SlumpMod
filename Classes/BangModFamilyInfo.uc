/**
 * AOC Family Info 
 *
 * Author: b3h47pte
 *
 * Copyright ? 2005-2014, Torn Banner Studios, All rights reserved
 * 
 * Gameplay-related class information is in here.
 * The presentation-side of families are called "Characters"; see AOCCharacterInfo. All mesh/texture/anim info is in there.
 * One character can be used by multiple families, so long as the Class and Faction match (Characters may have multiple classes and factions).
 */
class BangModFamilyInfo extends AOCFamilyInfo;

DefaultProperties
{
	// Extend parry box backward by making it much longer (Y) and reducing forward offset (X)
	// Since X can't go negative effectively, we compensate with massive Y depth
	ParryBoxScale=(X=0.1,Y=0.17,Z=0.35)
	ParryBoxTranslation=(X=5, Y=5, Z=-28)
}
