import UIKit
import Extensions

extension UITextView {
    
    public typealias AttachmentTransform = (NSTextAttachment) -> NSAttributedString?
    
    public func replaceAttachment(in range: UITextRange, transform: AttachmentTransform) {
        var didChanged: Bool = false
        // 先頭からのrange
        let nsRange = NSRange(range, in: self)
        attributedText(in: range)
            .enumerateAttribute(.attachment, in: nsRange, options: .reverse, using: { attachment, range, _ in
                if let attachment = attachment as? NSTextAttachment, let transformed = transform(attachment) {
                    let textRange = textRange(from: beginningOfDocument, for: range)
                    if let textRange {
                        performEditingTransaction {
                            silentReplace(textRange, withAttributedText: transformed)
                            return textRange
                        }
                        didChanged = true
                    }
                }
            })
        if didChanged {
            delegate?.textViewDidChange?(self)
        }
    }
}
