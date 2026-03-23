import Foundation

extension UserDefaults {
    private static let lyricsSourceKey = "lyricsSource"
    
    static var lyricsSource: LyricsSource {
        get {
            if let rawValue = container.object(forKey: lyricsSourceKey) as? Int {
                return LyricsSource(rawValue: rawValue) ?? .defaultSource
            }

            return LyricsSource.defaultSource
        }
        set (newSource) {
            container.set(newSource.rawValue, forKey: lyricsSourceKey)
        }
    }
}
