import UIKit

extension UITextView {
    public enum Granularity {
        case selectedLine
        case document
    }
    
    public typealias ShortcodeTransform = (Shortcode) -> AttributedString?
    
    public func replaceShortcode(
        _ transform: ShortcodeTransform,
        regexExpression: String = AttributedString.defaultShortcodeRegexExpression,
        granularity: Granularity
    ) {
        switch granularity {
        case .selectedLine:
            replaceShortcodeSelectedLine(regexExpression: regexExpression, transform: transform)
        case .document:
            replaceShortcodeWholeDocument(regexExpression: regexExpression, transform: transform)
        }
    }
    
    func replaceShortcodeSelectedLine(regexExpression: String, transform: ShortcodeTransform) {
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
        replaceShortcode(in: selectedLineRange, regexExpression: regexExpression, transform: transform)
    }
    
    func replaceShortcodeWholeDocument(regexExpression: String, transform: ShortcodeTransform) {
        let documentRange = textRange(from: beginningOfDocument, to: endOfDocument)
        guard let documentRange else { return }
        replaceShortcode(in: documentRange, regexExpression: regexExpression, transform: transform)
    }
    
    func replaceShortcode(in range: UITextRange, regexExpression: String, transform: ShortcodeTransform) {
        let lineAttributedText = AttributedString(attributedText(in: range))
        let newLineAttributedText = lineAttributedText.replacingShortcode(
            regexExpression: regexExpression,
            with: transform
        )
        if lineAttributedText != newLineAttributedText {
            let newLineNSAttributedText = NSAttributedString(newLineAttributedText)
            replace(range, withAttributedText: newLineNSAttributedText)
        }
    }
}

