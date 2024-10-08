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
        let from = position
        let to = self.position(from: position, offset: text.utf16.count)!
        let range = textRange(from: to, to: to)!
        //insertText(text)
        let mattr = attributedText.copyAsMutable()
        
        let locationStart = self.offset(from: self.beginningOfDocument, to: from)
        let locationEnd = self.offset(from: self.beginningOfDocument, to: from)
        let nsRange = NSRange(location: locationStart, length: locationEnd - locationStart)
        mattr.replaceCharacters(in: nsRange, with: text)
        self.attributedText = mattr
        self.selectedTextRange = range
    }
    
    func appendText(_ text: String) {
        let beforeTextRange = selectedTextRange!
        insertText(text)
        selectedTextRange = beforeTextRange
    }
}
