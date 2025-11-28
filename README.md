# TextReplaceKit

iOS 向けのテキスト置換ユーティリティ群です。`UITextView` を拡張してショートコード・添付ファイル・パディング挿入を安全に扱えます。

## モジュール構成
- `TextReplaceKit`: エクスポート用エントリポイント。
- `ShortcodeReplace`: `:emoji:` 形式のショートコード検出と置換。
- `AttachmentReplace`: `NSTextAttachment` の置換。
- `PaddingInsert`: 先頭/末尾のスペース付与や追記。
- `Extensions`: 共有ユーティリティ。

## 主な API
### ショートコード置換 (UITextView)
```swift
textView.replaceShortcodes({ shortcode in
    switch shortcode.name {
    case "cat": NSAttributedString(attachment: TextAttachment("🐈"))
    default: nil
    }
}, granularity: .selectedLine)  // .document も可
```
デリゲート通知なしで置換したい場合は `replaceShortcodesSilently` を使います。

### 添付ファイル置換 (UITextView)
```swift
textView.replaceAttachments({ attachment in
    guard let attachment = attachment as? TextAttachment else { return nil }
    return NSAttributedString(string: ":cat:")
}, skipUnbrokenAttachments: true, granularity: .document)
```

### 選択範囲を保ったまま置換
```swift
textView.replacePreservingSelection(textRange, withText: "🐈")
```
互換の旧名 `replaceAndAdjustSelectedTextRange` も残していますが、新 API への移行を推奨します。

### ショートコード解析
```swift
let parser = ShortcodeChunkParser()
let chunk = parser.parse(" :cat: ")
chunk?.hasLeadingWhitespace  // true
chunk?.shortcode.name        // "cat"
```
旧名 `ShortcodeChunkDecoder.decode` は非推奨です。

## 開発・テスト
```bash
swift test
```
※ サンドボックス環境では SwiftPM がユーザーキャッシュへ書き込めず失敗する場合があります。その際はキャッシュ書き込み可能な環境で実行してください。

## 変更履歴のポイント
- メソッド/クラス名をより意図が伝わるものに改名し、既存名には非推奨エイリアスを残しました。
- テストをヘルパー化して可読性を向上させました。
