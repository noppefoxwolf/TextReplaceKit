import RegexBuilder
import Foundation

public struct Shortcode: Sendable {
    public let rawValue: Substring
    public let name: Substring
}

public struct ShortcodeChunk: Sendable {
    public let hasPrefixWhiteSpace: Bool
    public let hasSuffixWhiteSpace: Bool
    public let shortcode: Shortcode
}

public struct ShortcodeChunkDecoder {
    public init() {}
    
    public func decode(_ text: String) -> ShortcodeChunk? {
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
            Capture(as: shortcodeReference, {
                ":"
                Capture(as: shortcodeNameReference, {
                    OneOrMore {
                        CharacterClass(
                            .anyOf("_"),
                            ("a"..."z"),
                            ("A"..."Z"),
                            ("0"..."9")
                        )
                    }
                })
                ":"
            })
            Capture(
                Optionally(.whitespace),
                as: hasSuffixWhiteSpaceReference,
                transform: { !$0.isEmpty }
            )
        }
        guard let match = text.wholeMatch(of: regex) else { return nil }
        
        let hasPrefixWhiteSpace = match[hasPrefixWhiteSpaceReference]
        let hasSuffixWhiteSpace = match[hasSuffixWhiteSpaceReference]
        let shortcodeRawValue = match[shortcodeReference]
        let shortcodeName = match[shortcodeNameReference]
        
        let shortcode = Shortcode(rawValue: shortcodeRawValue, name: shortcodeName)
        
        return ShortcodeChunk(
            hasPrefixWhiteSpace: hasPrefixWhiteSpace,
            hasSuffixWhiteSpace: hasSuffixWhiteSpace,
            shortcode: shortcode
        )
        
    }
}
