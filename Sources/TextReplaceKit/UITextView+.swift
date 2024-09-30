import UIKit

extension UITextView {
  public enum Granularity {
    case selectedLine
    case document
  }

  public typealias ShortcodeTransform = (Shortcode) -> NSAttributedString?

  public func replaceShortcode(
    _ transform: ShortcodeTransform,
    granularity: Granularity
  ) {
    switch granularity {
    case .selectedLine:
      replaceShortcodeLine(transform: transform, at: selectedTextRange?.start ?? endOfDocument)
    case .document:
      replaceShortcodeWholeDocument(transform: transform)
    }
  }

  func replaceShortcodeLine(transform: ShortcodeTransform, at posision: UITextPosition) {
    let lineRangeStart = tokenizer.position(
      from: posision,
      toBoundary: .line,
      inDirection: .layout(.left)
    )
    let lineRangeEnd = tokenizer.position(
      from: posision,
      toBoundary: .line,
      inDirection: .layout(.right)
    )
    guard let lineRangeStart, let lineRangeEnd else { return }
    let selectedLineRange = textRange(from: lineRangeStart, to: lineRangeEnd)
    guard let selectedLineRange else { return }
    replaceShortcode(in: selectedLineRange, transform: transform)
  }

  func replaceShortcodeWholeDocument(transform: ShortcodeTransform) {
    let documentRange = textRange(from: beginningOfDocument, to: endOfDocument)
    guard let documentRange else { return }
    replaceShortcode(in: documentRange, transform: transform)
  }

  func replaceShortcode(in range: UITextRange, transform: ShortcodeTransform) {
    attributedText(in: range).enumerateShortcodes(
      transform: transform,
      using: { replaceAttributedString, nsRange, _ in
        let start = position(
          from: range.start,
          offset: nsRange.location
        )
        let end = position(
          from: range.start,
          offset: nsRange.location + nsRange.length
        )
        guard let start, let end else { return }
        let textRange = textRange(from: start, to: end)
        if let textRange {
          performEditingTransaction {
            workaround.replace(textRange, withAttributedText: replaceAttributedString)
            return textRange
          }
        }
      }
    )
  }
}

extension UITextView {
  func closestPosition(to position: UITextPosition, within range: UITextRange) -> UITextPosition {
    let lower = compare(range.start, to: position)
    let upper = compare(range.end, to: position)
    if upper == .orderedAscending || upper == .orderedSame {
      return range.end
    }
    if lower == .orderedDescending || lower == .orderedSame {
      return range.start
    }
    return range.end
  }

  func contains(_ range: UITextRange, to position: UITextPosition) -> Bool {
    switch compare(range.start, to: position) {
    case .orderedAscending, .orderedSame:
      switch compare(range.end, to: position) {
      case .orderedDescending, .orderedSame:
        return true
      default:
        return false
      }
    default:
      return false
    }
  }
}

extension UITextView {
  func performEditingTransaction(_ transaction: () -> UITextRange) {
    enum Anchor: Sendable {
      case leading
      case trailing
    }

    let beforeTextRange = selectedTextRange
    let changedRange = transaction()
    let afterTextRange = selectedTextRange

    guard let beforeTextRange, let afterTextRange else { return }

    let closestPosition = closestPosition(to: beforeTextRange.start, within: changedRange)
    let isRangeContainsPosition = contains(changedRange, to: beforeTextRange.start)
    let anchor = closestPosition == changedRange.start ? Anchor.leading : Anchor.trailing
    switch anchor {
    case .leading:
      self.selectedTextRange = beforeTextRange
    case .trailing:
      let offset = offset(
        from: closestPosition, to: isRangeContainsPosition ? closestPosition : beforeTextRange.start
      )
      let from = position(from: afterTextRange.start, offset: offset)
      let to = position(from: afterTextRange.end, offset: offset)
      guard let from, let to else { return }
      let fixedTextRange = textRange(from: from, to: to)
      if let fixedTextRange {
        selectedTextRange = fixedTextRange
      }
    }
  }
}
