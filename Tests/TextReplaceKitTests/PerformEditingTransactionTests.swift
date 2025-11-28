import Testing
import UIKit

@testable import TextReplaceKit

private func makeTextView(text: String, selectedRange: NSRange) -> UITextView {
    let textView = UITextView()
    textView.text = text
    textView.selectedRange = selectedRange
    return textView
}

private func replace(
    _ textView: UITextView,
    in range: UITextRange? = nil,
    with text: String
) {
    let targetRange = range ?? textView.documentRange
    textView.replacePreservingSelection(
        targetRange,
        withAttributedText: NSAttributedString(string: text)
    )
}

@MainActor
@Suite("文字数が減るケース")
struct SelectionPreservationWhenShrinkingTests {
    @Test("[]:emoji: -> []🐈")
    func replace() async throws {
        let textView = makeTextView(text: ":emoji:", selectedRange: NSRange(location: 0, length: 0))
        #expect(textView.visualText == "[]:emoji:")
        replace(textView, with: "🐈")
        #expect(textView.visualText == "[]🐈")
    }

    @Test(":emoji:[] -> 🐈[]")
    func replace2() async throws {
        let textView = makeTextView(text: ":emoji:", selectedRange: NSRange(location: 7, length: 0))
        #expect(textView.visualText == ":emoji:[]")
        replace(textView, with: "🐈")
        #expect(textView.visualText == "🐈[]")
    }

    @Test(":emo[]ji: -> 🐈[]")
    func replace3() async throws {
        let textView = makeTextView(text: ":emoji:", selectedRange: NSRange(location: 4, length: 0))
        #expect(textView.visualText == ":emo[]ji:")
        replace(textView, with: "🐈")
        #expect(textView.visualText == "🐈[]")
    }

    @Test(":em[oj]i: -> 🐈[]")
    func replace4() async throws {
        let textView = makeTextView(text: ":emoji:", selectedRange: NSRange(location: 3, length: 2))
        #expect(textView.visualText == ":em[oj]i:")
        replace(textView, with: "🐈")
        #expect(textView.visualText == "🐈[]")
    }

    @Test(":emo[ji:] -> 🐈[]")
    func replace5() async throws {
        let textView = makeTextView(text: ":emoji:", selectedRange: NSRange(location: 4, length: 3))
        #expect(textView.visualText == ":emo[ji:]")
        replace(textView, with: "🐈")
        #expect(textView.visualText == "🐈[]")
    }

    @Test("head[er:emoji:foo]ter -> head[er🐈foo]ter")
    func replace6() async throws {
        let textView = makeTextView(
            text: "header:emoji:footer",
            selectedRange: NSRange(location: 4, length: 12)
        )
        #expect(textView.visualText == "head[er:emoji:foo]ter")
        replace(textView, in: textView.textRange(location: 6, length: 7)!, with: "🐈")
        #expect(textView.visualText == "head[er🐈foo]ter")
    }

    @Test("header:emoji:[footer] -> header🐈[footer]")
    func replace7() async throws {
        let textView = makeTextView(
            text: "header:emoji:footer",
            selectedRange: NSRange(location: 13, length: 6)
        )
        #expect(textView.visualText == "header:emoji:[footer]")
        replace(textView, in: textView.textRange(location: 6, length: 7)!, with: "🐈")

        #expect(textView.visualText == "header🐈[footer]")
    }

    @Test("he[a]der:emoji:footer -> he[a]der🐈footer")
    func replace8() async throws {
        let textView = makeTextView(
            text: "header:emoji:footer",
            selectedRange: NSRange(location: 2, length: 1)
        )
        #expect(textView.visualText == "he[a]der:emoji:footer")
        replace(textView, in: textView.textRange(location: 6, length: 7)!, with: "🐈")

        #expect(textView.visualText == "he[a]der🐈footer")
    }

    @Test("header:emoji:fo[o]ter -> header🐈fo[o]ter")
    func replace9() async throws {
        let textView = makeTextView(
            text: "header:emoji:footer",
            selectedRange: NSRange(location: 15, length: 1)
        )
        #expect(textView.visualText == "header:emoji:fo[o]ter")
        replace(textView, in: textView.textRange(location: 6, length: 7)!, with: "🐈")

        #expect(textView.visualText == "header🐈fo[o]ter")
    }

