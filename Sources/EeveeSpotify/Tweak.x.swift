import Orion
import UIKit

let tweakInitTime = Date()

struct EeveeSpotify: Tweak {
    enum HookTarget {
        case v91
        case lastAvailableiOS14
        case latest
    }
    
    static var hookTarget: HookTarget = .latest
    
    init() {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        
        if version.hasPrefix("8.6") {
            EeveeSpotify.hookTarget = .lastAvailableiOS14
        } else if version.hasPrefix("9.1") {
            EeveeSpotify.hookTarget = .v91
        }
        
        // Activate standard groups
        BasePremiumPatchingGroup().activate()
        BaseLyricsGroup().activate()
        
        // Activate ad-blocking groups
        DarkPopUpsGroup().activate()
        SearchAdsHooksGroup().activate()
        
        // Activate other groups
        SessionProtectionGroup().activate()
    }
}
