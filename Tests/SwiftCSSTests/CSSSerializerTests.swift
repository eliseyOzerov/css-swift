import Testing
import SwiftCSS

@Test func serializesDeclarationBlocks() {
    let block: CSSDeclarationBlock = [
        CSSDeclaration(.display, "flex"),
        CSSDeclaration(.gap, .px(12)),
        CSSDeclaration(.color, .hex("ff00aa")),
    ]

    #expect(CSSSerializer().serialize(block) == "display: flex; gap: 12px; color: #ff00aa")
}

@Test func replacingDeclarationKeepsLatestValue() {
    var block = CSSDeclarationBlock()
    block.set(.display, "block")
    block.set(.display, "grid", important: true)

    #expect(CSSSerializer().serialize(block) == "display: grid !important")
}

@Test func serializesImportantDeclarations() {
    let block: CSSDeclarationBlock = [
        CSSDeclaration(.color, .rgb(26, 115, 232), important: true),
        CSSDeclaration(.backgroundColor, .hex("ffffff")),
    ]

    #expect(CSSSerializer().serialize(block) == "color: rgb(26 115 232) !important; background-color: #ffffff")
}

@Test func cssValuePresetsCoverRawAndUnitlessNumbers() {
    let block: CSSDeclarationBlock = [
        CSSDeclaration(.lineHeight, .num(1.25)),
        CSSDeclaration(.fontWeight, .num(700)),
        CSSDeclaration(.font, .raw(#"16px/1.5 "SF Pro Text", sans-serif"#)),
    ]

    #expect(CSSSerializer().serialize(block) == #"line-height: 1.25; font-weight: 700; font: 16px/1.5 "SF Pro Text", sans-serif"#)
}

@Test func cssValuesAcceptRawStringAndNumberLiterals() {
    let block: CSSDeclarationBlock = [
        .lineHeight(1.25),
        .fontWeight(700),
        .font(#"16px/1.5 "SF Pro Text", sans-serif"#),
        .customProperty("dot-editing", true),
        .margin(.horizontal(.auto)),
    ]

    #expect(CSSSerializer().serialize(block) == #"line-height: 1.25; font-weight: 700; font: 16px/1.5 "SF Pro Text", sans-serif; --dot-editing: true; margin: 0 auto"#)
}

@Test func typedCSSValuesCoverKeywordsBoxesAndBorders() {
    let sheet: CSSStyleSheet = [
        .class("card") {
            .margin(.horizontal(.auto));
            .padding(.ltrb(left: .rem(1.5), top: .rem(1), right: .rem(1.5), bottom: .zero));
            .border(.solid(.px(1), .hex("cfd7e6")));
            .outline(.none);
        },
    ]

    #expect(CSSSerializer().serialize(sheet) == ".card { margin: 0 auto; padding: 1rem 1.5rem 0 1.5rem; border: 1px solid #cfd7e6; outline: none }")
}

@Test func cssBoxValuesSerializeEdgeInsetPresets() {
    let block: CSSDeclarationBlock = [
        .padding(.all(.rem(1))),
        .margin(.vertical(top: .px(4), bottom: .px(8))),
        .padding(.horizontal(left: .px(12), right: .px(16))),
        .margin(.symmetric(vertical: .rem(1), horizontal: .auto)),
        .padding(.ltrb(left: .px(1), top: .px(2), right: .px(3), bottom: .px(4))),
    ]

    #expect(CSSSerializer().serialize(block) == "padding: 1rem; margin: 4px 0 8px 0; padding: 0 16px 0 12px; margin: 1rem auto; padding: 2px 3px 4px 1px")
}

@Test func parsesDeclarationBlocksWithCommonValueForms() throws {
    let block = try CSSDeclarationBlock(styleAttribute: """
    width: 50%; margin: 1em 2rem; color: rgb(10 20 30 / 0.5); transform: translateX(calc(100% - 2em)); background-image: url("a;b.png");
    """)

    #expect(block.declarations.map(\.name.rawValue) == [
        "width",
        "margin",
        "color",
        "transform",
        "background-image",
    ])
    #expect(block.declarations.map(\.value.rawValue) == [
        "50%",
        "1em 2rem",
        "rgb(10 20 30 / 0.5)",
        "translateX(calc(100% - 2em))",
        "url(\"a;b.png\")",
    ])
}

