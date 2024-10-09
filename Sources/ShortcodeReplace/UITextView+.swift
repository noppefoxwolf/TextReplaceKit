import UIKit
import Extensions

extension UITextView {
    public enum Granularity {
        case selectedLine
        case document
    }

    public typealias ShortcodeTransform = (Shortcode) -> NSAttributedString?

    public func replaceShortcode(
        _ transform: ShortcodeTransform,
        granularity: Granularity
    ) {
        switch granularity {
        case .selectedLine:
            replaceShortcodeLine(
                transform: transform,
                at: selectedTextRange?.start ?? endOfDocument
            )
        case .document:
            replaceShortcodeWholeDocument(transform: transform)
        }
    }

    func replaceShortcodeLine(transform: ShortcodeTransform, at posision: UITextPosition) {
        let lineRangeStart = tokenizer.position(
            from: posision,
            toBoundary: .line,
            inDirection: .layout(.left)
        )
        let lineRangeEnd = tokenizer.position(
            from: posision,
            toBoundary: .line,
            inDirection: .layout(.right)
        )
        guard let lineRangeStart, let lineRangeEnd else { return }
        let lineRange = textRange(from: lineRangeStart, to: lineRangeEnd)
        guard let lineRange else { return }
        replaceShortcode(in: lineRange, transform: transform)
    }

    func replaceShortcodeWholeDocument(transform: ShortcodeTransform) {
        let documentRange = textRange(from: beginningOfDocument, to: endOfDocument)
        guard let documentRange else { return }
        replaceShortcode(in: documentRange, transform: transform)
    }

    func replaceShortcode(in range: UITextRange, transform: ShortcodeTransform) {
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
        if didChanged {
            delegate?.textViewDidChange?(self)
        }
    }
}
