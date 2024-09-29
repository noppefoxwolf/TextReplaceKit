import Foundation

extension AttributedString {
    public static let defaultShortcodeRegexExpression = #"(^|\s):([a-zA-Z0-9_]+):(?!\S)"#
    public static let whitespace = " "
    
    public typealias ShortcodeTransform = (Shortcode) -> AttributedString?
    
    mutating public func replaceShortcode(
        decoder: ShortcodeChunkDecoder = ShortcodeChunkDecoder(),
        with transform: ShortcodeTransform
    ) {
        var substring: AttributedSubstring = self[startIndex...]
        var ranges: [Range<AttributedString.Index>] = []
        while let range = substring.range(of: Self.defaultShortcodeRegexExpression, options: .regularExpression) {
            ranges.append(range)
            substring = substring[range.upperBound...]
        }
        
        for range in ranges.reversed() {
            let attributedSubstring = self[range]
            let chunkText = String(attributedSubstring.characters)
            let chunk = decoder.decode(chunkText)
            if let chunk, var s = transform(chunk.shortcode) {
                if chunk.hasPrefixWhiteSpace {
                    s.insert(AttributedString(Self.whitespace), at: s.startIndex)
                }
                if chunk.hasSuffixWhiteSpace {
                    s.append(AttributedString(Self.whitespace))
                }
                self.replaceSubrange(range, with: s)
            }
        }
    }
    
    public func replacingShortcode(
        with transform: ShortcodeTransform
    ) -> AttributedString {
        var newValue = self
        newValue.replaceShortcode(with: transform)
        return newValue
    }
}

