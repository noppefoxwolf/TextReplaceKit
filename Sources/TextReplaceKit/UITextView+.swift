import UIKit

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
        let lineAttributedText = attributedText(in: range)
        let newLineAttributedText = lineAttributedText.copyAsMutable()
        newLineAttributedText.replaceShortcode(
            with: transform,
            replaceAction: { _,nsRange, s in
                let start = position(
                    from: range.start,
                    offset: nsRange.location
                )!
                let end = position(
                    from: range.start,
                    offset: nsRange.location + nsRange.length
                )!
                let textRange = textRange(from: start, to: end)!
                self.apply(textRange, withAttributedText: s)
            }
        )
        if lineAttributedText != newLineAttributedText {
            let newLineNSAttributedText = newLineAttributedText
            self.workaround.replace(range, withAttributedText: newLineNSAttributedText)
        }
    }
}

extension UITextView {
    func closestPosition(to position: UITextPosition, within range: UITextRange) -> UITextPosition {
        let lower = compare(range.start, to: position)
        let upper = compare(range.end, to: position)
        if upper == .orderedAscending || upper == .orderedSame {
            return range.end
        }
        if lower == .orderedDescending || lower == .orderedSame {
            return range.start
        }
        return range.end
    }
    
    func contains(_ range: UITextRange, to position: UITextPosition) -> Bool {
        switch compare(range.start, to: position) {
        case .orderedAscending, .orderedSame:
            switch compare(range.end, to: position) {
            case .orderedDescending, .orderedSame:
                return true
            default:
                return false
            }
        default:
            return false
        }
    }
}

extension UITextView {
    func apply(_ range: UITextRange, withAttributedText attributedText: NSAttributedString) {
        enum Anchor: Sendable {
            case leading
            case trailing
        }
        
        let closestPosition = closestPosition(to: selectedTextRange!.start, within: range)
        let isRangeContainsPosition = contains(range, to: selectedTextRange!.start)
        let anchor = closestPosition == range.start ? Anchor.leading : Anchor.trailing
        
        let beforeTextRange = selectedTextRange
        replace(range, withAttributedText: attributedText)
        let afterTextRange = selectedTextRange
        
        guard let beforeTextRange, let afterTextRange else { return }
        
        switch anchor {
        case .leading:
            self.selectedTextRange = beforeTextRange
        case .trailing:
            let offset = offset(from: closestPosition, to: isRangeContainsPosition ? closestPosition : beforeTextRange.start)
            let from = position(from: afterTextRange.start, offset: offset)
            let to = position(from: afterTextRange.end, offset: offset)
            guard let from, let to else { return }
            let fixedTextRange = textRange(from: from, to: to)
            if let fixedTextRange {
                selectedTextRange = fixedTextRange
            }
        }
    }
    
    /// Replaces the text in a document that is in the specified range And fixs selection offset.
    /// - Parameters:
    ///   - range: A range of text in a document.
    ///   - text: A string to replace the text in range.
    func apply(_ range: UITextRange, withText text: String) {
        apply(range, withAttributedText: NSAttributedString(string: text))
    }
}
