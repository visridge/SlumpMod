/**
* XangMod combat bot — drop-in replacement for AOCAICombatController that makes "addbots"
* bots dramatically more capable in melee. Extends AOCAIDuelCombatController so one controller
* covers both "addbots" and duel-practice bots. Adds a skill-scaled brain -- timed defence, feint
* reads, punishing openings and ripostes -- on top of the vanilla decision/movement skeleton.
*
*  1. SKILL FLOOR. Vanilla bots default to fSkill=0.6, and AOCAICombatController.ChooseBehaviour()
*     OVERWRITES fSkill from AOCGame.GameDifficulty at spawn whenever GameDifficulty != 0 — so
*     setting fSkill in DefaultProperties alone is silently clobbered on most servers. We override
*     ChooseBehaviour to call super first, then raise fSkill up to a floor. It's a floor, not a
*     hard set, so an admin who deliberately runs a higher GameDifficulty keeps their value.
*     fSkill feeds the bot's SkillRoll()/SkillBlur() everywhere: parry success, feint reads,
*     attack quality, decision sharpness.
*
*  2. THREAT AWARENESS. The "menacing" detection vars (how wide an angle / how far out an
*     incoming swing is noticed, and how fast threat escalates after being hit) are never touched
*     at runtime, so tuning them in DefaultProperties is reliable. Slightly widening/lengthening
*     detection gives the bot a fairer chance to react and parry instead of eating free hits.
*
* Everything else (positioning, aggression, attack-direction randomness) is left at vanilla to
* avoid bots over-committing or running into walls. Tune fXangModMinSkill / the menacing vars
* below to taste. Wired in via DefaultAIControllerClass in XangMod/Include/XangModGame.uci.
*/
class XangModAOCCombatBot extends AOCAIDuelCombatController;

// Lower bound on bot skill (0.0-1.0). Applied after super.ChooseBehaviour() so it survives the
// GameDifficulty overwrite. 0.85 ≈ markedly sharper than the 0.6 vanilla default without being
// a frame-perfect aimbot.
var float fXangModMinSkill;

// ---- Skill-scaled tunables (value at skill 0 -> value at skill 1) ----
var float XReactSlow, XReactFast;          // reaction time
var float XErrSlow, XErrFast;              // parry timing spread
var float XParryLead;                      // press parry this far ahead of the enemy release
var float XPunishSlow, XPunishFast;        // chance to punish an opening
var float XRiposteSlow, XRiposteFast;      // chance to riposte after a successful block
var float XRiposteDelaySlow, XRiposteDelayFast; // riposte delay
var float XAttackGapSlow, XAttackGapFast;  // steady pressure rhythm
var float XThreatRange;                    // how far out we watch incoming swings
var float XLowPosture;                     // stamina below which we stop attacking
var float XFeintChanceSlow, XFeintChanceFast; // chance to read (not fall for) a feint
var float XGuardChanceSlow, XGuardChanceFast; // chance to choose block over dodge

// ---- Defence plan state (server-side; no replication) ----
var AOCPawn XThreat;             // attacker we planned against
var float   XThreatEnd;          // estimated windup end when we planned
var int     XThreatFireMode;     // fire mode we planned against (morph detection)
var float   XPressAt;            // world time to raise the block, 0 = no plan
var float   XReleaseAt;          // world time to drop a held block
var bool    bXHolding;           // we are currently holding a block
var bool    bXPlanDodge;         // the plan is to dodge instead of block
var float   XRiposteAt;          // world time to riposte, 0 = undecided, -1 = declined
var float   XNextPressureAt;     // when to next consider a pressure attack
var float   XPunishUntil;        // punish window after the enemy whiffs

function ChooseBehaviour()
{
	super.ChooseBehaviour();

	// Raise dumb-low bots up to our floor; never lower an admin's higher GameDifficulty.
	if (fSkill < fXangModMinSkill)
		SetSkill(fXangModMinSkill);
}

event Possess(Pawn aPawn, bool bVehicleTransition)
{
	super.Possess(aPawn, bVehicleTransition);
	XResetPlan();
	if (!IsTimerActive('XThink'))
		SetTimer(0.05f, true, 'XThink');
}

