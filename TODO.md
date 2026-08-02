# SwiftCSS Implementation Order

1. Core CSS model
   - [x] Declaration names and values.
   - [x] Declaration blocks.
   - [x] Simple top-level style rules and stylesheets.
   - [x] Known CSS property inventory from W3C.
   - [x] Generated `CSSDeclarationName` conveniences for all known CSS property names.
   - [x] Common and modern value constructors.

2. Selectors
   - Add typed `CSSSelector` values for element, class, id, attribute, combinators, selector lists, pseudo-classes, and pseudo-elements.
   - Add modifier-like rule builders for pseudo-classes and pseudo-elements that serialize to official selector syntax.

3. Property helpers
   - Add ergonomic property-group helpers that expand prefixed APIs such as margin, padding, border, inset, and scroll-margin to ordinary flat CSS declarations.

4. Rules
   - Add media queries and supports queries.
   - Keep full browser CSS parser recovery out of scope unless explicitly needed.
