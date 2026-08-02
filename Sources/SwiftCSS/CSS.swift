/// The property or descriptor name of a CSS declaration.
///
/// `SwiftCSS` stores declaration names as authored strings and does not validate them
/// against any CSS property registry in the initial core.
public struct CSSDeclarationName: Hashable, Sendable, ExpressibleByStringLiteral {
    public var rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public init(cssPropertyCamelCase member: String) {
        self.init(Self.cssPropertyName(fromDynamicMember: member))
    }

    public init(stringLiteral value: String) {
        self.init(value)
    }
}

public extension CSSDeclarationName {
    static let backgroundColor: Self = "background-color"
    static let color: Self = "color"
    static let display: Self = "display"
    static let fontSize: Self = "font-size"
    static let gap: Self = "gap"
    static let height: Self = "height"
    static let margin: Self = "margin"
    static let padding: Self = "padding"
    static let width: Self = "width"

    fileprivate static func cssPropertyName(fromDynamicMember member: String) -> String {
        var output = ""
        for character in member {
            if character.isUppercase {
                output.append("-")
                output.append(character.lowercased())
            } else {
                output.append(character)
            }
        }

        if output.hasPrefix("webkit-") {
            return "-\(output)"
        }

        return output
    }
}

/// A serialized CSS declaration value.
///
/// Values are caller-provided CSS text. The initial core serializes declaration
/// lists and does not parse or normalize CSS component values.
public struct CSSValue: Hashable, Sendable, ExpressibleByStringLiteral {
    public var rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: String) {
        self.init(value)
    }
}

public extension CSSValue {
    static func number(_ value: Double) -> Self {
        Self(formatNumber(value))
    }

    static func px(_ value: Int) -> Self {
        Self("\(value)px")
    }

    static func px(_ value: Double) -> Self {
        Self("\(formatNumber(value))px")
    }

    static func em(_ value: Double) -> Self {
        Self("\(formatNumber(value))em")
    }

    static func rem(_ value: Double) -> Self {
        Self("\(formatNumber(value))rem")
    }

    static func percent(_ value: Double) -> Self {
        Self("\(formatNumber(value))%")
    }

    static func unit(_ value: Double, _ unit: String) -> Self {
        Self("\(formatNumber(value))\(unit)")
    }

    static func ch(_ value: Double) -> Self {
        unit(value, "ch")
    }

    static func cap(_ value: Double) -> Self {
        unit(value, "cap")
    }

    static func ex(_ value: Double) -> Self {
        unit(value, "ex")
    }

    static func ic(_ value: Double) -> Self {
        unit(value, "ic")
    }

    static func lh(_ value: Double) -> Self {
        unit(value, "lh")
    }

    static func rcap(_ value: Double) -> Self {
        unit(value, "rcap")
    }

    static func rch(_ value: Double) -> Self {
        unit(value, "rch")
    }

    static func rex(_ value: Double) -> Self {
        unit(value, "rex")
    }

    static func ric(_ value: Double) -> Self {
        unit(value, "ric")
    }

    static func rlh(_ value: Double) -> Self {
        unit(value, "rlh")
    }

    static func fr(_ value: Double) -> Self {
        unit(value, "fr")
    }

    static func cm(_ value: Double) -> Self {
        unit(value, "cm")
    }

    static func mm(_ value: Double) -> Self {
        unit(value, "mm")
    }

    static func q(_ value: Double) -> Self {
        unit(value, "Q")
    }

    static func inches(_ value: Double) -> Self {
        unit(value, "in")
    }

    static func pt(_ value: Double) -> Self {
        unit(value, "pt")
    }

    static func pc(_ value: Double) -> Self {
        unit(value, "pc")
    }

    static func vh(_ value: Double) -> Self {
        Self("\(formatNumber(value))vh")
    }

    static func vw(_ value: Double) -> Self {
        Self("\(formatNumber(value))vw")
    }

    static func vi(_ value: Double) -> Self {
        unit(value, "vi")
    }

    static func vb(_ value: Double) -> Self {
        unit(value, "vb")
    }

    static func svw(_ value: Double) -> Self {
        unit(value, "svw")
    }

    static func svh(_ value: Double) -> Self {
        unit(value, "svh")
    }

    static func svi(_ value: Double) -> Self {
        unit(value, "svi")
    }

    static func svb(_ value: Double) -> Self {
        unit(value, "svb")
    }

    static func svmin(_ value: Double) -> Self {
        unit(value, "svmin")
    }

    static func svmax(_ value: Double) -> Self {
        unit(value, "svmax")
    }

    static func lvw(_ value: Double) -> Self {
        unit(value, "lvw")
    }

    static func lvh(_ value: Double) -> Self {
        unit(value, "lvh")
    }

    static func lvi(_ value: Double) -> Self {
        unit(value, "lvi")
    }

    static func lvb(_ value: Double) -> Self {
        unit(value, "lvb")
    }

    static func lvmin(_ value: Double) -> Self {
        unit(value, "lvmin")
    }

    static func lvmax(_ value: Double) -> Self {
        unit(value, "lvmax")
    }

