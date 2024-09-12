import Foundation

extension AttributedString {
    public static let defaultShortcodeRegexExpression = ":([a-zA-Z_]+):"
    
    public typealias ShortcodeTransform = (AttributedString.Shortcode) -> AttributedString?
    
    mutating public func replaceShortcode(
        regexExpression: String = Self.defaultShortcodeRegexExpression,
        with transform: ShortcodeTransform
    ) {
        var substring: AttributedSubstring = self[self.startIndex...self.endIndex]
        while let range = substring.range(of: regexExpression, options: .regularExpression) {
            let attributedSubstring = self[range]
            let shortcode = Shortcode(rawValue: String(attributedSubstring.characters))
            if let s = transform(shortcode) {
                self.replaceSubrange(range, with: s)
            }
            
            substring = self[range.lowerBound...]
            if substring.characters.count == 0 {
                break
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
