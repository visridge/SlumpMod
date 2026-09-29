// Per-map TO stage bonus time overrides, read by XangModTO.ActivateNextObjectiveStage.
// Section [XangMod.XangModObjTimer]. Obj is 1-based; Bonus is seconds added on completing that stage.
class XangModObjTimer extends Object config(Game);

struct ObjTimerOverride
{
	var string Map;
	var int Obj;
	var float Bonus;
};

var config array<ObjTimerOverride> Overrides;

DefaultProperties
{
}
