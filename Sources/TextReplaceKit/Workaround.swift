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
    /// Addition note 001
    ///     - iOS18 replace(withAttributedText:) sometimes
    ///     `Thread 1: "-[NSNull _defaultLineHeightForUILayout]: unrecognized selector sent to instance 0x1e007fa58"`
    @MainActor
    func replace(
        _ range: UITextRange,
        withAttributedText attributedText: NSAttributedString
    ) {
        
        
        base.replace(range, withText: "")
        base.insertAttributedText(attributedText)
    }
}
