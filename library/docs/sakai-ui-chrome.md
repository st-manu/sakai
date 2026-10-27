# Sakai portal chrome contract

Stable CSS classes for the portal shell. Tools should target these when migrated; legacy `Mrphs-*` classes remain as aliases until each tool is updated.

| Slot | Class | Role |
|------|-------|------|
| HTML root | `.sakai-html` (+ legacy `.Mrphs-html`) | Document root; theme classes / `data-bs-theme` |
| Body | `.sakai-portal-body` (+ `.Mrphs-portalBody`) | Portal body |
| Shell grid | `.sakai-portal-wrapper` / `.portal-container` | CSS grid: sidebar + main (PASystem above) |
| Header (mobile) | `.sakai-portal-header--mobile` | Slim top bar on small screens only |
| Sidebar | `#portal-nav-sidebar` / `.sakai-sidebar` | Full-height: brand, user card, sites/tools, collapse |
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
| Tool alerts | `.portal-notifications-indicator` on `.sakai-sidebar-page__icon-wrap` | Novelty dot from `/api/sites/{id}` via `portal.sidebar.alerts.js` |
| All sites | `#select-site-sidebar` / `.sakai-sites-launcher` | Floating search-first panel. Sites tab: compact `sakai-course-card` (`show-pin` only here). Organize: `.sakai-reorder-*` |
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
- `.sakai-banner` (+ `--info` / `--success` / `--warn` / `--error`)
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

## Templates

Velocity templates live under `portal/.../vm/portal/` (config: `portal.templates=portal`).
