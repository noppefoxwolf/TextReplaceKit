import Testing
@testable import TextReplaceKit
import UIKit

@MainActor
@Suite
struct UITextViewInsertTests {
    @Test
    func testInsertHashtag() async throws {
        let textView = UITextView()
        textView.attributedText = NSMutableAttributedString("Hello")
        textView.selectedRange = NSRange(location: 3, length: 0)
        #expect(textView.visualText == "Hel[]lo")
        textView.insertText("#")
        #expect(textView.visualText == "Hel #[] lo")
    }
}
