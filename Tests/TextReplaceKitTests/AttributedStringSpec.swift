import Foundation
import Testing
import UIKit

@testable import TextReplaceKit
@testable import Extensions

@Suite
struct AttributedStringSpec {
    @Test("NSTextAttachmentも1characterとして扱われる")
    func attributedStringCount() {
        let attr = AttributedString(NSAttributedString(attachment: TextAttachment("👐")))
        #expect(attr.characters.count == 1)
        #expect(attr.string.count == 1)
        #expect(attr.toFoundation().length == 1)
        #expect(attr.toFoundation().string.count == 1)
    }

    @Test("SubstringのIndexは途中からになる")
    func substringIndex() {
        let attr = AttributedString("foo bar hoge")
        let subattr = attr[attr.range(of: "bar")!]
        #expect(attr.startIndex != subattr.startIndex)
    }

    @Test("mutableの方の変更は元のNSAttrに反映されない")
    func mutableAttributedString() {
        let attr = NSAttributedString("original")
        let mutableAttr = NSMutableAttributedString(attributedString: attr)
        mutableAttr.replaceCharacters(in: NSRange(location: 0, length: 8), with: "changed")

        #expect(attr.string == "original")
        #expect(mutableAttr.string == "changed")
        #expect(attr != mutableAttr)
        #expect(attr.string != mutableAttr.string)
    }

    @Test("絵文字のカウントは同じではない")
    func emojiCount() {
        let attr = NSAttributedString("👨‍👩‍👧‍👦")
        #expect(attr.length == 11)
        #expect(attr.toModern().characters.count == 1)
        #expect(attr.string.count == 1)
    }

    @Test("空のmutable attributed stringにinsertしてもクラッシュしない")
    func insertIntoEmptyMutableAttributedString() {
        let mutable = NSMutableAttributedString()
        #expect(mutable.string.isEmpty)

        mutable.insert("a", at: 0)

        #expect(mutable.string == "a")
        #expect(mutable.attribute(.font, at: 0, effectiveRange: nil) == nil)
    }

    @Test("空のmutable attributed stringにappendしてもクラッシュしない")
    func appendIntoEmptyMutableAttributedString() {
        let mutable = NSMutableAttributedString()
        #expect(mutable.string.isEmpty)

        mutable.append("abc")

        #expect(mutable.string == "abc")
        #expect(mutable.attribute(.font, at: 0, effectiveRange: nil) == nil)
        #expect(mutable.attribute(.font, at: 1, effectiveRange: nil) == nil)
        #expect(mutable.attribute(.font, at: 2, effectiveRange: nil) == nil)
    }

    @Test("insertはindexをクランプし属性を引き継ぐ")
    func insertClampsIndexAndKeepsAttributes() {
        let font = UIFont.systemFont(ofSize: 10)
        let mutable = NSMutableAttributedString(
            string: "abc",
            attributes: [.font: font]
        )

        // indexをlengthより大きく渡しても末尾に挿入される
        mutable.insert("X", at: 10)
        #expect(mutable.string == "abcX")
        let attr = mutable.attribute(.font, at: 3, effectiveRange: nil) as? UIFont
        #expect(attr?.isEqual(font) == true)
    }

    @Test("AttributedStatementで先頭/末尾の属性を保持する")
    func attributedStatementKeepsLeadingTrailingAttributes() {
        let leading = NSAttributedString(
            string: "L",
            attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.red
            ]
        )
        let body = NSAttributedString(
            string: "B",
            attributes: [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)
            ]
        )
        let trailing = NSAttributedString(
            string: "T",
            attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.blue
            ]
        )

        let statement = AttributedStatement(bodyAttributedText: body)
        statement.leadingAttributedText = leading
        statement.trailingAttributedText = trailing

        let composed = statement.attributedText

        #expect(composed.string == "LBT")
        let leadingColor = composed.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor
        #expect(leadingColor?.isEqual(UIColor.red) == true)
        let bodyFont = composed.attribute(.font, at: 1, effectiveRange: nil) as? UIFont
        #expect(bodyFont?.isEqual(UIFont.boldSystemFont(ofSize: 12)) == true)
        let trailingColor = composed.attribute(.foregroundColor, at: 2, effectiveRange: nil) as? UIColor
        #expect(trailingColor?.isEqual(UIColor.blue) == true)
    }

    @Test("replaceした時に残った部分にattributesが残る")
    func replaceAttributes() {
        let attr = NSMutableAttributedString(
            string: "foo bar baz",
            attributes: [.font: UIFont.boldSystemFont(ofSize: 100)]
        )
        let range = NSRange(location: 4, length: 3)
        #expect(attr.attributedSubstring(from: range).string == "bar")
        #expect(attr.attribute(.font, at: 4, effectiveRange: nil) != nil)
        attr.replaceCharacters(in: NSRange(location: 0, length: 3), with: NSAttributedString("foo"))
        attr.replaceCharacters(in: NSRange(location: 8, length: 3), with: NSAttributedString("baz"))
        #expect(attr.attribute(.font, at: 4, effectiveRange: nil) != nil)
    }

    @Test
    func findAttachmentUsingSpecialChar() async throws {
        let attr = NSMutableAttributedString(string: "foo")
        attr.append(NSAttributedString(attachment: TextAttachment("🐈")))
        attr.append("baz")
        let attachmentCharacter = Character(Unicode.Scalar(NSTextAttachment.character)!)
        #expect(attr.string == "foo\(attachmentCharacter)baz")
    }
}
