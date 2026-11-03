# Sakai portal chrome contract

Stable CSS classes for the portal shell. Tools should target these when migrated; legacy `Mrphs-*` classes remain as aliases until each tool is updated.

| Slot | Class | Role |
|------|-------|------|
| HTML root | `.sakai-html` (+ legacy `.Mrphs-html`) | Document root; theme classes / `data-bs-theme` |
| Body | `.sakai-portal-body` (+ `.Mrphs-portalBody`) | Portal body |
| Shell grid | `.sakai-portal-wrapper` / `.portal-container` | CSS grid: sidebar + main (PASystem above) |
| Header (mobile) | `.sakai-portal-header--mobile` | Slim top bar on small screens only |
| Sidebar | `#portal-nav-sidebar` / `.sakai-sidebar` | Full-height: brand, user, **current-site tools** (`#toolMenu`), **recent sites** (flat + pin; no pinned list), footer |
| Breadcrumb | `.portal-header-breadcrumb` | All Sites › site › tool (same markup in toolbar + mobile chrome) |
| Main toolbar | `.sakai-main-toolbar` | Breadcrumbs + utilities (desktop) |
| Main canvas | `.sakai-main-column` / `.sakai-portal-main` | Grey page background around the card |
| Page content | `.sakai-page-content` | White content card |
| Page chrome | `.sakai-page-chrome` | Portal-owned strip above tool body |
| Page header bar | `.sakai-page-header__bar` | Role meta + View Site As |
| Page header | `.sakai-page-header` (+ `.Mrphs-toolTitleNav`) | **Multi-tool / home only**: portlet title (+ reset). Single-tool pages omit it — breadcrumb owns site › tool + reset |
| Tool body | `.sakai-tool-body` (+ `.Mrphs-toolBody`) | Tool markup or iframe wrapper; tool owns view-level H1/H2 |
| Tool header | `.sakai-tool-header` (+ `__title`, `__actions`) | Tool-owned view heading + primary/secondary/utility actions (A/B/C). Reference: Polls |
| Intra-tool nav | Legacy `.navIntraTool` until each tool migrates | Tool-owned exclusive views. Target: `.sakai-tool-nav` / `.sakai-segmented-control` + action buttons. Roadmap: [`niobe-front-rules/sakai-ui-tool-migration.md`](../../niobe-front-rules/sakai-ui-tool-migration.md) |
| Footer | `.portal-footer` | Links · copyright · “Powered by …” |
| Floating actions | `.sakai-portal-fabs` | Fixed stack (bottom-end): presence FAB + jump-to-top. Main scroller uses `--sakai-portal-fabs-clearance` |
| Current tool / Lessons page | `.selected-page` + `aria-current="page"` on `.sakai-sidebar-page__link` | Server-rendered for the active tool; Lessons subnav JS may move it to the active subpage without clearing when no Lessons match |
| Print hide | `.sakai-no-print` | Opt-out for chrome / chrome-adjacent UI. Defined in skin `print.scss` (`media="print"`). Aliases: `.noprint`, `.hidden-print` |
| Tool alerts | `.portal-notifications-indicator` on `.sakai-sidebar-page__icon-wrap` | Novelty dot from `/api/sites/{id}` via `portal.sidebar.alerts.js` |
| All sites | `#select-site-sidebar` / `.sakai-sites-launcher` | Floating search-first panel. Pinned badges strip + site cards. Organize: always “Organize Pinned” (`.sakai-reorder-*`) |
| Account menu | `#sakai-account-panel` / `.sakai-account-launcher` | Floating modal panel (same shell as sites launcher). Triggers: header avatar / sidebar user |
| Impersonation | `.swapped-view` / `body.Mrphs-become-user-enabled` | `--sakai-page-background` brand tint (mobile-visible) + top `box-shadow` strip; page-header bar unchanged |
| Pins | `.si-pin` / `.si-pin-fill` via `$customIcons` | Dual icons + `[data-pinned]` CSS show/hide — no hardcoded Bootstrap glyph codes |

### Title ownership

1. **Breadcrumb** (toolbar / mobile): where you are — site › tool. Tool crumb is the reset control.
2. **Portal page header title**: only when several portlets share the page (home / multi-tool).
3. **View heading**: the active tool view. Prefer the tool’s own heading over repeating the tool name.
4. **Intra-tool nav**: tool-owned; not the page title. Flat `.navIntraTool` is legacy — migrate when the tool is touched (see roadmap).

## Primitives (SCSS)

Defined under [`sass/components/`](../src/skins/default/src/sass/components/):

