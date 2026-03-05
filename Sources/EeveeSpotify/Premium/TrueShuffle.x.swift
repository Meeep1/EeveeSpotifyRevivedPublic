import Foundation
import Orion

/// Restores deterministic-free shuffle behavior by disabling
/// Spotify's weighted/recommended-track injection path.
///
/// Original implementation inspiration:
/// https://github.com/YungSpecht/TrueShuffle
class SPTFreeTierPlaylistTrackShufflerHook: ClassHook<NSObject> {
    typealias Group = BasePremiumPatchingGroup

    static var targetName: String {
        let className = "SPTFreeTierPlaylistTrackShuffler"
        return NSClassFromString(className) != nil ? className : "UIView"
    }

    func weightForTrack(_ track: AnyObject, recommendedTrack: Bool, mergedList: Bool) -> Double {
        // Force Spotify to treat tracks as non-recommended/non-merged so
        // the weighted path does not bias order toward repeats/promotions.
        orig.weightForTrack(track, recommendedTrack: false, mergedList: false)
    }

    func weightedShuffleListWithTracks(_ tracks: AnyObject, recommendations: AnyObject) -> AnyObject? {
        // Returning nil disables the weighted recommendation list fallback,
        // preserving a true random shuffle path.
        nil
    }
}
