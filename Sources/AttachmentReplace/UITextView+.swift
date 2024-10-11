import UIKit
import Extensions

extension UITextView {
    public enum Granularity {
        case selectedLine
        case document
    }
    
    public typealias AttachmentTransform = (NSTextAttachment) -> NSAttributedString?
    
    public func replaceAttachment(
        _ transform: AttachmentTransform,
        granularity: Granularity
    ) {
        switch granularity {
        case .selectedLine:
            replaceAttachmentLine(
                transform: transform,
                at: selectedTextRange?.start ?? endOfDocument
            )
        case .document:
            replaceAttachmentWholeDocument(transform: transform)
        }
    }

    func replaceAttachmentLine(transform: AttachmentTransform, at posision: UITextPosition) {
        let lineRangeStart = tokenizer.position(
            from: posision,
            toBoundary: .line,
            inDirection: .layout(.left)
        )
        let lineRangeEnd = tokenizer.position(
            from: posision,
            toBoundary: .line,
            inDirection: .layout(.right)
        )
        guard let lineRangeStart, let lineRangeEnd else { return }
        let lineRange = textRange(from: lineRangeStart, to: lineRangeEnd)
        guard let lineRange else { return }
        replaceAttachment(in: lineRange, transform: transform)
    }

    func replaceAttachmentWholeDocument(transform: AttachmentTransform) {
        let documentRange = textRange(from: beginningOfDocument, to: endOfDocument)
        guard let documentRange else { return }
        replaceAttachment(in: documentRange, transform: transform)
    }
    
    func replaceAttachment(in range: UITextRange, transform: AttachmentTransform) {
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
        if didChanged {
            delegate?.textViewDidChange?(self)
        }
    }
}
