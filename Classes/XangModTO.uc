class XangModTO extends AOCTeamObjective;

// CE Autoskip: when enabled by admin, fires "ce skip" when objective timer reaches 5 seconds
var bool bCEAutoskipEnabled;
var bool bCEAutoskipFired;

`include(XangMod/Include/XangModTO.uci)
`include(XangMod/Include/XangModGame.uci)
`include(XangMod/Include/XangModTOGamemode.uci)

DefaultProperties
{
	// Team damage: 0.0 = none, 0.5 = 50% (vanilla), 1.0 = 100%
	fTeamDamagePercent=0.5
}
