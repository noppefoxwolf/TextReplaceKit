public import UIKit
import Extensions

extension UITextView {
    public enum TrailingPadding: Sendable {
        case insert
        case addition
    }
    
    public func insertText(
        _ text: String,
        leadingPadding: Bool,
        trailingPadding: TrailingPadding,
        usesDelegate: Bool = true
    ) {
        let textRange = selectedTextRange ?? textRange(from: endOfDocument, to: endOfDocument)
        guard let textRange else { return }
        replaceText(
            textRange: textRange,
            withText: text,
            leadingPadding: leadingPadding,
            trailingPadding: trailingPadding,
            usesDelegate: usesDelegate
        )
    }
    
    public func appendText(_ text: String, usesDelegate: Bool = true) {
        let textRange = selectedTextRange ?? textRange(from: endOfDocument, to: endOfDocument)
        guard let textRange else { return }
        
        let beforeTextRange = textRange
        replaceAndAdjustSelectedTextRange(textRange, withText: text)
        selectedTextRange = beforeTextRange
        if usesDelegate {
            delegate?.textViewDidChange?(self)
        }
    }
    
    public func replaceText(
        textRange: UITextRange,
        withText text: String,
        leadingPadding: Bool,
        trailingPadding: TrailingPadding,
        usesDelegate: Bool = true
    ) {
        var text = text
        let hasLeadingPadding = hasLeadingPadding(at: textRange.start)
        let hasTrailingPadding = hasTrailingPadding(at: textRange.end)
        if leadingPadding && !hasLeadingPadding {
            text.insert("\u{0020}", at: text.startIndex)
        }
        if trailingPadding == .insert {
            text.insert("\u{0020}", at: text.endIndex)
        }
        replaceAndAdjustSelectedTextRange(textRange, withText: text)
        if trailingPadding == .addition && !hasTrailingPadding {
            appendText("\u{0020}", usesDelegate: false)
        }
        if usesDelegate {
            delegate?.textViewDidChange?(self)
        }
    }
}
