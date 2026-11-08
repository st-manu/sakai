# Sakai portal chrome contract

Stable CSS classes for the portal shell. Tools should target these when migrated; legacy `Mrphs-*` classes remain as aliases until each tool is updated.

Visual language, type/spacing/color/state/motion: [`sakai-ui-foundations.md`](sakai-ui-foundations.md).

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
| Tool header | `.sakai-tool-header` (+ `__title`, `__actions`) | Tool-owned view heading + R and P0/P1–P4 action zones. A1 places go in `.sakai-tool-nav`, not here. Reference: Polls |
| Intra-tool nav | Legacy `.navIntraTool` until each tool migrates | Tool-owned **places**: A1 peer sections in `.sakai-tool-nav`, A2 object views in `.sakai-segmented-control` / object tabs; R return is a quiet back link, not an action. Actions are buttons, never tabs. Model: [`niobe-front-rules/navigation-model.md`](../../niobe-front-rules/navigation-model.md) |
| Footer | `.portal-footer` | Links · copyright · “Powered by …” |
| Floating actions | `.sakai-portal-fabs` | **Portal-owned** fixed stack (bottom-end): presence FAB + jump-to-top. Tools must not inject actions into it. Main scroller uses `--sakai-portal-fabs-clearance` |
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
4. **Intra-tool nav / return**: tool-owned; not the page title. It contains places (A1/A2) and the R back link, not actions. Flat `.navIntraTool` is legacy — migrate when the tool is touched (see [`navigation-model.md`](../../niobe-front-rules/navigation-model.md)).

### Tool header and actions

Every view of a tool renders `.sakai-tool-header` (view H1 + separator). The header owns **identity
and surface navigation**, not every action in the tool.

- **Return/up (R)**: a quiet back link or local breadcrumb on the leading side, e.g. `← Assignments`.
  It is navigation, not an action; never put it in the action cluster or `…`. Do not duplicate the
  footer Cancel on a flow.
- **Surface primary (P0-S)**: one maximum, trailing, e.g. Add or Compose. It repeats in the empty
  state. It does not appear on detail or flow views.
- **Object primary (P0-O)**: belongs to the object header (Edit, Reply), not the page header.
- **Flow primary (P0-F)**: Save/Submit belongs in `.sakai-actions` at the end of the form. Never in
  the page header.
- **Bulk primary (P0-B)**: belongs to the selection bar/table footer, not the page header.
- **Frequent secondary (P1)**: maximum one; visible from medium width.
- **Occasional secondary (P2)**: maximum two; visible only at wide width, otherwise `…`.
- **Utilities (P3)** and **destructive (P4)**: always in `…`; destructive is separated and
  confirmed.
- **Several A1 views**: render the **other** peer sections as `.sakai-tool-nav` below the header;
  the current view is the selected item (`aria-current="page"`), never a button and never a disabled
  link. A1 is never in `…`.
- **A1 limit**: 2–5 peers use `.sakai-tool-nav`; more than five need grouping (hub or grouped nav)
  before markup is written. A single home view uses the H1 only.

Shared implementation: `#sakaiToolHeader()` in `velocity/tool/src/templates/VM_chef_library.vm`
renders the heading plus menu-driven actions. It does **not** yet render R, A1 peers or the
P1/P2/P3/P4 priority model: a tool with those needs emits the rest of the header explicitly until
the macro gains typed slots.

### Tool navigation model

A tool screen is a **surface**, and every control belongs to a **zone**. Full audit, decision tree
and worked examples: [`niobe-front-rules/navigation-model.md`](../../niobe-front-rules/navigation-model.md).

