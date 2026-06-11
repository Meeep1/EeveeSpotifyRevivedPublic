import Foundation
import ObjectiveC.runtime

enum TrueShuffleHookInstaller {
    private static var didInstall = false
    private static var installAttempts = 0
    private static let maxInstallAttempts = 6

    private typealias WeightForTrackIMP = @convention(c) (
        AnyObject,
        Selector,
        AnyObject,
        Bool,
        Bool
    ) -> Double

    static func installIfEnabled() {
        guard UserDefaults.trueShuffleEnabled else {
            writeDebugLog("True Shuffle disabled in settings; skipping hook install")
            return
        }

        install()
    }

    private static func install() {
        guard !didInstall else { return }
        installAttempts += 1

        let weightSelector = NSSelectorFromString("weightForTrack:recommendedTrack:mergedList:")
        let weightedListSelector = NSSelectorFromString("weightedShuffleListWithTracks:recommendations:")

        var classCount: UInt32 = 0
        guard let classes = objc_copyClassList(&classCount) else {
            writeDebugLog("True Shuffle: failed to enumerate runtime classes")
            return
        }
        defer { free(classes) }

        for index in 0 ..< Int(classCount) {
            let cls: AnyClass = classes[index]
            let className = NSStringFromClass(cls)

            guard className.lowercased().contains("shuff") else {
                continue
            }

            guard let weightMethod = class_getInstanceMethod(cls, weightSelector),
                  method_getNumberOfArguments(weightMethod) == 5,
                  methodReturnType(weightMethod) == "d" else {
                continue
            }

            let originalWeightIMP = method_getImplementation(weightMethod)
            let weightBlock: @convention(block) (AnyObject, AnyObject, Bool, Bool) -> Double = {
                object,
                track,
                _,
                _ in
                let original = unsafeBitCast(originalWeightIMP, to: WeightForTrackIMP.self)
                return original(object, weightSelector, track, false, false)
            }

            method_setImplementation(weightMethod, imp_implementationWithBlock(weightBlock as Any))

            if let weightedListMethod = class_getInstanceMethod(cls, weightedListSelector),
               method_getNumberOfArguments(weightedListMethod) == 4,
               methodReturnType(weightedListMethod).hasPrefix("@") {
                let weightedListBlock: @convention(block) (AnyObject, AnyObject, AnyObject) -> AnyObject? = {
                    _,
                    _,
                    _ in
                    nil
                }

                method_setImplementation(weightedListMethod, imp_implementationWithBlock(weightedListBlock as Any))
            }

            didInstall = true
            writeDebugLog("True Shuffle hooks installed on class: \(className)")
            return
        }

        scheduleRetryIfNeeded()
    }

    private static func scheduleRetryIfNeeded() {
        guard installAttempts < maxInstallAttempts else {
            writeDebugLog("True Shuffle: no compatible shuffle class found")
            return
        }

        writeDebugLog("True Shuffle: no compatible shuffle class found; retrying")
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            install()
        }
    }

    private static func methodReturnType(_ method: Method) -> String {
        guard let returnType = method_copyReturnType(method) else { return "" }
        defer { free(returnType) }
        return String(cString: returnType)
    }
}
