import SwiftUI
import TextReplaceKit

struct ContentView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        UINavigationController(rootViewController: TextViewController())
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

        navigationController?.isToolbarHidden = false
        toolbarItems = [
            UIBarButtonItem(
                image: UIImage(systemName: "doc.on.clipboard.fill"),
                primaryAction: UIAction { [unowned self] _ in
                    textView.insertText(":fox: :fox::smile: :fox:")
                    textViewDidChange(textView)
                }
            )
        ]
    }

    func textViewDidChange(_ textView: UITextView) {
        textView.replaceShortcode(
            transform(_:),
            granularity: .selectedLine
        )
    }

    func transform(_ shortcode: Shortcode) -> AttributedString? {
        print(shortcode.rawValue)
        switch shortcode.name {
        case "fox":
            var attributedString = AttributedString("🦊")
            attributedString.font = textView.font
            attributedString.foregroundColor = textView.textColor
            return attributedString
        case "smile":
            var attributedString = AttributedString("😊")
            attributedString.font = textView.font
            attributedString.foregroundColor = textView.textColor
            return attributedString
        default:
            return nil
        }
    }
}
