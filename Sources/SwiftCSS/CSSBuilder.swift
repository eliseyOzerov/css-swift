/// Builds declaration blocks from declaration expressions.
@resultBuilder
public enum CSSDeclarationBlockBuilder {
    public static func buildBlock(_ components: [CSSDeclaration]...) -> [CSSDeclaration] {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ expression: CSSDeclaration) -> [CSSDeclaration] {
        [expression]
    }

    public static func buildExpression(_ expression: [CSSDeclaration]) -> [CSSDeclaration] {
        expression
    }
}

/// Builds stylesheets from style-rule expressions.
@resultBuilder
public enum CSSStyleSheetBuilder {
    public static func buildBlock(_ components: CSSStyleRule...) -> [CSSStyleRule] {
        components
    }
}

public extension CSSDeclarationBlock {
    init(@CSSDeclarationBlockBuilder _ declarations: () -> [CSSDeclaration]) {
        self.init(declarations())
    }
}

public extension CSSStyleSheet {
    init(@CSSStyleSheetBuilder _ rules: () -> [CSSStyleRule]) {
        self.init(rules())
    }
}

public extension CSSStyleRule {
    static func selector(_ selectors: CSSSelector..., style: CSSDeclarationBlock) -> Self {
        Self(CSSSelector.list(selectors), style: style)
    }

    static func selector(
        _ selectors: CSSSelector...,
        @CSSDeclarationBlockBuilder style: () -> [CSSDeclaration]
    ) -> Self {
        Self(CSSSelector.list(selectors), style: CSSDeclarationBlock(style))
    }

    static func raw(_ selectorText: String, style: CSSDeclarationBlock) -> Self {
        Self(selectorText, style: style)
    }

    static func raw(
        _ selectorText: String,
        @CSSDeclarationBlockBuilder style: () -> [CSSDeclaration]
    ) -> Self {
        Self(selectorText, style: CSSDeclarationBlock(style))
    }

    static func universal(style: CSSDeclarationBlock) -> Self {
        Self(.universal, style: style)
    }

    static func universal(@CSSDeclarationBlockBuilder style: () -> [CSSDeclaration]) -> Self {
        Self(.universal, style: CSSDeclarationBlock(style))
    }

    static func root(style: CSSDeclarationBlock) -> Self {
        Self(CSSSelector.raw(":root"), style: style)
    }

    static func root(@CSSDeclarationBlockBuilder style: () -> [CSSDeclaration]) -> Self {
        Self(CSSSelector.raw(":root"), style: CSSDeclarationBlock(style))
    }

    static func element(_ localName: String, style: CSSDeclarationBlock) -> Self {
        Self(.element(localName), style: style)
    }

    static func element(
        _ localName: String,
        @CSSDeclarationBlockBuilder style: () -> [CSSDeclaration]
    ) -> Self {
        Self(.element(localName), style: CSSDeclarationBlock(style))
    }

    static func id(_ id: String, style: CSSDeclarationBlock) -> Self {
        Self(.id(id), style: style)
    }

    static func id(
        _ id: String,
        @CSSDeclarationBlockBuilder style: () -> [CSSDeclaration]
    ) -> Self {
        Self(.id(id), style: CSSDeclarationBlock(style))
    }

    static func `class`(_ name: String, style: CSSDeclarationBlock) -> Self {
        Self(.class(name), style: style)
    }

    static func `class`(
        _ name: String,
        @CSSDeclarationBlockBuilder style: () -> [CSSDeclaration]
    ) -> Self {
        Self(.class(name), style: CSSDeclarationBlock(style))
    }
}

public extension CSSDeclaration {
    static func property(_ name: CSSDeclarationName, _ value: CSSValue) -> Self {
        Self(name, value)
    }

    static func customProperty(_ name: String, _ value: CSSValue) -> Self {
        let propertyName = name.hasPrefix("--") ? name : "--\(name)"
        return Self(CSSDeclarationName(propertyName), value)
    }

