import Cocoa

private let PANEL_W: CGFloat = 240
private let PAD: CGFloat = 14

class SliderPanel: NSPanel {

    private let countLabel = ClickableLabel(labelWithString: "0")
    private let captionLabel = label(NSLocalizedString("words", comment: "Caption next to the word count, e.g. \"18 words\""), size: 15, weight: .medium, alpha: 0.65)
    // Slider's own range is a plain 0...1 drag position; SliderCurve maps that to the
    // actual (non-linear) word count.
    private let slider = ReleaseSlider(value: 0, minValue: 0, maxValue: 1, target: nil, action: nil)
    private let copyToast = CopyToastView()
    private var card: CardView!

    private var hasBeenPositioned = false
    private var copyFeedbackTimer: Timer?

    convenience init() {
        self.init(
            contentRect: NSRect(x: 0, y: 0, width: PANEL_W, height: 120),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        isFloatingPanel = true
        // .floating (not .popUpMenu) is the level persistent utility palettes use to
        // stay above other apps' windows indefinitely — this panel is meant to be
        // left open on screen while working in another app, not dismissed the moment
        // you click elsewhere.
        level = .floating
        backgroundColor = .clear
        isOpaque = false
        hasShadow = true
        isMovableByWindowBackground = true
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        buildUI()
    }

    // MARK: - UI

    private func buildUI() {
        let root = NSView(frame: contentView!.bounds)
        root.autoresizingMask = [.width, .height]
        contentView = root

        card = CardView()
        card.translatesAutoresizingMaskIntoConstraints = false
        root.addSubview(card)
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: root.topAnchor, constant: 6),
            card.leadingAnchor.constraint(equalTo: root.leadingAnchor, constant: 6),
            card.trailingAnchor.constraint(equalTo: root.trailingAnchor, constant: -6),
            card.bottomAnchor.constraint(equalTo: root.bottomAnchor, constant: -6),
        ])

        countLabel.font = .monospacedDigitSystemFont(ofSize: 20, weight: .bold)
        countLabel.textColor = NSColor.white.withAlphaComponent(0.95)
        countLabel.onClick = { [weak self] in self?.copyCurrent() }
        captionLabel.onClick = { [weak self] in self?.copyCurrent() }

        slider.isContinuous = true
        slider.target = self
        slider.action = #selector(sliderChanged)
        slider.onRelease = { [weak self] in self?.copyCurrent() }
        slider.doubleValue = SliderCurve.position(forCount: LoremPreferences.lastCount)
        countLabel.stringValue = "\(currentCount)"

        // Number + caption on one line ("18 words") instead of stacked, so the whole
        // top section only needs one line's worth of height.
        let countRow = NSStackView(views: [countLabel, captionLabel])
        countRow.orientation = .horizontal
        countRow.alignment = .firstBaseline
        countRow.spacing = 5

        let rootStack = NSStackView(views: [countRow, slider])
        rootStack.orientation = .vertical
        rootStack.alignment = .leading
        rootStack.spacing = 8
        rootStack.edgeInsets = NSEdgeInsets(top: PAD, left: PAD, bottom: PAD, right: PAD)
        rootStack.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(rootStack)
        NSLayoutConstraint.activate([
            rootStack.topAnchor.constraint(equalTo: card.topAnchor),
            rootStack.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            rootStack.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            rootStack.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            slider.widthAnchor.constraint(equalTo: rootStack.widthAnchor, constant: -PAD * 2),
        ])

        // Added last so it renders above the card and everything in it, and lives
        // outside rootStack so it never reserves its own row height. Pinned to the
        // right edge (not centered) so it never sits on top of the word count, which
        // is left-aligned.
        copyToast.translatesAutoresizingMaskIntoConstraints = false
        copyToast.alphaValue = 0
        root.addSubview(copyToast)
        NSLayoutConstraint.activate([
            copyToast.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -10),
            copyToast.topAnchor.constraint(equalTo: card.topAnchor, constant: 10),
        ])
    }

    private func resize() {
        contentView?.layoutSubtreeIfNeeded()
        let fit = contentView!.fittingSize
        setContentSize(NSSize(width: PANEL_W, height: fit.height))
    }

    // MARK: - Show / hide

    func present(relativeTo button: NSStatusBarButton) {
        // Settle the window's real (compact) size *before* positioning it. setFrameTopLeftPoint
        // below anchors using the window's current frame size, and NSWindow keeps the
        // bottom edge fixed when that size later changes — so positioning first and
        // resizing after let a shorter final height drag the top edge down below where
        // it was placed, opening the panel well below the menu bar icon.
        resize()

        // Only auto-position under the menu bar icon the first time this panel is
        // ever shown. After that, leave it wherever the user last dragged it.
        if !hasBeenPositioned {
            if let screen = button.window?.screen ?? NSScreen.main {
                let btnFrame = button.window!.convertToScreen(button.frame)
                var x = btnFrame.midX - PANEL_W / 2
                var y = btnFrame.minY - 8
                x = min(x, screen.visibleFrame.maxX - PANEL_W - 8)
                x = max(x, screen.visibleFrame.minX + 8)
                // Defensive clamp: if the button's frame is ever reported before it has
                // a real on-screen position (as happens if this is ever triggered too
                // early in the app's lifecycle), btnFrame collapses toward (0,0) and the
                // panel would otherwise land off the bottom of the screen, permanently
                // out of reach since positioning only happens this once.
                y = max(y, screen.visibleFrame.minY + 8)
                y = min(y, screen.visibleFrame.maxY - 8)
                setFrameTopLeftPoint(NSPoint(x: x, y: y))
            }
            hasBeenPositioned = true
        }
        orderFrontRegardless()
    }

    func dismiss() {
        orderOut(nil)
    }

    // MARK: - Actions

    private var currentCount: Int {
        SliderCurve.wordCount(forPosition: slider.doubleValue)
    }

    @objc private func sliderChanged() {
        countLabel.stringValue = "\(currentCount)"
    }

    private func copyCurrent() {
        let count = currentCount
        LoremPreferences.lastCount = count
        let text = LoremGenerator.generate(wordCount: count)
        PasteboardWriter.copy(text)
        showCopyFeedback()
    }

    private func showCopyFeedback() {
        copyFeedbackTimer?.invalidate()
        copyToast.animator().alphaValue = 1
        copyFeedbackTimer = Timer.scheduledTimer(withTimeInterval: 1.4, repeats: false) { [weak self] _ in
            NSAnimationContext.runAnimationGroup { ctx in
                ctx.duration = 0.3
                self?.copyToast.animator().alphaValue = 0
            }
        }
    }
}

