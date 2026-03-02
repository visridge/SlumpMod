# BangMod Proximity Voice Chat Infrastructure

BangMod includes **proximity-based voice chat infrastructure** based on Chivalry's original (but incomplete) implementation.

## Current Status: Infrastructure Only

⚠️ **Important Limitation**: The actual voice codec (microphone capture & transmission) was removed from Chivalry's compiled engine. What we've implemented is:

✅ **Working Infrastructure:**
- Proximity distance calculation
- Server-side player filtering  
- HUD notifications when players "talk"
- Push-to-talk keybind system
- Team/all-chat display logic

❌ **Missing (Engine-Level):**
- Microphone audio capture
- Voice encoding/decoding
- Network voice transmission

## What This Means

The system will **visually indicate** when players press the talk button and who's in range, but **no actual voice is transmitted**. This could be useful for:

1. **Testing proximity systems** - See who's in voice range
2. **RP servers** - Visual indicator for "speaking" 
3. **Integration with external voice** - Use Discord/TeamSpeak with in-game proximity indicators
4. **Future development** - Infrastructure ready if voice codec is ever restored

## How It Works

### Client-Side
- Press and hold `G` to activate your microphone
- Your name appears in the "talking" list for nearby players
- You'll see a visual indicator when you're transmitting

### Server-Side
- Server calculates which players are within proximity range
- Only broadcasts voice data to nearby players
- Filters out players too far away to hear

### Configuration

Edit `DefaultBangMod.ini` or use console commands:

```ini
[AOC.AOCPlayerController]
ProximityChatDistance=2048.0  ; Distance in Unreal Units (52.5 UU = 1 meter)
bEnableProximityChat=true     ; Master toggle
```

**Distance Examples:**
- `1024` = ~19.5 meters (close quarters)
- `2048` = ~39 meters (default, typical battle range)
- `4096` = ~78 meters (long range)
- `8192` = ~156 meters (entire battlefield)

### Console Commands

```
testproximityvoice        - Check if proximity voice is enabled and your current status
gba_togglespeaking        - Manually trigger push-to-talk
```

## Technical Requirements

### Current Implementation (Working)
- Proximity distance checking ✅
- Server-side filtering ✅
- HUD visual indicators ✅
- Player state replication ✅

### Missing Requirements (Would Need Engine Modifications)
- Windows audio API integration ❌
- Voice codec (Speex/Opus) ❌
- Network voice packet handling ❌

### Potential Solutions for Actual Voice

1. **Native DLL**: Create a custom DLL with voice codec + hook into UE3
2. **External Voice Apps**: Use this with Discord/TeamSpeak and match proximity ranges
3. **Engine Rebuild**: Recompile UE3 with OnlineSubsystem voice enabled
4. **Wait for Official**: If Torn Banner ever releases source/fixes it

## Troubleshooting

### "No voice is transmitted"
This is expected - the voice codec is not available in the compiled engine.

### "Visual indicators not showing"

The default keybind is `G` (shared with drop item). To change it:

1. Edit `UDKPlayerInput.ini`
2. Find the line: `Bindings=(Name="G",Command="GBA_DropItem|GBA_ToggleSpeaking"...)`
3. Change the key or separate the commands

Example - Separate keybind to `V`:
```ini
Bindings=(Name="V",Command="GBA_ToggleSpeaking",FriendlyName="Voice Chat")
```

## Troubleshooting

### "Voice chat not working"
1. Check if Steam Overlay is enabled
2. Verify microphone works in Steam settings
3. Run `testproximityvoice` console command
4. Check `bEnableProximityChat=true` in config

### "Can't hear anyone"
1. Ensure other players are within proximity range
2. Check your Windows audio output settings
3. Verify `DefaultEnableVoice=true` in `UDKSettings.ini`

### "Everyone can hear me across the map"
- The proximity distance might be set too high
- Lower `ProximityChatDistance` in config

## Implementation Details

### What's Implemented
✅ Push-to-talk command (`GBA_ToggleSpeaking`)  
✅ Proximity distance checking  
✅ Server-side player filtering  
✅ HUD display of nearby talkers  
✅ Team-colored name displays  
✅ VOIP queue processing  
✅ Configuration options  

### What Relies on Engine
- **Audio capture**: Uses Steam/UE3's microphone system
- **Voice encoding**: Uses Steam/UE3's voice codec
- **Network transmission**: Uses existing UDK voice networking
- **Audio playback**: Uses Steam/UE3's voice output

### Limitations
- Voice quality depends on Steam/UE3 codec (typically 16kHz)
- No voice activity detection (VAD) - must use push-to-talk
- No individual volume control per player
- No mute functionality (yet)

## Future Enhancements

Possible additions:
- [ ] Voice activity detection (auto-detect speaking)
- [ ] Per-player mute commands
- [ ] Volume sliders for individual players
- [ ] Team-only vs proximity mode toggle
- [ ] Recording/playback for admin moderation
- [ ] Discord integration for dedicated servers

## Credits

- **Original Voice System**: Torn Banner Studios (discovered but unused code)
- **Proximity Implementation**: BangMod team
- **Testing**: BangMod community

## More Information

See the original findings about Chivalry's hidden voice chat system in the repository discussions.
