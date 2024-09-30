import RegexBuilder
import Testing
import UIKit

@testable import TextReplaceKit

@MainActor
@Suite
struct TextViewReplaceSelectionTests {

  @Test
  func keepingSelection() {
    let textView = UITextView()
    textView.text = "The Hello World !!"
    #expect(textView.visualText == "The Hello World !![]")

    let replaceText = "Hello"
    let withText = "👐"
    let replaceTextRange = textView.textRange(
      from: textView.position(from: textView.beginningOfDocument, offset: 4)!,
      to: textView.position(from: textView.beginningOfDocument, offset: 4 + replaceText.count)!
    )!
    #expect(!textView.contains(replaceTextRange, to: textView.selectedTextRange!.start))
    #expect(!textView.contains(replaceTextRange, to: textView.beginningOfDocument))

    textView.performEditingTransaction {
      textView.replace(replaceTextRange, withText: withText)
      return replaceTextRange
    }

    #expect(textView.visualText == "The 👐 World !![]")
  }

  @Test
  func keepingSelectionWithEmoji() {
    let textView = UITextView()
    textView.text = "👨‍👩‍👧‍👦he Hello World !!"
    #expect(textView.visualText == "👨‍👩‍👧‍👦he Hello World !![]")

    let offsetText = "👨‍👩‍👧‍👦he "
    let replaceText = "Hello"
    let withText = "👐"
    let replaceTextRange = textView.textRange(
      from: textView.position(from: textView.beginningOfDocument, offset: offsetText.utf16.count)!,
      to: textView.position(
        from: textView.beginningOfDocument, offset: offsetText.utf16.count + replaceText.utf16.count
      )!
    )!
    #expect(!textView.contains(replaceTextRange, to: textView.selectedTextRange!.start))
    #expect(!textView.contains(replaceTextRange, to: textView.beginningOfDocument))
    #expect(textView.visualText(replaceTextRange) == "👨‍👩‍👧‍👦he [Hello] World !!")

    textView.performEditingTransaction {
      textView.replace(replaceTextRange, withText: withText)
      return replaceTextRange
    }

    #expect(textView.visualText == "👨‍👩‍👧‍👦he 👐 World !![]")
  }

  @Test
  func keepingSelectionInText() {
    let textView = UITextView()
    textView.text = "The Hello World !!"
    #expect(textView.visualText == "The Hello World !![]")

    textView.selectedRange = NSRange(location: 6, length: 0)
    #expect(textView.visualText == "The He[]llo World !!")

    let replaceText = "Hello"
    let withText = "👐"
    let replaceTextRange = textView.textRange(
      from: textView.position(from: textView.beginningOfDocument, offset: 4)!,
      to: textView.position(from: textView.beginningOfDocument, offset: 4 + replaceText.count)!
    )!
    #expect(textView.contains(replaceTextRange, to: textView.selectedTextRange!.start))
    #expect(!textView.contains(replaceTextRange, to: textView.beginningOfDocument))

    textView.performEditingTransaction {
      textView.replace(replaceTextRange, withText: withText)
      return replaceTextRange
    }

    #expect(textView.visualText == "The 👐[] World !!")
  }

  @Test
  func keepingSelectionReplaceAfterSelection() {
    let textView = UITextView()
    textView.text = "The Hello World !!"
    #expect(textView.visualText == "The Hello World !![]")

    textView.selectedRange = NSRange(location: 0, length: 0)
    #expect(textView.visualText == "[]The Hello World !!")

    let replaceText = "Hello"
    let withText = "👐"
    let replaceTextRange = textView.textRange(
      from: textView.position(from: textView.beginningOfDocument, offset: 4)!,
      to: textView.position(from: textView.beginningOfDocument, offset: 4 + replaceText.count)!
    )!
    #expect(!textView.contains(replaceTextRange, to: textView.selectedTextRange!.start))
    #expect(!textView.contains(replaceTextRange, to: textView.beginningOfDocument))

    textView.performEditingTransaction {
      textView.replace(replaceTextRange, withText: withText)
      return replaceTextRange
    }

    #expect(textView.visualText == "[]The 👐 World !!")
  }

  @Test
  func testClosestPosition() {
    let textView = UITextView()
    textView.text = "The Hello World !!"
    textView.selectedRange = NSRange(location: 4, length: 5)
    #expect(textView.visualText == "The [Hello] World !!")

    let p1 = textView.closestPosition(
      to: textView.beginningOfDocument, within: textView.selectedTextRange!)
    textView.selectedTextRange = textView.textRange(from: p1, to: p1)
    #expect(textView.visualText == "The []Hello World !!")

    textView.selectedRange = NSRange(location: 4, length: 5)
    #expect(textView.visualText == "The [Hello] World !!")

    let p2 = textView.closestPosition(
      to: textView.endOfDocument, within: textView.selectedTextRange!)
    textView.selectedTextRange = textView.textRange(from: p2, to: p2)
    #expect(textView.visualText == "The Hello[] World !!")

    textView.selectedRange = NSRange(location: 4, length: 5)
    #expect(textView.visualText == "The [Hello] World !!")

    let inP = textView.position(from: textView.beginningOfDocument, offset: 6)!
    let p3 = textView.closestPosition(to: inP, within: textView.selectedTextRange!)
    textView.selectedTextRange = textView.textRange(from: p3, to: p3)
    #expect(textView.visualText == "The Hello[] World !!")
  }
}
