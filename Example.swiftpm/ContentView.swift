import SwiftUI
import TextReplaceKit
import AttachmentReplace

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
            ),
            UIBarButtonItem(
                image: UIImage(systemName: "abc"),
                primaryAction: UIAction { [unowned self] _ in
                    let textRange = textView.textRange(from: textView.beginningOfDocument, to: textView.endOfDocument)!
                    textView.replaceAttachment(in: textRange) { textAttachment in
                        let textAttachment = textAttachment as! TextAttachment
                        switch textAttachment.emoji {
                        case "🦊":
                            return NSAttributedString(string: "fox")
                        case "😊":
                            return NSAttributedString(string: "smile")
                        default:
                            return nil
                        }
                    }
                }
            ),
            UIBarButtonItem(
                image: UIImage(systemName: "abc"),
                primaryAction: UIAction { [unowned self] _ in
                    textView.setMarkedText("こんにち", selectedRange: NSRange(location: 0, length: 4))
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

    func transform(_ shortcode: Shortcode) -> NSAttributedString? {
        print(shortcode.rawValue)
        switch shortcode.name {
        case "fox":
            return NSAttributedString(attachment: TextAttachment("🦊"))
        case "smile":
            return NSAttributedString(attachment: TextAttachment("😊"))
        default:
            return nil
        }
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
