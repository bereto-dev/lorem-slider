import Foundation

enum LoremPreferences {
    private static let defaults = UserDefaults.standard
    private static let lastCountKey = "lastWordCount"

    static var lastCount: Int {
        get { defaults.integer(forKey: lastCountKey) }
        set { defaults.set(newValue, forKey: lastCountKey) }
    }
}
