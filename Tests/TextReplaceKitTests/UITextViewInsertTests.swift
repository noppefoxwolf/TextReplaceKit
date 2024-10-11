import Testing
@testable import TextReplaceKit
import UIKit

@MainActor
@Suite
struct UITextViewInsertTests {
    @Test
    func insertNormal() async throws {
        let textView = UITextView()
        textView.attributedText = NSMutableAttributedString("Hell")
        textView.selectedRange = NSRange(location: 4, length: 0)
        #expect(textView.visualText == "Hell[]")
        textView.insertText("o")
        #expect(textView.visualText == "Hello[]")
    }
    
    @Test
    func insertHashAfterWord() async throws {
        let textView = UITextView()
        textView.attributedText = NSMutableAttributedString("Hello")
        textView.selectedRange = NSRange(location: 5, length: 0)
        #expect(textView.visualText == "Hello[]")
        textView.insertText("#", leadingPadding: true, trailingPadding: .addition)
        #expect(textView.visualText == "Hello #[]")
    }
    
    @Test
    func insertHashAfterSpace() async throws {
        let textView = UITextView()
        textView.attributedText = NSMutableAttributedString("Hello ")
        textView.selectedRange = NSRange(location: 6, length: 0)
        #expect(textView.visualText == "Hello []")
        textView.insertText("#", leadingPadding: true, trailingPadding: .addition)
        #expect(textView.visualText == "Hello #[]")
    }
    
    @Test
    func insertHashStart() async throws {
        let textView = UITextView()
        textView.attributedText = NSMutableAttributedString("")
        textView.selectedRange = NSRange(location: 0, length: 0)
        #expect(textView.visualText == "[]")
        textView.insertText("#", leadingPadding: true, trailingPadding: .addition)
        #expect(textView.visualText == "#[]")
    }
    
    @Test
    func testInsertHashInWord() async throws {
        let textView = UITextView()
        textView.attributedText = NSMutableAttributedString("Hello")
        textView.selectedRange = NSRange(location: 3, length: 0)
        #expect(textView.visualText == "Hel[]lo")
        textView.insertText("#", leadingPadding: true, trailingPadding: .addition)
        #expect(textView.visualText == "Hel #[] lo")
    }
    
    @Test
    func testInsertHashtagAfterWord() async throws {
        let textView = UITextView()
        textView.attributedText = NSMutableAttributedString("Hello")
        textView.selectedRange = NSRange(location: 5, length: 0)
        #expect(textView.visualText == "Hello[]")
        textView.insertText("#apple", leadingPadding: true, trailingPadding: .insert)
        #expect(textView.visualText == "Hello #apple []")
    }
}
