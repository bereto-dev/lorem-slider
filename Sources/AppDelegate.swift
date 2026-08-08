import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarController: StatusBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        statusBarController = StatusBarController()
        // Deliberately not auto-showing the panel here: right after a cold launch,
        // the status item's window hasn't actually been placed on the real menu bar
        // strip yet (even one run loop turn later), so converting its frame to screen
        // coordinates yields a bogus frame and positions the panel off the bottom of
        // the screen — permanently, since positioning only ever happens once. Waiting
        // for the user's first real click sidesteps this entirely: by definition they
        // can't click a button that isn't already laid out on screen.
    }

    // Fires when the Dock icon (manually added by the user, since this LSUIElement
    // app has no Dock tile of its own while running) is clicked while already running.
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        statusBarController?.showPanel()
        return true
    }
}
