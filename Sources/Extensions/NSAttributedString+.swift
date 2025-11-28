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
        let clampedIndex = Swift.max(0, Swift.min(index, length))
        let baseAttributes: [NSAttributedString.Key: Any]
        if length > 0 {
            let attrIndex = clampedIndex == length ? length - 1 : clampedIndex
            baseAttributes = attributes(at: attrIndex, effectiveRange: nil)
        } else {
            baseAttributes = [:]
        }
        let newAttributedString = NSAttributedString(string: string, attributes: baseAttributes)
        insert(newAttributedString, at: clampedIndex)
    }

    package func append(_ string: String) {
        let baseAttributes: [NSAttributedString.Key: Any]
        if length > 0 {
            baseAttributes = attributes(at: length - 1, effectiveRange: nil)
        } else {
            baseAttributes = [:]
        }
        let newAttributedString = NSAttributedString(string: string, attributes: baseAttributes)
        append(newAttributedString)
    }
}
