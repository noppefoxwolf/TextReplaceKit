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
        skipUnbrokenAttachments: Bool = false,
        granularity: Granularity
    ) {
        switch granularity {
        case .selectedLine:
            replaceAttachment(
                in: selectedLineTextRange ?? documentRange,
                transform: transform,
                skipUnbrokenAttachments: skipUnbrokenAttachments,
                usesDelegate: false
            )
        case .document:
            replaceAttachment(
                in: documentRange,
                transform: transform,
                skipUnbrokenAttachments: skipUnbrokenAttachments,
                usesDelegate: false
            )
        }
    }
    
    public func replaceAttachment(
        _ transform: AttachmentTransform,
        skipUnbrokenAttachments: Bool = false,
        granularity: Granularity
    ) {
        switch granularity {
        case .selectedLine:
            replaceAttachment(
                in: selectedLineTextRange ?? documentRange,
                transform: transform,
                skipUnbrokenAttachments: skipUnbrokenAttachments,
                usesDelegate: true
            )
        case .document:
            replaceAttachment(
                in: documentRange,
                transform: transform,
                skipUnbrokenAttachments: skipUnbrokenAttachments,
                usesDelegate: true
            )
        }
    }
    
    func replaceAttachment(
        in range: UITextRange,
        transform: AttachmentTransform,
        skipUnbrokenAttachments: Bool = false,
        usesDelegate: Bool = true
    ) {
        var didChanged: Bool = false
        // 先頭からのrange
        let subAttributedText = attributedText(in: range)
        
        let nsRange = subAttributedText.range
        subAttributedText
            .enumerateAttribute(.attachment, in: nsRange, options: .reverse, using: { textAttachment, range, _ in
                guard let textAttachment = textAttachment as? NSTextAttachment else { return }
                
                let textRange = textRange(from: beginningOfDocument, for: range)
                if let textRange {
                    if skipUnbrokenAttachments {
                        let hasPadding = hasLeadingPadding(at: textRange.start) && hasTrailingPadding(at: textRange.end)
                        print(hasPadding, textAttachment)
                        if hasPadding {
                            return
                        }
                    }
                    
                    if let transformed = transform(textAttachment) {
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