    static func dvw(_ value: Double) -> Self {
        unit(value, "dvw")
    }

    static func dvh(_ value: Double) -> Self {
        unit(value, "dvh")
    }

    static func dvi(_ value: Double) -> Self {
        unit(value, "dvi")
    }

    static func dvb(_ value: Double) -> Self {
        unit(value, "dvb")
    }

    static func dvmin(_ value: Double) -> Self {
        unit(value, "dvmin")
    }

    static func dvmax(_ value: Double) -> Self {
        unit(value, "dvmax")
    }

    static func vmin(_ value: Double) -> Self {
        Self("\(formatNumber(value))vmin")
    }

    static func vmax(_ value: Double) -> Self {
        Self("\(formatNumber(value))vmax")
    }

    static func cqw(_ value: Double) -> Self {
        unit(value, "cqw")
    }

    static func cqh(_ value: Double) -> Self {
        unit(value, "cqh")
    }

    static func cqi(_ value: Double) -> Self {
        unit(value, "cqi")
    }

    static func cqb(_ value: Double) -> Self {
        unit(value, "cqb")
    }

    static func cqmin(_ value: Double) -> Self {
        unit(value, "cqmin")
    }

    static func cqmax(_ value: Double) -> Self {
        unit(value, "cqmax")
    }

    static func deg(_ value: Double) -> Self {
        Self("\(formatNumber(value))deg")
    }

    static func turn(_ value: Double) -> Self {
        unit(value, "turn")
    }

    static func rad(_ value: Double) -> Self {
        unit(value, "rad")
    }

    static func grad(_ value: Double) -> Self {
        unit(value, "grad")
    }

    static func seconds(_ value: Double) -> Self {
        Self("\(formatNumber(value))s")
    }

    static func milliseconds(_ value: Double) -> Self {
        Self("\(formatNumber(value))ms")
    }

    static func hz(_ value: Double) -> Self {
        unit(value, "Hz")
    }

    static func khz(_ value: Double) -> Self {
        unit(value, "kHz")
    }

    static func dpi(_ value: Double) -> Self {
        unit(value, "dpi")
    }

    static func dpcm(_ value: Double) -> Self {
        unit(value, "dpcm")
    }

    static func dppx(_ value: Double) -> Self {
        unit(value, "dppx")
    }

    static func x(_ value: Double) -> Self {
        unit(value, "x")
    }

    static func hex(_ value: String) -> Self {
        if value.hasPrefix("#") {
            return Self(value)
        }
        return Self("#\(value)")
    }

    static func rgb(_ red: Int, _ green: Int, _ blue: Int) -> Self {
        Self("rgb(\(red) \(green) \(blue))")
    }

    static func rgb(_ red: CSSValue, _ green: CSSValue, _ blue: CSSValue) -> Self {
        Self("rgb(\(red.rawValue) \(green.rawValue) \(blue.rawValue))")
    }

    static func rgba(_ red: Int, _ green: Int, _ blue: Int, _ alpha: Double) -> Self {
        Self("rgb(\(red) \(green) \(blue) / \(formatNumber(alpha)))")
    }

    static func colorFunction(_ name: String, _ components: [CSSValue]) -> Self {
        Self("\(name)(\(components.map(\.rawValue).joined(separator: " ")))")
    }

    static func function(_ name: String, _ arguments: String) -> Self {
        Self("\(name)(\(arguments))")
    }

    static func commaFunction(_ name: String, _ values: [CSSValue]) -> Self {
        Self("\(name)(\(values.map(\.rawValue).joined(separator: ", ")))")
    }

    static func rgbComma(_ red: Int, _ green: Int, _ blue: Int) -> Self {
        commaFunction("rgb", [.number(Double(red)), .number(Double(green)), .number(Double(blue))])
    }

    static func rgbaComma(_ red: Int, _ green: Int, _ blue: Int, _ alpha: Double) -> Self {
        commaFunction("rgba", [.number(Double(red)), .number(Double(green)), .number(Double(blue)), .number(alpha)])
    }

    static func hsl(_ hue: Double, _ saturation: Double, _ lightness: Double) -> Self {
        Self("hsl(\(formatNumber(hue))deg \(formatNumber(saturation))% \(formatNumber(lightness))%)")
    }

    static func hslComma(_ hue: Double, _ saturation: Double, _ lightness: Double) -> Self {
        Self("hsl(\(formatNumber(hue)), \(formatNumber(saturation))%, \(formatNumber(lightness))%)")
    }

    static func hsla(_ hue: Double, _ saturation: Double, _ lightness: Double, _ alpha: Double) -> Self {
        Self("hsl(\(formatNumber(hue))deg \(formatNumber(saturation))% \(formatNumber(lightness))% / \(formatNumber(alpha)))")
    }

    static func hslaComma(_ hue: Double, _ saturation: Double, _ lightness: Double, _ alpha: Double) -> Self {
        Self("hsla(\(formatNumber(hue)), \(formatNumber(saturation))%, \(formatNumber(lightness))%, \(formatNumber(alpha)))")
    }