| Role | Meaning | Where it goes |
|------|---------|---------------|
| **R** | Return/up to the parent surface | Quiet back link / breadcrumb, leading side. Not an action. |
| **A1** | Tool sections: peer destinations at the tool level | `.sakai-tool-nav`, current with `aria-current="page"` |
| **A2** | Object views: peer views of the selected object | `.sakai-segmented-control` or object tabs |
| **A3** | Nested tool: self-contained workspace | Clear entry action + nested H1 + own A1 + R |
| **P0-S** | Surface primary: create/do on the list/home | Page header trailing; repeat in the empty state |
| **P0-O** | Object primary: act on the selected object | Object header |
| **P0-F** | Flow primary: commit the form | `.sakai-actions` at the end of the form |
| **P0-B** | Bulk primary: act on the selection | Selection bar / table footer |
| **P1/P2** | Frequent/occasional secondary | Header, priority tiers |
| **P3/P4** | Utility/destructive | `…`, separated and confirmed |
| **D** | Search, filter, sort, pager, select-all, bulk | `.sakai-table-toolbar` / table head / bulk bar |
| **M** | Preview another role or change the audience | Explicit switch + banner + exit; portal “View Site As” first |

Zones:

| Zone | Owns | Must not contain |
|---|---|---|
| Page header | H1, R, P0-S, P1/P2, P3/P4 overflow | Object actions, Save/Submit, bulk actions, search/filter |
| Object header | Object identity, A2, P0-O, object P3/P4 | Global Add, Permissions, list toolbar |
| List toolbar | D | Create actions, navigation, object actions |
| Table / row | Row data and row actions | Global actions |
| Empty state | The same P0-S, in context | A different primary action |
| Action footer | P0-F, Cancel/Return, bulk P0-B | Surface navigation, global utilities |
| Nested header | Nested H1, R to parent, nested A1/P0 | Parent A1/P0 cluster |

Responsive tiers (container queries, not viewport):

| Tier | Container | Visible in the header | In `…` |
|---|---|---|---|
| **Compact** | `< 36rem` | R + P0 | P1, P2, P3, P4 |
| **Medium** | `36rem–47.999rem` | R + P0 + P1 | P2, P3, P4 |
| **Wide** | `>= 48rem` | R + P0 + P1 + P2 | P3, P4 |

Rules:

- **Places and actions never share a group.** Tabs are destinations; buttons perform actions.
- **R is navigation.** No “Return to list” button in the action cluster; use a specific back link.
  Do not add R everywhere: if the portal crumb or the footer Cancel already gives one clear exit,
  do not add another.
- **P0 is not one role.** P0-S/O/F/B live in different zones. Save/Submit never goes in the page
  header; bulk actions never appear before a selection exists.
- **No count-based collapse.** P1 max 1, P2 max 2; P3/P4 always in `…`. The server assigns
  priorities; CSS container queries decide visibility. Retire `utilityCount`/`--collapsed`.
  Do not hide every secondary action for uniformity: P1/P2 stay visible at their tier.
- **No empty `…`.** Render it only when there is something to hide.
- **No dead ends.** Every non-home surface has one obvious exit (R, portal tool crumb or footer Cancel).
- **Nested tools** hide the parent cluster, render their own H1 + A1 + R to the parent.
- **D is not navigation.** Search/filter/pager/bulk stay with the data.
- **Current state** is a selected item, not a dead chip or a disabled link.
- **No general FAB.** The portal FAB stack is portal chrome (presence + jump-to-top). Tools do not
  inject actions into it. A sticky action bar inside `.sakai-tool-body` is preferred for the narrow,
  content-light niche; no 2–3 s attention animation.

## Primitives (SCSS)

Defined under [`sass/components/`](../src/skins/default/src/sass/components/):

