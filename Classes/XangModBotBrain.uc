/**
* XangMod bot brain. A server-only helper the pawn attaches to any AI pawn whose controller is an
* AOCAICombatController, so it covers addbots, Kismet-spawned map bots and the King alike, without
* replacing the controller the map chose.
*
* Vanilla bots parry on a random 0.1-0.3s timer and decide whether to attack once a second. This
* layer replaces the parry with one timed from the attacker's real windup data, and adds punishes,
* ripostes and a steady attack rhythm. Pursuit steers for where the target is heading, sprints to
* close distance and hands over to pathfinding when blocked. Targeting and the attack stay vanilla.
* Skill (fSkill) scales reaction, timing spread and how often openings are taken. Kings get the
* top profile.
*/
class XangModBotBrain extends Info;

struct BrainThreat
{
	var AOCPawn P;
	var name LastState;
	var float StateStart;
};

var AOCPawn MyPawn;
var AOCAICombatController MyBot;
var array<BrainThreat> Threats;

// Current defence plan
var AOCPawn PlanThreat;
var float PlanEnd;          // threat's windup end when planned
var float PressAt;          // 0 = no plan
var float ShieldDropAt;
var float RiposteAt;        // 0 = undecided, -1 = declined
var float PunishAt;         // 0 = undecided, -1 = declined
var float NextPressureAt;
var bool bIsKing;
var name MyLastState;
var float MyStateStart;
var vector LastPos;
var float LastPosTime;
var float NextRepathAt;
var bool bChaseSprint;
var bool bCompForest;                          // set in Init: running AOCTO-CompForest_p
var float NextFollowAt;                        // throttle for FollowTeammates

// Tunables (normal bots / Kings)
var float SkillFloor, KingSkillFloor;
var float Aggression, KingAggression;          // vanilla fAggressiveBehavior, -1..1
var float ReactSlow, ReactFast;                // reaction at skill 0 / 1 (s)
var float ErrSlow, ErrFast;                    // parry timing spread at skill 0 / 1 (s)
var float ContactLead;                         // windup end to blade contact, roughly (s)
var float ThreatRange;
var float PunishSlow, PunishFast;              // chance to punish an opening at skill 0 / 1
var float GapSlow, GapFast;                    // pressure attack rhythm at skill 0 / 1 (s)
var float KingGapScale;
var float ComboChance, KingComboChance;
var float LowStamina;                          // below this a bot stops pressing
var float MaxLead;                             // furthest ahead of a moving target to steer (s)
var float ChaseSprintDist;                     // sprint when the target is further than this
var float StuckDist;                           // moved less than this in a second while chasing = stuck
var float FollowRange;                         // max distance to consider a teammate worth following
var float FollowDist;                          // stop this far from the followed teammate
var float FollowEnemyRange;                    // any enemy nearer than this stops the follow
var float FollowReissueInterval;               // how often to (re)consider following

function Init(AOCPawn P)
{
	MyPawn = P;
	MyBot = AOCAICombatController(P.Controller);
	bIsKing = P.PawnFamily != none && P.PawnFamily.ClassReference == ECLASS_King;
	bCompForest = InStr(WorldInfo.GetMapName(), "AOCTO-CompForest_p", false, true) != INDEX_NONE;
	SetTimer(0.05f, true, 'Think');
}

function float SkillLerp(float AtZero, float AtOne)
{
	return Lerp(AtZero, AtOne, FClamp(MyBot.fSkill, 0.f, 1.f));
}

// Roughly normal, mean 0.
function float Jitter(float Spread)
{
	return (FRand() + FRand() + FRand() - 1.5f) * Spread;
}

function bool IsEnemy(Pawn P)
{
	if (AOCGame(WorldInfo.Game) != none && !AOCGame(WorldInfo.Game).bIsTeamMode)
		return true;
	return P.GetTeamNum() != MyPawn.GetTeamNum();
}

