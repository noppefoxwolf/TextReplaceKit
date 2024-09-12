import Testing
@testable import ShortcodeReplacingKit
import UIKit
import RegexBuilder

@Test func replaceShortcode() async throws {
    var attributedString = AttributedString(":apple: 👨‍👩‍👦👨‍👩‍👦👨‍👩‍👦 :smile: :apple:")
    attributedString.replaceShortcode { shortcode in
        switch shortcode.name {
        case "apple": AttributedString("🍎")
        case "smile": AttributedString("😊")
        default: throw CancellationError()
        }
    }
    #expect(attributedString == "🍎 👨‍👩‍👦👨‍👩‍👦👨‍👩‍👦 😊 🍎")
}

