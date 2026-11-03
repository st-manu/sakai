# Icons: Bootstrap Icons standard

## Current standard

- **Bootstrap Icons** via `bi bi-*` classes
- Tool / nav mapping: `si si-sakai-*` in [`base/_icons.scss`](../src/skins/default/src/sass/base/_icons.scss)
- Institutions may override with `$customIcons`

Portal chrome and new `sakai-*` primitives use BI only. Banner icon Sass vars point at `.bi-*`.

## Legacy (do not use in new work)

| System | Location | Status |
|--------|----------|--------|
| Font Awesome 4 webfont | `sass/font-awesome/` | Legacy — remove when callers are gone |
| Lit FA SVG (`@sakai-ui/sakai-icon`) | `webcomponents/...` | Legacy — prefer `bi` in light DOM |

## Future purge

Tracked in [`niobe-front-rules/sakai-ui-tool-migration.md`](../../niobe-front-rules/sakai-ui-tool-migration.md). Do not block portal foundations on a monorepo-wide FA delete.
