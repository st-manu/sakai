# Sakai UI foundations (Niobe)

This is the design language behind the tokens, primitives and portal chrome. Tokens are the
implementation; this document explains **how the product should look, feel and behave**.

- Token reference: [`sakai-ui-tokens.md`](sakai-ui-tokens.md)
- Portal chrome contract: [`sakai-ui-chrome.md`](sakai-ui-chrome.md)
- Icons: [`sakai-ui-icons.md`](sakai-ui-icons.md)
- Working plan: [`niobe-front-rules/plan.md`](../../niobe-front-rules/plan.md)

**Status:** foundation implemented. The token roles below exist in `tokens/_primitives.scss` and
`tokens/_semantic.scss`; portal and tools migrate to them incrementally. Do not invent a tool-local
value. If a role is missing, add it at the right layer and document it.

## 1. Design principles

1. **Calm by default, content first.** The interface should recede so the course, the task and the
   data lead. Chrome is quiet; actions are deliberate.
2. **Predictable zones.** The same kind of control lives in the same kind of place: page header,
   object header, list toolbar, table, action footer. Consistency is structural, not identical.
3. **Institutional, not generic.** The institution owns the brand; Niobe owns the structure,
   spacing, typography and interaction. A skin should not need to rewrite layouts.
4. **Accessible by construction.** Contrast, focus, keyboard, target size, semantics and reduced
   motion are part of the component, not a later fix.
5. **Dense but breathable.** Sakai is a data-heavy LMS. Use compact density where the task needs it,
   but keep a clear rhythm between sections and actions.
6. **One system, many tools.** A tool is a surface inside Sakai, not a separate product. Moving
   between tools should feel like moving between rooms, not between applications.
7. **Functional motion only.** Motion explains a change; it never decorates or demands attention.

## 2. Visual language

### 2.1 Surfaces

| Surface | Use |
|---|---|
| **Canvas** | Page background around the content card. |
| **Card** | The main content surface (`.sakai-page-content`, cards, panels). |
| **Raised** | Menus, popovers, dropdown panels, floating editors. |
| **Sunken** | Wells, read-only areas, table headers, code blocks. |
| **Overlay** | Modal/offcanvas backdrop; never a content surface. |

Surfaces are separated by **one border and a restrained shadow**, not by heavy gradients or
decorative cards. Avoid card-in-card nesting unless the inner card is a real object.

### 2.2 Shape

Soft rectangles, 1px borders, moderate radii. Pills are reserved for tags, badges and segmented
controls; not for every button. Avoid mixed radius families in one view.

### 2.3 Color

- **Brand** is for primary action, current selection and identity. Do not use it for large
  backgrounds or decorative fills.
- **Neutral** carries structure: canvas, card, borders, text.
- **Status** (info/success/warn/error) is only for status. Never use status color as a brand accent.
- **Contrast is a requirement**: 4.5:1 for body text, 3:1 for large text and UI boundaries.
- **Status is never color-only**: pair it with text or an icon + text.

### 2.4 Typography

Use type **roles**, not ad-hoc sizes. The scale is intentionally small: display, h1, h2, h3, body,
body-sm, label, caption, code. Headings are sentence case. Avoid all-caps for long labels; reserve
uppercase for short eyebrows/section labels if the component needs it.

Default stacks:

- **Body/UI:** `ui-sans-serif, system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif`
- **Titles/headings:** `ui-serif, "Iowan Old Style", "Palatino Linotype", Palatino, "Book Antiqua", "Liberation Serif", "DejaVu Serif", Georgia, serif`
- **Code:** `ui-monospace, SFMono-Regular, Menlo, Consolas, "Liberation Mono", monospace`

No font files are distributed and no external font URL is loaded. Institutions may self-host a
licensed font and declare it in L0; the default uses system fonts for performance, privacy and
offline use.

### 2.5 Density

Default is **comfortable**. Data-heavy tables and admin lists may use **compact**. Density changes
row height and vertical gaps, not font size or touch targets. A tool must not invent a third density.

### 2.6 Motion

Motion is short, functional and optional. It explains opening, closing, expanding or moving. No
looping animation, no bouncing, no attention-seeking pulse, no delayed reveal to make an action
noticeable. Respect `prefers-reduced-motion`.

## 3. Foundations

### 3.1 Color roles

New code should consume **roles**, not numbered palette steps. During migration, the numbered
`--sakai-background-color-*` / `--sakai-text-color-*` vars are aliases.

