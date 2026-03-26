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
        
        // Aggressive Premium popup detection and dismissal
        if hasAdKeywords(in: dialogView) {
            target.dismiss(animated: false, completion: nil)
        }
    }
    
    // orion:new
    private func hasAdKeywords(in view: UIView) -> Bool {
        let keywords = ["premium", "ad-free", "upgrade", "subscribe", "offer", "try free", "plan", "get 3 months"]
        
        if let label = view as? UILabel, let text = label.text?.lowercased() {
            for keyword in keywords {
                if text.contains(keyword) { return true }
            }
        }
        
        for subview in view.subviews {
            if hasAdKeywords(in: subview) { return true }
        }
        
        return false
    }
}
