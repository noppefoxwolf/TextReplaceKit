# TextReplaceKit

Utility extensions for `UITextView` that handle shortcode replacement, text attachments, and padding insertion on iOS.

## Features
- Replace `:shortcode:` tokens with attributed content.
- Replace `NSTextAttachment` instances with attributed text (optionally skipping already padded attachments).
- Insert text with automatic leading/trailing padding.
- Replacements preserve the current selection where possible.
- `TextReplaceKit` re-exports the implementation modules.

## Module Overview
- **TextReplaceKit**: Public entry point that re-exports the modules below.
- **ShortcodeReplace**: Detects and replaces `:emoji:`-style shortcodes.
- **AttachmentReplace**: Transforms `NSTextAttachment` into attributed text.
- **PaddingInsert**: Inserts or appends text while managing whitespace.
- **Extensions**: Shared helpers (`NSRange`, `NSAttributedString`, `UITextView`, etc.).

## Installation (Swift Package Manager)
Add to your `Package.swift`:
```swift
.package(url: "https://github.com/noppefoxwolf/TextReplaceKit.git", from: "1.0.0"),
```
And include the products you need, e.g.:
```swift
.product(name: "TextReplaceKit", package: "TextReplaceKit")
```

## Usage
Import the package entry point:
```swift
import TextReplaceKit
```

### Replace shortcodes in a text view
```swift
textView.replaceShortcodes({ shortcode in
    switch shortcode.name {
    case "cat": return NSAttributedString(attachment: TextAttachment("🐈"))
    default: return nil
    }
}, textRange: textView.selectedTextRange!)
```
Use `replaceShortcodesSilently(_:textRange:)` to skip `UITextViewDelegate.textViewDidChange(_:)` callbacks.

### Replace attachments in a text view
```swift
textView.replaceAttachments({ attachment in
    guard let attachment = attachment as? TextAttachment else { return nil }
    return NSAttributedString(string: ":cat:")
}, skipUnbrokenAttachments: true, textRange: textView.selectedTextRange!)
```
Use `replaceAttachmentsSilently(_:skipUnbrokenAttachments:textRange:)` to skip `UITextViewDelegate.textViewDidChange(_:)` callbacks.

### Insert text with padding
```swift
textView.insertText("#apple", leadingPadding: true, trailingPadding: .insert)
textView.insertText("#", leadingPadding: true, trailingPadding: .addition)
```

- `leadingPadding: true` inserts a leading space when the insertion point is not already preceded by whitespace.
- `trailingPadding: .insert` inserts a trailing space as part of the replacement.
- `trailingPadding: .addition` adds a trailing space after the replacement when the following character is not already whitespace.

For plain insertion without padding options:
```swift
textView.insertText("hello")
textView.appendText(" world")
```

### Parse a shortcode token
```swift
let parser = ShortcodeChunkParser()
if let chunk = parser.parse(" :cat: ") {
    chunk.hasLeadingWhitespace  // true
    chunk.hasTrailingWhitespace // true
    chunk.shortcode.name        // "cat"
}
```

## Requirements
- iOS 18+
- Swift 6.3+

## Testing
This package depends on UIKit, so run tests with an iOS Simulator destination:
```bash
xcodebuild test -scheme TextReplaceKit -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.6'
```
If multiple simulators match the same name and OS, specify a simulator id instead:
```bash
xcodebuild test -scheme TextReplaceKit -destination 'id=634BDBF1-1FF3-489D-9AA6-97F303ED9B05'
```
Plain `swift test` builds for the macOS host and will fail because UIKit is unavailable there.

## Contributing
Issues and pull requests are welcome. Please keep changes small and include tests where possible.

## License
Specify your preferred OSS license in a `LICENSE` file (e.g., MIT). Until then, the project should be treated as “All rights reserved.”
