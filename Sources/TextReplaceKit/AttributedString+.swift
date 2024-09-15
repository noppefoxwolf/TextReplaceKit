import Foundation

extension AttributedString {
    public static let defaultShortcodeRegexExpression = #"(^|\s):([a-zA-Z0-9_]+):(?!\S)"#
    
    public typealias ShortcodeTransform = (Shortcode) -> AttributedString?
    
    mutating public func replaceShortcode(
        regexExpression: String = Self.defaultShortcodeRegexExpression,
        decoder: ShortcodeChunkDecoder = ShortcodeChunkDecoder(),
        with transform: ShortcodeTransform
    ) {
        var substring: AttributedSubstring = self[startIndex...]
        var ranges: [Range<AttributedString.Index>] = []
        while let range = substring.range(of: regexExpression, options: .regularExpression) {
            ranges.append(range)
            substring = substring[range.upperBound...]
        }
        
        for range in ranges.reversed() {
            let attributedSubstring = self[range]
            let chunkText = String(attributedSubstring.characters)
            let chunk = decoder.decode(chunkText)
            if let chunk, var s = transform(chunk.shortcode) {
                if chunk.hasPrefixWhiteSpace {
                    s.insert(AttributedString(" "), at: s.startIndex)
                }
                if chunk.hasSuffixWhiteSpace {
                    s.append(AttributedString(" "))
                }
                self.replaceSubrange(range, with: s)
            }
        }
    }
    
    public func replacingShortcode(
        regexExpression: String = Self.defaultShortcodeRegexExpression,
        with transform: ShortcodeTransform
    ) -> AttributedString {
        var newValue = self
        newValue.replaceShortcode(regexExpression: regexExpression, with: transform)
        return newValue
    }
}

