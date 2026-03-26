import Orion
import UIKit

class SearchAdsHooksGroup: InstructionGroup {}

// Hook for Search View Controllers to hide sponsored content
class SearchViewControllerHook: ClassHook<UIViewController> {
    typealias Group = SearchAdsHooksGroup
    static var targetNames: [String] {
        return ["SPTSearchViewController", "SPTBrowseSearchViewController", "SPTSearch2ViewController"]
    }

    func viewWillAppear(_ animated: Bool) {
        orig.viewWillAppear(animated)
        hideSponsoredContent(in: target.view)
    }

    func viewDidAppear(_ animated: Bool) {
        orig.viewDidAppear(animated)
        hideSponsoredContent(in: target.view)
    }

    // orion:new
    private func hideSponsoredContent(in view: UIView) {
        let sponsoredKeywords = ["Advertisement", "Sponsored", "Sponsored Recommendation", "Promoted", "立即收藏"]
        
        // Find labels with sponsored keywords
        for subview in view.subviews {
            if let label = subview as? UILabel, let text = label.text {
                for keyword in sponsoredKeywords {
                    if text.contains(keyword) {
                        // If we find a sponsored label, hide its parent container
                        // Usually the ad is inside a cell or a specific container view
                        hideParentContainer(of: subview)
                        return
                    }
                }
            }
            hideSponsoredContent(in: subview)
        }
    }

    // orion:new
    private func hideParentContainer(of view: UIView) {
        var current: UIView? = view
        while let parent = current?.superview {
            let className = String(describing: type(of: parent))
            // Target common cell or ad container classes
            if className.contains("Cell") || className.contains("Container") || className.contains("Banner") || className.contains("Card") {
                parent.isHidden = true
                parent.frame = .zero
                return
            }
            current = parent
        }
        view.isHidden = true
    }
}

// Hook for Ad Banners specifically
class SPTAdBannerViewHook: ClassHook<UIView> {
    typealias Group = SearchAdsHooksGroup
    static var targetName = "SPTAdBannerView"

    func layoutSubviews() {
        orig.layoutSubviews()
        target.isHidden = true
        target.frame = .zero
    }
}

// Hook for Now Playing View (NPV) Ad components
class SPTNowPlayingAdViewControllerHook: ClassHook<UIViewController> {
    typealias Group = SearchAdsHooksGroup
    static var targetNames: [String] {
        return ["SPTNowPlayingAdViewController", "SPTNowPlayingVideoAdViewController"]
    }

    func viewWillAppear(_ animated: Bool) {
        orig.viewWillAppear(animated)
        target.view.isHidden = true
        target.view.frame = .zero
    }
}
