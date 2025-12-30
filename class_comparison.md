# Spotify 9.1.0 vs 9.1.6 Class Comparison

## Analysis Summary

### ✅ Classes that EXIST in BOTH versions:
- `SPTDataLoaderService` - Core data loading (SAFE to hook)
- `NPVScrollViewController` - Now playing view controller
- `NowPlaying_ScrollImpl.NPVScrollViewController`
- `ContentOffliningUIHelperImplementation`
- `Offline_ContentOffliningUIImpl.ContentOffliningUIHelperImplementation`
- `PopUpPresentableContainer` - Popup presentation container
- `EncoreConsumerMobile_Wrappers.PopUpPresentableContainer`

### ❌ Classes REMOVED in 9.1.6:
- `Lyrics_NPVCommunicatorImpl.ScrollProvider` - **MISSING** ❌
- `LyricsScrollProvider` - **MISSING** ❌
- `$s26Lyrics_NPVCommunicatorImpl0A14ScrollProviderP` - **MISSING** ❌
- `_TtC26Lyrics_NPVCommunicatorImpl14ScrollProvider` - **MISSING** ❌

### ❓ Classes NOT FOUND in EITHER version:
- `SPTFreeTierArtistHubRemoteURLResolver` - Doesn't exist in 9.1.0 or 9.1.6
- `SPTEncorePopUpContainer` - Not found (but PopUpPresentableContainer exists)
- `SPTEncoreLabel` - Not found in search

## Lyrics Architecture Changes

### 9.1.0 Lyrics System:
- Uses `Lyrics_NPVCommunicatorImpl.ScrollProvider`
- Has `LyricsScrollProvider` protocol/class
- Lyrics are integrated with Now Playing View

### 9.1.6 Lyrics System (NEW):
- **Completely different architecture**
- Uses Component-based UI system:
  - `Components.UI.LyricsView`
  - `Components.UI.LyricsFullscreen`
  - `Components.UI.LyricsHeader`
  - `Components.UI.LyricsControlPanel`
  - `CanvasNowPlayingLyricsManager`
  - `CanvasNowPlayingLyricsView`
- New protobuf messages:
  - `Com_Spotify_Lyrics_V2_LyricsRequest`
  - `Com_Spotify_Lyrics_V2_LyricsResponse`
  - `Com_Spotify_Colorlyrics_ColorLyricsResponse`

## Recommendations

### For v6.2.10+ (Current Approach):
1. **Keep minimal mode active** - Only hook `SPTDataLoaderService`
2. **Disable all lyrics** for 9.1.x ✅ (Already done)
3. **Disable dark popups** for 9.1.x ✅ (Already done)
4. **Disable track rows enabler** for 9.1.x ✅ (Already done)

### For Future Lyrics Support on 9.1.6:
To re-enable lyrics, would need to:
1. Hook `Components.UI.LyricsView` instead of old classes
2. Use `CanvasNowPlayingLyricsManager` for lyrics management
3. Intercept `Com_Spotify_Lyrics_V2_LyricsRequest/Response` protobuf messages
4. Work with the new Component-based UI system
5. Likely requires significant rewrite of lyrics module

## What Should Work in v6.2.10:
- ✅ Basic premium patching via `SPTDataLoaderService` URL interception
- ✅ No crashes from missing classes (all problematic hooks disabled)
- ❌ No lyrics (architecture incompatible)
- ❌ No dark popups (disabled for safety)
- ❌ No artist hub track rows (class might not exist)

## If v6.2.10 Still Crashes:
The crash would be from `SPTDataLoaderService` hook itself, which exists in both versions but might have different method signatures in 9.1.6.
