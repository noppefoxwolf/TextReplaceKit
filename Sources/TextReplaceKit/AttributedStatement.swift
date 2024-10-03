import Foundation

final class AttributedStatement {
    var leadingAttributedText: NSAttributedString?
    let bodyAttributedText: NSAttributedString
    var trailingAttributedText: NSAttributedString?
    
    init(bodyAttributedText: NSAttributedString) {
        self.bodyAttributedText = bodyAttributedText
    }
    
    var attributedText: NSAttributedString {
        let attributedText = NSMutableAttributedString()
        if let leadingAttributedText {
            attributedText.append(leadingAttributedText)
        }
        attributedText.append(bodyAttributedText)
        if let trailingAttributedText {
            attributedText.append(trailingAttributedText)
        }
        attributedText.setAttributes(bodyAttributedText.attributes(at: 0, effectiveRange: nil), range: attributedText.range)
        return attributedText
    }
}
