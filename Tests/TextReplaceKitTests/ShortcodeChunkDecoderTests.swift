import RegexBuilder
import Testing
import UIKit

@testable import TextReplaceKit

@Test func shortcodeChunk() async throws {
  let decoder = ShortcodeChunkDecoder()
  let chunk1 = decoder.decode(" :text: ")!
  #expect(chunk1.hasPrefixWhiteSpace)
  #expect(chunk1.hasSuffixWhiteSpace)
  #expect(chunk1.shortcode.name == "text")
  #expect(chunk1.shortcode.rawValue == ":text:")

  let chunk2 = decoder.decode(" :text:")!
  #expect(chunk2.hasPrefixWhiteSpace)
  #expect(!chunk2.hasSuffixWhiteSpace)
  #expect(chunk2.shortcode.name == "text")
  #expect(chunk2.shortcode.rawValue == ":text:")

  let chunk3 = decoder.decode(":text: ")!
  #expect(!chunk3.hasPrefixWhiteSpace)
  #expect(chunk3.hasSuffixWhiteSpace)
  #expect(chunk3.shortcode.name == "text")
  #expect(chunk3.shortcode.rawValue == ":text:")

  let chunk4 = decoder.decode(":text:")!
  #expect(!chunk4.hasPrefixWhiteSpace)
  #expect(!chunk4.hasSuffixWhiteSpace)
  #expect(chunk4.shortcode.name == "text")
  #expect(chunk4.shortcode.rawValue == ":text:")
}
