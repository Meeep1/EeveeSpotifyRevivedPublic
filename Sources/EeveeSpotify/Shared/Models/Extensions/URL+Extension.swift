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
}