- `.sakai-btn`, `.sakai-btn-primary`, `.sakai-btn-secondary`, `.sakai-btn-ghost`, `.sakai-btn-icon`
- `.sakai-actions` (alias `.act`) — action row for **P0-F flow footers and P0-B bulk actions**, and inline section actions; uses `gap`, not per-child margins. Order and weight: primary save/confirm first, alternative actions as `.sakai-btn-secondary`, cancel/back/return as `.sakai-btn-ghost`, overflow (`…`) last. It is **not** a universal replacement for `navIntraTool`: surface navigation belongs in `.sakai-tool-nav`, and R is a back link.
- `.sakai-card`, `.sakai-page-content`
- `.sakai-page-header` (+ `__title`, `__actions`)
- `.sakai-tool-header` (+ `__title`, `__actions`, `__secondary`, `__more`) — the secondary cluster is visible at the wide container (≥48rem); below that, utilities move into `…`. Tools with explicit P1/P2 priorities can add their own tier classes. Title wraps without collapsing and actions move to their own line when needed. There is no `__actions--collapsed`/`utilityCount` rule. Do not unwrap a closed `<details>` with `display:contents`/`flex`.
- `.sakai-back-link` — quiet R affordance above the H1 (`si si-arrow-left` + a specific parent label such as “Back to list” or “Back to reports”). Not a secondary button. Use “Back to …” consistently; do not mix “Return to list” and “Back to list” for the same action.
- `.sakai-overflow-menu` (+ `__toggle`, `__panel`) — `…` for narrow header utilities and per-row secondary actions; inside `.sakai-table` and `.sakai-tool-header__actions` the global body bundle lifts the panel to a fixed layer, escapes scroll containers and clamps it inside the viewport (left/right/top/bottom)
- `.sakai-row-actions` (+ `__link`) — quiet per-row action + overflow menu
- `.sakai-segmented-control` — in-place switch between panels (`aria-selected`); `.sakai-tool-nav` — A1 peer destinations below the tool header (current item `aria-current="page"`, not a dead chip)
- `.sakai-banner` (+ `--info` / `--success` / `--warn` / `--error`) — same as old `sak-banner-*`: put content directly in the element; icon comes from CSS by type
- `.sakai-form-control`, `.sakai-form-label` (+ `.required`), `.sakai-form-error`
- `.sakai-form-section` (+ `__title`, `__intro`), `.sakai-form-grid` (+ `--3`), `.sakai-form-field` (+ `--span-2`), `.sakai-form-subfield`, `.sakai-form-help`, `.sakai-form-choice`, `.sakai-form-choice-group` (+ `--scroll`) — shared form composition: flat sections (no tool cards), responsive grids, label/control/help stacks and radio/checkbox rows
- `.sakai-table-toolbar` (+ `__filters`, `__scope`) — search / view filter / pager strip for list views. The three blocks are emitted by the shared `#searchFilterPanel`, `#viewFilterPanel` and `#pagerPanel` Velocity macros (`.sakai-table-searchFilter`, `.sakai-table-viewFilter`, `.sakai-table-pagerContainer`), so every tool that uses them gets the same pattern
- `.sakai-table` (+ `--striped` / `--hover` / `--sm` / `--stack`), `.sakai-table-wrap`, `__select`, `__sort`, `__actions`, `__primary`, `__nowrap` — cells are transparent so tables inherit the content card surface in light and dark; mark the important content column with `__primary` (absorbs extra width and keeps a 16rem floor on desktop); use `__nowrap` for single-line values such as timestamps; on mobile the wrap owns one outer border + radius, the stacked table/header/body rows fill the wrap width, and `--stack` rows are separated by a single border, with `data-label` cells laid out as a label/value grid; `.sakai-table__primary` cells render as the row title without a label; sortable `<th>` carries `aria-sort` and a `.sakai-table__print-label` for print. For server-rendered tables (JSF) the shared body script copies the visible `thead` text into `data-label`, so `--stack` alone is enough; empty cells are hidden. **Dense metadata (tags, status, availability) goes inside the `__primary` cell under the main text**, not in a separate column: use a wrapping `.sakai-badge` row so the table keeps its width and the extra column does not push the row actions out of view.
- `sakai-permissions` — shared permissions matrix (`.sakai-permissions` / `__table`); uses `.sakai-table` + `.sakai-actions`, not Bootstrap layout utilities

### Form conventions

- **Section vs field label**: `.sakai-form-section__title` names a section (`WHAT?`, `Limits`,
  `Recipients`). `.sakai-form-label` names a field or a choice group (`Totals by`, `Tools`,
  `Events`, `Selected users`). A group legend uses `.sakai-form-label`, not a section title.
- **One field wrapper**: `.sakai-form-field` is the only field wrapper (`.sakai-form-group` is
  retired). It owns the label/control/help stack and the gap between them.
