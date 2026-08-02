# SwiftCSS

SwiftCSS is a small, standards-shaped Swift package for CSS selectors, declaration values, declaration blocks, simple stylesheet rules, and deterministic serialization.

It is intentionally separate from SwiftHTML so HTML, SVG, and future Dot export code can share the same CSS primitives without making HTML the owner of CSS.

## Current Scope

- Build selector text from official selector concepts: type, class, ID, attribute selectors, selector lists, combinators, pseudo-classes, and pseudo-elements.
- Build declaration values for common and modern CSS units, colors, URLs, custom properties, and CSS functions.
- Parse and serialize simple declaration-block contents.
- Parse and serialize simple top-level style rules while preserving selector text.
- Keep full browser CSS parser recovery, at-rules, nesting, and selector validation out of the core subset until they are needed.
