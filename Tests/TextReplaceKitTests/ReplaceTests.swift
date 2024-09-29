import Testing
import UIKit
@testable import TextReplaceKit
import RegexBuilder

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
        
        textView.apply(replaceTextRange, withText: withText)
        
        #expect(textView.visualText == "The 👐 World !![]")
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
        
        textView.apply(replaceTextRange, withText: withText)
        
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
        
        textView.apply(replaceTextRange, withText: withText)
        
        #expect(textView.visualText == "[]The 👐 World !!")
    }
    
    @Test
    func testClosestPosition() {
        let textView = UITextView()
        textView.text = "The Hello World !!"
        textView.selectedRange = NSRange(location: 4, length: 5)
        #expect(textView.visualText == "The [Hello] World !!")
        
        let p1 = textView.closestPosition(to: textView.beginningOfDocument, within: textView.selectedTextRange!)
        textView.selectedTextRange = textView.textRange(from: p1, to: p1)
        #expect(textView.visualText == "The []Hello World !!")
        
        textView.selectedRange = NSRange(location: 4, length: 5)
        #expect(textView.visualText == "The [Hello] World !!")
        
        let p2 = textView.closestPosition(to: textView.endOfDocument, within: textView.selectedTextRange!)
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