function name WeaponState(Pawn P)
{
	if (P == none || P.Weapon == none)
		return '';
	return P.Weapon.GetStateName();
}

function Think()
{
	local AOCMeleeWeapon W;

	if (MyPawn == none || MyPawn.Health <= 0 || MyPawn.Controller != MyBot || MyBot == none)
	{
		Destroy();
		return;
	}
	W = AOCMeleeWeapon(MyPawn.Weapon);
	if (W == none)
		return;

	if (W.GetStateName() != MyLastState)
	{
		MyLastState = W.GetStateName();
		MyStateStart = WorldInfo.TimeSeconds;
	}
	if (MyBot.fSkill < (bIsKing ? KingSkillFloor : SkillFloor))
		MyBot.SetSkill(bIsKing ? KingSkillFloor : SkillFloor);
	MyBot.fAggressiveBehavior = bIsKing ? KingAggression : Aggression;
	if (MyBot.IsInState('MeleeAttack') && !W.bIsInCombo)
		MyBot.myComboPercent = FMax(MyBot.myComboPercent, bIsKing ? KingComboChance : ComboChance);

	Pursue();
	TrackThreats();
	FollowTeammates();
	RunDefence(W);
	TryRiposte(W);
	ConsiderAttack(W);
}

event Destroyed()
{
	if (MyBot != none && MyBot.vStrafeTarget == self)
		MyBot.vStrafeTarget = MyBot.myCombatTarget;
	super.Destroyed();
}

function StopChaseSprint()
{
	if (bChaseSprint)
	{
		bChaseSprint = false;
		MyPawn.ServerSprintState(false);
	}
}

// Vanilla steers at where the target is, re-rolls a random strafe every 0.5s and has its stuck check
// off in melee range, so bots trail, drift and wedge on walls. This brain is the steering point instead.
function Pursue()
{
	local AOCPawn T;
	local float Dist, Moved, Now;
	local vector Lead;
	local bool bSee, bChasing;

	Now = WorldInfo.TimeSeconds;
	T = MyBot.myCombatTarget;
	if (T == none || T.Health <= 0 || MyBot.bRemainStill || !MyBot.IsInState('MeleeStance'))
	{
		if (MyBot.vStrafeTarget == self)
			MyBot.vStrafeTarget = T;
		StopChaseSprint();
		return;
	}

	Dist = VSize(T.Location - MyPawn.Location);
	bSee = FastTrace(T.Location, MyPawn.Location);
	bChasing = Dist > MyBot.StrafeDistance * 1.2f;

	if (bSee && bChasing)
	{
		Lead = T.Location + T.Velocity * FClamp(Dist / FMax(MyPawn.GroundSpeed, 1.f), 0.f, MaxLead);
		Lead.Z = T.Location.Z;
		if (!FastTrace(Lead, MyPawn.Location))
			Lead = T.Location;
		SetLocation(Lead);
		MyBot.vStrafeTarget = self;
		MyBot.ApproachTendency = 1.f;
		MyBot.AvoidTendency = 0.f;
		MyBot.StrafeTendency = 0.f;
	}
	else if (MyBot.vStrafeTarget == self)
		MyBot.vStrafeTarget = T;

	if (bSee && Dist > ChaseSprintDist && MyPawn.Stamina > LowStamina + 10.f && !MyBot.IsInState('MeleeAttack'))
	{
		if (!bChaseSprint)
		{
			bChaseSprint = true;
			MyPawn.ServerSprintState(true);
		}
	}
	else
		StopChaseSprint();

	// Once a second: out of sight or not getting anywhere while chasing means pathfind.
	if (Now < LastPosTime + 1.f)
		return;
	Moved = VSize(MyPawn.Location - LastPos);
	LastPos = MyPawn.Location;
	LastPosTime = Now;
	if (bChasing && (!bSee || Moved < StuckDist) && Now >= NextRepathAt && !MyBot.IsInState('MeleeAttack'))
	{
		NextRepathAt = Now + 2.f;
		if (MyBot.vStrafeTarget == self)
			MyBot.vStrafeTarget = T;
		MyBot.myMoveTarget = T;
		MyBot.myDestReachRadius = MyBot.StrafeDistance;
		MyBot.PushState('LongRangeMove');
	}
}

