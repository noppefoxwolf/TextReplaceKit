import Testing
import UIKit

@testable import TextReplaceKit

@MainActor
@Suite
struct TextViewReplaceTests {
    @Test
    func replaceShortcode() {
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
    func replaceShortcodeWholeDocument() {
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
    
    @Test
    func replaceBug() {
        let textView = UITextView()
        textView.text = ":blobcat: :blobcat:test :blobcat: :blobcat:"
        let transform = { (shortcode: Shortcode) -> NSAttributedString? in
            switch shortcode.name {
            case "blobcat":
                NSAttributedString(attachment: TextAttachment("🐈"))
            default:
                nil
            }
        }
        textView.replaceShortcode(transform, granularity: .selectedLine)
        #expect(textView.visualText == "🐈 :blobcat:test 🐈 🐈[]")
    }
    
    @Test
    func replaceBug2() {
        class Watcher: NSObject, UITextViewDelegate {
            var didChange: Int = 0
            
            func textViewDidChange(_ textView: UITextView) {
                didChange += 1
            }
        }
        let watcher = Watcher()
        let textView = UITextView()
        textView.delegate = watcher
        textView.text = ":blobcat: :blobcat:test :blobcat: :blobcat:"
        let transform = { (shortcode: Shortcode) -> NSAttributedString? in
            switch shortcode.name {
            case "blobcat":
                NSAttributedString(attachment: TextAttachment("🐈"))
            default:
                nil
            }
        }
        textView.replaceShortcode(transform, granularity: .selectedLine)
        #expect(textView.visualText == "🐈 :blobcat:test 🐈 🐈[]")
        #expect(watcher.didChange == 1)
    }
    
    @Test
    func notCalledAnyChanges() {
        class Watcher: NSObject, UITextViewDelegate {
            var didChange: Int = 0
            
            func textViewDidChange(_ textView: UITextView) {
                didChange += 1
            }
        }
        let watcher = Watcher()
        let textView = UITextView()
        textView.delegate = watcher
        textView.text = ":blobcat: :blobcat:test :blobcat: :blobcat:"
        let transform = { (shortcode: Shortcode) -> NSAttributedString? in
            nil
        }
        textView.replaceShortcode(transform, granularity: .selectedLine)
        #expect(textView.visualText == ":blobcat: :blobcat:test :blobcat: :blobcat:[]")
        #expect(watcher.didChange == 0)
    }
    
    // attributes.fontがnilだとクラッシュする
    @available(iOS 18.0, *)
    @Test(.enabled(if: false))
    func defaultLineHeightForUILayoutBug() {
        let textView = UITextView()
        textView.font = UIFont.boldSystemFont(ofSize: 100)
        textView.attributedText = NSAttributedString(string: ":one: :two:")
        #expect(textView.visualText == ":one: :two:[]")

        let transform = { (shortcode: Shortcode) -> NSAttributedString? in
            switch shortcode.name {
            case "one":
                NSAttributedString(attachment: TextAttachment("1️⃣"), attributes: [.font : textView.font as Any])
            case "two":
                NSAttributedString(attachment: TextAttachment("2️⃣"), attributes: [.font : textView.font as Any])
            case "three":
                NSAttributedString(attachment: TextAttachment("3️⃣"), attributes: [.font : textView.font as Any])
            default:
                nil
            }
        }
        textView.replaceShortcode(transform, granularity: .document)

        let position = textView.position(
            from: textView.beginningOfDocument,
            offset: 2
        )!
        let textRange = textView.textRange(from: position, to: position)
        textView.selectedTextRange = textRange
        #expect(textView.visualText == "1️⃣ []2️⃣")

        // Thread 1: "-[NSNull _defaultLineHeightForUILayout]: unrecognized selector sent to instance 0x1e007fa58"
        textView.insertText(":three:")
        #expect(textView.visualText == "1️⃣ :three:[]2️⃣")
        textView.replaceShortcode(transform, granularity: .document)

        #expect(textView.visualText == "1️⃣ :three:[]2️⃣")
    }
    
    @available(iOS 18.0, *)
    @Test
    func workaorundDefaultLineHeightForUILayoutBug() {
        let textView = UITextView()
        textView.font = UIFont.boldSystemFont(ofSize: 100)
        textView.attributedText = NSAttributedString(string: ":one: :two:", attributes: textView.typingAttributes)
        #expect(textView.font != nil)
        #expect(textView.visualText == ":one: :two:[]")
        let transform = { (shortcode: Shortcode) -> NSAttributedString? in
            switch shortcode.name {
            case "one":
                NSAttributedString(attachment: TextAttachment("1️⃣"), attributes: textView.typingAttributes)
            case "two":
                NSAttributedString(attachment: TextAttachment("2️⃣"), attributes: textView.typingAttributes)
            case "three":
                NSAttributedString(attachment: TextAttachment("3️⃣"), attributes: textView.typingAttributes)
            default:
                nil
            }
        }
        textView.replaceShortcode(transform, granularity: .document)
        #expect(textView.font != nil)
        let position = textView.position(
            from: textView.beginningOfDocument,
            offset: 2
        )!
        let textRange = textView.textRange(from: position, to: position)
        textView.selectedTextRange = textRange
        #expect(textView.font != nil)
        #expect(textView.visualText == "1️⃣ []2️⃣")
        
        #expect(textView.font != nil)
        // Thread 1: "-[NSNull _defaultLineHeightForUILayout]: unrecognized selector sent to instance 0x1e007fa58"
        textView.insertText(":three:")
        #expect(textView.font != nil)
        
        #expect(textView.visualText == "1️⃣ :three:[]2️⃣")
        textView.replaceShortcode(transform, granularity: .document)

        #expect(textView.visualText == "1️⃣ :three:[]2️⃣")
        
        let range = NSRange(location: 3, length: 5)
        var foundedFont: UIFont? = nil
        textView.attributedText.enumerateAttribute(.font, in: range) { font, range, _ in
            foundedFont = font as? UIFont
        }
        #expect(foundedFont != nil)
    }
    
    @Test
    func alreadyReplacedAttributedString() {
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

        textView.insertText(":three:")
        #expect(textView.visualText == "1️⃣:three:[] 2️⃣")
        
        let attachmentTransform = { (textAttachment: NSTextAttachment) -> NSAttributedString? in
            guard let textAttachment = textAttachment as? TextAttachment else { return nil }
            switch textAttachment.emoji {
            case "1️⃣":
                return NSAttributedString(string: ":one:")
            default:
                return nil
            }
        }
        textView.replaceAttachment(attachmentTransform, skipUnbrokenAttachments: true, granularity: .selectedLine)
        #expect(textView.visualText == ":one::three:[] 2️⃣")
        
        textView.replaceShortcode(transform, granularity: .selectedLine)
        #expect(textView.visualText == ":one::three:[] 2️⃣")
    }
    
    @Test
    func newlineBug() async throws {
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        textView.insertText("\n")
        textView.insertText(":cat:")
        textView.replaceShortcode({ _ in
            NSAttributedString(attachment: TextAttachment("🐈"))
        }, granularity: .selectedLine)
        #expect(textView.visualText == "\n🐈[]")
        textView.setReplacedAttributedText({ _ in  NSAttributedString(string: ":cat:") }, skipUnbrokenAttachments: true, granularity: .selectedLine)
        #expect(textView.visualText == "\n🐈[]")
    }
    
    @Test
    func replacePiece() async throws {
        let textView = UITextView()
        textView.insertText("hoge:night_fox_da")
        let textRange = textView.textRange(location: 4, length: 13)!
        textView.replaceText(textRange: textRange, withText: ":night_fox_dawn:", leadingPadding: true, trailingPadding: .insert)
        #expect(textView.visualText == "hoge :night_fox_dawn: []")
    }
}

open class CodableTextAttachment: NSTextAttachment {
    public var rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
        super.init(data: nil, ofType: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
