import Foundation
import RegexBuilder

public struct Shortcode: Sendable {
    public let rawValue: Substring
    public let name: Substring
}

public struct ShortcodeChunk: Sendable {
    public let hasLeadingWhitespace: Bool
    public let hasTrailingWhitespace: Bool
    public let shortcode: Shortcode
}

public struct ShortcodeChunkParser {
    public init() {}

    public func parse(_ text: Substring) -> ShortcodeChunk? {
        guard let match = text.wholeMatch(of: ShortcodeChunkParser.regex) else { return nil }

        let output = match.output
        let hasLeadingWhitespace = output.1
        let shortcodeRawValue = output.2
        let shortcodeName = output.3
        let hasTrailingWhitespace = output.4

        let shortcode = Shortcode(rawValue: shortcodeRawValue, name: shortcodeName)

        return ShortcodeChunk(
            hasLeadingWhitespace: hasLeadingWhitespace,
            hasTrailingWhitespace: hasTrailingWhitespace,
            shortcode: shortcode
        )

    }
}

private extension ShortcodeChunkParser {
    static var regex: Regex<(Substring, Bool, Substring, Substring, Bool)> {
        Regex {
            Capture(
                Optionally(.whitespace),
                transform: { !$0.isEmpty }
            )
            Capture {
                ":"
                Capture {
                    OneOrMore {
                        CharacterClass(
                            .anyOf("_"),
                            ("a"..."z"),
                            ("A"..."Z"),
                            ("0"..."9")
                        )
                    }
                }
                ":"
            }
            Capture(
                Optionally(.whitespace),
                transform: { !$0.isEmpty }
            )
        }
    }
}
