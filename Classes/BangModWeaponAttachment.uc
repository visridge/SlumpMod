/**
* BangMod Base Weapon Attachment
* 
* Base class for all BangMod weapon attachments to apply netcode optimizations.
* Sets NetUpdateFrequency to 120Hz to match pawn and controller update rates.
* Adds 40ms damage delay to help with through-parry issues.
*/
class BangModWeaponAttachment extends AOCWeaponAttachment;

// Damage delay system - prevents damage/flinch but allows parry stamina drain
var bool bCanDoDamage;

/** Override HandleHitPawn to allow parry stamina drain even when damage is delayed
 *  This ensures parries cost stamina immediately, while damage/flinch are delayed by 40ms
 */
simulated function HandleHitPawn(AOCPawn HitPawn, Vector HitLocation, Vector HitNormal, TraceHitInfo HitInfo, Vector HitForce, optional ETracerType TracerType = ETracerType_Attack)
{
	local bool bIsParryHit;
	local HitInfo HitInfoLocal;
	
	// Parry detection check - same logic as base class uses for ParryPawns list
	bIsParryHit = (HitPawn.StateVariables.bIsParrying || HitPawn.StateVariables.bIsActiveShielding);
	
	// If damage is delayed AND this is NOT a parry, skip hit processing entirely
	// This blocks damage and flinch during the 40ms delay window
	if (!bCanDoDamage && !bIsParryHit)
	{
		return;
	}
	
	// For parry hits during damage delay: Call AttackOtherPawn for stamina drain
	// but set damage to 0 to prevent health damage during the delay window
	if (!bCanDoDamage && bIsParryHit)
	{
		// Create minimal HitInfo for parry stamina calculation
		HitInfoLocal.DamageType = AttackTypeInfo[CurrentAttack].cDamageType;
		HitInfoLocal.HitActor = HitPawn;
		HitInfoLocal.HitDamage = 0.0f;  // No damage during delay
		HitInfoLocal.HitLocation = HitLocation;
		HitInfoLocal.HitForce = HitForce;
		HitInfoLocal.HitNormal = HitNormal;
		HitInfoLocal.Instigator = AOCPawn(Owner);
		HitInfoLocal.AttackType = CurrentAttack;
		HitInfoLocal.BoneName = HitInfo.BoneName;
		
		if (AOCPawn(Owner).Weapon.Class == AOCPawn(Owner).PrimaryWeapon || AOCPawn(Owner).Weapon.Class == AOCPawn(Owner).AlternatePrimaryWeapon)
			HitInfoLocal.UsedWeapon = 0;
		else if (AOCPawn(Owner).Weapon.Class == AOCPawn(Owner).SecondaryWeapon)
			HitInfoLocal.UsedWeapon = 1;
		else
			HitInfoLocal.UsedWeapon = 3;
		
		// Call AttackOtherPawn with bParried = true to trigger parry stamina drain
		// Last param (swing type) uses LastSwingType from Hit() function
		if (Owner.Role < ROLE_Authority || WorldInfo.NetMode == NM_Standalone || Worldinfo.NetMode == NM_ListenServer || AOCPawn(Owner).bIsBot)
		{
			AOCPawn(Owner).AttackOtherPawn(HitInfoLocal, AOCWeapon(AOCPawn(Owner).Weapon).WeaponFontSymbol, false, true,,LastSwingType, AOCWeapon(AOCPawn(Owner).Weapon).bIsQuickKick);
		}
		
		return;
	}
	
	// Normal hit processing (damage enabled OR non-parry after delay)
	super.HandleHitPawn(HitPawn, HitLocation, HitNormal, HitInfo, HitForce, TracerType);
}

DefaultProperties
{
	// Netcode optimization: Match weapon attachment replication to 120Hz pawn updates
	// Ensures weapon animations and positions stay in sync with high-frequency pawn updates
	NetUpdateFrequency=120
	
	// Start with damage enabled (weapon will disable/enable as needed)
	bCanDoDamage=true
}
