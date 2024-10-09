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
    
    package var documentRange: UITextRange {
        textRange(from: beginningOfDocument, to: endOfDocument)!
    }
    
    package func length(from: UITextPosition, to: UITextPosition) -> Int {
        let start = offset(from: beginningOfDocument, to: from)
        let end = offset(from: beginningOfDocument, to: to)
        return end - start
    }
    
    package func textRange(location: Int, length: Int) -> UITextRange? {
        let from = position(from: beginningOfDocument, offset: location)
        let to = position(from: beginningOfDocument, offset: location + length)
        guard let from, let to else { return nil }
        return textRange(from: from, to: to)
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
    package func replace2(range: UITextRange, withAttributedText attr: NSAttributedString) {
        let bs = selectedTextRange!.start
        let be = selectedTextRange!.end
        
        let mattr = attributedText.copyAsMutable()
        let nsRange = NSRange(range, in: self)
        mattr.replaceCharacters(in: nsRange, with: attr)
        self.attributedText = mattr
        
        let changedRange = textRange(from: range.start, for: attr.range)!
        
        let startPosition: UITextPosition
        switch compare(range.end, to: bs) {
        case .orderedAscending: //endより右
            let offset = offset(from: range.end, to: bs)
            startPosition = position(from: changedRange.end, offset: offset)!
        case .orderedDescending: //endより左
            switch compare(range.start, to: bs) {
            case .orderedAscending:
                startPosition = changedRange.end
            default:
                startPosition = bs
            }
        case .orderedSame:
            let offset = offset(from: range.end, to: bs)
            startPosition = position(from: changedRange.end, offset: offset)!
        }
        
        let endPosition: UITextPosition
        switch compare(range.end, to: be) {
        case .orderedAscending: //endより右
            let offset = offset(from: range.end, to: be)
            endPosition = position(from: changedRange.end, offset: offset)!
        case .orderedDescending: //endより左
            switch compare(range.start, to: be) {
            case .orderedAscending:
                endPosition = changedRange.end
            default:
                endPosition = be
            }
        case .orderedSame:
            let offset = offset(from: range.end, to: be)
            endPosition = position(from: changedRange.end, offset: offset)!
        }
        
        self.selectedTextRange = textRange(
            from: startPosition,
            to: endPosition
        )!
    }
    
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
