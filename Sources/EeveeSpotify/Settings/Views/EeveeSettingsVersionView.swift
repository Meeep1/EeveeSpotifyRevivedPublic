import SwiftUI

struct EeveeSettingsVersionView: View {
    @State private var latestVersion: String?
    @State private var isPresentingContributorsSheet = false
    
    private func loadVersion() async throws {
        let release = try await GitHubHelper.shared.getLatestRelease()
        // Handle tag formats: "6.4.3", "v6.4.3", or "swift6.4.3"
        var version = release.tagName
        if version.hasPrefix("swift") {
            version = String(version.dropFirst(5)) // swift6.4.3 -> 6.4.3
        } else if version.hasPrefix("v") {
            version = String(version.dropFirst(1)) // v6.4.3 -> 6.4.3
        }
        latestVersion = version
    }
    
    private var isUpdateAvailable: Bool {
        guard let latestVersion = latestVersion else { return false }
        return isNewerVersion(latestVersion, than: EeveeSpotify.version)
    }
    
    private func isNewerVersion(_ version1: String, than version2: String) -> Bool {
        let v1Components = version1.split(separator: ".").compactMap { Int($0) }
        let v2Components = version2.split(separator: ".").compactMap { Int($0) }
        
        // Compare major, minor, patch
        for i in 0..<max(v1Components.count, v2Components.count) {
            let v1 = i < v1Components.count ? v1Components[i] : 0
            let v2 = i < v2Components.count ? v2Components[i] : 0
            
            if v1 > v2 { return true }  // version1 is newer
            if v1 < v2 { return false } // version1 is older
        }
        
        return false // versions are equal
    }
    
    var body: some View {
        Section {
            if isUpdateAvailable {
                Link(
                    "update_available".localized,
                    destination: URL(string: "https://github.com/Meeep1/EeveeSpotifyRevivedPublic/releases")!
                )
            }
        } footer: {
            VStack(alignment: .leading) {
                Text("v\(EeveeSpotify.version) (build \(EeveeSpotify.buildNumber))")
                
                if latestVersion == nil {
                    HStack(spacing: 10) {
                        ProgressView()
                        Text("checking_for_update".localized)
                    }
                }
                else {
                    Button("\("contributors".localized)...") {
                        isPresentingContributorsSheet = true
                    }
                    .foregroundColor(.gray)
                    .font(.subheadline.weight(.semibold))
                }
            }
        }
        .sheet(isPresented: $isPresentingContributorsSheet) {
            EeveeContributorsSheetView()
        }
        
        .animation(.default, value: latestVersion)
        
        .onAppear {
            Task {
                try await loadVersion()
            }
        }
    }
}
