/**
 * BangModDodge - Custom dodge class that remaps WeaponIdentifier for weapons
 * that have no dodge animations for MaA (e.g. doubleaxe is a Vanguard weapon type).
 *
 * Overrides GetWeaponIdentifier() to substitute identifiers that lack dodge anims
 * with ones that have them, while keeping the original WeaponIdentifier on the weapon
 * class so the AnimTree selects the correct idle/stance pose.
 */
class BangModDodge extends AOCDodge;

var bool bHasRemappedDodgeAttachment;
var name OriginalWeaponSocket;

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

simulated function bool IsUsingRemappedDodgeIdentifier()
{
	return super.GetWeaponIdentifier() != GetWeaponIdentifier();
}

simulated function name GetRemappedDodgeSocket()
{
	if (GetWeaponIdentifier() == "qstaff")
	{
		return class'AOCWeaponAttachment_QuarterStaff'.default.WeaponSocket;
	}

	return '';
}

simulated function ReattachCurrentWeaponToSocket(name SocketName)
{
	local AOCWeaponAttachment AOCAttach;

	AOCAttach = AOCWeaponAttachment(OwnerPawn.CurrentWeaponAttachment);
	if (AOCAttach == none || SocketName == '')
	{
		return;
	}

	if (OwnerPawn.Mesh.GetSocketByName(SocketName) != none)
	{
		OwnerPawn.HandleSocketAttachment(false, AOCAttach.Mesh, SocketName, AOCAttach);
		AOCAttach.SetBase(OwnerPawn,, OwnerPawn.Mesh, SocketName);
	}

	if (AOCAttach.bIsAttachedOverlay
		&& OwnerPawn.OwnerMesh != none
		&& OwnerPawn.OwnerMesh.GetSocketByName(SocketName) != none)
	{
		OwnerPawn.HandleSocketAttachment(true, AOCAttach.OverlayMesh, SocketName, AOCAttach);
	}
}

simulated function RestoreOriginalWeaponAttachment()
{
	if (bHasRemappedDodgeAttachment)
	{
		ReattachCurrentWeaponToSocket(OriginalWeaponSocket);
		bHasRemappedDodgeAttachment = false;
		OriginalWeaponSocket = '';
	}
}

/**
 * When the weapon identifier is remapped for dodge (e.g. doubleaxe -> qstaff), the skeleton
 * drives wepQstaffpoint during the animation but the weapon is attached to wep2haxepoint,
 * causing it to float. Reattach to the socket the animation actually drives.
 *
 * NOTE: HandleSocketAttachment always detaches before checking if the target socket exists.
 * If the socket is missing on a skeleton it returns early leaving the mesh unattached (floating).
 * Guard each call with a socket existence check to prevent this.
 */
simulated function StartDodgeSM(byte direction, byte WeaponId)
{
	local name RemappedSocket;
	local AOCWeaponAttachment AOCAttach;

	OwnerPawn.ClearTimer('RestoreDodgeWeaponAttachment');
	bHasRemappedDodgeAttachment = false;
	OriginalWeaponSocket = '';

	super.StartDodgeSM(direction, WeaponId);

	AOCAttach = AOCWeaponAttachment(OwnerPawn.CurrentWeaponAttachment);

	// If the identifier was remapped, reattach weapon to the socket the dodge anim drives
	if (AOCAttach != none
		&& IsUsingRemappedDodgeIdentifier())
	{
		RemappedSocket = GetRemappedDodgeSocket();
		OriginalWeaponSocket = AOCAttach.default.WeaponSocket;
		bHasRemappedDodgeAttachment = (RemappedSocket != '' && RemappedSocket != OriginalWeaponSocket);
		ReattachCurrentWeaponToSocket(RemappedSocket);
	}
}

/** Restore the weapon to its original socket after the dodge finishes. */
simulated function StopDodgeSM()
{
	local float LandAnimLength;
	local AnimationInfo Inf;

	if (bHasRemappedDodgeAttachment)
	{
		Inf = OwnerPawn.CreateAnimationInfo(name(AllDirAnimations[DodgeDir].DodgeAnims[1]), true, true, false,,true);
		Inf.AnimationName = name(Repl(string(Inf.AnimationName), "REPL", GetWeaponIdentifier(), true));
		LandAnimLength = OwnerPawn.Mesh.GetAnimLength(Inf.AnimationName);
	}

	super.StopDodgeSM();

	if (bHasRemappedDodgeAttachment)
	{
		if (LandAnimLength > 0.f)
		{
			OwnerPawn.SetTimer(LandAnimLength, false, 'RestoreDodgeWeaponAttachment');
		}
		else
		{
			RestoreOriginalWeaponAttachment();
		}
	}
}

defaultproperties
{
}
