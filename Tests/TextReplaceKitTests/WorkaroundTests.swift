import Testing
import UIKit

@testable import TextReplaceKit

@MainActor
@Suite
struct WorkaroundTests {
    @Test
    func example() throws {
        let textView = UITextView()
        textView.text = "Original"
        let textRange = textView.textRange(
            from: textView.beginningOfDocument,
            to: textView.endOfDocument
        )!
        textView.silentReplace(
            textRange,
            withAttributedText: NSAttributedString(string: "Replaced")
        )
        #expect(textView.text == "Replaced")
    }
}
