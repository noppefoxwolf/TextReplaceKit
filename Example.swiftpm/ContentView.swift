import SwiftUI
import TextReplaceKit

struct ContentView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        TextViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

final class TextViewController: UIViewController, UITextViewDelegate {
    let textView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.delegate = self
        textView.font = .preferredFont(forTextStyle: .body)
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: textView.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: textView.trailingAnchor),
        ])
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        textView.replaceShortcode(transform(_:), granularity: .selectedLine)
        return true
    }
    
    func transform(_ shortcode: AttributedString.Shortcode) -> AttributedString? {
        switch shortcode.name {
        case "fox":
            var attributedString = AttributedString("🦊")
            attributedString.font = textView.font
            return attributedString
        case "smile":
            var attributedString = AttributedString("😊")
            attributedString.font = textView.font
            return attributedString
        default:
            return nil
        }
    }
}