| Role | Token (target) | Use |
|---|---|---|
| Canvas | `--sakai-surface-canvas` | Page background outside the card |
| Card | `--sakai-surface-card` | Main content surface |
| Raised | `--sakai-surface-raised` | Menus, popovers, floating panels |
| Sunken | `--sakai-surface-sunken` | Wells, read-only blocks, table headers |
| Overlay | `--sakai-surface-overlay` | Modal/offcanvas backdrop |
| Text primary | `--sakai-text-primary` | Body and headings |
| Text secondary | `--sakai-text-secondary` | Meta, help, secondary labels |
| Text muted | `--sakai-text-muted` | De-emphasised text |
| Text disabled | `--sakai-text-disabled` | Disabled controls |
| Text inverse | `--sakai-text-inverse` | Text on brand/strong backgrounds |
| Border subtle | `--sakai-border-subtle` | Dividers, table row lines |
| Border default | `--sakai-border-default` | Controls, cards |
| Border strong | `--sakai-border-strong` | Emphasis, selected boundaries |
| Interactive primary | `--sakai-interactive-primary` | Primary action, current selection |
| Interactive hover | `--sakai-interactive-hover` | Hover state |
| Interactive active | `--sakai-interactive-active` | Pressed state |
| Interactive text | `--sakai-on-interactive` | Text/icon on interactive fill |
| Focus ring | `--sakai-focus-ring` | Composite focus ring |
| Link | `--sakai-link` | Inline links |
| Link hover | `--sakai-link-hover` | Link hover |
| Link visited | `--sakai-link-visited` | Visited links |
| Selection | `--sakai-selection-bg` / `--sakai-selection-text` | Text selection, selected rows |
| Status info | `--sakai-status-info-bg` / `-border` / `-text` | Info banners, info badges |
| Status success | `--sakai-status-success-bg` / `-border` / `-text` | Success |
| Status warn | `--sakai-status-warn-bg` / `-border` / `-text` | Warning |
| Status error | `--sakai-status-error-bg` / `-border` / `-text` | Error/destructive |

Rules:

- Do not pick `--sakai-background-color-4` because it looks right. Pick the role.
- Do not introduce a new status color in a tool. Propose it here.
- `--sakai-primary-text-color` must be contrast-aware. Do not hardcode white on brand; compute or
  test the on-primary text color for the institution's brand.
- Dark mode defines the same roles, not a parallel set of tool vars.

### 3.2 Typography roles

| Role | Token | Size | Line height | Weight | Use |
|---|---|---|---|---|---|
| Display | `--sakai-text-display` | 28px | 1.15 | 700 | Login/empty hero, rare |
| H1 | `--sakai-text-h1` | 24px | 1.2 | 700 | Page/view title |
| H2 | `--sakai-text-h2` | 20px | 1.25 | 600 | Section title |
| H3 | `--sakai-text-h3` | 18px | 1.3 | 600 | Subsection/object title |
| Body | `--sakai-text-body` | 14px | 1.5 | 400 | Default UI text |
| Body SM | `--sakai-text-body-sm` | 12px | 1.45 | 400 | Meta, help, table secondary |
| Label | `--sakai-text-label` | 12px | 1.3 | 600 | Field/section labels |
| Caption | `--sakai-text-caption` | 11px | 1.3 | 400 | Badges, dense captions |
| Code | `--sakai-text-code` | 13px | 1.4 | 400 | Code, IDs, monospace |

Rules:

- No `font-size: 1.375rem` in a component. Use a role token.
- No new external font import. Use the tokenized font family; if an institution needs a font, it
  must be self-hosted and declared in L0. The current `_defaults.scss` still imports Google Fonts;
  treat that as legacy and replace it with a self-hosted or system stack.
- Line height and weight come with the role. Do not set them ad hoc unless the component has a
  documented reason.
- Headings are sentence case. Uppercase is only for short eyebrows/labels.

### 3.3 Spacing and layout

Scale (4px base): `0, 4, 8, 12, 16, 24, 32, 40, 48, 64` → `--sakai-space-0` … `--sakai-space-9`.

Spacing is a **system scale**, not a brand knob. Institutional overrides of `--sakai-space-*` are
unsupported because they break every layout. The current `_brand.scss` still defines the scale;
treat that as a migration artifact and move it to a primitives/system file.

Semantic aliases:

| Token | Use |
|---|---|
| `--sakai-space-inline` | Gap between inline controls/icons (8px) |
| `--sakai-space-stack` | Gap in a field/label stack (8–12px) |
| `--sakai-space-section` | Gap between form/list sections (24px) |
| `--sakai-space-page` | Page padding (24px) |

Layout rules:

- Tools use the available content width and `@container sakai-tool`, not viewport media queries.
- Forms and reading surfaces get a readable max width; tables and data grids may use full width.
  `--sakai-page-content-max-width: none` is not a license for 2,000px forms.
- Section rhythm: section → 24px, field → 16px, inline control → 8px. Do not invent 13px.
- Density changes row height and vertical gaps, not font size.

