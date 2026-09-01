/**
* XangMod combat bot — drop-in replacement for AOCAICombatController that makes "addbots"
* bots noticeably less dumb in melee, with zero changes to the AI's decision logic. Only two
* low-risk levers are pulled:
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
class XangModAOCCombatBot extends AOCAICombatController;

// Lower bound on bot skill (0.0-1.0). Applied after super.ChooseBehaviour() so it survives the
// GameDifficulty overwrite. 0.85 ≈ markedly sharper than the 0.6 vanilla default without being
// a frame-perfect aimbot.
var float fXangModMinSkill;

function ChooseBehaviour()
{
	super.ChooseBehaviour();

	// Raise dumb-low bots up to our floor; never lower an admin's higher GameDifficulty.
	if (fSkill < fXangModMinSkill)
		SetSkill(fXangModMinSkill);
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
}
