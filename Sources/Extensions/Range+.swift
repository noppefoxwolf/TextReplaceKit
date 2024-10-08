import UIKit

extension UITextView {
    package func textRange(of range: Range<String.Index>, in text: String) -> UITextRange? {
        let from = position(
            from: beginningOfDocument,
            offset: range.lowerBound.utf16Offset(in: text)
        )
        let to = position(
            from: beginningOfDocument,
            offset: range.upperBound.utf16Offset(in: text)
        )
        guard let from, let to else { return nil }
        return textRange(from: from, to: to)
    }
}

extension NSRange {
    
    @MainActor
    package init(_ range: UITextRange, in textView: UITextView) {
        let startLocation = textView.offset(from: textView.beginningOfDocument, to: range.start)
        let endLocation = textView.offset(from: textView.beginningOfDocument, to: range.end)
        self.init(location: startLocation, length: endLocation - startLocation)
    }
}
