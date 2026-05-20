import Foundation
import ObjectiveC.runtime

enum TrueShuffleHookInstaller {
    private static var didInstall = false
    private static var retryTimer: Timer?
    private static var retryCount = 0
    private static let maxRetryCount = 20

    private typealias WeightForTrackIMP = @convention(c) (
        AnyObject,
        Selector,
        AnyObject,
        Bool,
        Bool
    ) -> Double

    static func installIfEnabled() {
        guard UserDefaults.trueShuffleEnabled else {
            writeDebugLog("True Shuffle is disabled in settings; skipping hook install")
            return
        }

        DispatchQueue.main.async {
            retryCount = 0
            retryTimer?.invalidate()
            retryTimer = nil

            if installWhenAvailable() {
                return
            }

            retryTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { timer in
                retryCount += 1

                if installWhenAvailable() || retryCount >= maxRetryCount {
                    timer.invalidate()
                    retryTimer = nil

                    if !didInstall {
                        writeDebugLog("True Shuffle: no compatible shuffle class found after retries")
                    }
                }
            }
        }
    }

    private static func installWhenAvailable() -> Bool {
        guard !didInstall else { return true }

        let weightSelector = NSSelectorFromString("weightForTrack:recommendedTrack:mergedList:")
        let weightedListSelector = NSSelectorFromString("weightedShuffleListWithTracks:recommendations:")

        if let knownClass = NSClassFromString("SPTFreeTierPlaylistTrackShuffler"),
           install(on: knownClass, weightSelector: weightSelector, weightedListSelector: weightedListSelector) {
            return true
        }

        var classCount: UInt32 = 0
        guard let classes = objc_copyClassList(&classCount) else {
            writeDebugLog("True Shuffle: failed to enumerate Objective-C classes")
            return false
        }
        defer { free(classes) }

        for index in 0 ..< Int(classCount) {
            let cls = classes[index]
            let className = NSStringFromClass(cls).lowercased()

            guard className.contains("shuffle") || className.contains("shuffler") else {
                continue
            }

            if install(on: cls, weightSelector: weightSelector, weightedListSelector: weightedListSelector) {
                return true
            }
        }

        return false
    }

    private static func install(
        on cls: AnyClass,
        weightSelector: Selector,
        weightedListSelector: Selector
    ) -> Bool {
        guard let weightMethod = class_getInstanceMethod(cls, weightSelector) else {
            return false
        }

        let originalWeightIMP = method_getImplementation(weightMethod)

        let weightBlock: @convention(block) (AnyObject, AnyObject, Bool, Bool) -> Double = {
            object,
            track,
            _,
            _
            in
            let original = unsafeBitCast(originalWeightIMP, to: WeightForTrackIMP.self)
            return original(object, weightSelector, track, false, false)
        }

        method_setImplementation(weightMethod, imp_implementationWithBlock(weightBlock as Any))

        if let weightedListMethod = class_getInstanceMethod(cls, weightedListSelector) {
            let weightedListBlock: @convention(block) (AnyObject, AnyObject, AnyObject) -> AnyObject? = {
                _,
                _,
                _
                in
                nil
            }

            method_setImplementation(weightedListMethod, imp_implementationWithBlock(weightedListBlock as Any))
        }

        didInstall = true
        retryTimer?.invalidate()
        retryTimer = nil
        writeDebugLog("True Shuffle hooks installed on class: \(NSStringFromClass(cls))")
        return true
    }
}
