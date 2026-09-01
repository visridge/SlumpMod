/**
* BangModFamilyInfo_Archer - Archer family info with the ninja-roll custom dodge.
*
* Holds the custom dodge config (roll anims + tuning knobs) that BangModDodge reads.
* Mirrors the roll config that used to live on BangModFamilyInfo_ManAtArms, which is
* now reverted to vanilla dodge.
*/
class BangModFamilyInfo_Archer extends AOCFamilyInfo_Archer;

var() bool               bUseCustomDodgeAnims;
var() array<string>      DodgeAnimUp;            // 1H roll anims
var() array<string>      DodgeAnimUp2H;          // 2H roll anims (left hand grips shaft)
var() float              fCustomDodgeSpeed;      // dodge velocity multiplier (1.0 = vanilla DodgeSpeed)
var() float              fCustomDodgeSpeedZ;     // vertical dodge velocity (0 = keep jump component)
var() float              fCustomDodgeHeight;     // visual mesh Z offset during roll (negative = lower)
var() int                iRollStaminaCost;       // stamina consumed by the roll (replaces iDodgeCost)
var() SoundCue           RollSound;              // voice/effort sound played at roll start

DefaultProperties
{
	bUseCustomDodgeAnims=true
	DodgeAnimUp(0)="rollF"
	DodgeAnimUp(1)="rollR"
	DodgeAnimUp(2)="rollB"
	DodgeAnimUp(3)="rollL"
	DodgeAnimUp2H(0)="rollF2H"
	DodgeAnimUp2H(1)="rollR2H"
	DodgeAnimUp2H(2)="rollB2H"
	DodgeAnimUp2H(3)="rollL2H"

	fCustomDodgeSpeed=1.5
	fCustomDodgeSpeedZ=0.0
	fCustomDodgeHeight=0.0

	// Stamina cost of the roll. Defaults to the archer's vanilla dodge cost; tune
	// here without touching iDodgeCost (used by vanilla dodge elsewhere).
	iRollStaminaCost=25

	// Effort/voice sound played when the roll starts.
	RollSound=SoundCue'A_VO_Pain.Agatha_MAA_Swing_grunt_tier1'

	// The roll only fires while a dodge-capable (melee) weapon is out; bows keep
	// bCanDodge=false at the weapon level.
	bCanDodge=true
}