// Notice when nearby enemies change weapon state, so windup ends can be predicted.
function TrackThreats()
{
	local AOCPawn P;
	local int i;
	local name S;

	for (i = Threats.Length - 1; i >= 0; i--)
	{
		if (Threats[i].P == none || Threats[i].P.Health <= 0 || VSize(Threats[i].P.Location - MyPawn.Location) > ThreatRange * 1.5f)
			Threats.Remove(i, 1);
	}
	foreach WorldInfo.AllPawns(class'AOCPawn', P, MyPawn.Location, ThreatRange)
	{
		if (P == MyPawn || P.Health <= 0 || !IsEnemy(P))
			continue;
		for (i = 0; i < Threats.Length; i++)
			if (Threats[i].P == P)
				break;
		if (i == Threats.Length)
		{
			Threats.Add(1);
			Threats[i].P = P;
		}
		S = WeaponState(P);
		if (S != Threats[i].LastState)
		{
			Threats[i].LastState = S;
			Threats[i].StateStart = WorldInfo.TimeSeconds;
		}
	}
}

// When this threat's swing will start striking; 0 if it isn't winding up.
function float SwingEnd(BrainThreat T)
{
	local AOCWeapon PW;
	local float Len;

	PW = AOCWeapon(T.P.Weapon);
	if (PW == none)
		return 0.f;
	if (T.LastState == 'Release')
		return T.StateStart;
	if (T.LastState != 'Windup' && T.LastState != 'Transition')
		return 0.f;
	Len = PW.WindupAnimations[PW.CurrentFireMode].fAnimationLength;
	if (Len <= 0.f)
		Len = 0.5f;
	if (T.LastState == 'Transition')
		Len *= 0.85f;
	return T.StateStart + Len;
}

function bool AimedAtMe(AOCPawn P)
{
	return (vector(P.Rotation) dot Normal(MyPawn.Location - P.Location)) >= MyBot.fMenacingDot && MyBot.LineOfSightTo(P);
}

function float ParryLength(AOCMeleeWeapon W)
{
	if (W.bEquipShield)
		return 0.4f;
	return FClamp(W.ReleaseAnimations[Attack_Parry].fAnimationLength, 0.3f, 0.7f);
}

