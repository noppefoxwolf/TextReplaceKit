import UIKit

@MainActor
final class Workaround: Sendable {
    let base: UITextView

    init(base: UITextView) {
        self.base = base
    }
}

extension UITextView {
    var workaround: Workaround { Workaround(base: self) }
}

extension Workaround {
    /// silentReplace don't call delegates
    @MainActor
    func silentReplace(
        _ range: UITextRange,
        withAttributedText attributedText: NSAttributedString
    ) {
        let textViewAttr = base.attributedText.copyAsMutable()
        let location = base.offset(from: base.beginningOfDocument, to: range.start)
        let length = base.offset(from: range.start, to: range.end)
        let nsRange = NSRange(location: location, length: length)
        textViewAttr.replaceCharacters(in: nsRange, with: attributedText)
        
        let beforeTypingAttributes = base.typingAttributes
        base.attributedText = textViewAttr
        base.typingAttributes = beforeTypingAttributes
        
        if let endedPosition = base.position(from: range.start, offset: attributedText.length) {
            base.selectedTextRange = base.textRange(from: endedPosition, to: endedPosition)
        }
    }
}
