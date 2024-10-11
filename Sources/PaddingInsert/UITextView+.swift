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
        trailingPadding: TrailingPadding
    ) {
        var text = text
        let hasLeadingPadding = hasLeadingPadding(at: selectedTextRange!.start)
        let hasTrailingPadding = hasTrailingPadding(at: selectedTextRange!.end)
        if leadingPadding && !hasLeadingPadding {
            text.insert("\u{0020}", at: text.startIndex)
        }
        if trailingPadding == .insert {
            text.insert("\u{0020}", at: text.endIndex)
        }
        insertText(text, at: selectedTextRange!.start)
        if trailingPadding == .addition && !hasTrailingPadding {
            appendText("\u{0020}")
        }
    }
    
    func appendText(_ text: String) {
        let beforeTextRange = selectedTextRange
        replaceAndAdjutSelectedTextRange(selectedTextRange!, withText: text)
        selectedTextRange = beforeTextRange
    }
    
    func insertText(_ text: String, at position: UITextPosition) {
        let range = textRange(from: position, to: position)!
        replaceAndAdjutSelectedTextRange(range, withText: text)
    }
    
    func hasLeadingPadding(at position: UITextPosition) -> Bool {
        guard let beforeText = documentContextBefore(at: position) else { return true }
        guard beforeText.rangeOfCharacter(from: .whitespacesAndNewlines) != nil else { return false }
        return true
    }
    
    func hasTrailingPadding(at position: UITextPosition) -> Bool {
        guard let afterText = documentContextAfter(at: position) else { return true }
        guard afterText.rangeOfCharacter(from: .whitespacesAndNewlines) != nil else { return false }
        return true
    }
    
    func documentContextBefore(at position: UITextPosition) -> String? {
        guard let from = self.position(from: position, offset: -1) else { return nil }
        guard let textRange = self.textRange(from: from, to: position) else { return nil }
        return text(in: textRange)
    }
    
    func documentContextAfter(at position: UITextPosition) -> String? {
        guard let from = self.position(from: position, offset: 1) else { return nil }
        guard let textRange = self.textRange(from: from, to: position) else { return nil }
        return text(in: textRange)
    }
}
