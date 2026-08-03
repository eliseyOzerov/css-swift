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
public struct CSSValue: Hashable, Sendable, ExpressibleByStringLiteral, ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral, ExpressibleByBooleanLiteral {
    public var rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: Int) {
        self.rawValue = "\(rawValue)"
    }

    public init(_ rawValue: Double) {
        self.rawValue = Self.formatNumber(rawValue)
    }

    public init(_ rawValue: Bool) {
        self.rawValue = rawValue ? "true" : "false"
    }

    public init(_ value: some CSSValueConvertible) {
        self = value.cssValue
    }

    public init(stringLiteral value: String) {
        self.init(value)
    }

    public init(integerLiteral value: Int) {
        self.init(value)
    }

    public init(floatLiteral value: Double) {
        self.init(value)
    }

    public init(booleanLiteral value: Bool) {
        self.init(value)
    }
}

public protocol CSSValueConvertible {
    var cssValue: CSSValue { get }
}

extension CSSValue: CSSValueConvertible {
    public var cssValue: CSSValue { self }
}

public struct CSSKeyword: Hashable, Sendable, CSSValueConvertible {
    public var rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public var cssValue: CSSValue {
        CSSValue(rawValue)
    }
}

public extension CSSKeyword {
    static let auto = Self("auto")
    static let currentColor = Self("currentColor")
    static let inherit = Self("inherit")
    static let initial = Self("initial")
    static let none = Self("none")
    static let revert = Self("revert")
    static let transparent = Self("transparent")
    static let unset = Self("unset")
}

public struct CSSBoxValue: Hashable, Sendable, CSSValueConvertible {
    public var values: [CSSValue]

    public init(_ all: CSSValue) {
        values = [all]
    }

    public init(_ block: CSSValue, _ inline: CSSValue) {
        values = [block, inline]
    }

    public init(_ top: CSSValue, _ inline: CSSValue, _ bottom: CSSValue) {
        values = [top, inline, bottom]
    }

    public init(_ top: CSSValue, _ right: CSSValue, _ bottom: CSSValue, _ left: CSSValue) {
        values = [top, right, bottom, left]
    }

    public var cssValue: CSSValue {
        CSSValue(values.map(\.rawValue).joined(separator: " "))
    }
}

public extension CSSBoxValue {
    static func all(_ value: CSSValue) -> Self {
        Self(value)
    }

    static func ltrb(left: CSSValue, top: CSSValue, right: CSSValue, bottom: CSSValue) -> Self {
        Self(top, right, bottom, left)
    }

    static func vertical(_ value: CSSValue, horizontal: CSSValue = .zero) -> Self {
        Self(value, horizontal)
    }

    static func vertical(top: CSSValue, bottom: CSSValue, horizontal: CSSValue = .zero) -> Self {
        Self(top, horizontal, bottom, horizontal)
    }

    static func horizontal(_ value: CSSValue, vertical: CSSValue = .zero) -> Self {
        Self(vertical, value)
    }

    static func horizontal(left: CSSValue, right: CSSValue, vertical: CSSValue = .zero) -> Self {
        Self(vertical, right, vertical, left)
    }

    static func symmetric(vertical: CSSValue, horizontal: CSSValue) -> Self {
        Self(vertical, horizontal)
    }

    static func axes(block: CSSValue, inline: CSSValue) -> Self {
        symmetric(vertical: block, horizontal: inline)
    }

    static func topInlineBottom(top: CSSValue, inline: CSSValue, bottom: CSSValue) -> Self {
        Self(top, inline, bottom)
    }

    static func edges(top: CSSValue, right: CSSValue, bottom: CSSValue, left: CSSValue) -> Self {
        ltrb(left: left, top: top, right: right, bottom: bottom)
    }
}

public enum CSSBorderStyle: String, Hashable, Sendable, CSSValueConvertible {
    case dashed
    case dotted
    case double
    case groove
    case hidden
    case inset
    case none
    case outset
    case ridge
    case solid

    public var cssValue: CSSValue {
        CSSValue(rawValue)
    }
}

public struct CSSBorderValue: Hashable, Sendable, CSSValueConvertible {
    public var width: CSSValue?
    public var style: CSSBorderStyle
    public var color: CSSValue?

    public init(width: CSSValue? = nil, style: CSSBorderStyle, color: CSSValue? = nil) {
        self.width = width
        self.style = style
        self.color = color
    }

    public var cssValue: CSSValue {
        CSSValue(([width, style.cssValue, color].compactMap { $0 }).map(\.rawValue).joined(separator: " "))
    }
}

