import Orion
import SwiftUI
import UIKit

// Settings integration for 9.1.x - uses AccountSettingsSection instead of ProfileSettingsSection
struct V91SettingsIntegrationGroup: HookGroup { }

class AccountSettingsSectionHook: ClassHook<NSObject> {
    typealias Group = V91SettingsIntegrationGroup
    static let targetName = "AccountSettingsSection"

    func numberOfRows() -> Int {
        // Add 1 extra row for EeveeSpotify
        return orig.numberOfRows() + 1
    }

    func didSelectRow(_ row: Int) {
        let originalRowCount = orig.numberOfRows()
        
        // If it's our added row (last row)
        if row == originalRowCount {
            // Show a simple alert with version info
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first,
                  let rootViewController = window.rootViewController else {
                return
            }
            
            let alert = UIAlertController(
                title: "EeveeSpotify",
                message: """
                Tweak Version: \(EeveeSpotify.version)
                Spotify Version: \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)
                
                Note: Limited functionality on Spotify 9.1.x
                - Lyrics are not available (architecture changed)
                - Full settings menu not available
                """,
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            
            alert.addAction(UIAlertAction(title: "GitHub", style: .default) { _ in
                if let url = URL(string: "https://github.com/Meeep1/EeveeSpotifyReborn2-swift") {
                    UIApplication.shared.open(url)
                }
            })
            
            rootViewController.present(alert, animated: true)
            return
        }

        // Otherwise, call original method for other rows
        orig.didSelectRow(row)
    }

    func cellForRow(_ row: Int) -> UITableViewCell {
        let originalRowCount = orig.numberOfRows()
        
        // If it's our added row
        if row == originalRowCount {
            // Try to create a cell using Spotify's cell class
            let cell = UITableViewCell(style: .default, reuseIdentifier: "EeveeSpotify")
            cell.textLabel?.text = "EeveeSpotify v\(EeveeSpotify.version)"
            cell.accessoryType = .disclosureIndicator
            return cell
        }

        return orig.cellForRow(row)
    }
}
