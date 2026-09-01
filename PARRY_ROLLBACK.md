Updated todo list

I can edit fine — those two tool calls were interrupted by your new messages before they executed, so nothing was written (the file is still untouched, as you saw). Switching to ask-mode: I'll print everything. Let me confirm a couple of hierarchy/context details first so the blocks are exact.

Read [](file:///c%3A/Program%20Files%20%28x86%29/Steam/steamapps/common/chivalrymedievalwarfare/Development/Src/XangMod/Include/XangModPawn.uci#14-33), lines 14 to 32

Read [](file:///c%3A/Program%20Files%20%28x86%29/Steam/steamapps/common/chivalrymedievalwarfare/Development/Src/AOC/classes/CDWDuelPawn.uc#1-61), lines 1 to 60

Searched for files matching `^class (XangModCDWDuelPawn|CDWDuelPawn|GiantSlayersPawn|XangModAOCDuelPawn)\b`, 4 results







Both mod duel pawns (`XangModAOCDuelPawn`, `XangModCDWDuelPawn`) extend `XangModPawn`, so they inherit the rewrite. Let me confirm they don't override `AttackOtherPawn`/`Tick` in a way that bypasses it.

Searched for files matching `AttackOtherPawn|event Tick|ProcessResolvedAttack|ProcessPendingHits`.

Searched for files matching `AttackOtherPawn|event Tick|ProcessResolvedAttack|ProcessPendingHits`.



Confirmed: the real mod pawns (`XangModAOCDuelPawn`, `XangModCDWDuelPawn`) extend `XangModPawn` and don't override these functions, so the rewrite covers bots-in-duel. Here's the complete decide‑once rewrite as copy‑paste blocks.

## Why it's currently broken
At 0 ping, bots enter `Parry` within the flat 60 ms defer window → `RollbackRecentHits` clears the `ApplyDeferredReplication` timer → the **entire** hit (which was 100 % deferred) is dropped: no damage/sound/blood. And when it *doesn't* cancel, you get commit‑then‑refund (the "bloody but alive" bug).

The fix: **hold** an incoming swing only as long as an in‑flight parry could take to arrive (= defender's one‑way ping, capped; **0 at 0 ping**). During the hold nothing is applied. A parry in the window resolves the held swing *as a parry* (canonical `DetectSuccessfulParry`); otherwise it commits once through the normal immediate path.

---

### File 1 — `XangMod\Classes\XangModPawn.uc`
**Replace lines 3–14** (the `RecentHitEntry` struct + 2 vars) with:

```unrealscript
// XANGMOD: Parry rollback — "decide once" netcode.
// An incoming melee swing is HELD on the defender for a latency-sized window (the time an
// in-flight parry could still take to reach the server). Nothing is applied during the hold,
// so a parry that lands inside the window suppresses the swing before any feedback plays —
// no commit-then-refund. At 0 ping the hold is 0 and the hit resolves instantly (vanilla).
// Defined here in the base class (not the .uci include) so every subclass shares one
// PendingHit type rather than each getting its own copy.
struct PendingHit
{
    var float fCommitTime;              // WorldInfo.TimeSeconds at which to commit the hit
    var XangModPawn Attacker;           // pawn that swung (resolves the hit / takes the deflect)
    var HitInfo Info;                   // captured hit info
    var string DamageString;
    var bool bBoxParrySuccess;
    var bool bHitShield;
    var SwingTypeImpactSound LastHit;
    var bool bQuickKick;
};
var array<PendingHit> PendingHits;       // swings held on this (defender) pawn awaiting resolution
var float fParryRollbackMaxHoldSeconds;  // cap on how long a swing may be held (s)
var float fParryRollbackMinHoldSeconds;  // holds shorter than this resolve immediately (s)
```

---

### File 2 — `XangMod\Include\XangModPawn.uci`

**(2a) Delete lines 18–30** (the deferred-state `var` block). Replace with nothing, or a one-liner:

```unrealscript
// (Deferred-hit state removed — replaced by the PendingHits hold model in XangModPawn.uc)
```

**(2b) Tick — insert the commit poll.** Change the top of `Tick` (around line 271):

```unrealscript
	// Call parent first to do all normal tick logic
	super.Tick(DeltaTime);

	// XANGMOD: commit any held swings whose latency window elapsed without a parry.
	if (Role == ROLE_Authority)
		ProcessPendingHits();

	if (Physics == PHYS_Walking || Physics == PHYS_Ladder || Physics == PHYS_Spider)
	{
		bKanaboExtraJumpUsed = false;
	}
```

**(2c) Replace the ENTIRE `AttackOtherPawn` function (current lines 1195–1714)** with these **two** functions:

```unrealscript
// XANGMOD: Thin dispatcher. Validates the swing once on RPC arrival, then either holds it
// (so an in-flight parry can suppress it before any feedback plays) or resolves it immediately.
// 'self' is the ATTACKER; Info.HitActor is the defender.
reliable server function AttackOtherPawn(HitInfo Info, string DamageString, optional bool bCheckParryOnly = false, optional bool bBoxParrySuccess, optional bool bHitShield = false, optional SwingTypeImpactSound LastHit = ESWINGSOUND_Slash, optional bool bQuickKick = false)
{
	local PlayerReplicationInfo PRI;
	local XangModPawn DefenderBM;
	local float fHold;
	local PendingHit NewPending;

	if (PlayerReplicationInfo == none)
		PRI = Info.PRI;
	else
		PRI = PlayerReplicationInfo;
	Info.PRI = PRI;

	LogHitTime(WorldInfo.TimeSeconds - fLastReleaseStartTime - 0.0087);

	// Block attacks while the attacker is flinched (no trade window)
	if (XangModMeleeWeapon(Weapon) != none && XangModMeleeWeapon(Weapon).IsInState('Flinch'))
		return;

	// Authority / lag-comp validation happens once, when the swing RPC arrives.
	if (!PerformAttackSSSC(Info) && WorldInfo.NetMode != NM_Standalone)
		return;

	// Decide whether to HOLD this swing so an in-flight parry can suppress it before any
	// feedback plays. Only enemy melee swings that would land as a hit are eligible; the hold
	// length is the defender's one-way latency (0 at 0 ping -> instant, vanilla behavior).
	DefenderBM = XangModPawn(Info.HitActor);
	fHold = 0.0;
	if (!bCheckParryOnly
		&& DefenderBM != none
		&& !Info.DamageType.default.bIsProjectile
		&& Info.AttackType != Attack_Shove
		&& !IsOnSameTeam(self, Info.HitActor)
		&& !Info.HitActor.StateVariables.bIsParrying
		&& !Info.HitActor.StateVariables.bIsActiveShielding)
	{
		fHold = DefenderBM.GetParryHoldSeconds();
	}

	if (fHold > 0.0)
	{
		NewPending.fCommitTime = WorldInfo.TimeSeconds + fHold;
		NewPending.Attacker = self;
		NewPending.Info = Info;
		NewPending.DamageString = DamageString;
		NewPending.bBoxParrySuccess = bBoxParrySuccess;
		NewPending.bHitShield = bHitShield;
		NewPending.LastHit = LastHit;
		NewPending.bQuickKick = bQuickKick;
		DefenderBM.PendingHits.AddItem(NewPending);
		return;
	}

	ProcessResolvedAttack(Info, DamageString, bCheckParryOnly, bBoxParrySuccess, bHitShield, LastHit, bQuickKick);
}

// XANGMOD: The single commit path for a swing — damage, feedback, and replication applied at
// once. Called directly from AttackOtherPawn (no hold needed), or from ProcessPendingHits /
// ResolvePendingHitsAsParry once a held swing's fate is decided. 'self' is the ATTACKER.
// When bForceParry is true the swing resolves as a parry (the defender parried while this swing
// was held); DetectSuccessfulParry still rejects illegal parries (e.g. back hits), which then
// fall through to a normal hit. Nothing is ever played and then undone.
function ProcessResolvedAttack(HitInfo Info, string DamageString, optional bool bCheckParryOnly = false, optional bool bBoxParrySuccess = false, optional bool bHitShield = false, optional SwingTypeImpactSound LastHit = ESWINGSOUND_Slash, optional bool bQuickKick = false, optional bool bForceParry = false)
{
	local bool bParry;
	local float ActualDamage;
	local bool bSameTeam;
	local bool bFlinch;
	local IAOCAIListener AIList;
	local int i;
	local float Resistance;
	local float GenericDamage;
	local float HitForceMag;
	local PlayerReplicationInfo PRI;
	local bool bOnFire;
	local bool bPassiveBlock;
	local AOCWeaponAttachment HitActorWeaponAttachment;
	local XangModMeleeWeapon DefendingMeleeWeapon;
	local class<AOCWeapon> UsedWeapon;
	local TraceHitInfo THI;
	local bool bEnemyWasBot;
	local bool bWasKilled;
	local float StaminaAtKill;
	local bool bParryActive;
	local float fTimeSinceParryStart;
	local bool bBallistaBolt;

	if (PlayerReplicationInfo == none)
		PRI = Info.PRI;
	else
		PRI = PlayerReplicationInfo;
	Info.PRI = PRI;

	bBallistaBolt = (Info.DamageType == class'AOCDmgType_BallistaBolt');

	if (Info.UsedWeapon == 0)
		UsedWeapon = PrimaryWeapon;
	else if (Info.UsedWeapon == 1)
		UsedWeapon = SecondaryWeapon;
	else
		UsedWeapon = TertiaryWeapon;

	HitActorWeaponAttachment = AOCWeaponAttachment(Info.HitActor.CurrentWeaponAttachment);
	DefendingMeleeWeapon = XangModMeleeWeapon(Info.HitActor.Weapon);

	bSameTeam = IsOnSameTeam(self, Info.HitActor);
	bFlinch = false;

	// Honor live parry flags or a fresh authoritative Parry state whose booleans have not
	// serialized yet (grace period). bForceParry covers a parry that landed while we were held.
	bParryActive = Info.HitActor.StateVariables.bIsParrying || Info.HitActor.StateVariables.bIsActiveShielding;
	if (!bParryActive && DefendingMeleeWeapon != none && Info.HitActor.Weapon.IsInState('Parry'))
	{
		fTimeSinceParryStart = WorldInfo.TimeSeconds - DefendingMeleeWeapon.fServerParryStartTime;
		if (fTimeSinceParryStart > 0 && fTimeSinceParryStart <= DefendingMeleeWeapon.fParryGracePeriod)
			bParryActive = true;
	}

	bParry = (CheckProjectileParry(Info) || bBoxParrySuccess || bForceParry)
			 && bParryActive
			 && class<AOCDmgType_Generic>(Info.DamageType) == none
			 && Info.DamageType != class'AOCDmgType_SiegeWeapon';

	// Only fists can block fists
	if (AOCWeapon_Fists(Info.HitActor.Weapon) != none && class<AOCDmgType_Fists>(Info.DamageType) == none)
		bParry = false;

	// If DetectSuccessfulParry returns false (e.g. butt-parry blocked), treat as a normal hit.
	if (bParry)
		if (!DetectSuccessfulParry(Info, i, bCheckParryOnly, 0))
			bParry = false;

	if (Info.DamageType.default.bIsProjectile && !bParry)
		AOCPRI(PlayerReplicationInfo).NumHits += 1;

	// Passive shield block (projectiles)
	bPassiveBlock = false;
	if (bHitShield && Info.DamageType.default.bIsProjectile) {
		bParry = true;
		Info.HitDamage = 0.0f;
		bPassiveBlock = !Info.HitActor.StateVariables.bIsActiveShielding;
	}

	if (bCheckParryOnly)
		return;

	// Play correct hit sound depending on parry success/failure
	AOCWeaponAttachment(CurrentWeaponAttachment).LastSwingType = LastHit;
	if (!bParry) {
		Info.HitActor.OnActionFailed(EACT_Block);
		Info.HitSound = AOCWeaponAttachment(CurrentWeaponAttachment).PlayHitPawnSound(Info.HitActor);
	} else
		Info.HitSound = AOCWeaponAttachment(CurrentWeaponAttachment).PlayHitPawnSound(Info.HitActor, true);

	if (AOCMeleeWeapon(Info.Instigator.Weapon) != none)
		AOCMeleeWeapon(Info.Instigator.Weapon).bHitPawn = true;

	if (bQuickKick)
		Info.HitDamage = 0;

	// Damage calculation
	ActualDamage = Info.HitDamage;
	GenericDamage = Info.HitDamage * Info.DamageType.default.DamageType[EDMG_Generic];
	ActualDamage -= GenericDamage;

	if (!CheckOtherPawnFacingMe(Info.HitActor) && !Info.DamageType.default.bIsProjectile && !bParry)
		ActualDamage *= PawnFamily.fBackstabModifier;

	if (Info.UsedWeapon == 0 && XangModWeapon_Crossbow(Weapon) != none && Info.DamageType.default.bIsProjectile)
		ActualDamage *= Info.HitActor.PawnFamily.CrossbowLocationModifiers[GetBoneLocation(Info.BoneName)];
	else
		ActualDamage *= (Info.DamageType.default.bIsProjectile ? Info.HitActor.PawnFamily.ProjectileLocationModifiers[GetBoneLocation(Info.BoneName)] :
			Info.HitActor.PawnFamily.LocationModifiers[GetBoneLocation(Info.BoneName)]);

	Resistance = 0;
	for (i = 0; i < ArrayCount(Info.DamageType.default.DamageType); i++)
		Resistance += Info.DamageType.default.DamageType[i] * Info.HitActor.PawnFamily.DamageResistances[i];
	ActualDamage *= Resistance;

	if (PawnFamily.FamilyFaction == Info.HitActor.PawnFamily.FamilyFaction)
		ActualDamage *= AOCGame(WorldInfo.Game).fTeamDamagePercent;

	ActualDamage += GenericDamage;
	ActualDamage = float(Round(ActualDamage));

	if (bBallistaBolt)
		ActualDamage = 0.0f;

	// Stun if the parry costs too much stamina
	if (bParry && !bPassiveBlock && Info.HitActor.Stamina <= 0) {
		bFlinch = true;
		AOCWeapon(Info.HitActor.Weapon).ActivateFlinch(true, Info.HitActor.GetHitDirection(Location), true, true, AOCWeapon(Weapon).bTwoHander);
	}

	// Counter-attack / flinch resolution
	if (Info.AttackType == Attack_Shove && !bParry && !Info.HitActor.StateVariables.bIsSprintAttack) {
		if (!bSameTeam) {
			if (Info.Instigator.StateVariables.bShieldEquipped && Info.HitActor.StateVariables.bIsActiveShielding && !bQuickKick) {
				bFlinch = true;
				AOCWeapon(Info.HitActor.Weapon).ActivateFlinch(true, Info.HitActor.GetHitDirection(Location), true, true, false);
			} else if (!Info.HitActor.StateVariables.bIsActiveShielding)
				AOCWeapon(Info.HitActor.Weapon).ActivateFlinch(true, Info.HitActor.GetHitDirection(Location), false, false, true);

			if (Info.HitActor.StateVariables.bIsActiveShielding && Info.HitActor.Stamina <= 0)
				Info.HitActor.ConsumeStamina(-30.0f);
		}
	}
	else if ((Info.HitActor.StateVariables.bIsParrying || Info.HitActor.StateVariables.bIsActiveShielding) && !bParry && !IsInRiposte(Info.HitActor)) {
		bFlinch = true;
		AOCWeapon(Info.HitActor.Weapon).ActivateFlinch(true, Info.HitActor.GetHitDirection(Location), false, false, AOCWeapon(Weapon).bTwoHander);
	}
	else if ((ShouldActivateFlinch(Info, UsedWeapon) || AOCWeapon_Fists(Info.Instigator.Weapon) != none) && !bParry) {
		if (bSameTeam) {
			AOCWeapon(Weapon).ActivateFlinch(true, GetHitDirection(Info.HitActor.Location), false, false, AOCWeapon(Info.HitActor.Weapon).bTwoHander);
			AOCWeapon(Info.HitActor.Weapon).ActivateFlinch(true, Info.HitActor.GetHitDirection(Location), false, false, AOCWeapon(Weapon).bTwoHander);
		} else {
			AOCWeapon(Info.HitActor.Weapon).ActivateFlinch(true, Info.HitActor.GetHitDirection(Location), false, false, AOCWeapon(Weapon).bTwoHander);
		}
	}
	else if (!bParry && !bSameTeam && AOCWeapon_JavelinThrow(Info.HitActor.Weapon) == none)
		AOCWeapon(Info.HitActor.Weapon).ActivateHitAnim(Info.HitActor.GetHitDirection(Location, false, true), bSameTeam);

	if (Info.HitActor.bInfiniteHealth)
		ActualDamage = 0.0f;

	if (ActualDamage > 0.0f) {
		Info.HitActor.SetHitDebuff();
		LastAttackedBy = Info.Instigator;
		PauseHealthRegeneration();
		Info.HitActor.PauseHealthRegeneration();
		Info.HitActor.DisableSprint(true);
		Info.HitActor.StartSprintRecovery();

		if (Info.DamageType.default.bIsProjectile)
			PlayRangedHitSound();
		else if (!bSameTeam)
			PlayMeleeHit();

		// Read health BEFORE TakeDamage so the death scream isn't doubled with the hit grunt.
		if (Info.HitActor.Health - ActualDamage > 0.0f)
			Info.HitActor.PlayHitSounds(ActualDamage, bFlinch);

		if (AOCPlayerController(Controller) != none)
			AOCPlayerController(Controller).PC_SuccessfulHit();

		if (Info.HitActor.ContributingDamagers.Find(AOCPRI(PlayerReplicationInfo)) == INDEX_NONE && !bSameTeam)
			Info.HitActor.ContributingDamagers.AddItem(AOCPRI(PlayerReplicationInfo));

		Info.HitActor.LastPawnToHurtYou = Controller;

		if (AOCDuel(WorldInfo.Game) == none || CDWDuel(WorldInfo.Game) == none)
			Info.HitActor.SetTimer(10.f, false, 'ClearLastPawnToAttack');

		if (Info.DamageType.default.bIsProjectile)
			Info.HitActor.StruckByProjectile(self, UsedWeapon);
	}

	if (AOCMeleeWeapon(Weapon) != none && Info.HitActor.Health - ActualDamage > 0.0f && Info.AttackType != Attack_Shove && Info.AttackType != Attack_Sprint && !bParry)
		AOCMeleeWeapon(Weapon).NotifyHitPawn();

	// Build replicated hit info
	Info.bParry = bParry;
	Info.DamageString = DamageString;
	if (Info.BoneName == 'b_Neck' && !Info.DamageType.default.bIsProjectile && Info.DamageType.default.bCanDecap && Info.AttackType != Attack_Stab)
		Info.DamageString $= "3";
	else if ((Info.BoneName == 'b_Neck' || Info.BoneName == 'b_Head') && Info.DamageType.default.bIsProjectile) {
		Info.DamageString $= "4";
		if (AOCPlayerController(Controller) != none)
			AOCPlayerController(Controller).NotifyAchievementHeadshot();
	}
	else if ((Info.BoneName == 'b_spine_A' || Info.BoneName == 'b_spine_B' || Info.BoneName == 'b_spine_C' || Info.BoneName == 'b_spine_D') && Info.DamageType.default.bIsProjectile) {
		if (AOCPlayerController(Controller) != none)
			AOCPlayerController(Controller).NotifyCupidProgress();
	}

	// Replicate to clients (repnotify -> HandlePawnGetHit: blood, impact sound, crosshair).
	Info.HitActor.ReplicatedHitInfo = Info;
	Info.HitDamage = ActualDamage;
	Info.HitForce *= int(PawnState != ESTATE_PUSH && PawnState != ESTATE_BATTERING);
	Info.HitForce *= int(!bFlinch);
	HitForceMag = VSize(Info.HitForce);
	Info.HitForce.Z = 0.f;
	Info.HitForce = Normal(Info.HitForce) * HitForceMag;

	if (PRI != none) {
		if (!bSameTeam)
			AOCPRI(PRI).EnemyDamageDealt += ActualDamage;
		else
			if (Info.HitActor.PawnInfo.myFamily.ClassReference != ECLASS_Peasant
				&& Info.HitActor.PlayerReplicationInfo != PRI) {
				AOCPlayerController(Controller).TeamDamageDealt += ActualDamage;
			}
		AOCPRI(PRI).bForceNetUpdate = TRUE;
	}

	if (Info.HitActor.PlayerReplicationInfo != none) {
		AOCPRI(Info.HitActor.PlayerReplicationInfo).DamageTaken += ActualDamage;
		AOCPRI(Info.HitActor.PlayerReplicationInfo).bForceNetUpdate = TRUE;
	}

	bOnFire = Info.HitActor.bIsBurning;
	THI = MakeTraceHitInfoFromHitInfo(Info);
	bEnemyWasBot = Info.HitActor.bIsBot || Info.HitActor.PlayerReplicationInfo.bBot || AOCPRI(Info.HitActor.PlayerReplicationInfo).bIsBot || AOCAIController(Info.HitActor.Controller) != none;

	// Apply damage once.
	Info.HitActor.TakeDamage(ActualDamage, Controller != none ? Controller : CurrentSiegeWeapon.Controller, Info.HitLocation, Info.HitForce, Info.DamageType, THI, self);

	bWasKilled = (Info.HitActor == none || Info.HitActor.Health <= 0);
	Info.HitActor.ReplicatedHitInfo.bWasKilled = bWasKilled;

	if (Info.HitActor.Health <= 0 && !bSameTeam) {
		if (PawnInfo.myFamily.ClassReference == ECLASS_ManAtArms)
			Info.Instigator.ConsumeStamina(-50.f);
		else
			Info.Instigator.ConsumeStamina(-30.f);
		StaminaAtKill = Info.Instigator.Stamina;
		if (StaminaAtKill > MaxStamina)
			Info.Instigator.Stamina = MaxStamina;
	}

	if (bWasKilled && WorldInfo.NetMode == NM_DedicatedServer) {
		if (AOCPlayerController(Controller).StatWrapper != none
			&& !bSameTeam
			&& Info.UsedWeapon < 2
			&& !bEnemyWasBot) {
			AOCPlayerController(Controller).StatWrapper.IncrementKillStats(
				Info.UsedWeapon == 0 ? PrimaryWeapon : SecondaryWeapon,
				PawnFamily,
				Info.HitActor.PawnFamily,
				class<AOCWeapon>(HitActorWeaponAttachment.WeaponClass)
			);
		}
		if (Info.BoneName == 'b_Neck' && !Info.DamageType.default.bIsProjectile && Info.DamageType.default.bCanDecap && Info.AttackType != Attack_Stab) {
			if (AOCPlayerController(Controller) != none && bOnFire)
				AOCPlayerController(Controller).UnlockRotisserieChef();
			AOCPlayerController(Controller).NotifyAchievementDecap();
		}
		if (class<AOCDmgType_Fists>(Info.DamageType) != none)
			if (AOCPlayerController(Controller) != none)
				AOCPlayerController(Controller).NotifyFistofFuryProgress();
	}

	foreach AICombatInterests(AIList) {
		AIList.NotifyPawnPerformSuccessfulAttack(self);
	}
	foreach Info.HitActor.AICombatInterests(AIList) {
		if (!bParry)
			AIList.NotifyPawnReceiveHit(Info.HitActor, self);
		else
			AIList.NotifyPawnSuccessBlock(Info.HitActor, self);
	}

	// Standalone/listen: replicate the hit reaction locally.
	if (WorldInfo.NetMode == NM_Standalone || Worldinfo.NetMode == NM_ListenServer)
		Info.HitActor.HandlePawnGetHit();

	// Firebug ignition (after the blunt impact sound).
	if (XangModWeapon_Firebug(Weapon) != none && Info.HitActor != none
		&& ActualDamage > 0.0f && !bParry && !bSameTeam && !Info.HitActor.bIsBurning
		&& Info.HitActor.IsAliveAndWell())
	{
		Info.HitActor.SetPawnOnFire(none, Controller, self, class'XangModDmgType_TorchBurn');
	}
}
```

**(2d) Replace `ApplyDeferredReplication` (current lines 1729–1775)** with these three helpers, and **delete `RollbackRecentHits` entirely (current lines 1792–1883)**. Keep the `TakeDamage` override between them untouched.

```unrealscript
// XANGMOD: How long to hold an incoming swing on THIS (defender) pawn so an in-flight parry
// can still reach the server and suppress it. Equals the defender's one-way latency, capped.
// Returns 0 on LAN/bots (no network crossing to compensate) -> swings resolve instantly.
function float GetParryHoldSeconds()
{
	local float fPingSec;
	local float fHold;

	if (PlayerReplicationInfo != none)
		fPingSec = float(PlayerReplicationInfo.Ping) * 0.004; // UE3 stores ping as ms/4

	fHold = FMin(fPingSec, fParryRollbackMaxHoldSeconds);

	if (fHold < fParryRollbackMinHoldSeconds)
		return 0.0;

	return fHold;
}

// XANGMOD: Commit held swings whose hold window elapsed without a parry. Runs on the defender
// (self) from Tick. Each commits exactly once through the normal hit path.
function ProcessPendingHits()
{
	local int i;
	local PendingHit Entry;
	local float fNow;

	if (PendingHits.Length == 0)
		return;

	fNow = WorldInfo.TimeSeconds;

	for (i = 0; i < PendingHits.Length; i++)
	{
		if (fNow >= PendingHits[i].fCommitTime)
		{
			Entry = PendingHits[i];
			PendingHits.Remove(i, 1);
			i--;

			if (Entry.Attacker != none && Entry.Attacker.Weapon != none)
				Entry.Attacker.ProcessResolvedAttack(Entry.Info, Entry.DamageString, false, Entry.bBoxParrySuccess, Entry.bHitShield, Entry.LastHit, Entry.bQuickKick);
		}
	}
}

// XANGMOD: A parry landed while swings were still held on us — resolve every one as a parry
// BEFORE any hit feedback plays (decide-once). DetectSuccessfulParry still rejects illegal
// parries (e.g. back hits), which then fall through to a normal hit. Runs on the defender (self)
// from XangModMeleeWeapon.Parry.BeginState, after super sets bIsParrying/bIsActiveShielding.
function ResolvePendingHitsAsParry()
{
	local int i;
	local PendingHit Entry;

	if (PendingHits.Length == 0)
		return;

	for (i = 0; i < PendingHits.Length; i++)
	{
		Entry = PendingHits[i];
		if (Entry.Attacker != none && Entry.Attacker.Weapon != none)
			Entry.Attacker.ProcessResolvedAttack(Entry.Info, Entry.DamageString, false, Entry.bBoxParrySuccess, Entry.bHitShield, Entry.LastHit, Entry.bQuickKick, true);
	}
	PendingHits.Length = 0;
}
```

**(2e) DefaultProperties — replace line 1980:**

```unrealscript
	// Parry rollback: hold an incoming swing up to this long (capped at defender one-way ping)
	// so an in-flight parry can suppress it before any feedback plays. 0 hold at 0 ping.
	fParryRollbackMaxHoldSeconds=0.060
	fParryRollbackMinHoldSeconds=0.013
```

---

### File 3 — `XangMod\Classes\XangModMeleeWeapon.uc`
**Replace `Parry`'s `BeginState` (lines 574–599)** with:

```unrealscript
	simulated event BeginState(Name PreviousStateName)
	{
		// Server records when the parry became active (grace-period validation for hits that
		// arrive just after this point).
		if (Role == ROLE_Authority)
			fServerParryStartTime = WorldInfo.TimeSeconds;

		// Call parent first so bIsParrying / bIsActiveShielding are set before we resolve.
		super.BeginState(PreviousStateName);

		// XANGMOD: Suppress any swings currently HELD on us — resolve them as parries before
		// any hit feedback plays. Must run AFTER super so parry validation sees the parry state.
		if (Role == ROLE_Authority && AOCOwner != none && XangModPawn(AOCOwner) != none)
			XangModPawn(AOCOwner).ResolvePendingHitsAsParry();

		// XANGMOD: Disable riposte for shields — must come AFTER super because
		// AOCMeleeWeapon.Parry.BeginState resets bCanParryHitCounter = true
		if (bEquipShield)
		{
			bCanParryHitCounter = false;
		}
	}
```

---

### Notes
- **0 ping / bots:** `GetParryHoldSeconds` returns 0 → dispatcher calls `ProcessResolvedAttack` immediately → damage, sound, blood all play. The old commit‑then‑refund is gone, so no jarring double feedback.
- **Laggy attacker vs human defender:** swing is held `min(defenderPing, 60ms)`; a parry in that window calls `ResolvePendingHitsAsParry` → clean parry (stamina drain, deflect, parry sound, sparks), **no** hit effects ever fire.
- **Tunable:** `fParryRollbackMaxHoldSeconds` (cap) and `fParryRollbackMinHoldSeconds` (floor below which holds are skipped).
- You can delete `PARRY_ROLLBACK.md` or I can give you a rewritten version — it now describes the old model.

Want me to apply these with the edit tools and run `UDK.exe make` to compile‑verify, or are you handling it from here?