import Testing
import UIKit

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

extension UITextView {
    func closestPosition(to position: UITextPosition, within range: UITextRange) -> UITextPosition {
        let lower = compare(range.start, to: position)
        let upper = compare(range.end, to: position)
        if upper == .orderedAscending || upper == .orderedSame {
            return range.end
        }
        if lower == .orderedDescending || lower == .orderedSame {
            return range.start
        }
        return range.end
    }
    
    func contains(_ range: UITextRange, to position: UITextPosition) -> Bool {
        switch compare(range.start, to: position) {
        case .orderedAscending, .orderedSame:
            switch compare(range.end, to: position) {
            case .orderedDescending, .orderedSame:
                return true
            default:
                return false
            }
        default:
            return false
        }
    }
}

extension UITextView {
    func apply(_ range: UITextRange, withAttributedText attributedText: NSAttributedString) {
        enum Anchor {
            case leading
            case trailing
        }
        
        let closestPosition = closestPosition(to: selectedTextRange!.start, within: range)
        let isRangeContainsPosition = contains(range, to: selectedTextRange!.start)
        let anchor = closestPosition == range.start ? Anchor.leading : Anchor.trailing
        
        let beforeTextRange = selectedTextRange
        replace(range, withAttributedText: attributedText)
        let afterTextRange = selectedTextRange
        
        guard let beforeTextRange, let afterTextRange else { return }
        
        switch anchor {
        case .leading:
            self.selectedTextRange = beforeTextRange
        case .trailing:
            let offset = offset(from: closestPosition, to: isRangeContainsPosition ? closestPosition : beforeTextRange.start)
            let from = position(from: afterTextRange.start, offset: offset)
            let to = position(from: afterTextRange.end, offset: offset)
            guard let from, let to else { return }
            let fixedTextRange = textRange(from: from, to: to)
            if let fixedTextRange {
                selectedTextRange = fixedTextRange
            }
        }
        
    }
    
    /// Replaces the text in a document that is in the specified range And fixs selection offset.
    /// - Parameters:
    ///   - range: A range of text in a document.
    ///   - text: A string to replace the text in range.
    func apply(_ range: UITextRange, withText text: String) {
        apply(range, withAttributedText: NSAttributedString(string: text))
    }
}
