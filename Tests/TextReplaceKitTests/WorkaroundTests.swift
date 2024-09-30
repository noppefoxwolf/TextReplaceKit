import Testing
@testable import TextReplaceKit
import UIKit

@MainActor
@Suite
struct WorkaroundTests {
    @Test
    func example() throws {
        let textView = UITextView()
        textView.text = "Original"
        let textRange = textView.textRange(from: textView.beginningOfDocument, to: textView.endOfDocument)!
        textView.workaround.replace(textRange, withAttributedText: NSAttributedString(string: "Replaced"))
        #expect(textView.text == "Replaced")
    }
}