function PawnDied(Pawn P)
{
	XResetPlan();
	super.PawnDied(P);
}

function XResetPlan()
{
	XThreat = none;
	XPressAt = 0.f;
	XReleaseAt = 0.f;
	bXHolding = false;
	bXPlanDodge = false;
	XRiposteAt = 0.f;
}

function float XSkillLerp(float AtZero, float AtOne)
{
	return Lerp(AtZero, AtOne, FClamp(fSkill, 0.f, 1.f));
}

// Roughly normal, mean 0, bounded by +/- 1.5 * Spread.
function float XJitter(float Spread)
{
	return (FRand() + FRand() + FRand() - 1.5f) * Spread;
}

function bool XIsEnemy(AOCPawn P)
{
	if (AOCGame(WorldInfo.Game) != none && !AOCGame(WorldInfo.Game).bIsTeamMode)
		return true;
	return P.GetTeamNum() != Pawn.GetTeamNum();
}

function bool XAimedAtUs(AOCPawn P)
{
	return (vector(P.GetViewRotation()) dot Normal(Pawn.Location - P.Location)) >= fMenacingDot
		&& LineOfSightTo(P);
}

// Estimated windup end for a pawn whose weapon is winding up; 0 if not.
function float XWindupEnd(AOCPawn P)
{
	local AOCWeapon W;

	W = AOCWeapon(P.Weapon);
	if (W == none || !W.IsInState('Windup'))
		return 0.f;
	return WorldInfo.TimeSeconds + W.GetRealAnimLength(W.WindupAnimations[W.CurrentFireMode]);
}

function bool XIsWindingUp(AOCPawn P)
{
	local AOCWeapon W;

	W = AOCWeapon(P.Weapon);
	return W != none && W.IsInState('Windup');
}

// Main loop (0.05s): timed defence always; punish/riposte/pressure only from the stance.
function XThink()
{
	if (Pawn == none || Pawn.Health <= 0)
	{
		XResetPlan();
		return;
	}
	if (myCombatTarget == none || myCombatTarget.Health <= 0)
	{
		XResetPlan();
		return;
	}
	if (!IsInState('MeleeStance') && !IsInState('MeleeAttack'))
	{
		XResetPlan();
		return;
	}

	XWatchThreats();
	XRunPlan();

	if (IsInState('MeleeStance'))
	{
		XTryRiposte();
		XConsiderAttack();
	}
}

// Pick the soonest enemy windup aimed at us and plan a block/dodge for it; re-plan on morphs.
function XWatchThreats()
{
	local AOCPawn P, Best;
	local float End, BestEnd;

	Best = none;
	BestEnd = 0.f;

	foreach WorldInfo.AllPawns(class'AOCPawn', P, Pawn.Location, XThreatRange)
	{
		if (P == Pawn || P.Health <= 0 || !XIsEnemy(P) || !XAimedAtUs(P))
			continue;
		End = XWindupEnd(P);
		if (End <= 0.f)
			continue;
		if (Best == none || End < BestEnd)
		{
			Best = P;
			BestEnd = End;
		}
	}

	// Our current threat stopped winding up (feint/abort): drop the plan.
	if (Best == none)
	{
		if (XThreat != none && !XIsWindingUp(XThreat))
			XResetPlan();
		return;
	}

	// New threat, or the same swing morphed (fire mode changed): (re)plan.
	if (Best != XThreat || XThreatFireMode != AOCWeapon(Best.Weapon).CurrentFireMode || XPressAt <= 0.f)
	{
		XThreat = Best;
		XThreatFireMode = AOCWeapon(Best.Weapon).CurrentFireMode;
		XPlanDefence(Best, BestEnd);
	}
}

