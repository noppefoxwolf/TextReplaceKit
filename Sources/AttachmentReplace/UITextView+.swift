import Extensions
public import UIKit

extension UITextView {
    public typealias AttachmentTransform = (NSTextAttachment) -> NSAttributedString?

    public func replaceAttachmentsSilently(
        _ transform: AttachmentTransform,
        skipUnbrokenAttachments: Bool = false,
        textRange: UITextRange
    ) {
        if let range = attachmentTextRange(adjacentTo: textRange) {
            replaceAttachments(
                in: range,
                transform: transform,
                skipUnbrokenAttachments: skipUnbrokenAttachments,
                usesDelegate: false
            )
        }
    }

    public func replaceAttachments(
        _ transform: AttachmentTransform,
        skipUnbrokenAttachments: Bool = false,
        textRange: UITextRange
    ) {
        if let range = attachmentTextRange(adjacentTo: textRange) {
            replaceAttachments(
                in: range,
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

    private func attachmentTextRange(adjacentTo range: UITextRange) -> UITextRange? {
        let lowerBound = offset(from: beginningOfDocument, to: range.start)
        let upperBound = offset(from: beginningOfDocument, to: range.end)
        let attributedText = attributedText ?? NSAttributedString()

        var matchedRange: NSRange?
        attributedText.enumerateAttribute(.attachment, in: attributedText.range) { value, nsRange, stop in
            guard value is NSTextAttachment else { return }
            guard nsRange.location <= upperBound && lowerBound <= nsRange.upperBound else { return }
            if let currentRange = matchedRange {
                matchedRange = currentRange.union(nsRange)
            } else {
                matchedRange = nsRange
            }
        }

        guard let matchedRange else { return nil }
        return textRange(location: matchedRange.location, length: matchedRange.length)
    }
}