function RunDefence(AOCMeleeWeapon W)
{
	local int i, Best;
	local float End, BestEnd, Now, MyEnd, Contact, React;
	local name MyState, TS;

	Now = WorldInfo.TimeSeconds;
	MyState = W.GetStateName();

	// Pick the soonest swing aimed at us.
	Best = -1;
	for (i = 0; i < Threats.Length; i++)
	{
		End = SwingEnd(Threats[i]);
		if (End <= 0.f || Now - End > 0.35f || !AimedAtMe(Threats[i].P))
			continue;
		if (Best < 0 || End < BestEnd)
		{
			Best = i;
			BestEnd = End;
		}
	}

	// Vanilla's random parry would fire on top of our timed one.
	if (Best >= 0 || PressAt > 0.f)
	{
		MyBot.bForceBlock = false;
		MyBot.ClearTimer('DoParry');
	}

	if (Best >= 0 && (Threats[Best].P != PlanThreat || Abs(BestEnd - PlanEnd) > 0.03f))
	{
		// Our own swing lands first by a clear margin: keep swinging.
		MyEnd = 0.f;
		if (MyState == 'Windup')
			MyEnd = MyStateStart + W.WindupAnimations[W.CurrentFireMode].fAnimationLength;
		if (MyState == 'Release' || (MyEnd > 0.f && MyEnd < BestEnd - 0.1f))
			return;

		React = SkillLerp(ReactSlow, ReactFast) * (0.85f + 0.3f * FRand());
		Contact = BestEnd + ContactLead;
		PlanThreat = Threats[Best].P;
		PlanEnd = BestEnd;
		PressAt = FMax(Now + React, Contact - ParryLength(W) * 0.45f + Jitter(SkillLerp(ErrSlow, ErrFast)));

		// Mid-windup, feint out first if we still can; otherwise we have to take the trade.
		if (MyState == 'Windup')
		{
			if (W.bCanFeint && MyPawn.Stamina > W.iFeintStaminaCost && FRand() < MyBot.fSkill)
				W.DoFeintAttack();
			else
				PressAt = 0.f;
		}
	}

	if (PressAt > 0.f && Now >= PressAt)
	{
		PressAt = 0.f;
		TS = WeaponState(PlanThreat);
		// The planned swing vanished (feint): skilled bots hold, the rest get baited.
		if (TS != 'Windup' && TS != 'Transition' && TS != 'Release' && FRand() < MyBot.fSkill * 0.7f)
			return;
		MyPawn.StartFire(Attack_Parry);
		if (W.bEquipShield)
			ShieldDropAt = Now + 0.5f;
	}
	if (ShieldDropAt > 0.f && Now >= ShieldDropAt)
	{
		ShieldDropAt = 0.f;
		W.LowerShield();
	}
}

// After a successful parry, counter while the riposte is available.
function TryRiposte(AOCMeleeWeapon W)
{
	if (!W.IsInState('ParryRelease') || !W.bSuccessfulParry || W.bParryHitCounter || W.bEquipShield)
	{
		RiposteAt = 0.f;
		return;
	}
	if (RiposteAt == 0.f)
		RiposteAt = FRand() < SkillLerp(0.35f, 0.95f) ? WorldInfo.TimeSeconds + SkillLerp(0.3f, 0.08f) : -1.f;
	if (RiposteAt > 0.f && WorldInfo.TimeSeconds >= RiposteAt)
	{
		RiposteAt = -1.f;
		MyPawn.StartFire(EAttack(Rand(3)));
	}
}

// Openings first (whiffs, missed parries, flinches, feints), otherwise a steady rhythm.
function ConsiderAttack(AOCMeleeWeapon W)
{
	local AOCPawn T;
	local float Now, Dist, Reach, Gap;
	local name TS;

	Now = WorldInfo.TimeSeconds;
	T = MyBot.myCombatTarget;
	if (T == none || T.Health <= 0 || MyBot.bRemainStill || MyBot.bParryOnly || MyBot.bTurtleOnly || MyBot.bDodgeOnly)
		return;
	if (!W.IsInState('Active') || PressAt > 0.f || MyBot.IsInState('MeleeAttack'))
		return;

	Dist = VSize(T.Location - MyPawn.Location);
	Reach = MyBot.CalculateVanillaAttackStartDistance(Attack_Slash) + T.GetCollisionRadius() + 30.f;
	TS = WeaponState(T);

	if (TS == 'Recovery' || TS == 'Feint' || TS == 'Flinch' || TS == 'Hit' || TS == 'Deflect' || TS == 'WorldDeflect')
	{
		if (Dist > Reach + 40.f)
			return;
		if (PunishAt == 0.f)
			PunishAt = FRand() < SkillLerp(PunishSlow, PunishFast) ? Now + SkillLerp(ReactSlow, ReactFast) : -1.f;
		if (PunishAt > 0.f && Now >= PunishAt)
		{
			PunishAt = -1.f;
			MyPawn.StartFire(EAttack(Rand(3)));
		}
		return;
	}
	PunishAt = 0.f;

	// Don't start into a swing that is already about to land on us.
	if (TS == 'Windup' || TS == 'Transition' || TS == 'Release')
		return;
	if (!MyBot.IsInState('MeleeStance') || Now < NextPressureAt || Dist > Reach * 1.6f)
		return;

	Gap = SkillLerp(GapSlow, GapFast) * (0.7f + 0.6f * FRand());
	if (bIsKing)
		Gap *= KingGapScale;
	if (T.Stamina < 40.f)
		Gap *= 0.6f;
	NextPressureAt = Now + Gap;
	if (MyPawn.Stamina >= LowStamina || FRand() < 0.3f)
		MyBot.GotoState('MeleeAttack');
}

