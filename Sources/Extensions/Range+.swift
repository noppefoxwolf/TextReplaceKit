import UIKit

extension NSRange {
    @MainActor
    package init(_ range: UITextRange, in textView: UITextView) {
        let startLocation = textView.offset(from: textView.beginningOfDocument, to: range.start)
        let endLocation = textView.offset(from: textView.beginningOfDocument, to: range.end)
        self.init(location: startLocation, length: endLocation - startLocation)
    }
}
