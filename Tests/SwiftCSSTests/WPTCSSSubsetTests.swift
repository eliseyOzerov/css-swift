import Testing
import SwiftCSS

@Test func wptCSSSyntaxDeclarationsTrimWhitespaceSubset() throws {
    // Upstream: web-platform-tests/css/css-syntax/declarations-trim-whitespace.html
    // Help link: https://drafts.csswg.org/css-syntax/#consume-declaration
    let sheet = try CSSStyleSheet(stylesheet: """
    #foo {
      --foo-1:bar;
      --foo-2: bar;
      --foo-3:bar ;
      --foo-4: bar ;
      --foo-5: bar !important;
      --foo-6: bar !important ;
      --foo-7:bar!important;
      --foo-8:bar!important ;
      --foo-9:bar
    }
    """)

    #expect(sheet.rules.count == 1)
    let declarations = sheet.rules[0].style.declarations
    #expect(declarations.map(\.name.rawValue) == [
        "--foo-1",
        "--foo-2",
        "--foo-3",
        "--foo-4",
        "--foo-5",
        "--foo-6",
        "--foo-7",
        "--foo-8",
        "--foo-9",
    ])
    #expect(declarations.map(\.value.rawValue) == Array(repeating: "bar", count: 9))
    #expect(declarations.map(\.important) == [
        false,
        false,
        false,
        false,
        true,
        true,
        true,
        true,
        false,
    ])
}

@Test func wptCSSOMImportantDeclarationSerializationSubset() throws {
    // Upstream: web-platform-tests/css/cssom/serialization-CSSDeclaration-with-important.html
    // Help link: https://drafts.csswg.org/cssom/#serialize-a-css-declaration
    let noWhitespace = try CSSDeclarationBlock(styleAttribute: "display: inline!important;")
    let whitespace = try CSSDeclarationBlock(styleAttribute: "background-color: blue !important; color: red ! important;")

    #expect(CSSSerializer().serialize(noWhitespace) == "display: inline !important")
    #expect(CSSSerializer().serialize(whitespace) == "background-color: blue !important; color: red !important")
}

@Test func wptCSSVariablesCustomPropertyNamesAreCaseSensitiveSubset() throws {
    // Upstream: web-platform-tests/css/css-variables/css-vars-custom-property-case-sensitive-001.html
    // Help link: https://www.w3.org/TR/css-variables-1/#defining-variables
    let block = try CSSDeclarationBlock(styleAttribute: "--Foo: RED; --foo: blue; color: Var(--Foo);")

    #expect(block.declarations.map(\.name.rawValue) == ["--Foo", "--foo", "color"])
    #expect(block.declarations.map(\.value.rawValue) == ["RED", "blue", "Var(--Foo)"])
    #expect(CSSSerializer().serialize(block) == "--Foo: RED; --foo: blue; color: Var(--Foo)")
}
