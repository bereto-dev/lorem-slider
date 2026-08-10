import Foundation

enum LoremPreferences {
    private static let defaults = UserDefaults.standard
    private static let lastCountKey = "lastWordCount"

    static var lastCount: Int {
        // UserDefaults.integer(forKey:) returns 0 both when nothing's been saved yet
        // and if 0 were ever actually stored; since the slider's minimum is 1, treating
        // 0 as "unset" and falling back to 1 is unambiguous.
        get {
            let value = defaults.integer(forKey: lastCountKey)
            return value == 0 ? 1 : value
        }
        set { defaults.set(newValue, forKey: lastCountKey) }
    }
}
