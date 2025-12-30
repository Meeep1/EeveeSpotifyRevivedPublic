import Orion
import EeveeSpotifyC
import UIKit

func writeDebugLog(_ message: String) {
    let logPath = NSTemporaryDirectory() + "eeveespotify_debug.log"
    let timestamp = Date().description
    let logMessage = "[\(timestamp)] \(message)\n"
    
    if FileManager.default.fileExists(atPath: logPath) {
        if let fileHandle = FileHandle(forWritingAtPath: logPath) {
            fileHandle.seekToEndOfFile()
            if let data = logMessage.data(using: .utf8) {
                fileHandle.write(data)
            }
            fileHandle.closeFile()
        }
    } else {
        try? logMessage.write(toFile: logPath, atomically: true, encoding: .utf8)
    }
}

func exitApplication() {
    UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
    Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
        exit(EXIT_SUCCESS)
    }
}

struct BasePremiumPatchingGroup: HookGroup { }

struct IOS14PremiumPatchingGroup: HookGroup { }
struct NonIOS14PremiumPatchingGroup: HookGroup { }
struct IOS14And15PremiumPatchingGroup: HookGroup { }
struct LatestPremiumPatchingGroup: HookGroup { }

func activatePremiumPatchingGroup() {
    BasePremiumPatchingGroup().activate()
    
    if EeveeSpotify.hookTarget == .lastAvailableiOS14 {
        IOS14PremiumPatchingGroup().activate()
    }
    else {
        NonIOS14PremiumPatchingGroup().activate()
        
        if EeveeSpotify.hookTarget == .lastAvailableiOS15 {
            IOS14And15PremiumPatchingGroup().activate()
        }
        else {
            LatestPremiumPatchingGroup().activate()
        }
    }
}

struct EeveeSpotify: Tweak {
    static let version = "6.2.6"
    
    static var hookTarget: VersionHookTarget {
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        
        NSLog("[EeveeSpotify] Detected Spotify version: \(version)")
        
        switch version {
        case "9.0.48":
            return .lastAvailableiOS15
        case "8.9.8":
            return .lastAvailableiOS14
        case "9.1.0", "9.1.6":
            // 9.1.x versions don't have modern classes like NPVScrollViewController
            // Use iOS15 hooks for compatibility
            return .lastAvailableiOS15
        default:
            return .latest
        }
    }
    
    init() {
        NSLog("[EeveeSpotify] Swift tweak initialization starting...")
        writeDebugLog("Swift tweak initialization starting")
        NSLog("[EeveeSpotify] Hook target: \(EeveeSpotify.hookTarget)")
        writeDebugLog("Hook target: \(EeveeSpotify.hookTarget)")
        
        do {
            if UserDefaults.experimentsOptions.showInstagramDestination {
                NSLog("[EeveeSpotify] Activating Instagram destination hooks")
                writeDebugLog("Activating Instagram destination hooks")
                InstgramDestinationGroup().activate()
                writeDebugLog("Instagram hooks activated successfully")
            }
            
            if UserDefaults.darkPopUps {
                NSLog("[EeveeSpotify] Activating dark popups hooks")
                writeDebugLog("Activating dark popups hooks")
                DarkPopUps().activate()
                writeDebugLog("Dark popups hooks activated successfully")
            }
            
            if UserDefaults.patchType.isPatching {
                NSLog("[EeveeSpotify] Activating premium patching hooks")
                writeDebugLog("Activating premium patching hooks")
                activatePremiumPatchingGroup()
                writeDebugLog("Premium patching hooks activated successfully")
            }
            
            if UserDefaults.lyricsSource.isReplacingLyrics {
                NSLog("[EeveeSpotify] Activating lyrics hooks")
                writeDebugLog("Activating lyrics hooks")
                BaseLyricsGroup().activate()
                writeDebugLog("Base lyrics hooks activated successfully")
                
                if EeveeSpotify.hookTarget == .latest {
                    writeDebugLog("Activating modern lyrics hooks")
                    ModernLyricsGroup().activate()
                    writeDebugLog("Modern lyrics hooks activated successfully")
                }
                else {
                    writeDebugLog("Activating legacy lyrics hooks")
                    LegacyLyricsGroup().activate()
                    writeDebugLog("Legacy lyrics hooks activated successfully")
                }
            }
            
            NSLog("[EeveeSpotify] Swift tweak initialization completed successfully")
            writeDebugLog("Swift tweak initialization completed successfully")
        } catch {
            let errorMsg = "ERROR during initialization: \(error)"
            NSLog("[EeveeSpotify] \(errorMsg)")
            writeDebugLog(errorMsg)
        }
    }
}