### 3.4 Shape, border, elevation

| Token | Use |
|---|---|
| `--sakai-radius-xs` (2px) | Dense tags, tiny controls |
| `--sakai-radius-sm` (6px) | Inputs, badges, small buttons |
| `--sakai-radius-md` (8px) | Default controls, cards |
| `--sakai-radius-lg` (12px) | Cards, panels |
| `--sakai-radius-xl` (16px) | Modals/offcanvas |
| `--sakai-radius-pill` (999px) | Tags, chips, segmented controls |
| `--sakai-border-width` (1px) | Default border |
| `--sakai-border-width-strong` (2px) | Selected/emphasis |
| `--sakai-elevation-card` | Card |
| `--sakai-elevation-menu` | Dropdown/popover |
| `--sakai-elevation-modal` | Modal/offcanvas |
| `--sakai-elevation-toast` | Toast/banner overlay |

Rules:

- One border + subtle shadow. No decorative shadows.
- Dark mode prefers border + lower shadow; a heavy black shadow is not a dark-mode elevation.
- Do not mix radius families in one view.

### 3.5 Motion

| Token | Value |
|---|---|
| `--sakai-motion-fast` | 100ms |
| `--sakai-motion-base` | 150ms |
| `--sakai-motion-slow` | 250ms |
| `--sakai-motion-ease-standard` | `cubic-bezier(0.2, 0, 0, 1)` |
| `--sakai-motion-ease-in` | `cubic-bezier(0.4, 0, 1, 1)` |
| `--sakai-motion-ease-out` | `cubic-bezier(0, 0, 0.2, 1)` |

Rules:

- Motion explains a change; it does not decorate.
- No looping, bouncing or attention-seeking animations.
- No delayed reveal to make an action noticeable. If it needs that, it is not a primary action.
- `@media (prefers-reduced-motion: reduce)` sets durations to near-zero and disables non-essential
  animation.
- Components define enter/exit/hover/press motion with tokens, not hardcoded `0.12s ease`.

### 3.6 Iconography

- Front-end consumes `si si-*` only; `bi-*` lives only in `base/_icons.scss` as the central map. Never add a direct `bi bi-*` in markup.
- Icon sizes: `--sakai-icon-sm` (16px), `--sakai-icon-md` (20px), `--sakai-icon-lg` (24px).
- Icons are paired with text for actions; icon-only requires an accessible name and a tooltip only
  as a supplement.
- Status is icon + text, not icon-only.
- Do not mix Font Awesome and the Sakai icon map in one view.

### 3.7 Interaction states

Every interactive component must define:

| State | Requirement |
|---|---|
| Rest | Default token. |
| Hover | Subtle surface/border change; no layout shift. |
| Active/pressed | Slightly stronger than hover. |
| Focus | Visible ring, 3px, offset 2px; never removed. |
| Selected/current | Distinct from hover; `aria-current`/`aria-selected`. |
| Disabled | Muted text + surface; cursor not-allowed; no hover/active. |
| Loading | Spinner/skeleton + accessible status; control disabled while pending. |
| Error | Error text/border + accessible message; not color-only. |
| Success | Brief, text-based; not a color flash. |
| Read-only | Looks editable but not; no disabled color unless truly disabled. |
| Dirty/unsaved | Visible indicator; confirm before leaving. |

If a component does not define a state, it is incomplete.

### 3.8 Content and voice

- **Sentence case** for labels, headings, buttons and messages.
- **Verbs for actions**, nouns for places: “Add assignment”, “Grade report”, “Permissions”.
- **Empty state**: what is empty, why it matters, one action.
- **Error**: what happened, what to do next, no blame, no raw stack.
- **Confirmation**: name the object and the consequence; destructive action last.
- **Success**: brief and specific.
- **Dates, numbers, names**: use Sakai locale and timezone; never browser defaults.
- **No jargon** in student-facing copy; instructor/admin copy may use domain terms.
- **No color-only status**; include text.

### 3.9 Data display

- Tables are the default for comparable data; charts are supporting, not decoration.
- Use a fixed, accessible series palette; do not invent per-tool chart colors.
- Every chart has a title, axis/legend labels and an accessible table or text summary.
- Do not rely on red/green alone; pair status with text/icons.
- Badges and progress include text; avatars have initials/fallback.
- Avoid 3D, pie-by-default and decorative chart effects.

### 3.10 Responsive and density

- Portal shell: viewport media queries.
- Tools: container queries (`@container sakai-tool`).
- Compact/medium/wide tiers for action overflow; see `navigation-model.md`.
- Touch targets: minimum 24px; prefer 40–44px for primary touch controls.
- Tables: stacked layout under 40rem; primary cell as row title.
- Forms: single column under 48rem; two/three columns only when the content benefits.
- No horizontal scroll for the page; tables may scroll inside their wrapper.

