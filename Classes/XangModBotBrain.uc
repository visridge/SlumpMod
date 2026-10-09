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
class XangModBotBrain extends Info config(Game);

struct BrainThreat
{
	var AOCPawn P;
	var name LastState;
	var float StateStart;
};

var AOCPawn MyPawn;
var AOCAICombatController MyBot;
var array<BrainThreat> Threats;

// VO / chatter
var float LastHealth;                          // MyPawn.Health snapshot (damage taunt)
var AOCPawn PrevTarget;                        // last combat target ("all clear" transition)
var float NextVOAt;                            // cooldown gate between voice lines
var float VOMinInterval;                       // min seconds between voice lines
var float VOChance;                            // chance a calm bot calls out near a teammate

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
var float FocusUnlockAt;
var Actor Home;             // where we spawned; Kings are leashed to it
var Actor Post;             // high ground near home a King waits on, if the map has any
var float NextHomeAt;
var bool bFollowMap;                           // set in Init: this map allows teammate following
var float NextFollowAt;                        // throttle for FollowTeammates
var int PostTries;          // moves toward Post that got no closer; give up on it after a few
var float PostDist;    // we turned to face a threat that isn't our target; release the lock then

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
var float ThreatDot;                           // facing cosine for a swing to count as aimed at us
var float ThreatReach;                         // a swing further than this at contact can't reach us
var float DodgeChance;                         // dodge instead of parry, dodge-capable classes
var float KingLeash;                           // Kings further than this from home walk back
var float KingEngage;                          // ...unless an enemy is within this of home
var float KingHighGround;                      // a nav point this far above the throne counts as high ground
var float OnUsDot;                             // during a release, the blade counts as on us past this facing
var config string FollowMaps;                  // [XangMod.XangModBotBrain] comma-separated maps that allow following; "*" = every map
var float FollowRange;                         // max distance to consider a teammate worth following
var float FollowDist;                          // stop this far from the followed teammate
var float FollowEnemyRange;                    // any enemy nearer than this stops the follow
var float FollowReissueInterval;               // how often to (re)consider following

function Init(AOCPawn P)
{
	MyPawn = P;
	MyBot = AOCAICombatController(P.Controller);
	bIsKing = P.PawnFamily != none && P.PawnFamily.ClassReference == ECLASS_King;
	Home = P.LastStartSpot;
	if (bIsKing)
		FindPost();
	bFollowMap = MapListed(FollowMaps != "" ? FollowMaps : "CompForest,KingsGarden,Stoneshill");
	LastHealth = P.Health;
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

	if (bIsKing && KeepHome())
		return;
	Pursue();
	TrackThreats();
	Chatter();
	FollowTeammates();
	RunDefence(W);
	TryRiposte(W);
	ConsiderAttack(W);
}

