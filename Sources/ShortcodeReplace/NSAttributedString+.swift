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
        transform: (Shortcode) -> NSAttributedString?,
        using block: (AttributedStatement, NSRange, inout Bool) -> Void
    ) {
        let regex = Regex.shortcodeWithPadding
        enumerateMatches(regex) { substring, nsRange, shouldStop in
            guard let chunk = ShortcodeChunk.parseFromMatchedSubstring(substring) else { return }
            if let s = transform(chunk.shortcode) {
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

private extension ShortcodeChunk {
    static func parseFromMatchedSubstring(_ substring: Substring) -> ShortcodeChunk? {
        guard !substring.isEmpty else { return nil }
        let hasLeadingWhitespace = substring.first?.isWhitespace ?? false
        let hasTrailingWhitespace = substring.last?.isWhitespace ?? false
        let startIndex = hasLeadingWhitespace ? substring.index(after: substring.startIndex) : substring.startIndex
        guard startIndex < substring.endIndex, substring[startIndex] == ":" else { return nil }
        let nameStartIndex = substring.index(after: startIndex)
        guard let nameEndIndex = substring[nameStartIndex...].firstIndex(of: ":") else { return nil }
        let rawValue = substring[startIndex...nameEndIndex]
        let name = substring[nameStartIndex..<nameEndIndex]

        return ShortcodeChunk(
            hasLeadingWhitespace: hasLeadingWhitespace,
            hasTrailingWhitespace: hasTrailingWhitespace,
            shortcode: Shortcode(rawValue: rawValue, name: name)
        )
    }
}
