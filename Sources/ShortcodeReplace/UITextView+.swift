public import UIKit
import Extensions

extension UITextView {
    public typealias ShortcodeTransform = (Shortcode) -> NSAttributedString?

    public func replaceShortcodesSilently(
        _ transform: ShortcodeTransform,
        granularity: TextReplaceGranularity
    ) {
        switch granularity {
        case .selectedLine:
            replaceShortcodes(
                in: selectedLineTextRange ?? documentRange,
                transform: transform,
                usesDelegate: false
            )
        case .document:
            replaceShortcodes(
                in: documentRange,
                transform: transform,
                usesDelegate: false
            )
        }
    }

    public func replaceShortcodes(
        _ transform: ShortcodeTransform,
        granularity: TextReplaceGranularity
    ) {
        switch granularity {
        case .selectedLine:
            replaceShortcodes(
                in: selectedLineTextRange ?? documentRange,
                transform: transform,
                usesDelegate: true
            )
        case .document:
            replaceShortcodes(
                in: documentRange,
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
}
