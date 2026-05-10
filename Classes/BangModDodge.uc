/**
 * BangModDodge - Custom dodge class that remaps WeaponIdentifier for weapons
 * that have no dodge animations for MaA (e.g. doubleaxe is a Vanguard weapon type).
 *
 * Overrides GetWeaponIdentifier() to substitute identifiers that lack dodge anims
 * with ones that have them, while keeping the original WeaponIdentifier on the weapon
 * class so the AnimTree selects the correct idle/stance pose.
 */
class BangModDodge extends AOCDodge;

simulated function string GetWeaponIdentifier()
{
	local string Identifier;

	Identifier = super.GetWeaponIdentifier();

	// Remap Vanguard weapon identifiers that lack MaA dodge animations
	// doubleaxe (GrandMace/Kanabo) -> qstaff (QuarterStaff, a 2H MaA weapon with dodge anims)
	if (Identifier == "doubleaxe")
	{
		return "qstaff";
	}

	return Identifier;
}

/**
 * When the weapon identifier is remapped for dodge (e.g. doubleaxe -> qstaff), the skeleton
 * drives wepQstaffpoint during the animation but the weapon is attached to wep2haxepoint,
 * causing it to float. Reattach to the socket the animation actually drives.
 */
simulated function StartDodgeSM(byte direction, byte WeaponId)
{
	local name RemappedSocket;

	super.StartDodgeSM(direction, WeaponId);

	// If the identifier was remapped, reattach weapon to the socket the dodge anim drives
	if (OwnerPawn.CurrentWeaponAttachment != none
		&& super.GetWeaponIdentifier() != GetWeaponIdentifier())
	{
		RemappedSocket = 'wepQstaffpoint';
		OwnerPawn.HandleSocketAttachment(false, OwnerPawn.CurrentWeaponAttachment.Mesh, RemappedSocket, OwnerPawn.CurrentWeaponAttachment);
		if (OwnerPawn.CurrentWeaponAttachment.bIsAttachedOverlay)
		{
			OwnerPawn.HandleSocketAttachment(true, OwnerPawn.CurrentWeaponAttachment.OverlayMesh, RemappedSocket, OwnerPawn.CurrentWeaponAttachment);
		}
	}
}

/** Restore the weapon to its original socket after the dodge finishes. */
simulated function StopDodgeSM()
{
	local name OrigSocket;

	if (OwnerPawn.CurrentWeaponAttachment != none
		&& super.GetWeaponIdentifier() != GetWeaponIdentifier())
	{
		OrigSocket = class<AOCWeaponAttachment>(OwnerPawn.CurrentWeaponAttachment.Class).default.WeaponSocket;
		OwnerPawn.HandleSocketAttachment(false, OwnerPawn.CurrentWeaponAttachment.Mesh, OrigSocket, OwnerPawn.CurrentWeaponAttachment);
		if (OwnerPawn.CurrentWeaponAttachment.bIsAttachedOverlay)
		{
			OwnerPawn.HandleSocketAttachment(true, OwnerPawn.CurrentWeaponAttachment.OverlayMesh, OrigSocket, OwnerPawn.CurrentWeaponAttachment);
		}
	}

	super.StopDodgeSM();
}

defaultproperties
{
}
