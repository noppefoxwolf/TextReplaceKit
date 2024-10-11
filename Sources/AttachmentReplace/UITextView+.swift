import UIKit
import Extensions

extension UITextView {
    public enum Granularity {
        case selectedLine
        case document
    }
    
    public typealias AttachmentTransform = (NSTextAttachment) -> NSAttributedString?
    
    public func setReplacedAttributedText(
        _ transform: AttachmentTransform,
        granularity: Granularity
    ) {
        switch granularity {
        case .selectedLine:
            replaceAttachment(in: selectedLineTextRange ?? documentRange, transform: transform, usesDelegate: false)
        case .document:
            replaceAttachment(in: documentRange, transform: transform, usesDelegate: false)
        }
    }
    
    public func replaceAttachment(
        _ transform: AttachmentTransform,
        granularity: Granularity
    ) {
        switch granularity {
        case .selectedLine:
            replaceAttachment(in: selectedLineTextRange ?? documentRange, transform: transform, usesDelegate: true)
        case .document:
            replaceAttachment(in: documentRange, transform: transform, usesDelegate: true)
        }
    }
    
    func replaceAttachment(in range: UITextRange, transform: AttachmentTransform, usesDelegate: Bool = true) {
        var didChanged: Bool = false
        // 先頭からのrange
        let nsRange = NSRange(range, in: self)
        attributedText(in: range)
            .enumerateAttribute(.attachment, in: nsRange, options: .reverse, using: { attachment, range, _ in
                if let attachment = attachment as? NSTextAttachment, let transformed = transform(attachment) {
                    let textRange = textRange(from: beginningOfDocument, for: range)
                    if let textRange {
                        replaceAndAdjutSelectedTextRange(textRange, withAttributedText: transformed)
                        didChanged = true
                    }
                }
            })
        if didChanged && usesDelegate {
            delegate?.textViewDidChange?(self)
        }
    }
}
