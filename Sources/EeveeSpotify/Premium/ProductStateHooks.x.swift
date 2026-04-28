import Orion

// MARK: - ConsentProductStateDataLoaderImpl Hook (9.1.34+)
// 
// Spotify 9.1.34 added a new ConsentProductStateDataLoaderImpl class that fetches
// fresh product state data from a new endpoint. This data contains the real
// free-tier state which overwrites our premium patches.
//
// This hook intercepts those fetches and returns empty data to prevent the
// real free-tier state from being applied.

class ConsentProductStateDataLoaderImplHook: ClassHook<NSObject> {
    typealias Group = PremiumBootstrapGroup
    
    static var targetName: String {
        switch EeveeSpotify.hookTarget {
        case .v91:
            return "_TtC26DeviceLocation_ConsentImpl33ConsentProductStateDataLoaderImpl"
        default:
            return "_TtC26DeviceLocation_ConsentImpl33ConsentProductStateDataLoaderImpl"
        }
    }
    
    func loadProductState() {
        let elapsed = Int(Date().timeIntervalSince(tweakInitTime))
        writeDebugLog("[CONSENT] loadProductState intercepted at \(elapsed)s")
        // Don't call orig - return empty to prevent free-tier state from being applied
        // The original bootstrap data already has our premium patches
    }
}

class ConsentProductStateDataLoaderImplHookAlt: ClassHook<NSObject> {
    typealias Group = PremiumBootstrapGroup
    static var targetName: String {
        return "ConsentProductStateDataLoaderImpl"
    }
    
    func loadProductState() {
        let elapsed = Int(Date().timeIntervalSince(tweakInitTime))
        writeDebugLog("[CONSENT-ALT] loadProductState intercepted at \(elapsed)s")
    }
}

// MARK: - ProductStateDataSource Hook (9.1.34+)
// Hook into ProductStateDataSource to catch when it tries to update product state

class ProductStateDataSourceHook: ClassHook<NSObject> {
    typealias Group = PremiumBootstrapGroup
    static var targetName: String {
        switch EeveeSpotify.hookTarget {
        case .v91:
            return "_TtC29Settings_SharedDataSourceImpl22ProductStateDataSource"
        default:
            return "_TtC29Settings_SharedDataSourceImpl22ProductStateDataSource"
        }
    }
    
    // orion:new
    func updateProductState() {
        let elapsed = Int(Date().timeIntervalSince(tweakInitTime))
        writeDebugLog("[PRODUCT-STATE-DS] updateProductState intercepted at \(elapsed)s")
        // Intercept but don't call orig - let bootstrap state remain
    }
}

class ProductStateDataSourceHookAlt: ClassHook<NSObject> {
    typealias Group = PremiumBootstrapGroup
    static var targetName: String {
        return "Settings_SharedDataSourceImpl.ProductStateDataSource"
    }
    
    func updateProductState() {
        let elapsed = Int(Date().timeIntervalSince(tweakInitTime))
        writeDebugLog("[PRODUCT-STATE-DS-ALT] updateProductState intercepted at \(elapsed)s")
    }
}

// MARK: - ProductStateSwitchDataSource Hook (9.1.34+)
// Hook into ProductStateSwitchDataSource which controls feature flags

class ProductStateSwitchDataSourceHook: ClassHook<NSObject> {
    typealias Group = PremiumBootstrapGroup
    static var targetName: String {
        switch EeveeSpotify.hookTarget {
        case .v91:
            return "_TtC32Settings_ProductStateSettingsKit28ProductStateSwitchDataSource"
        default:
            return "_TtC32Settings_ProductStateSettingsKit28ProductStateSwitchDataSource"
        }
    }
    
    func updateProductState() {
        let elapsed = Int(Date().timeIntervalSince(tweakInitTime))
        writeDebugLog("[PRODUCT-STATE-SWITCH] updateProductState intercepted at \(elapsed)s")
    }
}