    @Test("head[er:emoji:]footer -> head[er🐈]footer")
    func replace10() async throws {
        let textView = makeTextView(
            text: "header:emoji:footer",
            selectedRange: NSRange(location: 4, length: 9)
        )
        #expect(textView.visualText == "head[er:emoji:]footer")
        replace(textView, in: textView.textRange(location: 6, length: 7)!, with: "🐈")

        #expect(textView.visualText == "head[er🐈]footer")
    }

    @Test("[header:emo]ji:footer -> [header🐈]footer")
    func replace11() async throws {
        let textView = makeTextView(
            text: "header:emoji:footer",
            selectedRange: NSRange(location: 0, length: 10)
        )
        #expect(textView.visualText == "[header:emo]ji:footer")
        replace(textView, in: textView.textRange(location: 6, length: 7)!, with: "🐈")

        #expect(textView.visualText == "[header🐈]footer")
    }

    @Test("header:em[oji:foot]er -> header🐈[foot]er")
    func replace12() async throws {
        let textView = makeTextView(
            text: "header:emoji:footer",
            selectedRange: NSRange(location: 9, length: 8)
        )
        #expect(textView.visualText == "header:em[oji:foot]er")
        replace(textView, in: textView.textRange(location: 6, length: 7)!, with: "🐈")

        #expect(textView.visualText == "header🐈[foot]er")
    }
}

@MainActor
@Suite("文字数が増えるケース")
struct SelectionPreservationWhenExpandingTests {
    @Test("[]🐈 -> []:cat:")
    func replace() async throws {
        let textView = makeTextView(text: "🐈", selectedRange: NSRange(location: 0, length: 0))
        #expect(textView.visualText == "[]🐈")
        replace(textView, with: ":cat:")
        #expect(textView.visualText == "[]:cat:")
    }

    @Test("🐈[] -> :cat:[]")
    func replace2() async throws {
        let textView = makeTextView(text: "🐈", selectedRange: NSRange(location: 7, length: 0))
        #expect(textView.visualText == "🐈[]")
        replace(textView, with: ":cat:")
        #expect(textView.visualText == ":cat:[]")
    }

    @Test("head[er🐈foo]ter -> head[er:cat:foo]ter")
    func replace6() async throws {
        let textView = makeTextView(text: "header🐈footer", selectedRange: NSRange(location: 4, length: 7))
        #expect(textView.visualText == "head[er🐈foo]ter")
        replace(textView, in: textView.textRange(location: 6, length: 2)!, with: ":cat:")
        #expect(textView.visualText == "head[er:cat:foo]ter")
    }

    @Test("header🐈[footer] -> header:cat:[footer]")
    func replace7() async throws {
        let textView = makeTextView(text: "header🐈footer", selectedRange: NSRange(location: 8, length: 6))
        #expect(textView.visualText == "header🐈[footer]")
        replace(textView, in: textView.textRange(location: 6, length: 2)!, with: ":cat:")

        #expect(textView.visualText == "header:cat:[footer]")
    }

    @Test("he[a]der🐈footer -> he[a]der:cat:footer")
    func replace8() async throws {
        let textView = makeTextView(text: "header🐈footer", selectedRange: NSRange(location: 2, length: 1))
        #expect(textView.visualText == "he[a]der🐈footer")
        replace(textView, in: textView.textRange(location: 6, length: 2)!, with: ":cat:")

        #expect(textView.visualText == "he[a]der:cat:footer")
    }

    @Test("header🐈fo[o]ter -> header:cat:fo[o]ter")
    func replace9() async throws {
        let textView = makeTextView(text: "header🐈footer", selectedRange: NSRange(location: 10, length: 1))
        #expect(textView.visualText == "header🐈fo[o]ter")
        replace(textView, in: textView.textRange(location: 6, length: 2)!, with: ":cat:")

        #expect(textView.visualText == "header:cat:fo[o]ter")
    }

    @Test("head[er🐈]footer -> head[er:cat:]footer")
    func replace10() async throws {
        let textView = makeTextView(text: "header🐈footer", selectedRange: NSRange(location: 4, length: 4))
        #expect(textView.visualText == "head[er🐈]footer")
        replace(textView, in: textView.textRange(location: 6, length: 2)!, with: ":cat:")

        #expect(textView.visualText == "head[er:cat:]footer")
    }
}
