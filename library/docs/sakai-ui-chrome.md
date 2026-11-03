# Sakai portal chrome contract

Stable CSS classes for the portal shell. Tools should target these when migrated; legacy `Mrphs-*` classes remain as aliases until each tool is updated.

| Slot | Class | Role |
|------|-------|------|
| HTML root | `.sakai-html` (+ legacy `.Mrphs-html`) | Document root; theme classes / `data-bs-theme` |
| Body | `.sakai-portal-body` (+ `.Mrphs-portalBody`) | Portal body |
| Shell grid | `.sakai-portal-wrapper` / `.portal-container` | CSS grid: sidebar + main (PASystem above) |
| Header (mobile) | `.sakai-portal-header--mobile` | Slim top bar on small screens only |
| Sidebar | `#portal-nav-sidebar` / `.sakai-sidebar` | Full-height: brand, user, **current-site tools** (`#toolMenu`), footer |
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
| All sites | `#select-site-sidebar` / `.sakai-sites-launcher` | Floating search-first panel. Pinned badges strip, recent badges strip, then site cards. Organize: always “Organize Pinned” (`.sakai-reorder-*`) |
| Account menu | `#sakai-account-panel` / `.sakai-account-launcher` | Floating modal panel (same shell as sites launcher). Compact top-right card on mobile; only the sites launcher goes full-screen. Triggers: header avatar / sidebar user |
| Impersonation | `.swapped-view` / `body.Mrphs-become-user-enabled` | `--sakai-page-background` brand tint (mobile-visible) + top `box-shadow` strip; page-header bar unchanged |
| Pins | `.si-pin` / `.si-pin-fill` via `$customIcons` | Dual icons + `[data-pinned]` CSS show/hide — no hardcoded Bootstrap glyph codes |

### Title ownership

1. **Breadcrumb** (toolbar / mobile): where you are — site › tool. Tool crumb is the reset control.
2. **Portal page header title**: only when several portlets share the page (home / multi-tool).
3. **View heading**: the active tool view. Prefer the tool’s own heading over repeating the tool name.
4. **Intra-tool nav**: tool-owned; not the page title. Flat `.navIntraTool` is legacy — migrate when the tool is touched (see roadmap).

### Tool header and actions

Every view of a tool renders `.sakai-tool-header` (view H1 + separator). The action cluster is
**tool level, not view level**:

- **Tool home**: the A/B/C actions from the tool menu — create as `.sakai-btn-primary`, utilities
  as `.sakai-btn-secondary`, permissions as `.sakai-btn-ghost`. Utilities show inline next to the
  primary action only when there are **at most three**; more than three collapse into `…` at every
  width. Narrow containers collapse them too.
- **Several A views**: render the **other** views as `.sakai-btn-secondary` in the action cluster;
  the current view is never rendered. They follow the same ≤3 / narrow overflow rule.
- **Action order** (every view): primary first, secondary/views next, return/back next, overflow
  (`…`) **last**. Never place a return/back after the overflow.
- **Detail and flow views** (add, edit, bulk, permissions, options, reorder, merge, preview):
  a single `Return to List` action. Do not repeat the global create/utility cluster there: an
  “Add” next to “Permissions” reads as “add permissions”.
- An item detail view may expose object actions (edit/delete) instead of the global cluster.
- The current view's action is never rendered as a link; the tool home is also the breadcrumb
  tool crumb. Flow buttons (save/cancel/preview) stay in `.sakai-actions` at the end of the form.

Shared implementation: `#sakaiToolHeader()` in `velocity/tool/src/templates/VM_chef_library.vm`
renders the heading plus menu-driven actions; the shared permissions template uses it, so every
tool's permissions page keeps the same heading and separator.

## Primitives (SCSS)

Defined under [`sass/components/`](../src/skins/default/src/sass/components/):

- `.sakai-btn`, `.sakai-btn-primary`, `.sakai-btn-secondary`, `.sakai-btn-ghost`, `.sakai-btn-icon`
- `.sakai-actions` (alias `.act`) — form/tool footer button row; uses `gap`, not per-child margins. Order and weight: primary save/confirm first, alternative actions as `.sakai-btn-secondary`, cancel/back/return as `.sakai-btn-ghost`
- `.sakai-card`, `.sakai-page-content`
- `.sakai-page-header` (+ `__title`, `__meta`, `__actions`, `__breadcrumb`)
- `.sakai-tool-header` (+ `__title`, `__actions`, `__secondary`, `__more`, `__actions--collapsed`) — at ≥48rem container: up to three secondary actions inline, more than three always in `__more` (`…`); narrower: `__more` (`…`). Title wraps without collapsing and actions move to their own line when needed. Do not unwrap a closed `<details>` with `display:contents`/`flex`.
- `.sakai-overflow-menu` (+ `__toggle`, `__panel`) — `…` for narrow header utilities and per-row secondary actions; inside `.sakai-table` the panel is lifted to a fixed layer by the global body bundle so it escapes the table's scroll container
- `.sakai-row-actions` (+ `__link`) — quiet per-row action + overflow menu
- `.sakai-segmented-control`, `.sakai-tool-nav`
- `.sakai-banner` (+ `--info` / `--success` / `--warn` / `--error`) — same as old `sak-banner-*`: put content directly in the element; icon comes from CSS by type
- `.sakai-form-control`, `.sakai-form-label`, `.sakai-form-group`
- `.sakai-form-section` (+ `__title`, `__intro`, `__heading`), `.sakai-form-grid` (+ `--3`), `.sakai-form-field` (+ `--span-2`), `.sakai-form-divider`, `.sakai-form-help`, `.sakai-form-choice` — shared form composition: flat sections (no tool cards), responsive grids, label/control/help stacks and radio/checkbox rows
- `.sakai-table-toolbar` (+ `__filters`, `__scope`) — search / view filter / pager strip for list views. The three blocks are emitted by the shared `#searchFilterPanel`, `#viewFilterPanel` and `#pagerPanel` Velocity macros (`.sakai-table-searchFilter`, `.sakai-table-viewFilter`, `.sakai-table-pagerContainer`), so every tool that uses them gets the same pattern
- `.sakai-table` (+ `--striped` / `--hover` / `--sm` / `--stack`), `.sakai-table-wrap`, `__select`, `__sort`, `__actions`, `__primary`, `__nowrap` — cells are transparent so tables inherit the content card surface in light and dark; mark the important content column with `__primary` (absorbs extra width and keeps a 16rem floor on desktop); use `__nowrap` for single-line values such as timestamps; on mobile the wrap owns one outer border + radius and `--stack` rows are separated by a single border, with `data-label` cells laid out as a label/value grid; sortable `<th>` carries `aria-sort` and a `.sakai-table__print-label` for print
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
- Pins: dual `.si-pin` / `.si-pin-fill` via `[data-pinned]` on the sites-launcher badges only; pinning moves a recent badge into the pinned strip.
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
