/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
*
* Original Author: Michael Bao
*
* BangMod Weapon: Agatha Flag.
* Extends AOCWeapon_AgathaFlag so we can nerf stats without touching AOC files.
*/
class BangModWeapon_AgathaFlag extends AOCWeapon_AgathaFlag;

defaultproperties
{
	AttachmentClass=class'BangModWeaponAttachment_AgathaFlag'
	InventoryAttachmentClass=class'BangModInventoryAttachment_AgathaFlag'

	// Reuse spear icon for loadout screen
	WeaponFontSymbol="7"
	WeaponLargePortrait="UI_WeaponImages_SWF.weapon_select_spear"
	WeaponSmallPortrait="UI_WeaponImages_SWF.icon_weapon_select_spear_png"

	// TODO: Add nerfs here. Examples below (commented out for now):
	// fParryNegation=10
	// ParryDrain(0)=18
	// ParryDrain(1)=23
	// ParryDrain(2)=18
	// WeaponReach=90
	// iFeintStaminaCost=18
}