public extension CSSBorderValue {
    static func line(width: CSSValue? = nil, style: CSSBorderStyle, color: CSSValue? = nil) -> Self {
        Self(width: width, style: style, color: color)
    }

    static func solid(_ width: CSSValue? = nil, _ color: CSSValue? = nil) -> Self {
        Self(width: width, style: .solid, color: color)
    }

    static func dashed(_ width: CSSValue? = nil, _ color: CSSValue? = nil) -> Self {
        Self(width: width, style: .dashed, color: color)
    }
}

public extension CSSValue {
    static let auto = CSSKeyword.auto.cssValue
    static let currentColor = CSSKeyword.currentColor.cssValue
    static let inherit = CSSKeyword.inherit.cssValue
    static let initial = CSSKeyword.initial.cssValue
    static let none = CSSKeyword.none.cssValue
    static let revert = CSSKeyword.revert.cssValue
    static let transparent = CSSKeyword.transparent.cssValue
    static let unset = CSSKeyword.unset.cssValue
    static let zero = CSSValue("0")

    static func raw(_ value: String) -> Self {
        Self(value)
    }

    static func num(_ value: Double) -> Self {
        number(value)
    }

    static func num(_ value: Int) -> Self {
        Self(value)
    }

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

/// Convenience factories for related CSS declarations.
///
/// These helpers keep CSS serialization flat. They group Swift authoring calls
/// such as margins, padding, insets, and scroll margins, but each helper returns
/// ordinary declarations like `margin-top` and `padding-inline`.
public enum CSSDeclarations {
    public static func prefixed(_ prefix: String, _ components: [(String, CSSValue)]) -> [CSSDeclaration] {
        components.map { suffix, value in
            CSSDeclaration(CSSDeclarationName(propertyName(prefix: prefix, suffix: suffix)), value)
        }
    }

    public static func margin(
        top: CSSValue? = nil,
        right: CSSValue? = nil,
        bottom: CSSValue? = nil,
        left: CSSValue? = nil,
        block: CSSValue? = nil,
        inline: CSSValue? = nil,
        blockStart: CSSValue? = nil,
        blockEnd: CSSValue? = nil,
        inlineStart: CSSValue? = nil,
        inlineEnd: CSSValue? = nil
    ) -> [CSSDeclaration] {
        boxDeclarations(prefix: "margin", top: top, right: right, bottom: bottom, left: left, block: block, inline: inline, blockStart: blockStart, blockEnd: blockEnd, inlineStart: inlineStart, inlineEnd: inlineEnd)
    }

    public static func padding(
        top: CSSValue? = nil,
        right: CSSValue? = nil,
        bottom: CSSValue? = nil,
        left: CSSValue? = nil,
        block: CSSValue? = nil,
        inline: CSSValue? = nil,
        blockStart: CSSValue? = nil,
        blockEnd: CSSValue? = nil,
        inlineStart: CSSValue? = nil,
        inlineEnd: CSSValue? = nil
    ) -> [CSSDeclaration] {
        boxDeclarations(prefix: "padding", top: top, right: right, bottom: bottom, left: left, block: block, inline: inline, blockStart: blockStart, blockEnd: blockEnd, inlineStart: inlineStart, inlineEnd: inlineEnd)
    }

    public static func inset(
        top: CSSValue? = nil,
        right: CSSValue? = nil,
        bottom: CSSValue? = nil,
        left: CSSValue? = nil,
        block: CSSValue? = nil,
        inline: CSSValue? = nil,
        blockStart: CSSValue? = nil,
        blockEnd: CSSValue? = nil,
        inlineStart: CSSValue? = nil,
        inlineEnd: CSSValue? = nil
    ) -> [CSSDeclaration] {
        boxDeclarations(prefix: "inset", top: top, right: right, bottom: bottom, left: left, block: block, inline: inline, blockStart: blockStart, blockEnd: blockEnd, inlineStart: inlineStart, inlineEnd: inlineEnd)
    }

    public static func scrollMargin(
        top: CSSValue? = nil,
        right: CSSValue? = nil,
        bottom: CSSValue? = nil,
        left: CSSValue? = nil,
        block: CSSValue? = nil,
        inline: CSSValue? = nil,
        blockStart: CSSValue? = nil,
        blockEnd: CSSValue? = nil,
        inlineStart: CSSValue? = nil,
        inlineEnd: CSSValue? = nil
    ) -> [CSSDeclaration] {
        boxDeclarations(prefix: "scroll-margin", top: top, right: right, bottom: bottom, left: left, block: block, inline: inline, blockStart: blockStart, blockEnd: blockEnd, inlineStart: inlineStart, inlineEnd: inlineEnd)
    }

