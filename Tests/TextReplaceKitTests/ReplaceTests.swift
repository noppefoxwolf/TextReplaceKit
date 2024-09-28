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
}

extension UITextView {
    
    
    func endOfPosition(_ range: UITextRange, to position: UITextPosition) -> UITextPosition {
        // 間にある時はrangeの最後かselectionの後ろの方をとる
        if contains(range, to: position) {
            switch compare(range.end, to: position) {
            case .orderedDescending:
                return range.end
            default:
                return position
            }
        } else {
            return position
        }
    }
    
    func apply(_ range: UITextRange, withAttributedText attributedText: NSAttributedString) {
        
        let beforeTextRange = selectedTextRange
        replace(range, withAttributedText: attributedText)
        let afterTextRange = selectedTextRange
        
        guard let beforeTextRange, let afterTextRange else { return }
        
        let replaceTrailing = endOfPosition(range, to: beforeTextRange.start)
        let offset = offset(from: range.end, to: replaceTrailing)
        let from = position(from: afterTextRange.start, offset: offset)
        let to = position(from: afterTextRange.end, offset: offset)
        guard let from, let to else { return }
        let fixedTextRange = textRange(from: from, to: to)
        if let fixedTextRange {
            selectedTextRange = fixedTextRange
        }
    }
    
    /// Replaces the text in a document that is in the specified range And fixs selection offset.
    /// - Parameters:
    ///   - range: A range of text in a document.
    ///   - text: A string to replace the text in range.
    func apply(_ range: UITextRange, withText text: String) {
        apply(range, withAttributedText: NSAttributedString(string: text))
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
