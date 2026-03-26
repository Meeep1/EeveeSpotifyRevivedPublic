import Foundation
extension URL {
    var isLyrics: Bool {
        self.path.contains("color-lyrics/v2")
    }
    
    var isPlanOverview: Bool {
        self.path.contains("GetPlanOverview")
    }
    
    var isPremiumPlanRow: Bool {
        self.path.contains("v1/GetPremiumPlanRow")
    }
    
    var isPremiumBadge: Bool {
        self.path.contains("GetYourPremiumBadge")
    }
    var isOpenSpotifySafariExtension: Bool {
        self.host == "eevee"
    }
    
    var isCustomize: Bool {
        self.path.contains("v1/customize")
    }
    
    var isBootstrap: Bool {
        self.path.contains("v1/bootstrap")
    }
    // Blocked endpoint matchers (session protection)
    var isDeleteToken: Bool {
        self.path.contains("DeleteToken")
    }
    var isAccountValidate: Bool {
        self.path.contains("signup/public")
    }
    var isOndemandSelector: Bool {
        self.path.contains("select-ondemand-set")
    }
    var isTrialsFacade: Bool {
        self.path.contains("trials-facade/start-trial")
    }
    var isPremiumMarketing: Bool {
        self.path.contains("premium-marketing/upsellOffer")
    }
    var isPendragonFetchMessageList: Bool {
        self.path.contains("pendragon") && self.path.contains("FetchMessageList")
    }
    var isPushkaTokens: Bool {
        self.path.contains("pushka-tokens")
    }
    // Additional session protection endpoints
    var isSessionInvalidation: Bool {
        self.path.contains("logout") || self.path.contains("sign-out") ||
        self.path.contains("session/purge") || self.path.contains("token/revoke") ||
        self.path.contains("auth/expire") ||
        (self.path.contains("melody") && self.path.contains("check")) ||
        self.path.contains("product-state") ||
        (self.path.contains("license") && self.path.contains("check"))
    }

    // NEW: Comprehensive Ad Detection
    var isAdLogic: Bool {
        let adPaths = [
            "ad-logic",
            "ads/v",
            "sponsored",
            "in-app-messaging",
            "merchandising",
            "v1/merch",
            "v1/ad",
            "v2/ad",
            "v1/ads",
            "v2/ads",
            "v1/sponsored",
            "v2/sponsored",
            "npv-video-ads",
            "audio-ads",
            "video-ads",
            "banner-ads",
            "promoted",
            "upsell",
            "premium-upsell"
        ]
        
        let adHosts = [
            "ads-fa.spotify.com",
            "audio-ak.cdn.spotify.com",
            "video-ak.cdn.spotify.com",
            "pixel.spotify.com",
            "merch-img.scdn.co",
            "ad.doubleclick.net",
            "googleads.g.doubleclick.net",
            "pagead2.googlesyndication.com",
            "tpc.googlesyndication.com",
            "adservice.google.com",
            "securepubads.g.doubleclick.net"
        ]
        
        let pathLower = self.path.lowercased()
        let hostLower = self.host?.lowercased() ?? ""
        
        for p in adPaths {
            if pathLower.contains(p) { return true }
        }
        
        for h in adHosts {
            if hostLower.contains(h) { return true }
        }
        
        // Check query parameters for ad-related flags
        if let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems {
            for item in queryItems {
                let name = item.name.lowercased()
                if name.contains("ad_id") || name.contains("ad-id") || name.contains("sponsored") {
                    return true
                }
            }
        }
        
        return false
    }
}
