package import Foundation

extension NSAttributedString {
    package func copyAsMutable() -> NSMutableAttributedString {
        NSMutableAttributedString(attributedString: self)
    }

    package func toModern() -> AttributedString {
        AttributedString(self)
    }

    package var range: NSRange {
        NSRange(location: 0, length: length)
    }
}

extension AttributedString {
    package func toFoundation() -> NSAttributedString {
        NSAttributedString(self)
    }

    package var string: String {
        String(characters)
    }
}

extension NSMutableAttributedString {
    package func insert(_ string: String, at index: Int) {
        guard length > 0 else { return }
        let attributes = attributes(at: 0, effectiveRange: nil)
        let newAttributedString = NSAttributedString(string: string, attributes: attributes)
        insert(newAttributedString, at: index)
    }

    package func append(_ string: String) {
        guard length > 0 else { return }
        let attributes = attributes(at: 0, effectiveRange: nil)
        let newAttributedString = NSAttributedString(string: string, attributes: attributes)
        append(newAttributedString)
    }
}
