import Testing
import RegexBuilder

@Suite
struct RegexSpec {
    @Test
    func regex() {
        let regex = Regex {
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
        
        let text1 = ":foo:"
        #expect(text1.matches(of: regex).count == 1)
        let text2 = ":foo::foo:"
        #expect(text2.matches(of: regex).count == 0)
        let text3 = ":foo: :foo:"
        #expect(text3.matches(of: regex).count == 2)
    }
}



