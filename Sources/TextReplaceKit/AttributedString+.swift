import Foundation

extension AttributedString {
    public static let defaultShortcodeRegexExpression = #"(^|\s):([a-zA-Z0-9_]+):(?!\S)"#
    public static let whitespace = " "
    
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
        regexExpression: String = Self.defaultShortcodeRegexExpression,
        with transform: ShortcodeTransform
    ) -> AttributedString {
        var newValue = self
        newValue.replaceShortcode(regexExpression: regexExpression, with: transform)
        return newValue
    }
}

extension NSMutableAttributedString {
    public static let defaultShortcodeRegexExpression = #"(^|\s):([a-zA-Z0-9_]+):(?!\S)"#
    public static let whitespace = " "
    
    public typealias ShortcodeTransform = (Shortcode) -> AttributedString?
    
    public func replaceShortcode(
        regexExpression: String = NSMutableAttributedString.defaultShortcodeRegexExpression,
        decoder: ShortcodeChunkDecoder = ShortcodeChunkDecoder(),
        with transform: ShortcodeTransform,
        replaceAction: (NSMutableAttributedString, NSRange, NSAttributedString) -> Void = {
            $0.replaceCharacters(in: $1, with: $2)
        }
    ) {
        let regex = try! Regex(regexExpression)
        for match in string.matches(of: regex).reversed() {
            let chunkText = String(string[match.range])
            let chunk = decoder.decode(chunkText)
            if let chunk, let s = transform(chunk.shortcode)?.toFoundation().toMutable() {
                if chunk.hasPrefixWhiteSpace {
                    s.insert(NSAttributedString(string: Self.whitespace), at: 0)
                }
                if chunk.hasSuffixWhiteSpace {
                    s.append(NSAttributedString(string: Self.whitespace))
                }
                
                let nsRange = NSRange(match.range, in: string)
                replaceAction(self, nsRange, s)
            }
        }
    }
}

extension NSAttributedString {
    public func replacingShortcode(
        regexExpression: String = NSMutableAttributedString.defaultShortcodeRegexExpression,
        with transform: NSMutableAttributedString.ShortcodeTransform,
        replaceAction: (NSMutableAttributedString, NSRange, NSAttributedString) -> Void = {
            $0.replaceCharacters(in: $1, with: $2)
        }
    ) -> NSAttributedString {
        let newValue = self.toMutable()
        newValue.replaceShortcode(
            regexExpression: regexExpression,
            with: transform,
            replaceAction: replaceAction
        )
        return newValue
    }
}


extension NSAttributedString {
    func toMutable() -> NSMutableAttributedString {
        NSMutableAttributedString(attributedString: self)
    }
    
    func toModern() -> AttributedString {
        AttributedString(self)
    }
}

extension AttributedString {
    func toFoundation() -> NSAttributedString {
        NSAttributedString(self)
    }
    
    var string: String {
        String(characters)
    }
}
