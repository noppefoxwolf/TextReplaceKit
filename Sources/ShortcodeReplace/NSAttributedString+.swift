import Foundation
import Extensions

extension NSMutableAttributedString {
    public func replaceShortcode(with transform: ShortcodeTransform) {
        enumerateShortcodes(transform: transform) { statement, range, _ in
            replaceCharacters(in: range, with: statement.attributedText)
        }
    }
}

extension NSAttributedString {
    public static let whitespace = " "
    public typealias ShortcodeTransform = (Shortcode) -> NSAttributedString?

    func enumerateShortcodes(
        decoder: ShortcodeChunkDecoder = ShortcodeChunkDecoder(),
        transform: (Shortcode) -> NSAttributedString?,
        using block: (AttributedStatement, NSRange, inout Bool) -> Void
    ) {
        let regex = Regex.shortcodeWithPadding
        enumerateMatches(regex) { substring, nsRange, shouldStop in
            let chunk = decoder.decode(substring)
            if let chunk, let s = transform(chunk.shortcode) {
                let statement = AttributedStatement(bodyAttributedText: s)
                if chunk.hasPrefixWhiteSpace {
                    statement.leadingAttributedText = NSAttributedString(string: Self.whitespace)
                }
                if chunk.hasSuffixWhiteSpace {
                    statement.trailingAttributedText = NSAttributedString(string: Self.whitespace)
                }
                block(statement, nsRange, &shouldStop)
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