function XPlanDefence(AOCPawn P, float End)
{
	local float Now, React, Ideal;
	local bool bGuard;
	local AOCWeapon W;

	Now = WorldInfo.TimeSeconds;
	W = AOCWeapon(Pawn.Weapon);

	// Already holding a block: just extend the release so it covers this swing.
	if (bXHolding)
	{
		XReleaseAt = FMax(XReleaseAt, End + XParryLead + 0.3f);
		XThreatEnd = End;
		return;
	}

	// Our own swing is already out (release/recovery): commit to it, block next time.
	if (W != none && (W.IsInState('Release') || W.IsInState('Recovery')))
		return;

	React = XSkillLerp(XReactSlow, XReactFast) * (0.85f + 0.3f * FRand());
	bGuard = AOCPawn(Pawn).StateVariables.bShieldEquipped || FRand() > XSkillLerp(XGuardChanceSlow, XGuardChanceFast);
	if (AOCPawn(Pawn).Stamina < XLowPosture)
		bGuard = false;

	bXPlanDodge = !bGuard && AOCPawn(Pawn).PawnFamily.bCanDodge && FRand() < 0.12f;

	if (bGuard)
	{
		Ideal = End - XParryLead + XJitter(XSkillLerp(XErrSlow, XErrFast));
		XReleaseAt = End + 0.35f;
	}
	else
	{
		Ideal = End - 0.05f + XJitter(XSkillLerp(XErrSlow, XErrFast));
		XReleaseAt = 0.f;
	}

	XThreatEnd = End;
	XPressAt = FMax(Now + React, Ideal);
	if (XReleaseAt == 0.f)
		XReleaseAt = XPressAt + 0.3f;
}

function XRunPlan()
{
	if (XPressAt > 0.f && WorldInfo.TimeSeconds >= XPressAt)
	{
		XPressAt = 0.f;

		// The swing we planned for is gone (feint): skilled bots hold off, the rest get baited.
		if ((XThreat == none || !XIsWindingUp(XThreat)) && FRand() < XSkillLerp(XFeintChanceSlow, XFeintChanceFast))
		{
			XResetPlan();
			return;
		}

		if (bXPlanDodge && AOCPawn(Pawn).Dodge(DCLICK_Back))
		{
			XResetPlan();
			return;
		}

		XDoParry();
		bXHolding = true;
	}

	if (bXHolding && WorldInfo.TimeSeconds >= XReleaseAt)
	{
		bXHolding = false;
		XThreat = none;
		if (AOCWeapon(Pawn.Weapon) != none)
			AOCWeapon(Pawn.Weapon).LowerShield();
	}
}

// Raise the block, feinting our own swing into a guard if we were mid-windup.
function XDoParry()
{
	local AOCWeapon W;

	if (Pawn == none || Pawn.Weapon == none)
		return;

	W = AOCWeapon(Pawn.Weapon);

	if (W.IsInState('Windup'))
	{
		if (W.bCanFeint && AOCPawn(Pawn).HasEnoughStamina(W.iFeintStaminaCost)
			&& W.CurrentFireMode != Attack_Shove && W.CurrentFireMode != Attack_Sprint)
		{
			W.DoFeintAttack();
			SetTimer(0.15f, false, 'XDoParry');
		}
		return;
	}

	if (W.IsInState('Active'))
	{
		Pawn.StartFire(Attack_Parry);
		if (AOCPawn(Pawn).StateVariables.bShieldEquipped)
			SetTimer(1.0f, false, 'LowerShield');
	}
}

function XTryRiposte()
{
	if (XRiposteAt <= 0.f)
		return;
	if (WorldInfo.TimeSeconds < XRiposteAt)
		return;

	XRiposteAt = -1.f;
	XResetPlan();
	XGotoAttack();
}

function XGotoAttack()
{
	if (myCombatTarget == none || myCombatTarget.Health <= 0)
		return;
	if (IsInState('MeleeAttack'))
		return;
	GotoState('MeleeAttack');
}

