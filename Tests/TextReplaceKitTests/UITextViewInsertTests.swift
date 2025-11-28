import Testing
import UIKit

@testable import TextReplaceKit

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

    @Test
    func callDidChanged() async throws {
        final class Delegate: NSObject, UITextViewDelegate {
            var textViewDidChange: Int = 0
            func textViewDidChange(_ textView: UITextView) {
                textViewDidChange += 1
            }
        }
        let delegate = Delegate()
        let textView = UITextView()
        textView.delegate = delegate
        textView.insertText("a")
        #expect(delegate.textViewDidChange == 1)
        textView.insertText("b", leadingPadding: true, trailingPadding: .addition)
        #expect(delegate.textViewDidChange == 2)
        textView.appendText("c")
        #expect(delegate.textViewDidChange == 3)
    }

    @Test
    func newlineBug() async throws {
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        textView.insertText("\n")
        #expect(textView.visualText == "\n[]")
        textView.insertText(":ai_icon:", leadingPadding: true, trailingPadding: .insert)
        #expect(textView.visualText == "\n:ai_icon: []")
    }
}
