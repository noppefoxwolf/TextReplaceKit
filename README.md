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
}, granularity: .selectedLine) // or .document
```
Use `replaceShortcodesSilently(_:granularity:)` to skip `UITextViewDelegate.textViewDidChange(_:)` callbacks.

### Replace attachments in a text view
```swift
textView.replaceAttachments({ attachment in
    guard let attachment = attachment as? TextAttachment else { return nil }
    return NSAttributedString(string: ":cat:")
}, skipUnbrokenAttachments: true, granularity: .document)
```
Use `replaceAttachmentsSilently(_:skipUnbrokenAttachments:granularity:)` to skip `UITextViewDelegate.textViewDidChange(_:)` callbacks.

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
- Swift tools 6.3+

## Testing
```bash
swift test
```
If you are running in a restricted/sandboxed environment, SwiftPM may fail to write its caches. Run tests in an environment that allows writing to user caches.

## Contributing
Issues and pull requests are welcome. Please keep changes small and include tests where possible.

## License
Specify your preferred OSS license in a `LICENSE` file (e.g., MIT). Until then, the project should be treated as “All rights reserved.”
