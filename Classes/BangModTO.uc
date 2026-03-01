class BangModTO extends AOCTeamObjective;

`include(BangMod/Include/BangModTO.uci)
`include(BangMod/Include/BangModGame.uci)
`include(BangMod/Include/BangModTOGamemode.uci)

DefaultProperties
{
	// Team damage: 0.0 = none, 0.5 = 50% (vanilla), 1.0 = 100%
	fTeamDamagePercent=0.5
}