- **Legacy `legend` reset**: the Morpheus skin still styles `legend` with `display:inline-block`,
  padding and float. The shared `.sakai-form-label` and `.sakai-form-section__title` reset those
  properties, so a `<legend class="sakai-form-label">` and a `<label>` render identically.
- **Required and errors**: mark required labels with `.sakai-form-label.required` (the asterisk is
  CSS); render field errors with `.sakai-form-error`. Do not reintroduce the old
  `instruction` / `reqStarInline` required-legend block.
- **Choice groups**: checkboxes/radios use `.sakai-form-choice-group` with one `.sakai-form-choice`
  per row. Use `--scroll` when the list can be long (events, users, groups). Do not leave a native
  `<select multiple>` in a form: replace it with a choice group. Keep a Select2-enhanced single
  control (Messages recipients) as-is; it is not a visible native multi-select.
- **Subfields and grids**: nested conditional options use `.sakai-form-subfield`. Consecutive
  `.sakai-form-grid` blocks get their separation from `.sakai-form-grid + .sakai-form-grid`; a
  section after a grid or field gets it from `.sakai-form-grid + .sakai-form-section` /
  `.sakai-form-field + .sakai-form-section`; a field after a standalone choice row gets it from
  `.sakai-form-choice + .sakai-form-field`. Do not add per-form margins or dividers.
- **No width caps**: forms use the available tool width; no per-form `max-width`.
- **Actions**: the same `.sakai-actions` row closes every form. Save/confirm is
  `.sakai-btn-primary`; preview, save-draft and other alternatives are `.sakai-btn-secondary`;
  cancel, back and return are `.sakai-btn-ghost`; overflow is last.

New portal markup must not use Bootstrap layout/spacing utilities (`d-flex`, `d-md-none`, `align-items-*`, `ms-*`, `p-*`, `gap-*`, …). Keep Bootstrap for components (`btn`, `modal`, `offcanvas`, `collapse`, …) behind `sakai-*` where needed.

## Responsive breakpoints

| Layer | Mechanism | Why |
|-------|-----------|-----|
| Portal shell (sidebar / mobile bar / main toolbar) | Viewport `@media` / Bootstrap breakpoints in SCSS | Chrome owns the full window |
| Tool content inside `.sakai-page-content` / `.sakai-tool-body` | CSS **container queries** (`container-type: inline-size`; `@container sakai-tool (...)`) | Tool width = viewport minus sidebar/toolbar |

## Icons

Front-end consumes **`si si-*`** only. `bi-*` lives only in [`base/_icons.scss`](../src/skins/default/src/sass/base/_icons.scss) as the central map; add or change an icon there. Do not add Font Awesome in new work.

## CSS quality (Niobe chrome)

- Prefer tokens and `sakai-*` selectors; win cascade with specificity, not `!important`.
- Do not author visual `style="…"` on portal markup, and do not set visual properties from JS.
- Exception: collapsed rail flyout position may set CSS custom properties (`--sakai-rail-flyout-*`) on the open group host.

## Accessibility (portal chrome)

- Sidebar tools: `#current-site-pages` is a `role="tree"`; groups use `treeitem` toggles + `role="group"` panels. Lessons/Subsites: tool icon on the **root** only; nested rows are text + indent; small chevron on the **leading** edge of expandable rows.
- Keyboard: tree items are focusable (`tabindex="0"`); ArrowUp/Down/Home/End move focus; ArrowRight/Left (RTL-aware) expand/collapse groups.
- Collapsed rail: Lessons/Subsites keep their tool icon (tooltip = name); click opens a right-side flyout with the tree. Other tools keep icon + tooltip; click navigates.
- Status (hidden / locked / prerequisites): `.sakai-sidebar-page__chip` under the label — icon + text, not trailing icon-only.
- Pins: dual `.si-pin` / `.si-pin-fill` via `[data-pinned]` on the sites-launcher badges only. A pinned site can also appear in the recent strip; the badge carries `isPinned` so the UI can show both. The current site is excluded from recents. `portal.max.recent.sites` is the number shown; one extra row is stored to keep the current site available before filtering.
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