    static func background(_ value: CSSValue) -> Self { property(.background, value) }
    static func border(_ value: CSSValue) -> Self { property(.border, value) }
    static func border(_ value: CSSBorderValue) -> Self { property(.border, value.cssValue) }
    static func borderBottom(_ value: CSSValue) -> Self { property(.borderBottom, value) }
    static func borderBottom(_ value: CSSBorderValue) -> Self { property(.borderBottom, value.cssValue) }
    static func borderCollapse(_ value: CSSValue) -> Self { property(.borderCollapse, value) }
    static func borderLeft(_ value: CSSValue) -> Self { property(.borderLeft, value) }
    static func borderLeft(_ value: CSSBorderValue) -> Self { property(.borderLeft, value.cssValue) }
    static func borderRadius(_ value: CSSValue) -> Self { property(.borderRadius, value) }
    static func borderTop(_ value: CSSValue) -> Self { property(.borderTop, value) }
    static func borderTop(_ value: CSSBorderValue) -> Self { property(.borderTop, value.cssValue) }
    static func boxSizing(_ value: CSSValue) -> Self { property(.boxSizing, value) }
    static func caretColor(_ value: CSSValue) -> Self { property(.caretColor, value) }
    static func color(_ value: CSSValue) -> Self { property(.color, value) }
    static func colorScheme(_ value: CSSValue) -> Self { property(.colorScheme, value) }
    static func content(_ value: CSSValue) -> Self { property(.content, value) }
    static func display(_ value: CSSValue) -> Self { property(.display, value) }
    static func font(_ value: CSSValue) -> Self { property(.font, value) }
    static func fontFamily(_ value: CSSValue) -> Self { property(.fontFamily, value) }
    static func fontSize(_ value: CSSValue) -> Self { property(.fontSize, value) }
    static func fontWeight(_ value: CSSValue) -> Self { property(.fontWeight, value) }
    static func height(_ value: CSSValue) -> Self { property(.height, value) }
    static func letterSpacing(_ value: CSSValue) -> Self { property(.letterSpacing, value) }
    static func lineHeight(_ value: CSSValue) -> Self { property(.lineHeight, value) }
    static func listStyle(_ value: CSSValue) -> Self { property(.listStyle, value) }
    static func margin(_ value: CSSValue) -> Self { property(.margin, value) }
    static func margin(_ value: CSSBoxValue) -> Self { property(.margin, value.cssValue) }
    static func marginBottom(_ value: CSSValue) -> Self { property(.marginBottom, value) }
    static func marginLeft(_ value: CSSValue) -> Self { property(.marginLeft, value) }
    static func marginRight(_ value: CSSValue) -> Self { property(.marginRight, value) }
    static func marginTop(_ value: CSSValue) -> Self { property(.marginTop, value) }
    static func maxWidth(_ value: CSSValue) -> Self { property(.maxWidth, value) }
    static func minHeight(_ value: CSSValue) -> Self { property(.minHeight, value) }
    static func outline(_ value: CSSValue) -> Self { property(.outline, value) }
    static func overflow(_ value: CSSValue) -> Self { property(.overflow, value) }
    static func overflowWrap(_ value: CSSValue) -> Self { property(.overflowWrap, value) }
    static func padding(_ value: CSSValue) -> Self { property(.padding, value) }
    static func padding(_ value: CSSBoxValue) -> Self { property(.padding, value.cssValue) }
    static func paddingBottom(_ value: CSSValue) -> Self { property(.paddingBottom, value) }
    static func paddingLeft(_ value: CSSValue) -> Self { property(.paddingLeft, value) }
    static func position(_ value: CSSValue) -> Self { property(.position, value) }
    static func textAlign(_ value: CSSValue) -> Self { property(.textAlign, value) }
    static func textDecoration(_ value: CSSValue) -> Self { property(.textDecoration, value) }
    static func textTransform(_ value: CSSValue) -> Self { property(.textTransform, value) }
    static func transform(_ value: CSSValue) -> Self { property(.transform, value) }
    static func whiteSpace(_ value: CSSValue) -> Self { property(.whiteSpace, value) }
    static func width(_ value: CSSValue) -> Self { property(.width, value) }
}