@Test func parsesDeclarationCommentsAndImportantPriority() throws {
    let block = try CSSDeclarationBlock(styleAttribute: """
    /* leading */ color: rgb(26 115 232) ! important; content: "/* literal */"; margin: calc(100% - 2em) /* between */ !IMPORTANT;
    """)

    #expect(block.declarations.map(\.name.rawValue) == ["color", "content", "margin"])
    #expect(block.declarations.map(\.value.rawValue) == ["rgb(26 115 232)", "\"/* literal */\"", "calc(100% - 2em)"])
    #expect(block.declarations.map(\.important) == [true, false, true])
    #expect(CSSSerializer().serialize(block) == "color: rgb(26 115 232) !important; content: \"/* literal */\"; margin: calc(100% - 2em) !important")
}

@Test func serializesSimpleStyleSheets() {
    let sheet: CSSStyleSheet = [
        CSSStyleRule(".card", style: [
            CSSDeclaration(.display, "grid"),
            CSSDeclaration(.gap, .em(1.5)),
        ]),
        CSSStyleRule("[data-state=\"active\"] > .badge", style: [
            CSSDeclaration(.color, .rgb(10, 20, 30)),
        ]),
    ]

    #expect(CSSSerializer().serialize(sheet) == ".card { display: grid; gap: 1.5em }\n[data-state=\"active\"] > .badge { color: rgb(10 20 30) }")
}

@Test func parsesSimpleStyleSheets() throws {
    let sheet = try CSSStyleSheet(stylesheet: """
    /* top level */
    .card, main > section {
      width: clamp(12rem, 80%, 960px);
      color: rgb(26 115 232);
    }
    [data-value="a{b}"] /* selector comment */ ::before {
      content: "x;y";
      color: white !important;
    }
    """)

    #expect(sheet.rules.count == 2)
    #expect(sheet.rules[0].selectorText == ".card, main > section")
    #expect(sheet.rules[0].style.declarations.map(\.name.rawValue) == ["width", "color"])
    #expect(sheet.rules[0].style.declarations.map(\.value.rawValue) == ["clamp(12rem, 80%, 960px)", "rgb(26 115 232)"])
    #expect(sheet.rules[1].selectorText == "[data-value=\"a{b}\"]   ::before")
    #expect(sheet.rules[1].style.declarations.map(\.name.rawValue) == ["content", "color"])
    #expect(sheet.rules[1].style.declarations.map(\.value.rawValue) == ["\"x;y\"", "white"])
    #expect(sheet.rules[1].style.declarations.map(\.important) == [false, true])
    #expect(CSSSerializer().serialize(sheet) == ".card, main > section { width: clamp(12rem, 80%, 960px); color: rgb(26 115 232) }\n[data-value=\"a{b}\"]   ::before { content: \"x;y\"; color: white !important }")
}

@Test func cssSelectorConveniencesSerializeOfficialSelectorConcepts() {
    let compoundAndComplex = CSSSelector
        .element("button")
        .id("save")
        .className("primary")
        .attribute("data-state", equals: "selected", modifier: .caseInsensitive)
        .pseudoClass(.hover)
        .child(.element("span").pseudoElement(.before))

    #expect(compoundAndComplex.rawValue == "button#save.primary[data-state=\"selected\" i]:hover > span::before")

    let selectorList = CSSSelector.list(
        .className("card"),
        .element("main").child(.element("section")),
        .attribute("data-value", .substring, "a\"b").descendant(.element("a").pseudoClass(.focusVisible))
    )

    #expect(selectorList.rawValue == ".card, main > section, [data-value*=\"a\\\"b\"] a:focus-visible")

    let functionalPseudoClasses = CSSSelector
        .element("article")
        .pseudoClass(.has("> img"))
        .pseudoClass(.not(.className("disabled")))

    #expect(functionalPseudoClasses.rawValue == "article:has(> img):not(.disabled)")

    let sheet: CSSStyleSheet = [
        CSSStyleRule(compoundAndComplex, style: [
            CSSDeclaration(.color, .rgb(26, 115, 232)),
        ]),
        CSSStyleRule(selectorList, style: [
            CSSDeclaration(.display, "grid"),
        ]),
    ]

    #expect(CSSSerializer().serialize(sheet) == "button#save.primary[data-state=\"selected\" i]:hover > span::before { color: rgb(26 115 232) }\n.card, main > section, [data-value*=\"a\\\"b\"] a:focus-visible { display: grid }")
}

