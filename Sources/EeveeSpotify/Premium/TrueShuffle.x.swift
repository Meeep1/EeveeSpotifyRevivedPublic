import Foundation
import ObjectiveC.runtime

enum TrueShuffleHookInstaller {
    private static var didInstall = false

    private typealias WeightForTrackIMP = @convention(c) (
        AnyObject,
        Selector,
        AnyObject,
        Bool,
        Bool
    ) -> Double

    static func installIfEnabled() {
        guard UserDefaults.trueShuffleEnabled else {
            writeDebugLog("True Shuffle is disabled in settings; skipping runtime hook install")
            return
        }

        install()
    }

    private static func install() {
        guard !didInstall else { return }

        let weightSelector = NSSelectorFromString("weightForTrack:recommendedTrack:mergedList:")
        let weightedListSelector = NSSelectorFromString("weightedShuffleListWithTracks:recommendations:")

        var classCount: UInt32 = 0
        guard let classes = objc_copyClassList(&classCount) else {
            writeDebugLog("True Shuffle: failed to enumerate Objective-C classes")
            return
        }
        defer { free(classes) }

        for index in 0 ..< Int(classCount) {
            let cls = classes[index]
            let className = NSStringFromClass(cls)

            guard className.lowercased().contains("shuff") else {
                continue
            }

            guard let weightMethod = class_getInstanceMethod(cls, weightSelector) else {
                continue
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
            writeDebugLog("True Shuffle hooks installed on class: \(className)")
            return
        }

        writeDebugLog("True Shuffle: no compatible shuffle class found; feature not applied")
    }
}
