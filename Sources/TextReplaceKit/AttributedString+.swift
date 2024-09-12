import Foundation

extension AttributedString {
    public static let defaultShortcodeRegexExpression = ":([a-zA-Z_]+):"
    
    public typealias ShortcodeTransform = (AttributedString.Shortcode) -> AttributedString?
    
    mutating public func replaceShortcode(
        regexExpression: String = Self.defaultShortcodeRegexExpression,
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
            let shortcode = Shortcode(rawValue: String(attributedSubstring.characters))
            if let s = transform(shortcode) {
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

extension AttributedString {
    public struct Shortcode: Sendable {
        public let rawValue: String
        
        public var name: Substring {
            let start = rawValue.index(after: rawValue.startIndex)
            let end = rawValue.index(before: rawValue.endIndex)
            return rawValue[start..<end]
        }
    }
}