@Test func cssBuilderDSLSerializesStyleSheets() {
    let sheet: CSSStyleSheet = [
        .root {
            .colorScheme("light dark");
            .customProperty("dot-accent", "#1f7ae0");
        },
        .class("card") {
            .display("grid");
            .fontSize(.rem(1.2));
        },
        .id("save") {
            .color(.variable("dot-accent"));
        },
    ]

    #expect(CSSSerializer().serialize(sheet) == ":root { color-scheme: light dark; --dot-accent: #1f7ae0 }\n.card { display: grid; font-size: 1.2rem }\n#save { color: var(--dot-accent) }")
}

@Test func cssDeclarationGroupHelpersExpandToFlatProperties() throws {
    let declarations =
        CSSDeclarations.margin(top: .px(8), inline: .rem(1), blockEnd: .em(2)) +
        CSSDeclarations.padding(left: .ch(3), block: .px(12)) +
        CSSDeclarations.inset(top: .px(0), inlineEnd: .percent(10)) +
        CSSDeclarations.scrollMargin(blockStart: .px(24)) +
        CSSDeclarations.border(width: .px(1), style: "solid", color: .hex("cfd7e6")) +
        CSSDeclarations.prefixed("scroll-padding", [("inline", .rem(2))])

    let block = CSSDeclarationBlock(declarations)

    #expect(CSSSerializer().serialize(block) == "margin-inline: 1rem; margin-top: 8px; margin-block-end: 2em; padding-block: 12px; padding-left: 3ch; inset-top: 0px; inset-inline-end: 10%; scroll-margin-block-start: 24px; border-width: 1px; border-style: solid; border-color: #cfd7e6; scroll-padding-inline: 2rem")

    let parsed = try CSSDeclarationBlock(styleAttribute: CSSSerializer().serialize(block))
    #expect(parsed == block)
}

@Test func rejectsUnsupportedAtRulesInSimpleStyleSheets() throws {
    #expect(throws: CSSParseError.unsupportedAtRule("@media screen")) {
        try CSSStyleSheet(stylesheet: "@media screen { .card { display: grid } }")
    }
}

@Test func knownCSSPropertyInventoryIncludesGeneratedPropertiesAndCustomProperties() {
    #expect(CSSKnownProperties.all.count >= 700)
    #expect(CSSKnownProperties.contains("accent-color"))
    #expect(CSSKnownProperties.contains("animation-range-start"))
    #expect(CSSKnownProperties.contains("view-transition-name"))
    #expect(CSSKnownProperties.contains("--dot-accent"))
}

@Test func parsesEveryKnownCSSPropertyName() throws {
    for property in CSSKnownProperties.all.map(\.rawValue).sorted() where property != "--*" {
        let block = try CSSDeclarationBlock(styleAttribute: "\(property): 1px")

        #expect(block.declarations.count == 1)
        #expect(block.declarations[0].name.rawValue == property)
        #expect(block.declarations[0].value.rawValue == "1px")
        #expect(CSSSerializer().serialize(block) == "\(property): 1px")
    }

    let custom = try CSSDeclarationBlock(styleAttribute: "--dot-accent: rgb(10 20 30)")
    #expect(custom.declarations[0].name.rawValue == "--dot-accent")
}

@Test func cssDeclarationNameStaticConveniencesCoverKnownPropertyInventory() {
    #expect(CSSDeclarationName.accentColor.rawValue == "accent-color")
    #expect(CSSDeclarationName.viewTransitionName.rawValue == "view-transition-name")
    #expect(CSSDeclarationName.webkitLineClamp.rawValue == "-webkit-line-clamp")

    for property in CSSKnownProperties.all.map(\.rawValue).sorted() where property != "--*" {
        let memberName = swiftCSSMemberName(for: property)
        #expect(CSSDeclarationName(cssPropertyCamelCase: memberName).rawValue == property)
    }
}

@Test func cssValueConveniencesCoverCommonUnitsAndFunctions() {
    let block: CSSDeclarationBlock = [
        CSSDeclaration(.width, .percent(50)),
        CSSDeclaration(.fontSize, .em(1.25)),
        CSSDeclaration(.color, .rgb(10, 20, 30)),
        CSSDeclaration(.backgroundColor, .hsl(210, 50, 40)),
        CSSDeclaration(.gap, .calc("100% - 2em")),
    ]

    #expect(CSSSerializer().serialize(block) == "width: 50%; font-size: 1.25em; color: rgb(10 20 30); background-color: hsl(210deg 50% 40%); gap: calc(100% - 2em)")
}