### 3.11 Accessibility baseline

- WCAG 2.2 AA: 4.5:1 text, 3:1 large text/UI, visible focus, keyboard operable.
- Real `<button>` for actions, `<a href>` for navigation.
- Accessible names; no `title`-only names.
- Honest ARIA; no fake `menu`/`menubar` without a keyboard model.
- Status as text; no color-only.
- Focus not trapped; modals restore focus.
- Reduced motion respected.
- Target size at least 24×24px; prefer 44×44px.
- Headings ordered; one H1 per view.

## 4. Token architecture

| Layer | File | Audience | Rule |
|---|---|---|---|
| **T0 Primitives** | generated palette, scales | System only | Never consume directly in a tool. |
| **L0 Brand** | `tokens/_brand.scss` | Institutions | Logo, brand HSL, optional font family, logo sizes, radius personality. |
| **L1 Semantic** | `tokens/_semantic.scss` | Product UI | Roles: surface, text, border, interactive, status, focus. |
| **L2 Components** | `tokens/_components.scss` | Components | Button, form, table, banner, card, modal, menu. |
| **L3 Regions** | `tokens/_portal.scss` / `tokens/tools/` | Portal/tool region | Region-specific only; never a second design system. |
| **Legacy** | `tokens/_legacy-light.scss` | Migration only | No new consumers; track in the legacy ledger. |

Naming:

- Role first: `--sakai-<role>-<variant>-<state>`.
- Example: `--sakai-surface-card`, `--sakai-text-secondary`, `--sakai-status-error-bg`,
  `--sakai-btn-primary-bg-hover`.
- Do not add a token for a single tool. If a tool needs a one-off, it is a component variant or a
  design review, not a token.

## 5. Theming contract

**Supported institutional overrides (L0):**

- Logo light/dark, icon light/dark, logo dimensions/opacity.
- Brand HSL.
- Optional self-hosted font family.
- Radius personality within a bounded range.
- Page/card background only when the brand requires it.

**Not supported:**

- Spacing scale, type sizes, line heights, z-index, motion, semantic color roles.
- Component tokens (L2) or region tokens (L3) per tool.
- Arbitrary CSS overrides in a custom skin.
- External font imports (performance, privacy, offline).

If an institution needs a change outside L0, it should become a supported token or a component
variant in Niobe, not a local override.

**Dark mode:**

- Every semantic role has a dark value.
- No tool-specific dark overrides.
- Contrast is checked in both themes.
- Elevation in dark mode uses border + lower shadow, not a heavy black shadow.

## 6. Governance

1. **Propose** the token/component in this doc or a design review.
2. **Add** the token at the right layer (L1/L2/L3) and map it from existing aliases.
3. **Consume** it in the component; do not leave raw values.
4. **Document** the component's states, anatomy and accessibility.
5. **Deprecate** the old token/class with an alias and a legacy-ledger entry.
6. **Remove** only when the ledger shows zero consumers.
7. **Verify** with light/dark, brand tokens, contrast, keyboard and visual regression.

Visual regression and contrast checks belong in CI. A component is not “done” because it looks right
on one screen; it is done when it survives the matrix.

## 7. Anti-patterns

- Bootstrap utility soup (`d-flex`, `mt-4`, `p-2`, `w-100`, …) in new markup.
- Tool-local hex/rgb colors or raw shadows.
- Numbered token picking (`--sakai-background-color-4`) instead of a role.
- One-off cards, gradients, glassmorphism or decorative shadows.
- Multiple primary buttons on one surface.
- Icon-only status, icon-only actions without an accessible name.
- Attention-seeking animation or delayed reveal.
- External font imports.
- Per-tool dark themes or per-tool L2/L3 overrides.
- “Deep mode” skin overrides treated as supported design.
- Native `<select multiple>`, `.sakai-form-group`, `instruction`, `reqStarInline`.

## 8. Checklist for a new component

- [ ] Uses T0/L1/L2 tokens; no raw color, size, spacing, radius, shadow or motion values.
- [ ] Defines rest/hover/active/focus/selected/disabled/loading/error/read-only states.
- [ ] Works in light and dark.
- [ ] Works at compact/medium/wide containers.
- [ ] Keyboard operable; focus visible; accessible name.
- [ ] Status text, not color-only.
- [ ] Long labels and translations do not overflow.
- [ ] Print behaviour defined (`.sakai-no-print` where needed).
- [ ] Motion uses tokens and respects `prefers-reduced-motion`.
- [ ] Documented in the relevant reference; legacy/deprecation recorded.
