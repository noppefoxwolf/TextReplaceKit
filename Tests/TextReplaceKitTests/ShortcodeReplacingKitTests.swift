import Testing
@testable import TextReplaceKit
import UIKit
import RegexBuilder

@Test func replaceShortcode() async throws {
    var attributedString = AttributedString(":apple: 👨‍👩‍👦 Hello 👨‍👩‍👦👨‍👩‍👦 :smile: :apple:")
    attributedString.replaceShortcode { shortcode in
        switch shortcode.name {
        case "apple": AttributedString("🍎")
        case "smile": AttributedString("😊")
        default: nil
        }
    }
    #expect(attributedString == "🍎 👨‍👩‍👦 Hello 👨‍👩‍👦👨‍👩‍👦 😊 🍎")
}

@Test func replaceEmpty() async throws {
    var attributedString = AttributedString("")
    attributedString.replaceShortcode { shortcode in
        switch shortcode.name {
        case "apple": AttributedString("🍎")
        case "smile": AttributedString("😊")
        default: nil
        }
    }
    #expect(attributedString == "")
}

@Test func replaceSingle() async throws {
    var attributedString = AttributedString(":apple:")
    attributedString.replaceShortcode { shortcode in
        switch shortcode.name {
        case "apple": AttributedString("🍎")
        case "smile": AttributedString("😊")
        default: nil
        }
    }
    #expect(attributedString == "🍎")
}

