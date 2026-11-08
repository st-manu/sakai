# Sakai UI design tokens

Tokens are the implementation of the Niobe design language. Read
[`sakai-ui-foundations.md`](sakai-ui-foundations.md) first for the principles, roles, states and
theming contract.

Sakai’s default skin uses **layered CSS custom properties**. Prefer the shallowest layer that meets
your need, and always consume a **role**, not a raw palette step.

> Role tokens are defined in `tokens/_primitives.scss` and `tokens/_semantic.scss`. The numbered
> vars remain migration aliases; new code consumes the roles. Do not invent a tool-local value.

| Layer | File | Audience | Rule |
|-------|------|----------|------|
| **T0 Primitives** | generated palette / scales | System only | Never consume directly in a tool. |
| **L0 Brand** | [`tokens/_brand.scss`](../src/skins/default/src/sass/tokens/_brand.scss) | Institutions | Logo, brand HSL, optional font family, logo sizes, radius personality. |
| **L1 Semantic** | [`tokens/_semantic.scss`](../src/skins/default/src/sass/tokens/_semantic.scss) | Product UI | Surface, text, border, interactive, status, focus, type and spacing roles. |
| **L2 Components** | [`tokens/_components.scss`](../src/skins/default/src/sass/tokens/_components.scss) | Components | Buttons, forms, tables, banners, cards, modals, menus. |
| **L3 Regions** | [`tokens/_portal.scss`](../src/skins/default/src/sass/tokens/_portal.scss) / `tokens/tools/` | Portal/tool region | Region-specific only; never a second design system. |
| **Legacy** | [`tokens/_legacy-light.scss`](../src/skins/default/src/sass/tokens/_legacy-light.scss) | Migration only | No new consumers; track in the legacy ledger. |

Dark theme overrides live in [`themes/_dark.scss`](../src/skins/default/src/sass/themes/_dark.scss)
and must define the **same semantic roles**, not a parallel set of tool vars.

> **Migration aliases:** the numbered vars (`--sakai-background-color-1..9`,
> `--sakai-text-color-1..3`, `--infoBanner-*`, …) remain during migration. New or touched code uses
> the role tokens below.

## Color roles

| Role | Token | Current alias / mapping |
|---|---|---|
| Canvas | `--sakai-surface-canvas` | `--sakai-page-background` |
| Card | `--sakai-surface-card` | `--sakai-card-background` / `--sakai-background-color-1` |
| Raised | `--sakai-surface-raised` | `--sakai-background-color-1` |
| Sunken | `--sakai-surface-sunken` | `--sakai-background-color-2/3` |
| Overlay | `--sakai-surface-overlay` | `--portal-mask-background` |
| Text primary | `--sakai-text-primary` | `--sakai-text-color-1` |
| Text secondary | `--sakai-text-secondary` | `--sakai-text-color-2` |
| Text muted | `--sakai-text-muted` | `--sakai-text-color-dimmed` |
| Text disabled | `--sakai-text-disabled` | `--sakai-text-color-disabled` |
| Text inverse | `--sakai-text-inverse` | `--sakai-text-color-inverted` |
| Border subtle | `--sakai-border-subtle` | `--sakai-border-color` |
| Border default | `--sakai-border-default` | `--sakai-border-color` |
| Border strong | `--sakai-border-strong` | `--sakai-border-color-modal` |
| Interactive primary | `--sakai-interactive-primary` | `--sakai-primary-color-1` |
| Interactive hover | `--sakai-interactive-hover` | `--sakai-primary-color-2` |
| Interactive active | `--sakai-interactive-active` | `--sakai-primary-color-3` |
| On interactive | `--sakai-on-interactive` | `--sakai-primary-text-color` (must be contrast-aware) |
| Focus ring | `--sakai-focus-ring` | `--focus-outline-color` + width/offset |
| Link | `--sakai-link` | `--link-color` |
| Link hover | `--sakai-link-hover` | `--link-hover-color` |
| Link visited | `--sakai-link-visited` | `--link-visited-color` |
| Selection | `--sakai-selection-bg` / `--sakai-selection-text` | new |
| Status info | `--sakai-status-info-bg` / `-border` / `-text` | `--infoBanner-*` |
| Status success | `--sakai-status-success-bg` / `-border` / `-text` | `--successBanner-*` |
| Status warn | `--sakai-status-warn-bg` / `-border` / `-text` | `--warnBanner-*` |
| Status error | `--sakai-status-error-bg` / `-border` / `-text` | `--errorBanner-*` |

Rules:

- Do not pick `--sakai-background-color-4` because it looks right; pick the role.
- `--sakai-on-interactive` must be chosen/tested for contrast against the institution's brand.
  Do not hardcode white.
- Status colors are only for status, not accents.
- Dark mode defines the same roles.

## Typography roles

| Role | Token | Size | Line height | Weight |
|---|---|---|---|---|
| Display | `--sakai-text-display` | 28px | 1.15 | 700 |
| H1 | `--sakai-text-h1` | 24px | 1.2 | 700 |
| H2 | `--sakai-text-h2` | 20px | 1.25 | 600 |
| H3 | `--sakai-text-h3` | 18px | 1.3 | 600 |
| Body | `--sakai-text-body` | 14px | 1.5 | 400 |
| Body SM | `--sakai-text-body-sm` | 12px | 1.45 | 400 |
| Label | `--sakai-text-label` | 12px | 1.3 | 600 |
| Caption | `--sakai-text-caption` | 11px | 1.3 | 400 |
| Code | `--sakai-text-code` | 13px | 1.4 | 400 |

