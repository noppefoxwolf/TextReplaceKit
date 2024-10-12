import UIKit
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
        
        var text = text
        let hasLeadingPadding = hasLeadingPadding(at: textRange.start)
        let hasTrailingPadding = hasTrailingPadding(at: textRange.end)
        if leadingPadding && !hasLeadingPadding {
            text.insert("\u{0020}", at: text.startIndex)
        }
        if trailingPadding == .insert {
            text.insert("\u{0020}", at: text.endIndex)
        }
        insertText(text, at: textRange.start)
        if trailingPadding == .addition && !hasTrailingPadding {
            appendText("\u{0020}", usesDelegate: false)
        }
        if usesDelegate {
            delegate?.textViewDidChange?(self)
        }
    }
    
    public func appendText(_ text: String, usesDelegate: Bool = true) {
        let textRange = selectedTextRange ?? textRange(from: endOfDocument, to: endOfDocument)
        guard let textRange else { return }
        
        let beforeTextRange = textRange
        replaceAndAdjutSelectedTextRange(textRange, withText: text)
        selectedTextRange = beforeTextRange
        if usesDelegate {
            delegate?.textViewDidChange?(self)
        }
    }
    
    func insertText(_ text: String, at position: UITextPosition) {
        let range = textRange(from: position, to: position)!
        replaceAndAdjutSelectedTextRange(range, withText: text)
    }
}
