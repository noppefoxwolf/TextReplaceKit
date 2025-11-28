import Extensions
public import Foundation

extension NSMutableAttributedString {
    public func replaceShortcodes(with transform: ShortcodeTransform) {
        enumerateShortcodes(transform: transform) { statement, range, _ in
            replaceCharacters(in: range, with: statement.attributedText)
        }
    }

    @available(*, deprecated, renamed: "replaceShortcodes(with:)")
    public func replaceShortcode(with transform: ShortcodeTransform) {
        replaceShortcodes(with: transform)
    }
}

extension NSAttributedString {
    public static let whitespace = " "
    public typealias ShortcodeTransform = (Shortcode) -> NSAttributedString?

    func enumerateShortcodes(
        decoder: ShortcodeChunkParser = ShortcodeChunkParser(),
        transform: (Shortcode) -> NSAttributedString?,
        using block: (AttributedStatement, NSRange, inout Bool) -> Void
    ) {
        let regex = Regex.shortcodeWithPadding
        enumerateMatches(regex) { substring, nsRange, shouldStop in
            let chunk = decoder.parse(substring)
            if let chunk, let s = transform(chunk.shortcode) {
                let statement = AttributedStatement(bodyAttributedText: s)
                if chunk.hasLeadingWhitespace {
                    statement.leadingAttributedText = NSAttributedString(string: Self.whitespace)
                }
                if chunk.hasTrailingWhitespace {
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
