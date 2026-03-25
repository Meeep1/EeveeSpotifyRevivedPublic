import Orion
import UIKit
import SwiftUI
struct DarkPopUps: HookGroup { }
private var popUpContainerViewController: String {
    // For 9.1.x, use dummy UIView to avoid crashes
    if EeveeSpotify.hookTarget == .v91 {
        return "UIView"
    }
    
    switch EeveeSpotify.hookTarget {
    case .lastAvailableiOS14: return "SPTEncorePopUpContainer"
    default: return "SPTEncorePopUpContainer" // Use older class for compatibility
    }
}
class EncoreLabelHook: ClassHook<UIView> {
    typealias Group = DarkPopUps
    
    static var targetName: String {
        return EeveeSpotify.hookTarget == .v91 ? "UIView" : "SPTEncoreLabel"
    }
    func intrinsicContentSize() -> CGSize {
        if let viewController = WindowHelper.shared.viewController(for: target),
            NSStringFromClass(type(of: viewController)) == popUpContainerViewController
        {
            let label = Dynamic.convert(target.subviews.first!, to: UILabel.self)
            if !label.hasParent(matching: "Primary") {
                label.textColor = .white
            }
        }
        return orig.intrinsicContentSize()
    }
}
class SPTEncorePopUpContainerHook: ClassHook<UIViewController> {
    typealias Group = DarkPopUps
    static var targetName: String {
        return popUpContainerViewController
    }
    
    func containedView() -> SPTEncorePopUpDialog {
        return orig.containedView()
    }
    
    func viewDidAppear(_ animated: Bool) {
        orig.viewDidAppear(animated)
        
        let dialogView = containedView().uiView()
        dialogView.backgroundColor = UIColor(Color(hex: "#242424"))
        
        // Attempt to identify if this is a Premium upsell/ad popup
        // If it is, we dismiss it immediately
        if let titleLabel = findLabel(in: dialogView), 
           let text = titleLabel.text?.lowercased(),
           (text.contains("premium") || text.contains("ad-free") || text.contains("upgrade")) {
            
            // Dismiss the view controller silently
            target.dismiss(animated: false, completion: nil)
        }
    }
    
    // Helper to find labels in the view hierarchy
    // orion:new
    private func findLabel(in view: UIView) -> UILabel? {
        if let label = view as? UILabel {
            return label
        }
        for subview in view.subviews {
            if let found = findLabel(in: subview) {
                return found
            }
        }
        return nil
    }
}
