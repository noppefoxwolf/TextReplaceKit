import RegexBuilder
import Testing
import UIKit

@testable import TextReplaceKit

@Test func parseChunkRespectsWhitespace() async throws {
    let parser = ShortcodeChunkParser()
    let chunk1 = parser.parse(" :text: ")!
    #expect(chunk1.hasLeadingWhitespace)
    #expect(chunk1.hasTrailingWhitespace)
    #expect(chunk1.shortcode.name == "text")
    #expect(chunk1.shortcode.rawValue == ":text:")

    let chunk2 = parser.parse(" :text:")!
    #expect(chunk2.hasLeadingWhitespace)
    #expect(!chunk2.hasTrailingWhitespace)
    #expect(chunk2.shortcode.name == "text")
    #expect(chunk2.shortcode.rawValue == ":text:")

    let chunk3 = parser.parse(":text: ")!
    #expect(!chunk3.hasLeadingWhitespace)
    #expect(chunk3.hasTrailingWhitespace)
    #expect(chunk3.shortcode.name == "text")
    #expect(chunk3.shortcode.rawValue == ":text:")

    let chunk4 = parser.parse(":text:")!
    #expect(!chunk4.hasLeadingWhitespace)
    #expect(!chunk4.hasTrailingWhitespace)
    #expect(chunk4.shortcode.name == "text")
    #expect(chunk4.shortcode.rawValue == ":text:")
}
