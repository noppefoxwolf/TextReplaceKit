import Extensions
public import UIKit

extension UITextView {
    public typealias AttachmentTransform = (NSTextAttachment) -> NSAttributedString?

    public func replaceAttachmentsSilently(
        _ transform: AttachmentTransform,
        skipUnbrokenAttachments: Bool = false,
        granularity: TextReplaceGranularity
    ) {
        switch granularity {
        case .selectedLine:
            replaceAttachments(
                in: selectedLineTextRange ?? documentRange,
                transform: transform,
                skipUnbrokenAttachments: skipUnbrokenAttachments,
                usesDelegate: false
            )
        case .document:
            replaceAttachments(
                in: documentRange,
                transform: transform,
                skipUnbrokenAttachments: skipUnbrokenAttachments,
                usesDelegate: false
            )
        }
    }

    public func replaceAttachments(
        _ transform: AttachmentTransform,
        skipUnbrokenAttachments: Bool = false,
        granularity: TextReplaceGranularity
    ) {
        switch granularity {
        case .selectedLine:
            replaceAttachments(
                in: selectedLineTextRange ?? documentRange,
                transform: transform,
                skipUnbrokenAttachments: skipUnbrokenAttachments,
                usesDelegate: true
            )
        case .document:
            replaceAttachments(
                in: documentRange,
                transform: transform,
                skipUnbrokenAttachments: skipUnbrokenAttachments,
                usesDelegate: true
            )
        }
    }

    func replaceAttachments(
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
                            replacePreservingSelection(
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
