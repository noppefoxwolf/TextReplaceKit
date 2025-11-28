import Extensions
public import UIKit

extension UITextView {
    public typealias AttachmentTransform = (NSTextAttachment) -> NSAttributedString?

    public func setReplacedAttributedText(
        _ transform: AttachmentTransform,
        skipUnbrokenAttachments: Bool = false,
        granularity: TextReplaceGranularity
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
        granularity: TextReplaceGranularity
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
            .enumerateAttribute(
                .attachment,
                in: nsRange,
                options: .reverse,
                using: { textAttachment, subNSRange, _ in
                    guard let textAttachment = textAttachment as? NSTextAttachment else { return }

                    let textRange = textRange(from: range.start, for: subNSRange)
                    if let textRange {
                        if skipUnbrokenAttachments {
                            let hasPadding =
                                hasLeadingPadding(at: textRange.start)
                                && hasTrailingPadding(at: textRange.end)
                            if hasPadding {
                                return
                            }
                        }

                        if let transformed = transform(textAttachment) {
                            replaceAndAdjustSelectedTextRange(
                                textRange,
                                withAttributedText: transformed
                            )
                            didChanged = true
                        }
                    }
                }
            )
        if didChanged && usesDelegate {
            delegate?.textViewDidChange?(self)
        }
    }
}
