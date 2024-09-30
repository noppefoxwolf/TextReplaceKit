import UIKit

extension UITextView {
  var visualText: String {
    visualText(selectedRange)
  }

  func visualText(_ range: UITextRange) -> String {
    let location = self.offset(from: beginningOfDocument, to: range.start)
    let length = self.offset(from: range.start, to: range.end)
    return visualText(NSRange(location: location, length: length))
  }

  func visualText(_ range: NSRange) -> String {

    let attributedText = NSMutableAttributedString(attributedString: attributedText!)
    let attributedSubText = NSMutableAttributedString(
      attributedString: attributedText.attributedSubstring(from: range)
    )
    attributedSubText.insert(NSAttributedString("["), at: 0)
    attributedSubText.append(NSAttributedString("]"))

    attributedText.replaceCharacters(in: range, with: attributedSubText)

    var output = ""
    let range = NSRange(location: 0, length: attributedText.length)
    attributedText.enumerateAttributes(
      in: range,
      using: { attributes, range, _ in
        if let attachment = attributes[.attachment] {
          output += (attachment as! TextAttachment).emoji
        } else {
          output += attributedText.attributedSubstring(from: range).string
        }
      }
    )
    return output
  }
}