    static func url(_ value: String) -> Self {
        Self("url(\"\(value)\")")
    }

    static func variable(_ name: String, fallback: CSSValue? = nil) -> Self {
        let customName = name.hasPrefix("--") ? name : "--\(name)"
        guard let fallback else {
            return Self("var(\(customName))")
        }
        return Self("var(\(customName), \(fallback.rawValue))")
    }

    static func calc(_ expression: String) -> Self {
        Self("calc(\(expression))")
    }

    static func min(_ values: CSSValue...) -> Self {
        Self("min(\(values.map(\.rawValue).joined(separator: ", ")))")
    }

    static func max(_ values: CSSValue...) -> Self {
        Self("max(\(values.map(\.rawValue).joined(separator: ", ")))")
    }

    static func clamp(_ minimum: CSSValue, _ preferred: CSSValue, _ maximum: CSSValue) -> Self {
        Self("clamp(\(minimum.rawValue), \(preferred.rawValue), \(maximum.rawValue))")
    }

    static func repeatFunction(_ count: String, _ track: CSSValue) -> Self {
        Self("repeat(\(count), \(track.rawValue))")
    }

    static func minmax(_ minimum: CSSValue, _ maximum: CSSValue) -> Self {
        Self("minmax(\(minimum.rawValue), \(maximum.rawValue))")
    }

    private static func formatNumber(_ value: Double) -> String {
        if value.rounded() == value {
            return String(Int(value))
        }
        return String(value)
    }
}

/// A single CSS declaration consisting of a name and serialized value.
public struct CSSDeclaration: Hashable, Sendable {
    public var name: CSSDeclarationName
    public var value: CSSValue
    public var important: Bool

    public init(_ name: CSSDeclarationName, _ value: CSSValue) {
        self.init(name, value, important: false)
    }

    public init(_ name: CSSDeclarationName, _ value: CSSValue, important: Bool) {
        self.name = name
        self.value = value
        self.important = important
    }
}

/// Ordered CSS declaration-block contents.
///
/// This type represents the declaration-list text used by HTML `style`
/// attributes, excluding the surrounding braces of a stylesheet rule block.
public struct CSSDeclarationBlock: Hashable, Sendable, ExpressibleByArrayLiteral {
    public var declarations: [CSSDeclaration]

    public init(_ declarations: [CSSDeclaration] = []) {
        self.declarations = declarations
    }

    public init(styleAttribute value: String) throws {
        self = try CSSParser().parseDeclarationBlock(value)
    }

    public init(arrayLiteral elements: CSSDeclaration...) {
        self.init(elements)
    }

    public mutating func set(_ name: CSSDeclarationName, _ value: CSSValue) {
        set(name, value, important: false)
    }

    public mutating func set(_ name: CSSDeclarationName, _ value: CSSValue, important: Bool) {
        declarations.removeAll { $0.name == name }
        declarations.append(CSSDeclaration(name, value, important: important))
    }
}

/// A simple CSS qualified rule with selector text and declaration-block contents.
///
/// This type models the ordinary stylesheet rule shape `selector { name: value }`
/// for SwiftHTML-authored stylesheets. Selector text is preserved as authored;
/// selector parsing, at-rules, nesting, and CSSOM normalization are outside the
/// initial stylesheet subset.
public struct CSSStyleRule: Hashable, Sendable {
    public var selectorText: String
    public var style: CSSDeclarationBlock

    public init(_ selectorText: String, style: CSSDeclarationBlock) {
        self.selectorText = selectorText
        self.style = style
    }
}

/// Ordered simple CSS stylesheet contents.
///
/// The initial stylesheet model stores only ordinary style rules. It is intended
/// for Dot/SwiftHTML-authored stylesheets where parse and serialize should
/// preserve selectors, declaration order, and raw declaration values without
/// implementing full CSS Syntax or CSSOM behavior.
public struct CSSStyleSheet: Hashable, Sendable, ExpressibleByArrayLiteral {
    public var rules: [CSSStyleRule]

    public init(_ rules: [CSSStyleRule] = []) {
        self.rules = rules
    }

    public init(stylesheet source: String) throws {
        self = try CSSParser().parseStyleSheet(source)
    }

    public init(arrayLiteral elements: CSSStyleRule...) {
        self.init(elements)
    }
}

/// Serializes simple CSS declaration blocks.
///
/// The serializer emits a stable `name: value` declaration list for the initial
/// SwiftHTML style-attribute and stylesheet subsets. It does not implement full
/// CSSOM shorthand serialization or CSS value normalization.
public struct CSSSerializer: Sendable {
    public init() {}

    public func serialize(_ block: CSSDeclarationBlock) -> String {
        block.declarations
            .map { "\($0.name.rawValue): \($0.value.rawValue)\($0.important ? " !important" : "")" }
            .joined(separator: "; ")
    }

    public func serialize(_ sheet: CSSStyleSheet) -> String {
        sheet.rules
            .map { "\($0.selectorText) { \(serialize($0.style)) }" }
            .joined(separator: "\n")
    }
}
