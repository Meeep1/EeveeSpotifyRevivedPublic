import Orion
import SwiftUI
import UIKit

// Universal settings integration that works across all Spotify versions
struct UniversalSettingsIntegrationGroup: HookGroup { }

// MARK: - Primary: ProfileSettingsSection hook for settings menu row
class UniversalProfileSettingsSectionHook: ClassHook<NSObject> {
    typealias Group = UniversalSettingsIntegrationGroup
    static let targetName = "ProfileSettingsSection"
    
    func numberOfRows() -> Int {
        let original = orig.numberOfRows()
        return original + 1
    }
    
    func didSelectRow(_ row: Int) {
        let originalRows = orig.numberOfRows()
        
        if row == originalRows {
            openEeveeSettingsFromHook()
            return
        }
        
        orig.didSelectRow(row)
    }
    
    func cellForRow(_ row: Int) -> UITableViewCell {
        let originalRows = orig.numberOfRows()
        
        if row == originalRows {
            let settingsTableCell = Dynamic.SPTSettingsTableViewCell
                .alloc(interface: SPTSettingsTableViewCell.self)
                .initWithStyle(3, reuseIdentifier: "EeveeSpotify")
            
            let tableViewCell = Dynamic.convert(settingsTableCell, to: UITableViewCell.self)
            
            tableViewCell.accessoryView = type(
                of: Dynamic.SPTDisclosureAccessoryView
                    .alloc(interface: SPTDisclosureAccessoryView.self)
            )
            .disclosureAccessoryView()
            
            tableViewCell.textLabel?.text = "EeveeSpotify"
            
            return tableViewCell
        }
        
        return orig.cellForRow(row)
    }
    
    private func openEeveeSettingsFromHook() {
        // Try to find the root settings controller
        let rootSettingsController = WindowHelper.shared.findFirstViewController("RootSettingsViewController")
            ?? WindowHelper.shared.findFirstViewController("SettingsViewController")
            ?? WindowHelper.shared.findFirstViewController("ProfileViewController")
        
        guard let rootController = rootSettingsController,
              let navigationController = rootController.navigationController else {
            return
        }
        
        let eeveeSettingsController = EeveeSettingsViewController(
            rootController.view.bounds,
            settingsView: AnyView(EeveeSettingsView(navigationController: navigationController)),
            navigationTitle: "EeveeSpotify"
        )
        
        let button = UIButton()
        
        if let githubImage = BundleHelper.shared.uiImage("github") {
            button.setImage(githubImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else {
             // Fallback if github image is missing
             button.setImage(UIImage(systemName: "globe"), for: .normal)
        }
        
        button.addTarget(
            eeveeSettingsController,
            action: #selector(eeveeSettingsController.openRepositoryUrl(_:)),
            for: .touchUpInside
        )
        
        let menuBarItem = UIBarButtonItem(customView: button)
        menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 22).isActive = true
        menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 22).isActive = true
        eeveeSettingsController.navigationItem.rightBarButtonItem = menuBarItem
        
        navigationController.pushViewController(eeveeSettingsController, animated: true)
    }
}

// MARK: - Global Helper to avoid Orion Hooking Issues with setupEeveeButton
// This logic is moved outside the ClassHook so Orion doesn't try to find it as an Obj-C method on the target class.
func injectEeveeButton(into target: UIViewController) {
    NSLog("[EeveeSpotify] injectEeveeButton called for \(String(describing: type(of: target)))")
    
    // Check if the button already exists in rightBarButtonItems
    if let rightItems = target.navigationItem.rightBarButtonItems {
        if rightItems.contains(where: { $0.tag == 1337 }) {
             NSLog("[EeveeSpotify] Button already exists (tag 1337)")
             return 
        }
    }

    NSLog("[EeveeSpotify] Creating and injecting button...")
    
    let button = UIButton(type: .system)
    // Use system image to guarantee visibility and avoid crashes
    let image = UIImage(systemName: "gearshape.fill") ?? UIImage()
    button.setImage(image, for: .normal)
    button.tintColor = .white
    
    let action = UIAction { [weak target] _ in
        guard let target = target, let navigationController = target.navigationController else { 
            NSLog("[EeveeSpotify] Navigation controller not found")
            return 
        }
        
        NSLog("[EeveeSpotify] Opening EeveeSettings...")
        
        let eeveeSettingsController = EeveeSettingsViewController(
            target.view.bounds,
            settingsView: AnyView(EeveeSettingsView(navigationController: navigationController)),
            navigationTitle: "EeveeSpotify"
        )
        
        // Add GitHub button to the Eevee settings page itself
        let subButton = UIButton(type: .system)
        
        // Try loading hex image, fallback to system "globe" if it fails or bundle is missing
        let bundleImage = BundleHelper.shared.uiImage("hex")
        // Check if the image returned from BundleHelper is valid (has a size)
        if let bundleImage = bundleImage, bundleImage.size != .zero {
            subButton.setImage(bundleImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else {
             subButton.setImage(UIImage(systemName: "globe"), for: .normal)
        }
        
        subButton.tintColor = .white
        
        let subAction = UIAction { [weak eeveeSettingsController] _ in
            eeveeSettingsController?.openRepositoryUrl(subButton)
        }
        subButton.addAction(subAction, for: .touchUpInside)
        
        let menuBarItem = UIBarButtonItem(customView: subButton)
        menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 22).isActive = true
        menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 22).isActive = true
        eeveeSettingsController.navigationItem.rightBarButtonItem = menuBarItem
        
        navigationController.pushViewController(eeveeSettingsController, animated: true)
    }
    
    button.addAction(action, for: .touchUpInside)
    
    let item = UIBarButtonItem(customView: button)
    item.tag = 1337 // Tag to prevent duplicate addition
    item.customView?.widthAnchor.constraint(equalToConstant: 22).isActive = true
    item.customView?.heightAnchor.constraint(equalToConstant: 22).isActive = true
    
    var items = target.navigationItem.rightBarButtonItems ?? []
    items.insert(item, at: 0) // Prepend instead of append to ensure visibility
    target.navigationItem.rightBarButtonItems = items
    
    NSLog("[EeveeSpotify] Button injected. Items count: \(items.count)")
}

