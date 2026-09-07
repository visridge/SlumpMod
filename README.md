# XangMod
A mod dedicated to the greatness of Emperor Bill

## CompForest Sluice Gate Alternating Spawns

CompForest TO can optionally alternate between tagged A/B player-start groups during
the sluice gate objective only. It is disabled by default.

Server default:

```ini
[XangMod.XangModTO]
bEnableCompForestAlternatingSpawns=false
```

Admin console command:

```text
AdminCompForestAlternatingSpawns true
AdminCompForestAlternatingSpawns false
```

Tag the sluice gate `AOCPlayerStart` actors with:

```text
Obj3_Agatha_A
Obj3_Agatha_B
Obj3_Mason_A
Obj3_Mason_B
```

The tagged starts still need their normal `PlayerStartFaction` set correctly. If no
valid tagged start is available, spawning falls back to vanilla behavior.