@Test func cssValueConveniencesCoverAdditionalUnitsAndFunctions() {
    let block: CSSDeclarationBlock = [
        CSSDeclaration(.width, .clamp(.rem(12), .vw(50), .px(960))),
        CSSDeclaration(.height, .min(.vh(80), .px(720))),
        CSSDeclaration(.gap, .minmax(.ch(12), .fr(1))),
        CSSDeclaration("rotate", .turn(0.5)),
        CSSDeclaration("resolution", .dppx(2)),
        CSSDeclaration("color", .colorFunction("color", ["display-p3", .number(1), .number(0.5), .number(0)])),
    ]

    #expect(CSSSerializer().serialize(block) == "width: clamp(12rem, 50vw, 960px); height: min(80vh, 720px); gap: minmax(12ch, 1fr); rotate: 0.5turn; resolution: 2dppx; color: color(display-p3 1 0.5 0)")
}

@Test func cssValueConveniencesCoverModernLengthAndResolutionUnits() {
    let block: CSSDeclarationBlock = [
        CSSDeclaration("font-size", .max(.cap(1), .ic(1.5), .rcap(2), .ric(2.5))),
        CSSDeclaration("inline-size", .clamp(.vi(10), .dvi(20), .lvi(30))),
        CSSDeclaration("block-size", .min(.vb(10), .svb(20), .dvb(30))),
        CSSDeclaration("width", .max(.svw(20), .lvw(30), .dvw(40), .svmin(10), .lvmax(50))),
        CSSDeclaration("height", .min(.svh(20), .lvh(30), .dvh(40), .dvmin(10), .dvmax(50))),
        CSSDeclaration("margin", .max(.cqw(10), .cqh(11), .cqi(12), .cqb(13), .cqmin(14), .cqmax(15))),
        CSSDeclaration("image-resolution", .x(2)),
        CSSDeclaration("resolution", .dpcm(38)),
    ]

    #expect(CSSSerializer().serialize(block) == "font-size: max(1cap, 1.5ic, 2rcap, 2.5ric); inline-size: clamp(10vi, 20dvi, 30lvi); block-size: min(10vb, 20svb, 30dvb); width: max(20svw, 30lvw, 40dvw, 10svmin, 50lvmax); height: min(20svh, 30lvh, 40dvh, 10dvmin, 50dvmax); margin: max(10cqw, 11cqh, 12cqi, 13cqb, 14cqmin, 15cqmax); image-resolution: 2x; resolution: 38dpcm")
}

@Test func cssValueConveniencesCoverLegacyCommaFunctionsAndGenericFunctions() throws {
    let block: CSSDeclarationBlock = [
        CSSDeclaration(.backgroundColor, .rgbComma(26, 115, 232)),
        CSSDeclaration(.color, .rgbaComma(255, 255, 255, 0.92)),
        CSSDeclaration(.borderColor, .hslComma(210, 80, 45)),
        CSSDeclaration(.outlineColor, .hslaComma(210, 80, 45, 0.5)),
        CSSDeclaration(.filter, .function("drop-shadow", "0 2px 4px rgba(0, 0, 0, 0.35)")),
        CSSDeclaration(.backgroundImage, .function("linear-gradient", "90deg, rgb(10, 20, 30), hsl(210, 50%, 40%)")),
    ]

    #expect(CSSSerializer().serialize(block) == "background-color: rgb(26, 115, 232); color: rgba(255, 255, 255, 0.92); border-color: hsl(210, 80%, 45%); outline-color: hsla(210, 80%, 45%, 0.5); filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.35)); background-image: linear-gradient(90deg, rgb(10, 20, 30), hsl(210, 50%, 40%))")

    let parsed = try CSSDeclarationBlock(styleAttribute: CSSSerializer().serialize(block))
    #expect(parsed == block)
}

private func swiftCSSMemberName(for property: String) -> String {
    let trimmed = property.trimmingPrefix("-")
    let parts = trimmed.split(separator: "-").map(String.init)
    guard let first = parts.first else {
        return "property"
    }
    return first + parts.dropFirst().map { part in
        guard let firstCharacter = part.first else {
            return ""
        }
        return firstCharacter.uppercased() + String(part.dropFirst())
    }.joined()
}

private extension String {
    func trimmingPrefix(_ prefix: Character) -> String {
        var value = self
        while value.first == prefix {
            value.removeFirst()
        }
        return value
    }
}
