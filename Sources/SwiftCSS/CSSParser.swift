import Foundation

public enum CSSParseError: Error, Equatable, Sendable {
    case expectedDeclarationName
    case expectedColon(name: String)
    case expectedStyleRuleSelector
    case expectedRuleOpeningBrace(selector: String)
    case expectedRuleClosingBrace(selector: String)
    case unsupportedAtRule(String)
}

/// Parses simple CSS declaration-block contents.
///
/// This parser is intended for style attributes and authored SwiftHTML values.
/// It preserves declaration values as raw CSS text and only understands enough
/// syntax to avoid splitting semicolons inside strings, functions, and blocks.
/// For stylesheets it supports top-level qualified style rules only.
public struct CSSParser: Sendable {
    public init() {}

    public func parseDeclarationBlock(_ source: String) throws -> CSSDeclarationBlock {
        let chunks = splitDeclarations(removingCSSComments(from: source))
        var declarations: [CSSDeclaration] = []

        for chunk in chunks {
            let declaration = chunk.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !declaration.isEmpty else { continue }

            guard let colon = firstTopLevelColon(in: declaration) else {
                throw CSSParseError.expectedDeclarationName
            }

            let name = declaration[..<colon].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !name.isEmpty else {
                throw CSSParseError.expectedDeclarationName
            }

            let valueStart = declaration.index(after: colon)
            let value = declaration[valueStart...].trimmingCharacters(in: .whitespacesAndNewlines)
            let parsedValue = extractImportant(from: String(value))
            let parsedName = String(name)
            declarations.append(CSSDeclaration(
                CSSDeclarationName(parsedName.hasPrefix("--") ? parsedName : parsedName.lowercased()),
                CSSValue(parsedValue.value),
                important: parsedValue.important
            ))
        }

        return CSSDeclarationBlock(declarations)
    }

    public func parseStyleSheet(_ source: String) throws -> CSSStyleSheet {
        var state = StyleSheetParserState(source)
        var rules: [CSSStyleRule] = []

        while true {
            state.skipWhitespaceAndComments()
            guard !state.isAtEnd else { break }

            if state.peek == "@" {
                throw CSSParseError.unsupportedAtRule(state.consumeUntilTopLevelOpeningBraceOrSemicolon())
            }

            let selector = removingCSSComments(from: state.consumeUntilTopLevelOpeningBrace())
                .trimmingCharacters(in: .whitespacesAndNewlines)
            guard !selector.isEmpty else {
                throw CSSParseError.expectedStyleRuleSelector
            }

            guard state.consume("{") else {
                throw CSSParseError.expectedRuleOpeningBrace(selector: selector)
            }

            guard let block = state.consumeDeclarationBlockBody(selector: selector) else {
                throw CSSParseError.expectedRuleClosingBrace(selector: selector)
            }

            rules.append(CSSStyleRule(selector, style: try parseDeclarationBlock(block)))
        }

        return CSSStyleSheet(rules)
    }

    private func removingCSSComments(from source: String) -> String {
        var output = ""
        var index = source.startIndex
        var quote: Character?
        var escaped = false

        while index < source.endIndex {
            let character = source[index]

            if escaped {
                output.append(character)
                escaped = false
                index = source.index(after: index)
                continue
            }

            if character == "\\" {
                output.append(character)
                escaped = true
                index = source.index(after: index)
                continue
            }

            if let activeQuote = quote {
                output.append(character)
                if character == activeQuote {
                    quote = nil
                }
                index = source.index(after: index)
                continue
            }

            if character == "\"" || character == "'" {
                quote = character
                output.append(character)
                index = source.index(after: index)
                continue
            }

            if source[index...].hasPrefix("/*"),
               let commentEnd = source[index...].range(of: "*/") {
                output.append(" ")
                index = commentEnd.upperBound
                continue
            }

            output.append(character)
            index = source.index(after: index)
        }

        return output
    }

    private func extractImportant(from source: String) -> (value: String, important: Bool) {
        let trimmed = source.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let range = trimmed.range(
            of: #"!\s*important\s*$"#,
            options: [.regularExpression, .caseInsensitive]
        ) else {
            return (trimmed, false)
        }

        let value = trimmed[..<range.lowerBound].trimmingCharacters(in: .whitespacesAndNewlines)
        return (value, true)
    }

    private func splitDeclarations(_ source: String) -> [String] {
        var chunks: [String] = []
        var current = ""
        var quote: Character?
        var escaped = false
        var depth = 0

        for character in source {
            if escaped {
                current.append(character)
                escaped = false
                continue
            }

            if character == "\\" {
                current.append(character)
                escaped = true
                continue
            }

            if let activeQuote = quote {
                current.append(character)
                if character == activeQuote {
                    quote = nil
                }
                continue
            }

            if character == "\"" || character == "'" {
                quote = character
                current.append(character)
                continue
            }

            if character == "(" || character == "[" || character == "{" {
                depth += 1
                current.append(character)
                continue
            }

            if (character == ")" || character == "]" || character == "}") && depth > 0 {
                depth -= 1
                current.append(character)
                continue
            }

            if character == ";" && depth == 0 {
                chunks.append(current)
                current = ""
                continue
            }

            current.append(character)
        }

        chunks.append(current)
        return chunks
    }