// MARK: - Fallback: Hook SettingsViewController directly (New UI)
class SettingsViewControllerHook: ClassHook<UIViewController> {
    typealias Group = UniversalSettingsIntegrationGroup
    static let targetName = "SettingsViewController"

    func viewDidLoad() {
        orig.viewDidLoad()
        injectEeveeButton(into: target)
    }

    func viewWillAppear(_ animated: Bool) {
        orig.viewWillAppear(animated)
        injectEeveeButton(into: target)
    }
}

// MARK: - Fallback: Hook RootSettingsViewController directly
class RootSettingsViewControllerHook: ClassHook<UIViewController> {
    typealias Group = UniversalSettingsIntegrationGroup
    static let targetName = "RootSettingsViewController"

    func viewDidLoad() {
        orig.viewDidLoad()
        injectEeveeButton(into: target)
    }

    func viewWillAppear(_ animated: Bool) {
        orig.viewWillAppear(animated)
        injectEeveeButton(into: target)
    }
}

// MARK: - Generic Fallback: Hook UINavigationController to catch Settings by title/class name
class SettingsNavigationStackHook: ClassHook<UINavigationController> {
    typealias Group = UniversalSettingsIntegrationGroup

    func pushViewController(_ viewController: UIViewController, animated: Bool) {
        orig.pushViewController(viewController, animated: animated)
        
        let targetVC = viewController
        
        // Check both immediately and with a delay
        let checkBlock = {
            let className = String(describing: type(of: targetVC))
            
            // Check title - localized "Settings" / "Preferences" in Spotify-supported languages
            let settingsTitles: Set<String> = [
                // English
                "Settings", "Preferences",
                // German
                "Einstellungen", "Präferenzen",
                // French
                "Paramètres", "Préférences",
                // Spanish
                "Configuración", "Ajustes", "Preferencias",
                // Italian
                "Impostazioni", "Preferenze",
                // Portuguese
                "Definições", "Configurações", "Preferências",
                // Dutch
                "Instellingen", "Voorkeuren",
                // Turkish
                "Ayarlar", "Tercihler",
                // Polish
                "Ustawienia", "Preferencje",
                // Russian
                "Настройки", "Параметры",
                // Ukrainian
                "Налаштування", "Параметри",
                // Czech
                "Nastavení", "Předvolby",
                // Swedish
                "Inställningar",
                // Norwegian
                "Innstillinger",
                // Danish
                "Indstillinger",
                // Finnish
                "Asetukset",
                // Hungarian
                "Beállítások",
                // Romanian
                "Setări", "Preferințe",
                // Slovak
                "Nastavenia",
                // Croatian/Bosnian/Serbian
                "Postavke", "Podešavanja",
                // Slovenian
                "Nastavitve",
                // Bulgarian
                "Настройки",
                // Greek
                "Ρυθμίσεις", "Προτιμήσεις",
                // Hebrew
                "הגדרות", "העדפות",
                // Arabic
                "الإعدادات", "التفضيلات",
                // Persian
                "تنظیمات", "ترجیحات",
                // Japanese
                "設定", "環境設定",
                // Korean
                "설정", "환경설정",
                // Chinese (Simplified)
                "设置", "偏好设置",
                // Chinese (Traditional)
                "設定", "偏好設定",
                // Thai
                "การตั้งค่า",
                // Vietnamese
                "Cài đặt", "Tùy chọn",
                // Indonesian
                "Pengaturan", "Setelan", "Preferensi",
                // Malay
                "Tetapan", "Keutamaan",
                // Filipino
                "Mga Setting", "Mga Kagustuhan",
                // Hindi
                "सेटिंग", "प्राथमिकताएं",
                // Bengali
                "সেটিংস",
                // Tamil
                "அமைப்புகள்",
                // Catalan
                "Configuració", "Preferències",
                // Basque
                "Ezarpenak",
                // Galician
                "Configuración", "Preferencias",
            ]
            if let title = targetVC.title, settingsTitles.contains(title) {
                NSLog("[EeveeSpotify] Detected Settings via Title: \(className)")
                injectEeveeButton(into: targetVC)
                return
            }
            
            // Check class name
            if className.contains("Settings") && !className.contains("Eevee") {
                NSLog("[EeveeSpotify] Detected Settings via Class Name: \(className)")
                injectEeveeButton(into: targetVC)
                return
            }
        }
        
        checkBlock()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: checkBlock)
    }
}
