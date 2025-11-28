import Testing
import UIKit

@testable import AttachmentReplace

@MainActor
@Suite
struct AttachmentReplaceTests {
    @Test
    func cursorForward() throws {
        let attr = NSMutableAttributedString()
        attr.append(NSAttributedString(string: "HogeHoge"))
        attr.append(NSAttributedString(attachment: TextAttachment("🐈")))
        attr.append(NSAttributedString(string: "FugaFuga"))

        let textView = UITextView()
        textView.attributedText = attr
        textView.selectedRange = NSRange(location: 13, length: 0)
        #expect(textView.visualText == "HogeHoge🐈Fuga[]Fuga")

        let from = textView.position(from: textView.beginningOfDocument, offset: 4)!
        let to = textView.position(from: textView.beginningOfDocument, offset: 13)!
        let range = textView.textRange(from: from, to: to)!
        #expect(textView.attributedText(in: range).string == "Hoge￼Fuga")
        textView.replaceAttachments(
            in: textView.documentRange,
            transform: { _ in
                NSAttributedString(string: ":cat:")
            }
        )
        #expect(textView.visualText == "HogeHoge:cat:Fuga[]Fuga")
    }

    @Test
    func cursorBackward() throws {
        let attr = NSMutableAttributedString()
        attr.append(NSAttributedString(string: "HogeHoge"))
        attr.append(NSAttributedString(attachment: TextAttachment("🐈")))
        attr.append(NSAttributedString(string: "FugaFuga"))

        let textView = UITextView()
        textView.attributedText = attr
        textView.selectedRange = NSRange(location: 4, length: 0)
        #expect(textView.visualText == "Hoge[]Hoge🐈FugaFuga")

        let from = textView.position(from: textView.beginningOfDocument, offset: 4)!
        let to = textView.position(from: textView.beginningOfDocument, offset: 13)!
        let range = textView.textRange(from: from, to: to)!
        #expect(textView.attributedText(in: range).string == "Hoge￼Fuga")
        textView.replaceAttachments(
            in: textView.documentRange,
            transform: { _ in
                NSAttributedString(string: ":cat:")
            }
        )
        #expect(textView.visualText == "Hoge[]Hoge:cat:FugaFuga")
    }

    @Test
    func range() throws {
        let attr = NSMutableAttributedString()
        attr.append(NSAttributedString(string: "HogeHoge"))
        attr.append(NSAttributedString(attachment: TextAttachment("🐈")))
        attr.append(NSAttributedString(string: "FugaFuga"))

        let textView = UITextView()
        textView.attributedText = attr
        textView.selectedRange = NSRange(location: 9, length: 4)
        #expect(textView.visualText == "HogeHoge🐈[Fuga]Fuga")

        let from = textView.position(from: textView.beginningOfDocument, offset: 4)!
        let to = textView.position(from: textView.beginningOfDocument, offset: 13)!
        let range = textView.textRange(from: from, to: to)!
        #expect(textView.attributedText(in: range).string == "Hoge￼Fuga")
        textView.replaceAttachments(
            in: textView.documentRange,
            transform: { _ in
                NSAttributedString(string: ":cat:")
            }
        )
        #expect(textView.visualText == "HogeHoge:cat:[Fuga]Fuga")
    }

    @Test(##"Thread 1: "NSMutableRLEArray objectAtIndex:effectiveRange:runIndex:: Out of bounds""##)
    func crashBug() throws {
        let textView = UITextView()
        textView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        textView.insertText("#きつねかわいい", leadingPadding: true, trailingPadding: .insert)
        textView.replaceAttachmentsSilently(
            { (textAttachment: NSTextAttachment) in
                nil
            },
            granularity: .selectedLine
        )
    }
}
