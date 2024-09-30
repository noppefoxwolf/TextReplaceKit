import Testing
@testable import TextReplaceKit
import UIKit

@MainActor
@Suite
struct TextViewReplaceTests {
    @Test
    func insert() {
        let textView = UITextView()
        textView.attributedText = NSAttributedString(string: ":one: :two:")
        #expect(textView.visualText == ":one: :two:[]")
        
        let transform = { (shortcode: Shortcode) -> NSAttributedString? in
            switch shortcode.name {
            case "one":
                NSAttributedString(attachment: TextAttachment("1️⃣"))
            case "two":
                NSAttributedString(attachment: TextAttachment("2️⃣"))
            case "three":
                NSAttributedString(attachment: TextAttachment("3️⃣"))
            default:
                nil
            }
        }
        textView.replaceShortcode(transform, granularity: .selectedLine)
        
        let position = textView.position(
            from: textView.beginningOfDocument,
            offset: 1
        )!
        let textRange = textView.textRange(from: position, to: position)
        textView.selectedTextRange = textRange
        #expect(textView.visualText == "1️⃣[] 2️⃣")
        
        textView.insertText(" :three:")
        #expect(textView.visualText == "1️⃣ :three:[] 2️⃣")
        textView.replaceShortcode(transform, granularity: .selectedLine)
        
        #expect(textView.visualText == "1️⃣ 3️⃣[] 2️⃣")
    }
    
    @Test
    func insertWholeDocument() {
        let textView = UITextView()
        textView.attributedText = NSAttributedString(string: ":one: :two:")
        #expect(textView.visualText == ":one: :two:[]")
        
        let transform = { (shortcode: Shortcode) -> NSAttributedString? in
            switch shortcode.name {
            case "one":
                NSAttributedString(attachment: TextAttachment("1️⃣"))
            case "two":
                NSAttributedString(attachment: TextAttachment("2️⃣"))
            case "three":
                NSAttributedString(attachment: TextAttachment("3️⃣"))
            default:
                nil
            }
        }
        textView.replaceShortcode(transform, granularity: .document)
        
        let position = textView.position(
            from: textView.beginningOfDocument,
            offset: 1
        )!
        let textRange = textView.textRange(from: position, to: position)
        textView.selectedTextRange = textRange
        #expect(textView.visualText == "1️⃣[] 2️⃣")
        
        textView.insertText(" :three:")
        #expect(textView.visualText == "1️⃣ :three:[] 2️⃣")
        textView.replaceShortcode(transform, granularity: .document)
        
        #expect(textView.visualText == "1️⃣ 3️⃣[] 2️⃣")
    }
}

final class TextAttachment: NSTextAttachment {
    
    let emoji: String
    
    init(_ emoji: String) {
        self.emoji = emoji
        super.init(data: nil, ofType: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func image(
        forBounds imageBounds: CGRect,
        textContainer: NSTextContainer?,
        characterIndex charIndex: Int
    ) -> UIImage? {
        UIImage(systemName: "apple.logo")
    }
}

