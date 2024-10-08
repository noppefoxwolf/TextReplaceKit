import UIKit

extension UITextView {
    /// silentReplace don't call delegates
    package func silentReplace(
        _ range: UITextRange,
        withAttributedText attributedText: NSAttributedString
    ) {
        let textViewAttr = self.attributedText.copyAsMutable()
        let location = offset(from: beginningOfDocument, to: range.start)
        let length = offset(from: range.start, to: range.end)
        let nsRange = NSRange(location: location, length: length)
        textViewAttr.replaceCharacters(in: nsRange, with: attributedText)
        
        let beforeTypingAttributes = typingAttributes
        self.attributedText = textViewAttr
        self.typingAttributes = beforeTypingAttributes
        
        if let endedPosition = position(from: range.start, offset: attributedText.length) {
            self.selectedTextRange = textRange(from: endedPosition, to: endedPosition)
        }
    }
    
    package func closestPosition(to position: UITextPosition, within range: UITextRange) -> UITextPosition {
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

    package func contains(_ range: UITextRange, to position: UITextPosition) -> Bool {
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
    
    package func textRange(from position: UITextPosition, for nsRange: NSRange) -> UITextRange? {
        let from = self.position(
            from: position,
            offset: nsRange.location
        )
        let to = self.position(
            from: position,
            offset: nsRange.location + nsRange.length
        )
        guard let from, let to else { return nil }
        return textRange(from: from, to: to)
    }
}

extension UITextView {
    package func performEditingTransaction(_ transaction: () -> UITextRange) {
        enum Anchor: Sendable {
            case leading
            case trailing
        }

        let beforeTextRange = selectedTextRange
        let changedRange = transaction()
        let afterTextRange = selectedTextRange

        guard let beforeTextRange, let afterTextRange else { return }

        let closestPosition = closestPosition(to: beforeTextRange.start, within: changedRange)
        let isRangeContainsPosition = contains(changedRange, to: beforeTextRange.start)
        
        let anchor: Anchor = closestPosition == changedRange.start ? Anchor.leading : Anchor.trailing
        switch anchor {
        case .leading:
            self.selectedTextRange = beforeTextRange
        case .trailing:
            let offset = offset(
                from: closestPosition,
                to: isRangeContainsPosition ? closestPosition : beforeTextRange.start
            )
            let from = position(from: afterTextRange.start, offset: offset)
            let to = position(from: afterTextRange.end, offset: offset)
            guard let from, let to else { return }
            let fixedTextRange = textRange(from: from, to: to)
            if let fixedTextRange {
                selectedTextRange = fixedTextRange
            }
        }
    }
}