    public static func border(width: CSSValue? = nil, style: CSSValue? = nil, color: CSSValue? = nil) -> [CSSDeclaration] {
        var declarations: [CSSDeclaration] = []
        append(&declarations, prefix: "border", suffix: "width", value: width)
        append(&declarations, prefix: "border", suffix: "style", value: style)
        append(&declarations, prefix: "border", suffix: "color", value: color)
        return declarations
    }

    private static func boxDeclarations(
        prefix: String,
        top: CSSValue?,
        right: CSSValue?,
        bottom: CSSValue?,
        left: CSSValue?,
        block: CSSValue?,
        inline: CSSValue?,
        blockStart: CSSValue?,
        blockEnd: CSSValue?,
        inlineStart: CSSValue?,
        inlineEnd: CSSValue?
    ) -> [CSSDeclaration] {
        var declarations: [CSSDeclaration] = []
        append(&declarations, prefix: prefix, suffix: "block", value: block)
        append(&declarations, prefix: prefix, suffix: "inline", value: inline)
        append(&declarations, prefix: prefix, suffix: "top", value: top)
        append(&declarations, prefix: prefix, suffix: "right", value: right)
        append(&declarations, prefix: prefix, suffix: "bottom", value: bottom)
        append(&declarations, prefix: prefix, suffix: "left", value: left)
        append(&declarations, prefix: prefix, suffix: "block-start", value: blockStart)
        append(&declarations, prefix: prefix, suffix: "block-end", value: blockEnd)
        append(&declarations, prefix: prefix, suffix: "inline-start", value: inlineStart)
        append(&declarations, prefix: prefix, suffix: "inline-end", value: inlineEnd)
        return declarations
    }

    private static func append(
        _ declarations: inout [CSSDeclaration],
        prefix: String,
        suffix: String,
        value: CSSValue?
    ) {
        guard let value else {
            return
        }
        declarations.append(CSSDeclaration(CSSDeclarationName(propertyName(prefix: prefix, suffix: suffix)), value))
    }

    private static func propertyName(prefix: String, suffix: String) -> String {
        suffix.isEmpty ? prefix : "\(prefix)-\(suffix)"
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

/// A serialized CSS selector.
///
/// `CSSSelector` models the official Selectors terminology at the authoring
/// boundary: type selectors, class selectors, ID selectors, attribute selectors,
/// selector lists, combinators, pseudo-classes, and pseudo-elements. It does not
/// parse or validate arbitrary selector grammar; raw selector text remains
/// available for the full CSS surface.
public struct CSSSelector: Hashable, Sendable, ExpressibleByStringLiteral {
    public var rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: String) {
        self.init(value)
    }
}

public extension CSSSelector {
    static let universal: Self = "*"

    static func raw(_ selectorText: String) -> Self {
        Self(selectorText)
    }

    static func type(_ localName: String) -> Self {
        Self(localName)
    }

    static func element(_ localName: String) -> Self {
        type(localName)
    }

    static func id(_ id: String) -> Self {
        Self("#\(id)")
    }

    static func className(_ className: String) -> Self {
        Self(".\(className)")
    }

    static func `class`(_ name: String) -> Self {
        className(name)
    }

    static func attribute(_ name: String) -> Self {
        Self(attributeSelector(name: name))
    }

    static func attribute(
        _ name: String,
        _ matcher: CSSAttributeSelectorMatcher,
        _ value: String,
        modifier: CSSAttributeSelectorModifier? = nil
    ) -> Self {
        Self(attributeSelector(name: name, matcher: matcher, value: value, modifier: modifier))
    }

    static func attribute(
        _ name: String,
        equals value: String,
        modifier: CSSAttributeSelectorModifier? = nil
    ) -> Self {
        attribute(name, .exact, value, modifier: modifier)
    }

    static func list(_ selectors: [CSSSelector]) -> Self {
        Self(selectors.map(\.rawValue).joined(separator: ", "))
    }

    static func list(_ selectors: CSSSelector...) -> Self {
        list(selectors)
    }

    func id(_ id: String) -> Self {
        appending("#\(id)")
    }

    func className(_ className: String) -> Self {
        appending(".\(className)")
    }

    func `class`(_ name: String) -> Self {
        className(name)
    }

    func attribute(_ name: String) -> Self {
        appending(Self.attributeSelector(name: name))
    }

    func attribute(
        _ name: String,
        _ matcher: CSSAttributeSelectorMatcher,
        _ value: String,
        modifier: CSSAttributeSelectorModifier? = nil
    ) -> Self {
        appending(Self.attributeSelector(name: name, matcher: matcher, value: value, modifier: modifier))
    }

