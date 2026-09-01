/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
* 
* Original Author: Michael Bao
* 
* DoubleBlade Weapon Attachment.
* Uses the quarterstaff animation set with attack-based tracer routing.
* Each attack fires one tracer set, selected dynamically:
*   - Stab / Sprint / combo-Slash → TraceStart1 / TraceEnd1
*   - All other attacks           → TraceStart  / TraceEnd
* The weapon is held in the middle so the entire length is a striking surface.
*/
class XangModWeaponAttachment_DoubleBlade extends AOCWeaponAttachment_QuarterStaff;

/** Snapshot of bWindupStartAlternateSide for the current swing */
var bool bWindupAltSide;

/** Snapshot of bIsInCombo — true if this swing is part of a combo chain */
var bool bIsComboSwing;

/** Remembers previous swing's side for combo alternation */
var bool bLastSwingAltSide;

/** Remembers previous attack type */
var EAttack eLastAttack;

/** This swing's resolved side — computed once in BeginState, stable for the release */
var bool bMySwingAltSide;

simulated function float GetHandleTracerPercent(int i)
{
	return 0.0f;
}

simulated state Release
{
	simulated event BeginState(name PreviousStateName)
	{
		local AOCMeleeWeapon W;
		super.BeginState(PreviousStateName);
		W = AOCMeleeWeapon(AOCOwner.Weapon);
		if (W != none)
		{
			bWindupAltSide = W.bWindupStartAlternateSide;
			bIsComboSwing = W.bIsInCombo;
		}
		else
		{
			bWindupAltSide = false;
			bIsComboSwing = false;
		}

		// --- Resolve this swing's side ---

		// 1.  Natural side.
		if (CurrentAttack == Attack_Stab || CurrentAttack == Attack_Sprint)
		{
			bMySwingAltSide = true;
		}
		else if (CurrentAttack == Attack_Slash)
		{
			bMySwingAltSide = bWindupAltSide;
		}
		else
		{
			// Overheads, shoves, etc. always traced reg.
			bMySwingAltSide = false;
		}

		// 1b. Combo memory for Overheads — remember if it was alt even
		//     though tracers are reg. (AltSlash memory comes from bWindupAltSide.)
		if (CurrentAttack == Attack_Overhead)
			bLastSwingAltSide = bWindupAltSide;

		// 2.  Combo slashes are determined entirely by history,
		//     ignoring bWindupAltSide (which may be stale).
		if (bIsComboSwing && CurrentAttack == Attack_Slash)
		{
			if (eLastAttack == Attack_Overhead)
				bMySwingAltSide = bLastSwingAltSide;
			else
				bMySwingAltSide = !bLastSwingAltSide;
		}

		// 3.  Update combo memory. For all attacks, bLastSwingAltSide
		//     persists to the next swing via the begin-state snapshot.
		if (CurrentAttack == Attack_Overhead)
			bLastSwingAltSide = bWindupAltSide;   // Already set above, safety
		else if (CurrentAttack == Attack_Slash || CurrentAttack == Attack_Stab
			|| CurrentAttack == Attack_Sprint)
			bLastSwingAltSide = bMySwingAltSide;  // Slashes/Stabs: use resolved side
		else
			bLastSwingAltSide = false;             // Shove, etc.
	}

	simulated event EndState(name NextStateName)
	{
		eLastAttack = CurrentAttack;
		super.EndState(NextStateName);
	}

	simulated function GetTracerSocketNames(out name beginSocketName, out name endSocketName, int i)
	{
		if (bMySwingAltSide)
		{
			beginSocketName = 'TraceStart1';
			endSocketName   = 'TraceEnd1';
		}
		else
		{
			beginSocketName = 'TraceStart';
			endSocketName   = 'TraceEnd';
		}
	}
}

defaultproperties
{
	`include(XangMod/Include/XangModWeaponAttachment.uci);

	KickOffset=(X=50, Y=0, Z=-65)
	KickSize=20.f

	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'DoubleBlade.WEP_DoubleBlade'
	End Object

	Begin Object Name=SkeletalMeshComponent2
		SkeletalMesh=SkeletalMesh'DoubleBlade.WEP_DoubleBlade'
	End Object

	WeaponID=EWEP_QStaff
	WeaponClass=class'XangModWeapon_DoubleBlade'

	WeaponSocket=wepQstaffpoint
	bUseAlternativeKick=true

	WeaponStaticMeshScale=1

	// --- Attack-based tracer routing ---
	// Each attack fires only ONE tracer set, but which one depends on the attack:
	//   Stab / Sprint / combo Slash → TraceStart1 / TraceEnd1
	//   All other attacks           → TraceStart  / TraceEnd
	// See GetTracerSocketNames override above.
	WeaponNumTracers=1

	AttackTypeInfo(0)=(fBaseDamage=90.0, fForce=27200, cDamageType="AOC.AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(1)=(fBaseDamage=100.0, fForce=27200, cDamageType="AOC.AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(2)=(fBaseDamage=60.0, fForce=28000, cDamageType="AOC.AOCDmgType_Pierce", iWorldHitLenience=6)
	AttackTypeInfo(3)=(fBaseDamage=100.0, fForce=65000, cDamageType="AOC.AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(4)=(fBaseDamage=0.0, fForce=35500, cDamageType="AOC.AOCDmgType_Swing", iWorldHitLenience=6)
	AttackTypeInfo(5)=(fBaseDamage=5.0, fForce=45500.0, cDamageType="AOC.AOCDmgType_Shove", iWorldHitLenience=12)

Skins(0)={(
		SkeletalMeshPath="DoubleBlade.WEP_DoubleBlade",
		StaticMeshPath="DoubleBlade.mesh_DoubleBlade",
		MaterialPath="DoubleBlade.Material_001",
		StaticMeshScale=1.0,
		ImagePath="UI_CustWeaponImages_SWF.skin_bardiche_png"
		)};
	Skins(1)={(
		SkeletalMeshPath="DoubleBlade.WEP_DoubleBlade",
		StaticMeshPath="DoubleBlade.mesh_DoubleBlade",
		MaterialPath="DoubleBlade.Material_002",
		StaticMeshScale=1.0,
		ImagePath="UI_CustWeaponImages_SWF.skin_bardiche_png"
		)};
	Skins(2)={(
		SkeletalMeshPath="DoubleBlade.WEP_DoubleBlade",
		StaticMeshPath="DoubleBlade.mesh_DoubleBlade",
		MaterialPath="DoubleBlade.Material_003",
		StaticMeshScale=1.0,
		ImagePath="UI_CustWeaponImages_SWF.skin_bardiche_png"
		)};
	Skins(3)={(
		SkeletalMeshPath="DoubleBlade.WEP_DoubleBlade",
		StaticMeshPath="DoubleBlade.mesh_DoubleBlade",
		MaterialPath="DoubleBlade.Material_004",
		StaticMeshScale=1.0,
		ImagePath="UI_CustWeaponImages_SWF.skin_bardiche_png"
		)};
	Skins(4)={(
		SkeletalMeshPath="DoubleBlade.WEP_DoubleBlade",
		StaticMeshPath="DoubleBlade.mesh_DoubleBlade",
		MaterialPath="DoubleBlade.Material_005",
		StaticMeshScale=1.0,
		ImagePath="UI_CustWeaponImages_SWF.skin_bardiche_png"
		)};
}