- `.sakai-btn`, `.sakai-btn-primary`, `.sakai-btn-secondary`, `.sakai-btn-ghost`, `.sakai-btn-icon`
- `.sakai-actions` (alias `.act`) — form/tool footer button row; uses `gap`, not per-child margins
- `.sakai-card`, `.sakai-page-content`
- `.sakai-page-header` (+ `__title`, `__meta`, `__actions`, `__breadcrumb`)
- `.sakai-tool-header` (+ `__title`, `__actions`, `__secondary`, `__more`) — wide: `__secondary` inline; narrow: `__more` (`…`). Do not unwrap a closed `<details>` with `display:contents`/`flex`.
- `.sakai-overflow-menu` (+ `__toggle`, `__panel`) — `…` for narrow header utilities and per-row secondary actions
- `.sakai-row-actions` (+ `__link`) — quiet per-row action + overflow menu
- `.sakai-segmented-control`, `.sakai-tool-nav`
- `.sakai-banner` (+ `--info` / `--success` / `--warn` / `--error`) — same as old `sak-banner-*`: put content directly in the element; icon comes from CSS by type
- `.sakai-form-control`, `.sakai-form-label`, `.sakai-form-group`
- `.sakai-table` (+ `--striped` / `--hover` / `--sm` / `--stack`), `.sakai-table-wrap`, `__select`, `__sort` — `--stack` turns rows into cards under `@container sakai-tool` (row owns hover/focus/checked; cells do not paint)
- `sakai-permissions` — shared permissions matrix (`.sakai-permissions` / `__table`); uses `.sakai-table` + `.sakai-actions`, not Bootstrap layout utilities

New portal markup must not use Bootstrap layout/spacing utilities (`d-flex`, `d-md-none`, `align-items-*`, `ms-*`, `p-*`, `gap-*`, …). Keep Bootstrap for components (`btn`, `modal`, `offcanvas`, `collapse`, …) behind `sakai-*` where needed.

## Responsive breakpoints

| Layer | Mechanism | Why |
|-------|-----------|-----|
| Portal shell (sidebar / mobile bar / main toolbar) | Viewport `@media` / Bootstrap breakpoints in SCSS | Chrome owns the full window |
| Tool content inside `.sakai-page-content` / `.sakai-tool-body` | CSS **container queries** (`container-type: inline-size`; `@container sakai-tool (...)`) | Tool width = viewport minus sidebar/toolbar |

## Icons

Use **Bootstrap Icons** (`bi-*`) or the tool map (`si si-sakai-*` in [`base/_icons.scss`](../src/skins/default/src/sass/base/_icons.scss)). Do not add Font Awesome in new work.

## CSS quality (Niobe chrome)

- Prefer tokens and `sakai-*` selectors; win cascade with specificity, not `!important`.
- Do not author visual `style="…"` on portal markup, and do not set visual properties from JS.
- Exception: collapsed rail flyout position may set CSS custom properties (`--sakai-rail-flyout-*`) on the open group host.

## Accessibility (portal chrome)

- Sidebar tools: `#current-site-pages` is a `role="tree"`; groups use `treeitem` toggles + `role="group"` panels. Lessons/Subsites: tool icon on the **root** only; nested rows are text + indent; small chevron on the **leading** edge of expandable rows.
- Keyboard: tree items are focusable (`tabindex="0"`); ArrowUp/Down/Home/End move focus; ArrowRight/Left (RTL-aware) expand/collapse groups.
- Collapsed rail: Lessons/Subsites keep their tool icon (tooltip = name); click opens a right-side flyout with the tree. Other tools keep icon + tooltip; click navigates.
- Status (hidden / locked / prerequisites): `.sakai-sidebar-page__chip` under the label — icon + text, not trailing icon-only.
- Pins: dual `.si-pin` / `.si-pin-fill` via `[data-pinned]` on **Recent** only; pinning removes the row from Recent (favorites still sync All Sites badges).
- Site icon: `.sakai-sidebar__site-icon` wraps optional `pageNavIconUrl` (legacy class `img_site_toolmenu` kept as alias).
- Sites launcher: plain action links (no `menubar`); tabpanels labelled by the tab **button** ids.
- Account: action items are buttons; theme control is a single `role="switch"` with a stable `aria-label`.

## Print

Skin print stylesheet: `library/src/skins/default/src/sass/print.scss` → `print.css`, linked with `media="print"` from the portal CSS snippet.

- **Contract:** put `.sakai-no-print` on any portal (or tool) chrome that must not appear when printing. Do not invent per-tool print hide utilities.
- **Aliases:** `.noprint` and `.hidden-print` still hide for legacy markup; new work uses `.sakai-no-print`.
- **Portal shell:** sidebar, mobile header, main toolbar, mobile bar, footer, fabs, skip nav, sites/account/notifications/quicklinks/direct-url panels carry `.sakai-no-print`.
- **Content:** print should leave `.sakai-page-content` / tool body readable. Tool-specific print tweaks stay in `print.scss` under the tool body class until that tool migrates its own print affordances.
- Prefer marking markup with `.sakai-no-print` over growing long ID lists in `print.scss`; keep a small structural safety net for critical shell nodes.

## Templates

Velocity templates live under `portal/.../vm/portal/` (config: `portal.templates=portal`).