function XConsiderAttack()
{
	local float Now, Dist;
	local bool bVulnerable;

	Now = WorldInfo.TimeSeconds;

	if (myCombatTarget == none || myCombatTarget.Health <= 0)
		return;
	if (bRemainStill || bParryOnly || bTurtleOnly || bDodgeOnly)
		return;
	if (XPressAt > 0.f || bXHolding)
		return;
	if (AOCWeapon(Pawn.Weapon) == none || !Pawn.Weapon.IsInState('Active'))
		return;

	Dist = VSize(myCombatTarget.Location - Pawn.Location);
	if (Dist > CalculateVanillaAttackStartDistance(Attack_Slash) + myCombatTarget.GetCollisionRadius() * 2.f + 60.f)
		return;

	bVulnerable = XIsVulnerable(myCombatTarget) || (XPunishUntil > 0.f && Now < XPunishUntil);

	if (bVulnerable)
	{
		if (FRand() < XSkillLerp(XPunishSlow, XPunishFast))
			XGotoAttack();
		return;
	}

	// Steady pressure so the bot never sits idle too long.
	if (Now < XNextPressureAt)
		return;
	XNextPressureAt = Now + XSkillLerp(XAttackGapSlow, XAttackGapFast) * (0.7f + 0.6f * FRand());
	if (AOCPawn(Pawn).Stamina >= XLowPosture || FRand() < 0.3f)
		XGotoAttack();
}

function bool XIsVulnerable(AOCPawn P)
{
	local AOCWeapon W;

	if (P == none)
		return false;
	W = AOCWeapon(P.Weapon);
	if (W == none)
		return false;

	if (W.IsInState('Recovery') || W.IsInState('Flinch') || W.IsInState('Feint'))
		return true;

	if (P.Stamina < XLowPosture)
		return true;

	return false;
}

// Neutralise vanilla's randomly-timed parry: we own defence via XThink instead.
function NotifyPawnStartingAttack(AOCPawn Sender)
{
	// Intentionally empty. Vanilla would set bForceBlock here, which drives its
	// randomly-timed parry in DecideCombatAction; our timed defence replaces it.
}

function NotifyPawnSuccessBlock(AOCPawn Sender, AOCPawn Attacker)
{
	super.NotifyPawnSuccessBlock(Sender, Attacker);

	if (Sender == Pawn && Attacker == myCombatTarget)
	{
		if (FRand() < XSkillLerp(XRiposteSlow, XRiposteFast) && AOCPawn(Pawn).Stamina > XLowPosture)
			XRiposteAt = WorldInfo.TimeSeconds + XSkillLerp(XRiposteDelaySlow, XRiposteDelayFast) * (0.8f + 0.4f * FRand());
	}
}

function NotifyPawnPerformMissedAttack(AOCPawn Sender)
{
	super.NotifyPawnPerformMissedAttack(Sender);

	if (Sender == myCombatTarget)
		XPunishUntil = WorldInfo.TimeSeconds + XSkillLerp(0.8f, 0.25f);
}

function NotifyPawnReceiveHit(AOCPawn Sender, AOCPawn Attacker)
{
	super.NotifyPawnReceiveHit(Sender, Attacker);

	if (Sender == Pawn)
		XResetPlan();
}

DefaultProperties
{
	fXangModMinSkill=0.85f

	// Belt-and-suspenders: if GameDifficulty==0 (super leaves fSkill at the default), start high.
	fSkill=0.85f

	// Threat awareness (vanilla in comments). Wider menacing cone + longer range = the bot
	// notices incoming swings sooner and parries more; faster escalation after being hit.
	fMenacingDot=0.70f      // was 0.81 (narrower cone)
	fMenacingRange=500.0f   // was 400
	fIncHitMe=0.16f         // was 0.12

	// Skill-scaled brain tunables (skill 0 -> skill 1).
	XReactSlow=0.32
	XReactFast=0.12
	XErrSlow=0.20
	XErrFast=0.04
	XParryLead=0.15
	XPunishSlow=0.35
	XPunishFast=0.95
	XRiposteSlow=0.30
	XRiposteFast=0.90
	XRiposteDelaySlow=0.35
	XRiposteDelayFast=0.10
	XAttackGapSlow=1.40
	XAttackGapFast=0.55
	XThreatRange=450.0
	XLowPosture=30.0
	XFeintChanceSlow=0.30
	XFeintChanceFast=0.90
	XGuardChanceSlow=0.35
	XGuardChanceFast=0.90
}
