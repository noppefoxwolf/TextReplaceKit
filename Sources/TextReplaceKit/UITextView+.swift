import UIKit

extension UITextView {
    public enum Granularity {
        case selectedLine
        case document
    }
    
    public typealias ShortcodeTransform = (AttributedString.Shortcode) -> AttributedString?
    
    public func replaceShortcode(_ transform: ShortcodeTransform, granularity: Granularity) {
        switch granularity {
        case .selectedLine:
            replaceShortcodeSelectedLine(transform: transform)
        case .document:
            replaceShortcodeWholeDocument(transform: transform)
        }
    }
    
    func replaceShortcodeSelectedLine(transform: ShortcodeTransform) {
        guard let selectedTextRange else { return }
        let selectedLineRangeStart = tokenizer.position(
            from: selectedTextRange.start,
            toBoundary: .line,
            inDirection: .layout(.left)
        )
        let selectedLineRangeEnd = tokenizer.position(
            from: selectedTextRange.start,
            toBoundary: .line,
            inDirection: .layout(.right)
        )
        guard let selectedLineRangeStart, let selectedLineRangeEnd else { return }
        let selectedLineRange = textRange(from: selectedLineRangeStart, to: selectedLineRangeEnd)
        guard let selectedLineRange else { return }
        replaceShortcode(in: selectedLineRange, transform: transform)
    }
    
    func replaceShortcodeWholeDocument(transform: ShortcodeTransform) {
        let documentRange = textRange(from: beginningOfDocument, to: endOfDocument)
        guard let documentRange else { return }
        replaceShortcode(in: documentRange, transform: transform)
    }
    
    func replaceShortcode(in range: UITextRange, transform: ShortcodeTransform) {
        let lineAttributedText = AttributedString(attributedText(in: range))
        let newLineAttributedText = lineAttributedText.replacingShortcode(with: transform)
        if lineAttributedText != newLineAttributedText {
            let newLineNSAttributedText = NSAttributedString(newLineAttributedText)
            replace(range, withAttributedText: newLineNSAttributedText)
        }
    }
}