// CompForest only: when no enemies are around, drift toward a nearby teammate instead of
// standing alone. Follows humans first, then other bots; the King is excluded (it holds
// the throne). Only moves while the bot is truly idle (state Active), so squad and
// objective orders always win.
function FollowTeammates()
{
	local AOCPawn Follow;
	local float Dist;

	if (!bCompForest || bIsKing)
		return;
	if (MyBot == none || MyBot.myCombatTarget != none)
		return;
	if (MyBot.bRemainStill || MyBot.IsInState('MeleeAttack') || MyBot.IsInState('MeleeStance'))
		return;
	if (!MyBot.IsInState('Active'))
		return;
	if (WorldInfo.TimeSeconds < NextFollowAt)
		return;
	NextFollowAt = WorldInfo.TimeSeconds + FollowReissueInterval;

	if (HasEnemyNear(FollowEnemyRange))
		return;

	Follow = FindFollowTeammate();
	if (Follow == none)
		return;

	Dist = VSize(Follow.Location - MyPawn.Location);
	if (Dist <= FollowDist + MyPawn.GetCollisionRadius())
		return;

	MyBot.myMoveTarget = Follow;
	MyBot.myDestReachRadius = FollowDist;
	MyBot.PushState('LongRangeMove');
}

function bool HasEnemyNear(float Range)
{
	local AOCPawn P;

	foreach WorldInfo.AllPawns(class'AOCPawn', P, MyPawn.Location, Range)
	{
		if (P == MyPawn || P.Health <= 0 || !IsEnemy(P))
			continue;
		return true;
	}
	return false;
}

// Nearest alive teammate, humans preferred so the pack clusters on human anchors; on a
// bot-only server the bots still fall back to grouping on each other.
function AOCPawn FindFollowTeammate()
{
	local AOCPawn P, BestHuman, BestBot;
	local float D, BestHumanD, BestBotD;

	BestHumanD = FollowRange;
	BestBotD = FollowRange;

	foreach WorldInfo.AllPawns(class'AOCPawn', P, MyPawn.Location, FollowRange)
	{
		if (P == MyPawn || P.Health <= 0 || P.GetTeamNum() != MyPawn.GetTeamNum())
			continue;

		D = VSize(P.Location - MyPawn.Location);
		if (P.bIsBot)
		{
			if (D < BestBotD)
			{
				BestBot = P;
				BestBotD = D;
			}
		}
		else if (D < BestHumanD)
		{
			BestHuman = P;
			BestHumanD = D;
		}
	}

	if (BestHuman != none)
		return BestHuman;
	return BestBot;
}

DefaultProperties
{
	RemoteRole=ROLE_None

	SkillFloor=0.95
	KingSkillFloor=0.95
	Aggression=0.75
	KingAggression=1.0
	ReactSlow=0.32
	ReactFast=0.12
	ErrSlow=0.22
	ErrFast=0.05
	ContactLead=0.15
	ThreatRange=500.0
	PunishSlow=0.35
	PunishFast=0.95
	GapSlow=1.5
	GapFast=0.6
	KingGapScale=0.7
	ComboChance=0.65
	KingComboChance=0.8
	LowStamina=25.0
	MaxLead=0.6
	ChaseSprintDist=450.0
	StuckDist=25.0
	FollowRange=2500.0
	FollowDist=400.0
	FollowEnemyRange=1800.0
	FollowReissueInterval=1.5
}
