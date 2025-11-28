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

    @available(*, deprecated, renamed: "hasLeadingWhitespace")
    public var hasPrefixWhiteSpace: Bool { hasLeadingWhitespace }

    @available(*, deprecated, renamed: "hasTrailingWhitespace")
    public var hasSuffixWhiteSpace: Bool { hasTrailingWhitespace }
}

public struct ShortcodeChunkParser {
    public init() {}

    public func parse(_ text: Substring) -> ShortcodeChunk? {
        let hasPrefixWhiteSpaceReference = Reference<Bool>()
        let hasSuffixWhiteSpaceReference = Reference<Bool>()
        let shortcodeReference = Reference<Substring>()
        let shortcodeNameReference = Reference<Substring>()

        let regex = Regex {
            Capture(
                Optionally(.whitespace),
                as: hasPrefixWhiteSpaceReference,
                transform: { !$0.isEmpty }
            )
            Capture(
                as: shortcodeReference,
                {
                    ":"
                    Capture(
                        as: shortcodeNameReference,
                        {
                            OneOrMore {
                                CharacterClass(
                                    .anyOf("_"),
                                    ("a"..."z"),
                                    ("A"..."Z"),
                                    ("0"..."9")
                                )
                            }
                        }
                    )
                    ":"
                }
            )
            Capture(
                Optionally(.whitespace),
                as: hasSuffixWhiteSpaceReference,
                transform: { !$0.isEmpty }
            )
        }
        guard let match = text.wholeMatch(of: regex) else { return nil }

        let hasLeadingWhitespace = match[hasPrefixWhiteSpaceReference]
        let hasTrailingWhitespace = match[hasSuffixWhiteSpaceReference]
        let shortcodeRawValue = match[shortcodeReference]
        let shortcodeName = match[shortcodeNameReference]

        let shortcode = Shortcode(rawValue: shortcodeRawValue, name: shortcodeName)

        return ShortcodeChunk(
            hasLeadingWhitespace: hasLeadingWhitespace,
            hasTrailingWhitespace: hasTrailingWhitespace,
            shortcode: shortcode
        )

    }
}

@available(*, deprecated, renamed: "ShortcodeChunkParser")
public typealias ShortcodeChunkDecoder = ShortcodeChunkParser

public extension ShortcodeChunkParser {
    @available(*, deprecated, renamed: "parse(_:)")
    func decode(_ text: Substring) -> ShortcodeChunk? {
        parse(text)
    }
}
