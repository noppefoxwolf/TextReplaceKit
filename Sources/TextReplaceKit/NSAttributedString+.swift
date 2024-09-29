import Foundation

extension NSMutableAttributedString {
    public static let whitespace = " "
    
    public typealias ShortcodeTransform = (Shortcode) -> AttributedString?
    
    public func replaceShortcode(
        decoder: ShortcodeChunkDecoder = ShortcodeChunkDecoder(),
        with transform: ShortcodeTransform,
        replaceAction: (NSMutableAttributedString, NSRange, NSAttributedString) -> Void = {
            $0.replaceCharacters(in: $1, with: $2)
        }
    ) {
        let regex = Regex.shortcodeWithPadding
        enumerateMatches(regex) { substring, nsRange, _ in
            let chunkText = String(substring)
            let chunk = decoder.decode(chunkText)
            if let chunk, let s = transform(chunk.shortcode)?.toFoundation().toMutable() {
                if chunk.hasPrefixWhiteSpace {
                    s.insert(NSAttributedString(string: Self.whitespace), at: 0)
                }
                if chunk.hasSuffixWhiteSpace {
                    s.append(NSAttributedString(string: Self.whitespace))
                }
                replaceAction(self, nsRange, s)
            }
        }
    }
}

extension NSAttributedString {
    // default reversed
    public func enumerateMatches<R: RegexComponent>(
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
    
    public func replacingShortcode(
        with transform: NSMutableAttributedString.ShortcodeTransform,
        replaceAction: (NSMutableAttributedString, NSRange, NSAttributedString) -> Void = {
            $0.replaceCharacters(in: $1, with: $2)
        }
    ) -> NSAttributedString {
        let newValue = self.toMutable()
        newValue.replaceShortcode(
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
