import UIKit

@MainActor
final class Workaround: Sendable {
  let base: UITextView

  init(base: UITextView) {
    self.base = base
  }
}

extension UITextView {
  var workaround: Workaround { Workaround(base: self) }
}

extension Workaround {
  /// https://developer.apple.com/documentation/uikit/uitextinput/4462768-replace
  /// Before iOS18, UITextView don't implemented replace(range:withAttributedText:).
  @MainActor
  func replace(
    _ range: UITextRange,
    withAttributedText attributedText: NSAttributedString
  ) {
    if #available(iOS 18, *) {
      base.replace(range, withAttributedText: attributedText)
    } else {
      base.replace(range, withText: "")
      base.insertAttributedText(attributedText)
    }
  }
}