    private func firstTopLevelColon(in source: String) -> String.Index? {
        var quote: Character?
        var escaped = false
        var depth = 0

        for index in source.indices {
            let character = source[index]

            if escaped {
                escaped = false
                continue
            }

            if character == "\\" {
                escaped = true
                continue
            }

            if let activeQuote = quote {
                if character == activeQuote {
                    quote = nil
                }
                continue
            }

            if character == "\"" || character == "'" {
                quote = character
                continue
            }

            if character == "(" || character == "[" || character == "{" {
                depth += 1
                continue
            }

            if (character == ")" || character == "]" || character == "}") && depth > 0 {
                depth -= 1
                continue
            }

            if character == ":" && depth == 0 {
                return index
            }
        }

        return nil
    }
}

private struct StyleSheetParserState {
    let source: String
    var index: String.Index

    init(_ source: String) {
        self.source = source
        self.index = source.startIndex
    }

    var isAtEnd: Bool {
        index >= source.endIndex
    }

    var peek: Character? {
        isAtEnd ? nil : source[index]
    }

    mutating func skipWhitespaceAndComments() {
        while !isAtEnd {
            if source[index].isWhitespace {
                index = source.index(after: index)
                continue
            }

            if source[index...].hasPrefix("/*"),
               let commentEnd = source[index...].range(of: "*/") {
                index = commentEnd.upperBound
                continue
            }

            break
        }
    }

    mutating func consumeUntilTopLevelOpeningBrace() -> String {
        let start = index
        var quote: Character?
        var escaped = false
        var bracketDepth = 0
        var parenthesisDepth = 0

        while !isAtEnd {
            let character = source[index]

            if escaped {
                escaped = false
                index = source.index(after: index)
                continue
            }

            if character == "\\" {
                escaped = true
                index = source.index(after: index)
                continue
            }

            if let activeQuote = quote {
                if character == activeQuote {
                    quote = nil
                }
                index = source.index(after: index)
                continue
            }

            if character == "\"" || character == "'" {
                quote = character
                index = source.index(after: index)
                continue
            }

            if character == "[" {
                bracketDepth += 1
                index = source.index(after: index)
                continue
            }

            if character == "]", bracketDepth > 0 {
                bracketDepth -= 1
                index = source.index(after: index)
                continue
            }

            if character == "(" {
                parenthesisDepth += 1
                index = source.index(after: index)
                continue
            }

            if character == ")", parenthesisDepth > 0 {
                parenthesisDepth -= 1
                index = source.index(after: index)
                continue
            }

            if character == "{", bracketDepth == 0, parenthesisDepth == 0 {
                break
            }

            index = source.index(after: index)
        }

        return String(source[start..<index])
    }

    mutating func consumeUntilTopLevelOpeningBraceOrSemicolon() -> String {
        let start = index
        while !isAtEnd, source[index] != "{", source[index] != ";" {
            index = source.index(after: index)
        }
        if !isAtEnd, source[index] == ";" {
            index = source.index(after: index)
        }
        return String(source[start..<index]).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    mutating func consumeDeclarationBlockBody(selector: String) -> String? {
        let start = index
        var quote: Character?
        var escaped = false
        var nestedBraceDepth = 0

        while !isAtEnd {
            let character = source[index]

            if escaped {
                escaped = false
                index = source.index(after: index)
                continue
            }

            if character == "\\" {
                escaped = true
                index = source.index(after: index)
                continue
            }

            if let activeQuote = quote {
                if character == activeQuote {
                    quote = nil
                }
                index = source.index(after: index)
                continue
            }

            if character == "\"" || character == "'" {
                quote = character
                index = source.index(after: index)
                continue
            }

            if character == "{" {
                nestedBraceDepth += 1
                index = source.index(after: index)
                continue
            }

            if character == "}" {
                if nestedBraceDepth == 0 {
                    let block = String(source[start..<index])
                    index = source.index(after: index)
                    return block
                }
                nestedBraceDepth -= 1
                index = source.index(after: index)
                continue
            }

            index = source.index(after: index)
        }

        return nil
    }

    @discardableResult
    mutating func consume(_ prefix: String) -> Bool {
        guard source[index...].hasPrefix(prefix) else { return false }
        index = source.index(index, offsetBy: prefix.count)
        return true
    }
}

private extension Substring {
    func trimmingCharacters(in set: CharacterSet) -> String {
        String(self).trimmingCharacters(in: set)
    }
}
