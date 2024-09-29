import UIKit

extension UITextView {
    var visualText: String {
        
        let attributedText = NSMutableAttributedString(attributedString: attributedText!)
        let selectedAttributedText = NSMutableAttributedString(
            attributedString: attributedText.attributedSubstring(from: selectedRange)
        )
        selectedAttributedText.insert(NSAttributedString("["), at: 0)
        selectedAttributedText.append(NSAttributedString("]"))
        
        attributedText.replaceCharacters(in: selectedRange, with: selectedAttributedText)
        
        var output = ""
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.enumerateAttributes(
            in: range,
            using: { attributes, range, _ in
                if let attachment = attributes[.attachment] {
                    output += (attachment as!TextAttachment).emoji
                } else {
                    output += attributedText.attributedSubstring(from: range).string
                }
            }
        )
        return output
    }
}
