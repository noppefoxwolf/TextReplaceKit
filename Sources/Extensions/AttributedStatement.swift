package import Foundation

package final class AttributedStatement {
    package var leadingAttributedText: NSAttributedString?
    package let bodyAttributedText: NSAttributedString
    package var trailingAttributedText: NSAttributedString?

    package init(bodyAttributedText: NSAttributedString) {
        self.bodyAttributedText = bodyAttributedText
    }

    package var attributedText: NSAttributedString {
        let attributedText = NSMutableAttributedString()
        if let leadingAttributedText {
            attributedText.append(leadingAttributedText)
        }
        attributedText.append(bodyAttributedText)
        if let trailingAttributedText {
            attributedText.append(trailingAttributedText)
        }
        attributedText.setAttributes(
            bodyAttributedText.attributes(at: 0, effectiveRange: nil),
            range: attributedText.range
        )
        return attributedText
    }
}
