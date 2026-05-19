/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
*
* Original Author: Michael Bao
*
* Weapon: Spiked Mace - Bastard Sword gameplay with scaled Holy Water Sprinkler visuals
*/
class BangModWeapon_SpikedMace extends BangModWeapon_BastardSword;

DefaultProperties
{
	AttachmentClass=class'BangModWeaponAttachment_SpikedMace'
	InventoryAttachmentClass=class'AOCInventoryAttachment_HolyWaterSprinkler'
	CurrentWeaponType=EWEP_HolyWaterSprinkler
	WeaponName="Spiked Mace"
	WeaponFontSymbol="B"
	WeaponLargePortrait="UI_WeaponImages_SWF.weapon_select_hws"
	WeaponSmallPortrait="UI_WeaponImages_SWF.icon_weapon_select_hws_png"
}