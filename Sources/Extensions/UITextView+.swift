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
    package func replaceAndAdjutSelectedTextRange(_ range: UITextRange, withText text: String) {
        replaceAndAdjutSelectedTextRange(range, withAttributedText: NSAttributedString(string: text))
    }
    
    package func replaceAndAdjutSelectedTextRange(_ textRange: UITextRange, withAttributedText attributedText: NSAttributedString) {
        let beforeSelectedTextRange = selectedTextRange
        let beforeTypingAttributes = typingAttributes
        
        let mutableAttributedText = self.attributedText.copyAsMutable()
        let nsRange = NSRange(textRange, in: self)
        mutableAttributedText.replaceCharacters(in: nsRange, with: attributedText)
        self.attributedText = mutableAttributedText
        self.typingAttributes = beforeTypingAttributes
        
        let changedTextRange = self.textRange(from: textRange.start, for: attributedText.range)
        
        if let beforeSelectedTextRange, let changedTextRange {
            self.selectedTextRange = adjustedTextRange(beforeSelectedTextRange, replacingRange: textRange, replacedRange: changedTextRange)
        }
    }
    
    func adjustedTextRange(
        _ range: UITextRange,
        replacingRange: UITextRange,
        replacedRange: UITextRange
    ) -> UITextRange? {
        let from = adjustedPosition(range.start, replacingRange: replacingRange, replacedRange: replacedRange)
        let to = adjustedPosition(range.end, replacingRange: replacingRange, replacedRange: replacedRange)
        guard let from, let to else { return nil }
        return textRange(from: from, to: to)
    }
    
    func adjustedPosition(
        _ position: UITextPosition,
        replacingRange: UITextRange,
        replacedRange: UITextRange
    ) -> UITextPosition? {
        switch compare(replacingRange.end, to: position) {
        case .orderedAscending:
            let offset = offset(from: replacingRange.end, to: position)
            return self.position(from: replacedRange.end, offset: offset)
        case .orderedDescending:
            switch compare(replacingRange.start, to: position) {
            case .orderedAscending:
                return replacedRange.end
            default:
                return position
            }
        case .orderedSame:
            let offset = offset(from: replacingRange.end, to: position)
            return self.position(from: replacedRange.end, offset: offset)
        }
    }
}
