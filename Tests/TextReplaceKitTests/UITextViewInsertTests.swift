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
        textView.insertText2("#")
        #expect(textView.visualText == "Hel #[] lo")
    }
}

extension UITextView {
    func insertText2(_ text: String) {
        insertText(text, at: selectedTextRange!.start)
    }
    
    func insertText(_ text: String, at position: UITextPosition) {
        let range = textRange(from: position, to: position)!
        replaceAndAdjutSelectedTextRange(range, withText: text)
    }
    
    func appendText(_ text: String) {
        let beforeTextRange = selectedTextRange!
        insertText(text)
        selectedTextRange = beforeTextRange
    }
}
