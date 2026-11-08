# Icons: Sakai icon map (`si`) over Bootstrap Icons

## The rule

Front-end markup consumes **`si si-*`**, never `bi bi-*`.

```html
<span class="si si-sakai-announcements" aria-hidden="true"></span>
<span class="si si-trash" aria-hidden="true"></span>
<button type="button" class="sakai-btn sakai-btn-ghost">
  <span class="si si-edit" aria-hidden="true"></span>
  Edit
</button>
```

`bi-*` appears **only inside** [`base/_icons.scss`](../src/skins/default/src/sass/base/_icons.scss),
where each `si-*` name is mapped to a Bootstrap Icons glyph. That file is the single source of truth:
changing an icon means changing one map value, not touching every template.

## How the map works

`base/_icons.scss` defines `$defaultIcons` and runs `@include sakai-icons($customIcons)`:

- `.si` extends `.bi` (the Bootstrap Icons base).
- Each `si-<name>` extends the mapped `bi-<glyph>`.
- Institutions can extend/override the map with `$customIcons`.
- The compiled CSS still contains `.bi-*` because Bootstrap Icons is the underlying font; that is an
  implementation detail. Front-end code must not depend on it.

The map has two kinds of names:

- **Semantic tool names**: `si-sakai-announcements`, `si-sakai-assignment-grades`, `si-sakai-resources`, …
  Use these for tool identity and navigation.
- **Generic UI names**: `si-add`, `si-edit`, `si-close`, `si-remove`, `si-trash`, `si-print`,
  `si-share`, `si-settings`, `si-attachment`, `si-filter`, `si-all-sites`, `si-arrow-*`,
  `si-chevron-*`, … Use these for generic UI actions. The generic block is **alphabetical** and
  contains only names that the front-end uses.

Prefer one canonical name per purpose. Do not reintroduce a second name for the same action
(`pencil`/`edit`, `x`/`close`, `gear`/`settings`, `printer`/`print`, `paperclip`/`attachment`, …).
If an icon needs a different glyph, change the map value, not the name used in markup.

Do not add a new `bi-*` class in markup. If an icon is missing, add a map entry and use `si-*`.

## Sizes

Use the icon size tokens, not Bootstrap font-size utilities:

| Class | Token | Size |
|---|---|---|
| `si-sm` | `--sakai-icon-sm` | 16px |
| `si-md` | `--sakai-icon-md` | 20px |
| `si-lg` | `--sakai-icon-lg` | 24px |

```html
<span class="si si-attachment si-sm" aria-hidden="true"></span>
```

Inside a button, the icon inherits the button text size unless a size class is needed. Do not use
`fs-*`, `fs-5`, `me-*` or other Bootstrap utilities to size/space icons; use the icon size class and
the button/action gap.

## Accessibility

- Decorative icons: `aria-hidden="true"` and no text alternative.
- Icon-only controls: `aria-label` (or a visually hidden label) that names the action.
- Status icons: pair with visible text; do not rely on the glyph alone.
- Do not use `title` as the only accessible name.
- Focus ring comes from the button/control, not from the icon.

## Legacy

| System | Location | Status |
|---|---|---|
| Font Awesome 4 webfont | `sass/font-awesome/` | Legacy — remove when callers are gone |
| Lit FA SVG (`@sakai-ui/sakai-icon`) | `webcomponents/...` | Legacy — replace with `si si-*` |
| Direct `bi bi-*` in front-end | templates/JS/Java | Legacy — replaced with `si si-*`; do not add new ones |
| CSS `content: "\F…"` glyphs | tool SCSS | Legacy — replace with an `si si-*` element when the tool is touched |

Track removals in [`niobe-front-rules/sakai-ui-tool-migration.md`](../../niobe-front-rules/sakai-ui-tool-migration.md)
and the legacy ledger in the audit prompt.

## Adding or changing an icon

1. Find the Bootstrap Icons glyph name (e.g. `bi-paperclip`).
2. Add or change one entry in `$defaultIcons` in `base/_icons.scss`:
   `attachment: bi-paperclip,`
3. Use `si si-attachment` in markup.
4. If the icon is tool-specific, prefer a semantic name (`sakai-<tool>`) and map it.
5. Do not edit Bootstrap Icons CSS or add a one-off `background-image`.
