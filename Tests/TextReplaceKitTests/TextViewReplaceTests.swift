import Testing
import UIKit

@testable import TextReplaceKit

private func numberShortcodeTransform() -> (Shortcode) -> NSAttributedString? {
    { shortcode in
        switch shortcode.name {
        case "one":
            NSAttributedString(attachment: TextAttachment("1"))
        case "two":
            NSAttributedString(attachment: TextAttachment("2"))
        case "three":
            NSAttributedString(attachment: TextAttachment("3"))
        default:
            nil
        }
    }
}

@MainActor
@Suite
struct TextViewReplaceTests {
    @Test
    func replaceShortcodeAdjacentToPosition() {
        let textView = UITextView()
        textView.attributedText = NSAttributedString(string: ":one: :two:")

        let transform = numberShortcodeTransform()
        textView.replaceShortcodes(transform, textRange: textView.selectedTextRange!)
        #expect(textView.visualText == ":one: 2[]")

        let position = textView.position(from: textView.beginningOfDocument, offset: 5)!
        textView.selectedTextRange = textView.textRange(from: position, to: position)
        textView.replaceShortcodes(transform, textRange: textView.selectedTextRange!)

        #expect(textView.visualText == "1[] 2")
    }

    @Test
    func replaceShortcodeAdjacentToTextRangeEdges() {
        let textView = UITextView()
        textView.text = ":one: and :two:"
        let start = textView.position(from: textView.beginningOfDocument, offset: 2)!
        let end = textView.position(from: textView.beginningOfDocument, offset: 12)!
        textView.selectedTextRange = textView.textRange(from: start, to: end)

        textView.replaceShortcodes(numberShortcodeTransform(), textRange: textView.selectedTextRange!)

        #expect(textView.visualText == "1[ and 2]")
    }

    @Test
    func replaceShortcodeWithEmptyReplacement() {
        let textView = UITextView()
        textView.text = "Hello :one:"

        textView.replaceShortcodes(
            { _ in NSAttributedString(string: "") },
            textRange: textView.selectedTextRange!
        )

        #expect(textView.text == "Hello ")
    }

    @Test
    func ignoresNonAdjacentShortcode() {
        class Watcher: NSObject, UITextViewDelegate {
            var didChange = 0

            func textViewDidChange(_ textView: UITextView) {
                didChange += 1
            }
        }

        let watcher = Watcher()
        let textView = UITextView()
        textView.delegate = watcher
        textView.text = ":one: text"

        textView.replaceShortcodes(numberShortcodeTransform(), textRange: textView.selectedTextRange!)

        #expect(textView.visualText == ":one: text[]")
        #expect(watcher.didChange == 0)
    }

    @Test
    func skipsBrokenShortcodeAndReplacesAdjacentValidShortcode() {
        let textView = UITextView()
        textView.text = ":one:test :two:"

        textView.replaceShortcodes(numberShortcodeTransform(), textRange: textView.selectedTextRange!)

        #expect(textView.visualText == ":one:test 2[]")
    }

    @Test
    func silentlyReplacesShortcodeWithoutDelegateCallback() {
        class Watcher: NSObject, UITextViewDelegate {
            var didChange = 0

            func textViewDidChange(_ textView: UITextView) {
                didChange += 1
            }
        }

        let watcher = Watcher()
        let textView = UITextView()
        textView.delegate = watcher
        textView.text = ":one:"

        textView.replaceShortcodesSilently(numberShortcodeTransform(), textRange: textView.selectedTextRange!)

        #expect(textView.visualText == "1[]")
        #expect(watcher.didChange == 0)
    }

    @Test
    func replaceInsertedShortcodeOnly() {
        let textView = UITextView()
        textView.attributedText = NSAttributedString(string: ":one: :two:")
        textView.replaceShortcodes(numberShortcodeTransform(), textRange: textView.selectedTextRange!)

        let position = textView.position(from: textView.beginningOfDocument, offset: 5)!
        textView.selectedTextRange = textView.textRange(from: position, to: position)
        textView.insertText(" :three:")
        textView.replaceShortcodes(numberShortcodeTransform(), textRange: textView.selectedTextRange!)

        #expect(textView.visualText == ":one: 3[] 2")
    }

    @Test
    func replacePiece() async throws {
        let textView = UITextView()
        textView.insertText("hoge:night_fox_da")
        let textRange = textView.textRange(location: 4, length: 13)!
        textView.replaceText(
            textRange: textRange,
            withText: ":night_fox_dawn:",
            leadingPadding: true,
            trailingPadding: .insert
        )
        #expect(textView.visualText == "hoge :night_fox_dawn: []")
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
