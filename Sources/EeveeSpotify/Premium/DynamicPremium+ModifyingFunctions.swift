import Foundation
import UIKit

func modifyRemoteConfiguration(_ configuration: inout UcsResponse) {
    modifyAttributes(&configuration.attributes.accountAttributes)
    
    if UserDefaults.overwriteConfiguration {
        configuration.resolve.configuration = try! BundleHelper.shared.resolveConfiguration()
    }
    else {
        modifyAssignedValues(&configuration.assignedValues)
    }
}

private let propertyReplacements = [
    // capping
    EeveePropertyReplacement(name: "enable_common_capping", modification: .remove),
    EeveePropertyReplacement(name: "enable_pns_common_capping", modification: .remove),
    EeveePropertyReplacement(name: "enable_pick_and_shuffle_common_capping", modification: .remove),
    EeveePropertyReplacement(name: "enable_pick_and_shuffle_dynamic_cap", modification: .remove),
    EeveePropertyReplacement(name: "pick_and_shuffle_timecap", modification: .remove),
    EeveePropertyReplacement(scope: "ios-feature-queue", modification: .remove),
    
    // also capping idk
    EeveePropertyReplacement(name: "enable_free_on_demand_experiment", modification: .remove),
    EeveePropertyReplacement(name: "enable_free_on_demand_context_menu_experiment", modification: .remove),
    EeveePropertyReplacement(name: "enable_mft_plus_queue", modification: .remove),
    EeveePropertyReplacement(name: "enable_mft_plus_extended_queue", modification: .remove),
    EeveePropertyReplacement(name: "enable_playback_timeout_service", modification: .setBool(false)),
    EeveePropertyReplacement(name: "enable_playback_timeout_error_ui", modification: .setBool(false)),
    EeveePropertyReplacement(name: "playback_timeout_action", modification: .setEnum("Nothing")),
    EeveePropertyReplacement(name: "is_remove_from_queue_enabled_for_mft_plus", modification: .remove),
    EeveePropertyReplacement(name: "is_reordering_for_mft_plus_allowed", modification: .remove),
    
    // 😡😡😡 spotify, stop changing the scroll logic
    EeveePropertyReplacement(name: "should_nova_scroll_use_scrollsita", modification: .remove)
]

private func modifyAssignedValues(_ values: inout [AssignedValue]) {
    for replacement in propertyReplacements {
        let matchingIndices = values.indices.filter({ index in
            let value = values[index]
            let nameMatches = replacement.name.map { value.propertyID.name == $0 } ?? true
            let scopeMatches = replacement.scope.map { value.propertyID.scope == $0 } ?? true
            return nameMatches && scopeMatches
        })
        
        for index in matchingIndices.sorted(by: >) {
            switch replacement.modification {
            case .remove:
                values.remove(at: index)
                
            case .setBool(let newValue):
                values[index].boolValue = BoolValue.with { $0.value = newValue }
                
            case .setEnum(let newValue):
                values[index].enumValue = EnumValue.with { $0.value = newValue }
            }
        }
    }
}

private func modifyAttributes(_ attributes: inout [String: AccountAttribute]) {
    let oneYearFromNow = Calendar.current.date(byAdding: .year, value: 1, to: Date())!
    
    let formatter = ISO8601DateFormatter()
    formatter.timeZone = TimeZone(abbreviation: "UTC")
    
    attributes["ads"] = AccountAttribute.with {
        $0.boolValue = false
    }

    attributes["can_use_superbird"] = AccountAttribute.with {
        $0.boolValue = true
    }

    attributes["catalogue"] = AccountAttribute.with {
        $0.stringValue = "premium"
    }

    attributes["financial-product"] = AccountAttribute.with {
        $0.stringValue = "pr:premium,tc:0"
    }

    attributes["is-eligible-premium-unboxing"] = AccountAttribute.with {
        $0.boolValue = true
    }

    attributes["name"] = AccountAttribute.with {
        $0.stringValue = "Spotify Premium"
    }

    attributes["nft-disabled"] = AccountAttribute.with {
        $0.stringValue = "1"
    }

    attributes["offline"] = AccountAttribute.with {
        $0.boolValue = true // allow downloading
    }

    attributes["on-demand"] = AccountAttribute.with {
        $0.boolValue = true
    }

    attributes["payments-initial-campaign"] = AccountAttribute.with {
        $0.stringValue = "default"
    }

    attributes["player-license"] = AccountAttribute.with {
        $0.stringValue = "premium"
    }

    attributes["player-license-v2"] = AccountAttribute.with {
        $0.stringValue = "premium"
    }

    attributes["product-expiry"] = AccountAttribute.with {
        $0.stringValue = formatter.string(from: oneYearFromNow)
    }

    attributes["shuffle-eligible"] = AccountAttribute.with {
        $0.boolValue = true
    }

    attributes["social-session"] = AccountAttribute.with {
        $0.boolValue = true
    }

    attributes["social-session-free-tier"] = AccountAttribute.with {
        $0.boolValue = false
    }

    attributes["streaming-rules"] = AccountAttribute.with {
        $0.stringValue = ""
    }

    attributes["subscription-enddate"] = AccountAttribute.with {
        $0.stringValue = formatter.string(from: oneYearFromNow)
    }

    attributes["type"] = AccountAttribute.with {
        $0.stringValue = "premium"
    }

    attributes["unrestricted"] = AccountAttribute.with {
        $0.boolValue = true
    }

    attributes.removeValue(forKey: "payment-state")
    attributes.removeValue(forKey: "last-premium-activation-date")
    
    // Modern logout prevention (Spotify 9.1.22+)
    // Removing these forces the app to rely on the static premium attributes we set
    // and prevents it from performing "Smart Shuffle" or "Trial" validation logic
    // that often triggers a background logout.
    attributes.removeValue(forKey: "on-demand-trial")
    attributes.removeValue(forKey: "on-demand-trial-in-progress")
    attributes.removeValue(forKey: "smart-shuffle")
    
    // Additional keys that can trigger backend validation mismatches
    attributes.removeValue(forKey: "at-signal")
    attributes.removeValue(forKey: "feature-set-id-masked")
    attributes.removeValue(forKey: "strider-key")
}