// MARK: - Helpers

private func label(_ s: String, size: CGFloat, weight: NSFont.Weight, alpha: CGFloat) -> ClickableLabel {
    let f = ClickableLabel(labelWithString: s)
    f.font = .systemFont(ofSize: size, weight: weight)
    f.textColor = NSColor.white.withAlphaComponent(alpha)
    return f
}

/// A text label that copies the current word count when clicked — lets the count
/// and its caption act as a click-to-copy target, same as releasing the slider.
private class ClickableLabel: NSTextField {
    var onClick: (() -> Void)?

    override func mouseDown(with event: NSEvent) { onClick?() }

    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .pointingHand)
    }
}

private class CardView: NSView {
    override func draw(_ dirtyRect: NSRect) {
        let path = NSBezierPath(roundedRect: bounds, xRadius: 12, yRadius: 12)
        NSColor(red: 0.12, green: 0.12, blue: 0.13, alpha: 0.97).setFill()
        path.fill()
    }
}

/// Floating "Copied" pill overlaid on top of the whole panel — has its own opaque
/// background since it can appear over any content underneath it.
private class CopyToastView: NSView {
    private let label = NSTextField(labelWithString: "✓ " + NSLocalizedString("copied", comment: "Copy confirmation toast"))

    override init(frame: NSRect) {
        super.init(frame: frame)
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func draw(_ dirtyRect: NSRect) {
        let path = NSBezierPath(roundedRect: bounds, xRadius: bounds.height / 2, yRadius: bounds.height / 2)
        NSColor.black.withAlphaComponent(0.88).setFill()
        path.fill()
    }
}

/// NSSlider subclass that reports the drag release separately from its continuous
/// drag action, so the live label update (on every drag tick) and the
/// copy-to-clipboard behavior (only once, on release) can use different callbacks.
///
/// NSSlider tracks the entire drag — down, move, up — inside its own mouseDown(with:),
/// which runs a private event loop and never dispatches a separate mouseUp(with:) to
/// the view; overriding mouseUp directly is a no-op and silently never fires. Instead,
/// let super.mouseDown block for the whole drag as usual, then fire onRelease once it
/// returns — that return only happens once the mouse button has actually been released.
private class ReleaseSlider: NSSlider {
    var onRelease: (() -> Void)?

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        onRelease?()
    }
}
