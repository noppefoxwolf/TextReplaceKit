# TextReplaceKit

Utility extensions for `UITextView` that safely handle shortcode replacement, text attachments, and padding insertion on iOS. Written in Swift 6 for iOS 18+.

## Features
- Replace `:shortcode:` tokens with attributed content.
- Replace `NSTextAttachment` instances with attributed text (optionally skipping already padded attachments).
- Insert text with automatic leading/trailing padding.
- Selection-preserving replacements to keep cursor and ranges stable.
- Small, modular targets so you only import what you need.

## Module Overview
- **TextReplaceKit**: Export entry point that re-exports the modules below.
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
### Replace shortcodes in a text view
```swift
textView.replaceShortcodes({ shortcode in
    switch shortcode.name {
    case "cat": return NSAttributedString(attachment: TextAttachment("🐈"))
    default: return nil
    }
}, granularity: .selectedLine) // or .document
```
Use `replaceShortcodesSilently` to skip delegate callbacks.

### Replace attachments in a text view
```swift
textView.replaceAttachments({ attachment in
    guard let attachment = attachment as? TextAttachment else { return nil }
    return NSAttributedString(string: ":cat:")
}, skipUnbrokenAttachments: true, granularity: .document)
```

### Preserve selection while replacing
```swift
textView.replacePreservingSelection(textRange, withText: "🐈")
```
Legacy name `replaceAndAdjustSelectedTextRange` is kept as a deprecated alias.

### Parse a shortcode token
```swift
let parser = ShortcodeChunkParser()
if let chunk = parser.parse(" :cat: ") {
    chunk.hasLeadingWhitespace  // true
    chunk.hasTrailingWhitespace // true
    chunk.shortcode.name        // "cat"
}
```
Deprecated aliases: `ShortcodeChunkDecoder` and `decode(_:)`.

## Requirements
- iOS 18+
- Swift 6

## Testing
```bash
swift test
```
If you are running in a restricted/sandboxed environment, SwiftPM may fail to write its caches. Run tests in an environment that allows writing to user caches.

## Contributing
Issues and pull requests are welcome. Please keep changes small and include tests where possible.

## License
Specify your preferred OSS license in a `LICENSE` file (e.g., MIT). Until then, the project should be treated as “All rights reserved.”
