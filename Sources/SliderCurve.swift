import Foundation

/// Maps the slider's raw 0...1 drag position to a 0...500 word count using two
/// linear segments instead of one: the first half of the track covers 0-100 words
/// (fine-grained, for the counts people reach for most), the second half covers
/// 101-500 (coarser, for the rare large counts) — so the count accelerates instead
/// of moving at a constant rate across the whole drag.
enum SliderCurve {
    static let breakpointCount = 100
    static let maxCount = 500

    static func wordCount(forPosition position: Double) -> Int {
        let p = min(max(position, 0), 1)
        let count: Double
        if p <= 0.5 {
            count = (p / 0.5) * Double(breakpointCount)
        } else {
            count = Double(breakpointCount) + ((p - 0.5) / 0.5) * Double(maxCount - breakpointCount)
        }
        return Int(count.rounded())
    }

    static func position(forCount count: Int) -> Double {
        let c = Double(min(max(count, 0), maxCount))
        if c <= Double(breakpointCount) {
            return (c / Double(breakpointCount)) * 0.5
        } else {
            return 0.5 + ((c - Double(breakpointCount)) / Double(maxCount - breakpointCount)) * 0.5
        }
    }
}
