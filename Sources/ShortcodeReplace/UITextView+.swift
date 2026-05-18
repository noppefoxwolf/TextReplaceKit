public import UIKit
import Extensions

extension UITextView {
    public typealias ShortcodeTransform = (Shortcode) -> NSAttributedString?

    public func replaceShortcodesSilently(
        _ transform: ShortcodeTransform,
        textRange: UITextRange
    ) {
        if let range = shortcodeTextRange(adjacentTo: textRange) {
            replaceShortcodes(
                in: range,
                transform: transform,
                usesDelegate: false
            )
        }
    }

    public func replaceShortcodes(
        _ transform: ShortcodeTransform,
        textRange: UITextRange
    ) {
        if let range = shortcodeTextRange(adjacentTo: textRange) {
            replaceShortcodes(
                in: range,
                transform: transform,
                usesDelegate: true
            )
        }
    }

    func replaceShortcodes(
        in range: UITextRange,
        transform: ShortcodeTransform,
        usesDelegate: Bool = true
    ) {
        var didChanged: Bool = false
        attributedText(in: range)
            .enumerateShortcodes(
                transform: transform,
                using: { statement, nsRange, _ in
                    let textRange = textRange(from: range.start, for: nsRange)
                    if let textRange {
                        replacePreservingSelection(
                            textRange,
                            withAttributedText: statement.attributedText
                        )
                        didChanged = true
                    }
                }
            )
        if didChanged && usesDelegate {
            delegate?.textViewDidChange?(self)
        }
    }

    private func shortcodeTextRange(adjacentTo range: UITextRange) -> UITextRange? {
        let lowerBound = offset(from: beginningOfDocument, to: range.start)
        let upperBound = offset(from: beginningOfDocument, to: range.end)
        let attributedText = attributedText ?? NSAttributedString()

        var matchedRange: NSRange?
        attributedText.enumerateMatches(Regex.shortcodeWithPadding) { _, nsRange, shouldStop in
            guard nsRange.location <= upperBound && lowerBound <= nsRange.upperBound else { return }
            if let currentRange = matchedRange {
                matchedRange = currentRange.union(nsRange)
            } else {
                matchedRange = nsRange
            }
        }

        guard let matchedRange else { return nil }
        return textRange(location: matchedRange.location, length: matchedRange.length)
    }
}
