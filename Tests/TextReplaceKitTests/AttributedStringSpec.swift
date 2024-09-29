import Testing
import Foundation
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
}

