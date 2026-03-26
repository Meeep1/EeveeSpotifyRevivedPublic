import Orion
import UIKit

class SearchAdsHooksGroup: InstructionGroup {}

// Hook for Search View Controllers to hide sponsored content
class SearchViewControllerHook: ClassHook<UIViewController> {
    typealias Group = SearchAdsHooksGroup
    static var targetName: String { "SPTSearchViewController" }

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
        
        for subview in view.subviews {
            if let label = subview as? UILabel, let text = label.text {
                for keyword in sponsoredKeywords {
                    if text.contains(keyword) {
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

// Hook for BrowseSearchViewController
class BrowseSearchViewControllerHook: ClassHook<UIViewController> {
    typealias Group = SearchAdsHooksGroup
    static var targetName: String { "SPTBrowseSearchViewController" }

    func viewWillAppear(_ animated: Bool) {
        orig.viewWillAppear(animated)
        target.view.isHidden = false // Ensure main view is visible
    }
}

// Hook for Search2ViewController
class Search2ViewControllerHook: ClassHook<UIViewController> {
    typealias Group = SearchAdsHooksGroup
    static var targetName: String { "SPTSearch2ViewController" }

    func viewWillAppear(_ animated: Bool) {
        orig.viewWillAppear(animated)
    }
}

// Hook for Ad Banners specifically
class SPTAdBannerViewHook: ClassHook<UIView> {
    typealias Group = SearchAdsHooksGroup
    static var targetName: String { "SPTAdBannerView" }

    func layoutSubviews() {
        orig.layoutSubviews()
        target.isHidden = true
        target.frame = .zero
    }
}

// Hook for Now Playing View (NPV) Ad components
class SPTNowPlayingAdViewControllerHook: ClassHook<UIViewController> {
    typealias Group = SearchAdsHooksGroup
    static var targetName: String { "SPTNowPlayingAdViewController" }

    func viewWillAppear(_ animated: Bool) {
        orig.viewWillAppear(animated)
        target.view.isHidden = true
        target.view.frame = .zero
    }
}

class SPTNowPlayingVideoAdViewControllerHook: ClassHook<UIViewController> {
    typealias Group = SearchAdsHooksGroup
    static var targetName: String { "SPTNowPlayingVideoAdViewController" }

    func viewWillAppear(_ animated: Bool) {
        orig.viewWillAppear(animated)
        target.view.isHidden = true
        target.view.frame = .zero
    }
}