event Destroyed()
{
	if (MyBot != none && MyBot.vStrafeTarget == self)
		MyBot.vStrafeTarget = MyBot.myCombatTarget;
	if (MyBot != none && FocusUnlockAt > 0.f)
		MyBot.ReleaseFocusLock();
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

// Letters and digits only, lower case, so map titles and package names compare alike.
function string NameKey(string S)
{
	local string Out, C;
	local int i;

	S = Locs(S);
	for (i = 0; i < Len(S); i++)
	{
		C = Mid(S, i, 1);
		if (InStr("abcdefghijklmnopqrstuvwxyz0123456789", C) != INDEX_NONE)
			Out $= C;
	}
	return Out;
}

// True if this map's title or package name contains any entry of a comma-separated list; "*" lists every map.
function bool MapListed(string List)
{
	local string Map, Item;
	local int Cut;

	if (List == "*")
		return true;
	Map = NameKey(WorldInfo.GetMapName()) $ "|" $ NameKey(string(WorldInfo.GetPackageName()));
	while (List != "")
	{
		Cut = InStr(List, ",");
		Item = Cut == INDEX_NONE ? List : Left(List, Cut);
		List = Cut == INDEX_NONE ? "" : Mid(List, Cut + 1);
		if (NameKey(Item) != "" && InStr(Map, NameKey(Item)) != INDEX_NONE)
			return true;
	}
	return false;
}

// Facing cosine from P toward us.
function float FaceDot(AOCPawn P)
{
	return vector(P.Rotation) dot Normal(MyPawn.Location - P.Location);
}

// Nearest enemy to a point, within Range.
function float EnemyDistFrom(vector At, float Range)
{
	local AOCPawn P;
	local float D, Best;

	Best = Range;
	foreach WorldInfo.AllPawns(class'AOCPawn', P, At, Range)
	{
		if (P == MyPawn || P.Health <= 0 || !IsEnemy(P))
			continue;
		D = VSize(P.Location - At);
		if (D < Best)
			Best = D;
	}
	return Best;
}

// Solid ground under a point, within a step or so.
function bool HasFloor(vector Pt)
{
	local vector HitLoc, HitNorm, Ext;

	Ext = MyPawn.GetCollisionRadius() * 0.5f * vect(1,1,0);
	Ext.Z = 10.f;
	return Trace(HitLoc, HitNorm, Pt - vect(0,0,1) * (MyPawn.GetCollisionHeight() + MyPawn.MaxStepHeight + 60.f), Pt + vect(0,0,1) * 20.f, false, Ext) != none;
}

// Room to fight: floor on all four sides, so planks and ledges are out.
function bool HasRoom(vector Pt, float R)
{
	return HasFloor(Pt + vect(1,0,0) * R) && HasFloor(Pt - vect(1,0,0) * R)
		&& HasFloor(Pt + vect(0,1,0) * R) && HasFloor(Pt - vect(0,1,0) * R);
}

// Highest nav point within the leash that sits above the throne floor: balconies, stairs, walls.
function FindPost()
{
	local NavigationPoint N;
	local float Score, Best;

	Post = none;
	if (Home == none)
		return;
	foreach WorldInfo.RadiusNavigationPoints(class'NavigationPoint', N, Home.Location, KingLeash)
	{
		if (N.Location.Z < Home.Location.Z + KingHighGround || N.Location.Z > Home.Location.Z + 1200.f)
			continue;
		if (!HasRoom(N.Location, 110.f))
			continue;
		// Height first, nearer the throne as a tiebreak.
		Score = (N.Location.Z - Home.Location.Z) - 0.3f * VSize2D(N.Location - Home.Location);
		if (Post == none || Score > Best)
		{
			Post = N;
			Best = Score;
		}
	}
}

// Kings hold the throne: fight whatever comes near it, walk back when nothing does. True while walking.
function bool KeepHome()
{
	local float Now, Dist;
	local bool bAway;
	local Actor Goal;

	if (Home == none)
		return false;
	Now = WorldInfo.TimeSeconds;
	if (MyBot.IsInState('LongRangeMove'))
		return MyBot.myMoveTarget == Home || MyBot.myMoveTarget == Post;
	// Leash is measured flat, so the floors above the throne are still "home".
	Dist = VSize2D(MyPawn.Location - Home.Location);
	bAway = Dist > KingLeash || Abs(MyPawn.Location.Z - Home.Location.Z) > 1200.f;
	if (Now < NextHomeAt || MyBot.IsInState('MeleeAttack'))
		return false;
	// An enemy near the throne, or on us, is worth fighting out here.
	if (EnemyDistFrom(Home.Location, KingEngage) < KingEngage || EnemyDistFrom(MyPawn.Location, 350.f) < 350.f)
		return false;
	// Nothing coming: take the high ground if the map has it, else the throne.
	Goal = Post != none ? Post : Home;
	if (!bAway && VSize(MyPawn.Location - Goal.Location) < 200.f)
		return false;
	NextHomeAt = Now + 3.f;
	// A post we can't path to (a ledge, a locked door) is abandoned for the throne.
	if (Goal == Post)
	{
		if (PostDist > 0.f && VSize(MyPawn.Location - Post.Location) > PostDist - 100.f)
			PostTries++;
		PostDist = VSize(MyPawn.Location - Post.Location);
		if (PostTries >= 3)
		{
			Post = none;
			Goal = Home;
		}
	}
	StopChaseSprint();
	if (MyBot.vStrafeTarget == self)
		MyBot.vStrafeTarget = MyBot.myCombatTarget;
	MyBot.myMoveTarget = Goal;
	MyBot.myDestReachRadius = 120.f;
	MyBot.PushState('LongRangeMove');
	return true;
}

// A friendly standing in the swing would eat it.
function bool TeammateInArc(float Reach)
{
	local AOCPawn P;
	local vector Fwd;

	Fwd = vector(MyPawn.Rotation);
	foreach WorldInfo.AllPawns(class'AOCPawn', P, MyPawn.Location, Reach)
	{
		if (P == MyPawn || P.Health <= 0 || IsEnemy(P))
			continue;
		if ((Fwd dot Normal(P.Location - MyPawn.Location)) > 0.75f)
			return true;
	}
	return false;
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
	if (bIsKing && Home != none && VSize2D(T.Location - Home.Location) > KingEngage)
		bChasing = false; // let them come to the throne

	if (bSee && bChasing)
	{
		Lead = T.Location + T.Velocity * FClamp(Dist / FMax(MyPawn.GroundSpeed, 1.f), 0.f, MaxLead);
		Lead.Z = T.Location.Z;
		if (!FastTrace(Lead, MyPawn.Location))
			Lead = T.Location;
		// A step toward it would leave the floor (gap, plank edge): let vanilla path instead.
		if (!HasFloor(MyPawn.Location + Normal(Lead - MyPawn.Location) * 120.f))
		{
			if (MyBot.vStrafeTarget == self)
				MyBot.vStrafeTarget = T;
			StopChaseSprint();
			return;
		}
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

// Aimed our way, in sight, and close enough to land once it releases.
function bool AimedAtMe(AOCPawn P, float End)
{
	local vector At;

	At = P.Location + P.Velocity * FClamp(End - WorldInfo.TimeSeconds, 0.f, 0.6f);
	if (VSize(At - MyPawn.Location) > ThreatReach + P.GetCollisionRadius() + MyPawn.GetCollisionRadius())
		return false;
	return FaceDot(P) >= ThreatDot && MyBot.LineOfSightTo(P);
}

// How long a threat's release lasts; drags stretch the real contact out to about this.
function float ReleaseLength(AOCPawn P)
{
	local AOCWeapon PW;

	PW = AOCWeapon(P.Weapon);
	if (PW == none)
		return 0.6f;
	return FClamp(PW.ReleaseAnimations[PW.CurrentFireMode].fAnimationLength, 0.35f, 1.0f);
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
		if (End <= 0.f || Now - End > ReleaseLength(Threats[i].P) + 0.2f || !AimedAtMe(Threats[i].P, End))
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

	if (Best >= 0 && (Threats[Best].P != PlanThreat || Abs(BestEnd - PlanEnd) > 0.15f)) // windup->release re-estimates by a few frames; only real morphs re-plan
	{
		// Our own swing lands first by a clear margin: keep swinging.
		MyEnd = 0.f;
		if (MyState == 'Windup')
			MyEnd = MyStateStart + W.WindupAnimations[W.CurrentFireMode].fAnimationLength;
		if (MyState == 'Release' || (MyEnd > 0.f && MyEnd < BestEnd - 0.1f))
			return;

		React = SkillLerp(ReactSlow, ReactFast) * (0.85f + 0.3f * FRand());
		if (Threats[Best].LastState == 'Release')
			React *= 0.6f; // reverse overheads and late turns: we're reacting to a blade already moving
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
		// The parry box faces our target; turn to the attacker when it's someone else.
		if (PressAt > 0.f && PlanThreat != MyBot.myCombatTarget && !MyBot.IsInState('MeleeAttack'))
		{
			MyBot.ScriptedFocusOnActor(PlanThreat, true);
			FocusUnlockAt = Contact + 0.4f;
		}
	}
	if (FocusUnlockAt > 0.f)
	{
		if (Now >= FocusUnlockAt || PlanThreat == none || PlanThreat.Health <= 0)
		{
			FocusUnlockAt = 0.f;
			MyBot.ReleaseFocusLock();
		}
		else
			MyBot.FocusOnActor(PlanThreat); // keep the locked focal point on them as they move
	}

	if (PressAt > 0.f && Now >= PressAt)
	{
		PressAt = 0.f;
		TS = WeaponState(PlanThreat);
		// The planned swing vanished (feint): skilled bots hold, the rest get baited.
		if (TS != 'Windup' && TS != 'Transition' && TS != 'Release' && FRand() < MyBot.fSkill * 0.7f)
			return;
		// Drag read: they're releasing but looking away, so the blade isn't here yet. Wait for it to
		// come round, up to the point where the swing must be past us anyway. Skill decides who can.
		if (TS == 'Release' && FaceDot(PlanThreat) < OnUsDot && Now < PlanEnd + ReleaseLength(PlanThreat) * 0.5f
			&& FRand() < MyBot.fSkill)
		{
			PressAt = Now + 0.05f;
			return;
		}
		if (MyPawn.PawnFamily.bCanDodge && MyPawn.Stamina > LowStamina + 15.f && FRand() < DodgeChance)
		{
			MyBot.DodgeRandom();
			return;
		}
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
		if (!MyBot.IsInState('MeleeAttack'))
			MyBot.GotoState('MeleeAttack'); // vanilla picks the swing and handles combos
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
	if (!W.IsInState('Active') || PressAt > 0.f || !MyBot.IsInState('MeleeStance') || MyBot.IsInState('MeleeAttack'))
		return;

	Dist = VSize(T.Location - MyPawn.Location);
	Reach = MyBot.CalculateVanillaAttackStartDistance(Attack_Slash) + T.GetCollisionRadius() + 30.f;
	TS = WeaponState(T);
	if (TeammateInArc(Reach))
		return;

	if (TS == 'Recovery' || TS == 'Feint' || TS == 'Flinch' || TS == 'Hit' || TS == 'Deflect' || TS == 'WorldDeflect')
	{
		if (Dist > Reach + 40.f)
			return;
		if (PunishAt == 0.f)
			PunishAt = FRand() < SkillLerp(PunishSlow, PunishFast) ? Now + SkillLerp(ReactSlow, ReactFast) : -1.f;
		if (PunishAt > 0.f && Now >= PunishAt)
		{
			PunishAt = -1.f;
			MyBot.GotoState('MeleeAttack');
		}
		return;
	}
	PunishAt = 0.f;

	// Don't start into a swing that is already about to land on us.
	if (TS == 'Windup' || TS == 'Transition' || TS == 'Release')
		return;
	if (Now < NextPressureAt || Dist > Reach * 1.6f)
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

// When no enemies are around, drift toward a nearby teammate instead of standing alone.
// Humans first, then other bots; the King is excluded (it holds the throne). Only moves while
// the bot is truly idle (state Active), so squad and objective orders always win.
function FollowTeammates()
{
	local AOCPawn Follow;
	local float Dist;

	if (!bFollowMap || bIsKing)
		return;
	if (MyBot.myCombatTarget != none || MyBot.bRemainStill || !MyBot.IsInState('Active'))
		return;
	if (WorldInfo.TimeSeconds < NextFollowAt)
		return;
	NextFollowAt = WorldInfo.TimeSeconds + FollowReissueInterval;

	if (EnemyDistFrom(MyPawn.Location, FollowEnemyRange) < FollowEnemyRange)
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
		if (P == MyPawn || P.Health <= 0 || IsEnemy(P))
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

// ---- VO / chatter ----
// Vanilla Z/X menus (PlayZMenuVO/PlayXMenuVO) early-return on dedicated servers and only
// replicate while Role < ROLE_Authority, so a bot's server-owned pawn would say nothing.
// Call the static cue lookup directly and replicate through s_PlayVO, the same path a human
// voice command takes to other clients. Indices are 0-based (menu key "N" = N-1).
function SayTactical(int Index)
{
	local SoundCue Cue;

	if (MyPawn == none || MyPawn.SoundGroupClass == none)
		return;
	class<AOCPawnSoundGroup>(MyPawn.SoundGroupClass).static.getAOCZMenuVO(MyPawn, Index, Cue);
	if (Cue != none)
		MyPawn.s_PlayVO(Cue);
}

function SaySocial(int Index)
{
	local SoundCue Cue;

	if (MyPawn == none || MyPawn.SoundGroupClass == none)
		return;
	class<AOCPawnSoundGroup>(MyPawn.SoundGroupClass).static.getAOCXMenuVO(MyPawn, Index, Cue);
	if (Cue != none)
		MyPawn.s_PlayVO(Cue);
}

// Four cheap triggers mapped onto the menus, cooldown-gated so a bot never spams:
// hurt -> taunt (X+8), enemy acquired -> "hold your ground" (Z+6), enemy gone -> "all clear"
// (Z+0), and the occasional "follow me"/"forward" (Z+1/Z+2) when calm near a teammate.
function Chatter()
{
	local bool bHurt;
	local AOCPawn Target;
	local int Idx;

	Target = MyBot.myCombatTarget;
	bHurt = MyPawn.Health < LastHealth;

	if (bHurt && MyPawn.Health > 0 && WorldInfo.TimeSeconds >= NextVOAt)
	{
		NextVOAt = WorldInfo.TimeSeconds + VOMinInterval + FRand() * 1.5f;
		SaySocial(7);
	}
	else if (Target != none && Target != PrevTarget && WorldInfo.TimeSeconds >= NextVOAt)
	{
		NextVOAt = WorldInfo.TimeSeconds + VOMinInterval + FRand() * 1.5f;
		SayTactical(7);
	}
	else if (Target == none && PrevTarget != none && WorldInfo.TimeSeconds >= NextVOAt)
	{
		NextVOAt = WorldInfo.TimeSeconds + VOMinInterval + FRand() * 1.5f;
		SayTactical(9);
	}
	else if (Target == none && PrevTarget == none && WorldInfo.TimeSeconds >= NextVOAt)
	{
		// Re-arm regardless so we don't sweep AllPawns every 50 ms looking for a teammate.
		NextVOAt = WorldInfo.TimeSeconds + VOMinInterval + FRand() * 1.5f;
		if (FindFollowTeammate() != none && FRand() < VOChance)
		{
			Idx = (FRand() < 0.5f) ? 0 : 1;
			SayTactical(Idx);
		}
	}

	LastHealth = MyPawn.Health;
	PrevTarget = Target;
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
	ThreatDot=0.55
	ThreatReach=340.0
	DodgeChance=0.1
	KingLeash=700.0
	KingEngage=1400.0
	KingHighGround=150.0
	OnUsDot=0.8
	FollowRange=3000.0
	FollowDist=400.0
	FollowEnemyRange=1800.0
	FollowReissueInterval=1.5
	VOMinInterval=3.0
	VOChance=0.05
}