- Font family: `--sakai-font-family` (system UI sans), `--sakai-font-family-heading` (system serif),
  `--sakai-font-family-mono` (system mono).
- Do not import external fonts. Institutional fonts must be self-hosted and declared in L0. The
  Google Fonts import has been removed from `_defaults.scss`.
- Use a role token; do not set `font-size`, `line-height` or `font-weight` ad hoc.
- Headings are sentence case; uppercase only for short labels/eyebrows.

## Spacing, layout, shape

Spacing scale (4px base):

| Token | Value |
|---|---|
| `--sakai-space-0` | 0 |
| `--sakai-space-0-5` | 2px |
| `--sakai-space-1` | 4px |
| `--sakai-space-2` | 8px |
| `--sakai-space-3` | 12px |
| `--sakai-space-4` | 16px |
| `--sakai-space-5` | 24px |
| `--sakai-space-6` | 32px |
| `--sakai-space-7` | 40px |
| `--sakai-space-8` | 48px |
| `--sakai-space-9` | 64px |

Semantic aliases: `--sakai-space-inline` (8px), `--sakai-space-stack` (8–12px),
`--sakai-space-section` (24px), `--sakai-space-page` (24px).

Spacing is a **system scale**, not a brand knob. Institutional overrides of `--sakai-space-*` are
unsupported because they break every layout. The current `_brand.scss` still defines the scale; treat
that as a migration artifact and move it to a primitives/system file.

Shape:

| Token | Value |
|---|---|
| `--sakai-radius-xs` | 2px |
| `--sakai-radius-sm` | 6px |
| `--sakai-radius-md` | 8px |
| `--sakai-radius-lg` | 12px |
| `--sakai-radius-xl` | 16px |
| `--sakai-radius-pill` | 999px |
| `--sakai-border-width` | 1px |
| `--sakai-border-width-strong` | 2px |

Layout:

- Portal shell uses viewport media queries; tools use `@container sakai-tool`.
- Forms/reading surfaces get a readable max width; tables may use full width.
- Section rhythm: section 24px, field 16px, inline 8px.

## Elevation, motion, z-index, focus

| Token | Value / use |
|---|---|
| `--sakai-elevation-card` | card |
| `--sakai-elevation-menu` | dropdown/popover |
| `--sakai-elevation-modal` | modal/offcanvas |
| `--sakai-elevation-toast` | toast/overlay |
| `--sakai-motion-fast` | 100ms |
| `--sakai-motion-base` | 150ms |
| `--sakai-motion-slow` | 250ms |
| `--sakai-motion-ease-standard` | `cubic-bezier(0.2, 0, 0, 1)` |
| `--sakai-motion-ease-in` | `cubic-bezier(0.4, 0, 1, 1)` |
| `--sakai-motion-ease-out` | `cubic-bezier(0, 0, 0.2, 1)` |
| `--sakai-z-sticky` | 100 |
| `--sakai-z-dropdown` | 1000 |
| `--sakai-z-overlay` | 1040 |
| `--sakai-z-modal` | 1050 |
| `--sakai-z-toast` | 1060 |
| `--sakai-focus-ring-width` | 3px |
| `--sakai-focus-ring-offset` | 2px |
| `--sakai-focus-ring` | `0 0 0 var(--sakai-focus-ring-width) var(--sakai-focus-ring-color)` |
| `--sakai-icon-sm/md/lg` | 16 / 20 / 24px |
| `--sakai-touch-target-min` | 24px |
| `--sakai-touch-target` | 2.5rem (35px) |

- Elevation is semantic; do not choose `--elevation-8dp` directly.
- Dark mode uses border + lower shadow; heavy black shadows are not dark-mode elevation.
- Motion uses tokens and `prefers-reduced-motion`; no attention animations.
- Align z-index with Bootstrap when wrapping a Bootstrap component.

## Dark mode

- Every semantic role has a dark value.
- No tool-specific dark overrides.
- Contrast is checked in both themes.
- Shadows are lower; borders carry separation.
- `--sakai-image-invert` and similar filters are legacy; prefer theme-appropriate assets.

## Institutional customization

Maven still supports:

```bash
mvn clean install -Dsakai.skin.customization.file=/path/to/custom.scss
```

**Supported (L0 only):** logo/icon light/dark, brand HSL, optional self-hosted font family, logo
dimensions/opacity, radius personality, page/card background when the brand requires it.

**Not supported:** spacing, type sizes, line heights, z-index, motion, semantic roles, L2/L3
per-tool overrides, arbitrary skin CSS.

If an institution needs a change outside L0, it should become a supported token or component
variant in Niobe, not a local override.

Compiled entry point: [`tool.scss`](../src/skins/default/src/sass/tool.scss) → `tool.css`.

## Governance and legacy

1. Propose the token/component in [`sakai-ui-foundations.md`](sakai-ui-foundations.md) or a design
   review.
2. Add it at the right layer and map existing aliases.
3. Consume it in the component; remove raw values.
4. Document states/anatomy/accessibility.
5. Deprecate the old token/class with an alias and a legacy-ledger entry.
6. Remove only when the ledger shows zero consumers.
7. Verify light/dark, brand tokens, contrast, keyboard and visual regression.

Do not add a token for a single tool. Do not keep a legacy alias “just in case” without a ledger
entry and a removal condition.
