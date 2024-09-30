import Foundation
import Testing

@testable import TextReplaceKit

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
}
