import Foundation

extension NSAttributedString {
  public static let whitespace = " "
  public typealias ShortcodeTransform = (Shortcode) -> NSAttributedString?

  func enumerateShortcodes(
    decoder: ShortcodeChunkDecoder = ShortcodeChunkDecoder(),
    transform: (Shortcode) -> NSAttributedString?,
    using block: (NSAttributedString, NSRange, inout Bool) -> Void
  ) {
    let regex = Regex.shortcodeWithPadding
    enumerateMatches(regex) { substring, nsRange, shouldStop in
      let chunkText = String(substring)
      let chunk = decoder.decode(chunkText)
      if let chunk, let s = transform(chunk.shortcode)?.copyAsMutable() {
        if chunk.hasPrefixWhiteSpace {
          s.insert(NSAttributedString(string: Self.whitespace), at: 0)
        }
        if chunk.hasSuffixWhiteSpace {
          s.append(NSAttributedString(string: Self.whitespace))
        }
        block(s, nsRange, &shouldStop)
      }
    }
  }

  // default reversed
  func enumerateMatches<R: RegexComponent>(
    _ regex: R,
    using block: (Substring, NSRange, inout Bool) -> Void
  ) {
    var shouldStop: Bool = false
    for match in string.matches(of: regex).reversed() {
      let substring = string[match.range]
      let nsRange = NSRange(match.range, in: string)
      block(substring, nsRange, &shouldStop)
      if shouldStop {
        break
      }
    }
  }
}

extension NSAttributedString {
  func copyAsMutable() -> NSMutableAttributedString {
    NSMutableAttributedString(attributedString: self)
  }

  func toModern() -> AttributedString {
    AttributedString(self)
  }
}

extension AttributedString {
  func toFoundation() -> NSAttributedString {
    NSAttributedString(self)
  }

  var string: String {
    String(characters)
  }
}