    func attribute(
        _ name: String,
        equals value: String,
        modifier: CSSAttributeSelectorModifier? = nil
    ) -> Self {
        attribute(name, .exact, value, modifier: modifier)
    }

    func pseudoClass(_ pseudoClass: CSSPseudoClass) -> Self {
        appending(":\(pseudoClass.rawValue)")
    }

    func pseudoElement(_ pseudoElement: CSSPseudoElement) -> Self {
        appending("::\(pseudoElement.rawValue)")
    }

    func descendant(_ selector: CSSSelector) -> Self {
        combined(with: selector, separator: " ")
    }

    func child(_ selector: CSSSelector) -> Self {
        combined(with: selector, separator: " > ")
    }

    func nextSibling(_ selector: CSSSelector) -> Self {
        combined(with: selector, separator: " + ")
    }

    func subsequentSibling(_ selector: CSSSelector) -> Self {
        combined(with: selector, separator: " ~ ")
    }

    private func appending(_ suffix: String) -> Self {
        Self("\(rawValue)\(suffix)")
    }

    private func combined(with selector: CSSSelector, separator: String) -> Self {
        Self("\(rawValue)\(separator)\(selector.rawValue)")
    }

    private static func attributeSelector(
        name: String,
        matcher: CSSAttributeSelectorMatcher? = nil,
        value: String? = nil,
        modifier: CSSAttributeSelectorModifier? = nil
    ) -> String {
        guard let matcher, let value else {
            return "[\(name)]"
        }

        let modifierText = modifier.map { " \($0.rawValue)" } ?? ""
        return "[\(name)\(matcher.rawValue)\"\(escapeCSSString(value))\"\(modifierText)]"
    }

    private static func escapeCSSString(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
    }
}

/// Attribute selector match operators from Selectors.
public enum CSSAttributeSelectorMatcher: String, Hashable, Sendable {
    case exact = "="
    case whitespaceSeparated = "~="
    case dashSeparated = "|="
    case prefix = "^="
    case suffix = "$="
    case substring = "*="
}

/// Attribute selector case-sensitivity modifiers.
public enum CSSAttributeSelectorModifier: String, Hashable, Sendable {
    case caseInsensitive = "i"
    case caseSensitive = "s"
}

/// A CSS pseudo-class name or functional pseudo-class.
public struct CSSPseudoClass: Hashable, Sendable, ExpressibleByStringLiteral {
    public var rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: String) {
        self.init(value)
    }
}

public extension CSSPseudoClass {
    static let active: Self = "active"
    static let checked: Self = "checked"
    static let disabled: Self = "disabled"
    static let enabled: Self = "enabled"
    static let focus: Self = "focus"
    static let focusVisible: Self = "focus-visible"
    static let focusWithin: Self = "focus-within"
    static let hover: Self = "hover"
    static let root: Self = "root"

    static func function(_ name: String, _ argument: String) -> Self {
        Self("\(name)(\(argument))")
    }

    static func dir(_ direction: String) -> Self {
        function("dir", direction)
    }

    static func has(_ relativeSelectorList: String) -> Self {
        function("has", relativeSelectorList)
    }

    static func `is`(_ selectorList: CSSSelector) -> Self {
        function("is", selectorList.rawValue)
    }

    static func lang(_ languageRange: String) -> Self {
        function("lang", languageRange)
    }

    static func not(_ selectorList: CSSSelector) -> Self {
        function("not", selectorList.rawValue)
    }

    static func nthChild(_ argument: String) -> Self {
        function("nth-child", argument)
    }

    static func `where`(_ selectorList: CSSSelector) -> Self {
        function("where", selectorList.rawValue)
    }
}

/// A CSS pseudo-element name or functional pseudo-element.
public struct CSSPseudoElement: Hashable, Sendable, ExpressibleByStringLiteral {
    public var rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: String) {
        self.init(value)
    }
}

public extension CSSPseudoElement {
    static let after: Self = "after"
    static let backdrop: Self = "backdrop"
    static let before: Self = "before"
    static let fileSelectorButton: Self = "file-selector-button"
    static let firstLetter: Self = "first-letter"
    static let firstLine: Self = "first-line"
    static let marker: Self = "marker"
    static let placeholder: Self = "placeholder"
    static let selection: Self = "selection"

    static func function(_ name: String, _ argument: String) -> Self {
        Self("\(name)(\(argument))")
    }

    static func part(_ name: String) -> Self {
        function("part", name)
    }

    static func slotted(_ selector: CSSSelector) -> Self {
        function("slotted", selector.rawValue)
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

    public init(_ selector: CSSSelector, style: CSSDeclarationBlock) {
        self.init(selector.rawValue, style: style)
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
