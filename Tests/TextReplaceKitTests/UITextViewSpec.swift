import Testing
import UIKit

@MainActor
@Suite
struct UITextViewSpecTests {
    @Test
    func attributesなしのAttributedStringをsetした後はfontが反映される() {
        let textView = UITextView()
        textView.font = UIFont.boldSystemFont(ofSize: 100)
        #expect(textView.font != nil)
        textView.attributedText = NSAttributedString(string: ":one: :two:")
        #expect(textView.font == nil)
    }
    
    @Test
    func attributes付きのAttributedStringをsetした後はfontが反映される() {
        let textView = UITextView()
        textView.font = UIFont.boldSystemFont(ofSize: 100)
        #expect(textView.font != nil)
        textView.attributedText = NSAttributedString(string: ":one: :two:", attributes: [.font : UIFont.boldSystemFont(ofSize: 50)])
        #expect(textView.font == UIFont.boldSystemFont(ofSize: 50))
    }
}
