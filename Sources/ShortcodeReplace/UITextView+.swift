public import UIKit
import Extensions

extension UITextView {
    public enum Granularity {
        case selectedLine
        case document
    }

    public typealias ShortcodeTransform = (Shortcode) -> NSAttributedString?
    
    public func setReplacedAttributedText(
        _ transform: ShortcodeTransform,
        granularity: Granularity
    ) {
        switch granularity {
        case .selectedLine:
            replaceShortcode(
                in: selectedLineTextRange ?? documentRange,
                transform: transform,
                usesDelegate: false
            )
        case .document:
            replaceShortcode(
                in: documentRange,
                transform: transform,
                usesDelegate: false
            )
        }
    }

    public func replaceShortcode(
        _ transform: ShortcodeTransform,
        granularity: Granularity
    ) {
        switch granularity {
        case .selectedLine:
            replaceShortcode(
                in: selectedLineTextRange ?? documentRange,
                transform: transform,
                usesDelegate: true
            )
        case .document:
            replaceShortcode(
                in: documentRange,
                transform: transform,
                usesDelegate: true
            )
        }
    }

    func replaceShortcode(in range: UITextRange, transform: ShortcodeTransform, usesDelegate: Bool = true) {
        var didChanged: Bool = false
        attributedText(in: range)
            .enumerateShortcodes(
                transform: transform,
                using: { statement, nsRange, _ in
                    let textRange = textRange(from: range.start, for: nsRange)
                    if let textRange {
                        replaceAndAdjutSelectedTextRange(
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
