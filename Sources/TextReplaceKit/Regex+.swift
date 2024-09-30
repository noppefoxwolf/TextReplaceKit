import RegexBuilder

extension Regex where Self.RegexOutput == (Substring, Substring, Substring) {
  static var shortcodeWithPadding: Regex<(Substring, Substring, Substring)> {
    Regex {
      Capture {
        ChoiceOf {
          /^/
          One(.whitespace)
        }
      }
      ":"
      Capture {
        OneOrMore {
          CharacterClass(
            .anyOf("_"),
            ("a"..."z"),
            ("A"..."Z"),
            ("0"..."9")
          )
        }
      }
      ":"
      NegativeLookahead {
        One(.whitespace.inverted)
      }
    }
  }
}
