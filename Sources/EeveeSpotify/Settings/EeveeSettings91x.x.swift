import Orion
import SwiftUI
import UIKit

// Settings integration for 9.1.x - adds info button to settings screen
struct V91SettingsIntegrationGroup: HookGroup { }

// Helper class to handle button tap (not a hook, just a regular class)
class VersionInfoButtonHandler: NSObject {
    @objc func showVersionInfo() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              var topController = window.rootViewController else {
            return
        }
        
        // Find the top-most view controller
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        
        let alert = UIAlertController(
            title: "🎵 EeveeSpotify",
            message: """
            Tweak Version: \(EeveeSpotify.version)
            Spotify Version: \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)
            
            ⚠️ Limited functionality on Spotify 9.1.x:
            • Premium patching: ✓ Active
            • Lyrics: ✗ Not available
            • Full settings: ✗ Not available
            """,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        alert.addAction(UIAlertAction(title: "Open GitHub", style: .default) { _ in
            if let url = URL(string: "https://github.com/Meeep1/EeveeSpotifyReborn2-swift") {
                UIApplication.shared.open(url)
            }
        })
        
        topController.present(alert, animated: true)
        
        NSLog("[EeveeSpotify] Version info alert presented from settings")
    }
}

// Hook the root settings view controller to add our button
class SPTFeatureSettingsRootViewControllerHook: ClassHook<UIViewController> {
    typealias Group = V91SettingsIntegrationGroup
    static let targetName = "SPTFeatureSettingsRootViewController"
    
    static var buttonHandler = VersionInfoButtonHandler()
    static var hasAddedButton = false
    
    func viewDidLoad() {
        orig.viewDidLoad()
        
        NSLog("[EeveeSpotify] SPTFeatureSettingsRootViewController viewDidLoad called!")
        
        // Only add button once
        guard !Self.hasAddedButton else {
            NSLog("[EeveeSpotify] Button already added, skipping")
            return
        }
        Self.hasAddedButton = true
        
        NSLog("[EeveeSpotify] Creating info button...")
        
        // Create info button in navigation bar
        let infoButton = UIBarButtonItem(
            image: UIImage(systemName: "info.circle"),
            style: .plain,
            target: Self.buttonHandler,
            action: #selector(VersionInfoButtonHandler.showVersionInfo)
        )
        
        NSLog("[EeveeSpotify] Setting right bar button item...")
        target.navigationItem.rightBarButtonItem = infoButton
        
        // Also add a visible label to prove the hook is working
        let label = UILabel(frame: CGRect(x: 0, y: 100, width: target.view.bounds.width, height: 50))
        label.text = "🎵 EeveeSpotify v\(EeveeSpotify.version) - Tap for info"
        label.textAlignment = .center
        label.backgroundColor = .systemGreen
        label.textColor = .white
        label.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: Self.buttonHandler, action: #selector(VersionInfoButtonHandler.showVersionInfo))
        label.addGestureRecognizer(tapGesture)
        target.view.addSubview(label)
        
        NSLog("[EeveeSpotify] Info button added! Current navigationItem: \(target.navigationItem)")
    }
}
