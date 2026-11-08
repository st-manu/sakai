# Statistics — multi-view Thymeleaf reference

Statistics is the reference for a Thymeleaf tool with **several exclusive views (A1)** and
shared Lit widgets that also render on the dashboard. Use it together with
[`polls-reference.md`](polls-reference.md) (Thymeleaf home/flow views) and
[`announcements-reference.md`](announcements-reference.md) (server menu, Velocity).

Chrome contract: [`library/docs/sakai-ui-chrome.md`](../library/docs/sakai-ui-chrome.md).
Playbook: [`sakai-ui-tool-migration.md`](sakai-ui-tool-migration.md).

## A1/P0/P3 in Statistics

| Item | Kind | Markup |
|------|------|--------|
| Overview / Reports / User Activity / Preferences | **A1** | `.sakai-tool-nav` below the header; current item has `aria-current="page"` and `is-active` |
| Summary / All sites / Server-wide Reports (admin) | **A1** | Same `.sakai-tool-nav` pattern |
| Add report | **P0-S** | `.sakai-btn-primary`, first in the action cluster |
| Print report | **P0-O** | `.sakai-btn-primary` on the report view |
| Export XLS / CSV / PDF | **P3** | One `.sakai-overflow-menu` (`…`), last in the action cluster |
| Save / Generate / Cancel | P0-F + Cancel | `.sakai-actions` at the end of the report form |
| Return to reports / Back | **R** | `.sakai-back-link` near the H1, leading side |

The header actions carry the A1 links on the tool views (legacy pattern; see the note above).
Flow views (`report-edit`, `report-view`, `useractivity-details`) do not repeat them; they expose
only their return action. The report view keeps its object actions (Print, exports) because they
belong to the current report.

> **Navigation note:** A1 views render in `.sakai-tool-nav` below the header (see
> [`navigation-model.md`](navigation-model.md)); R is `.sakai-back-link`; P0/P1–P4 stay in the
> action cluster. The current view is marked with `aria-current="page"` and `is-active`.

Action order is fixed: primary, secondary, return/back, overflow (`…`) last. The current
view is never rendered as an action. Secondary actions move into the overflow menu at narrow
container widths; there is no count-based collapse.

Server-wide report types are a **second level** inside the Server-wide view. They keep
`.sakai-tool-nav` below the header; they are not the tool's A1 navigation.

## Layout contract

```
.portletBody.sakai-tool-body.sakai-sitestats
  header.sakai-tool-header
    h1.sakai-tool-header__title            ← active view ("Reports", report title, "New report")
    .sakai-tool-header__actions            ← primary + overflow
  .sakai-tool-nav                        ← A1 views (current has aria-current)
  .sakai-banner--success|--error           ← messages
  .sitestats-widgets                       ← overview / admin summary
  .sakai-table-wrap > .sakai-table         ← reports, user activity, admin sites
  .sakai-form-section                      ← report editor / preferences (shared form primitives)
  .sakai-actions                           ← form footer
```

The admin tool uses the same header/actions fragment with `adminTool=true`.

## Primitives and patterns

| Pattern | Classes / notes |
|---------|-----------------|
| Header | `.sakai-tool-header`, `__title`, `__actions` |
| A1 views | `.sakai-tool-nav` + `__btn`; current item has `aria-current="page"` and `is-active` |
| Actions | `.sakai-btn-primary`, `.sakai-btn-secondary`, `.sakai-btn-ghost` |
| Overflow | `.sakai-overflow-menu` + `__toggle` / `__panel`; exports are direct panel links |
| Forms | `.sakai-form-section` + `__title` / `__intro`, `.sakai-form-grid` (+ `--3`), `.sakai-form-field` (+ `--span-2`), `.sakai-form-subfield`, `.sakai-form-help`, `.sakai-form-label` (+ `.required`), `.sakai-form-control`, `.sakai-form-choice`, `.sakai-form-choice-group` (+ `--scroll`), `.sakai-form-error`; group legends use `.sakai-form-label`, not a section title |
| Tables | `.sakai-table sakai-table--hover sakai-table--stack`, `caption.visually-hidden`, `__primary` / `__nowrap` / `__actions`; rows carry `data-label` for the stacked layout |
| Row actions | One `…` overflow per report row (Edit / Duplicate / Delete). Copy and delete submit hidden forms through the button `form` attribute so the panel only contains direct links/buttons |
| Banners | `.sakai-banner sakai-banner--info|--success|--warn|--error` |
| Pagination | Bootstrap `.pagination` kept as a component; layout lives in `.sitestats-pagination` |
| Responsive | `@container sakai-tool` in `_sitestats.scss` and the Lit widget styles; no viewport queries inside the tool |

## Widgets and dashboard

The overview and admin summary use the shared Lit components:

- `sakai-sitestats-widget-metrics`
- `sakai-sitestats-highlights`
- `sakai-sitestats-widget-tab` → `sakai-sitestats-report-panel` → `sakai-sitestats-chart` / `sakai-sitestats-table`
- `sakai-sitestats-tool-filter`

The dashboard (`sakai-widget-panel`) reuses `sakai-sitestats-widget` with the same metrics and
highlights in compact mode. Changes to the shared components must be checked on both surfaces.
The chart/table styles live in the shadow DOM; they use Sakai tokens and `@container sakai-tool`.

## Form conventions

- The report editor and preferences use the available width; do not reintroduce
  `.sitestats-report-form` / `.sitestats-preferences` `max-width` wrappers.
- `Totals by`, `Tools`, `Events` and `Selected users` are `.sakai-form-choice-group` checkbox
  groups. `Events` and `Selected users` use `--scroll`; the user search appends
  `.sakai-form-choice` rows instead of `<option>`s.
- Consecutive grids separate through `.sakai-form-grid + .sakai-form-grid`; a section after a
  grid/field through `.sakai-form-grid + .sakai-form-section` / `.sakai-form-field +
  .sakai-form-section`. `.sakai-form-divider` is retired.
- Conditional blocks such as `#sorting-options` and `#max-results-options` are
  `.sakai-form-subfield`.
- Cancel/back/return actions are `.sakai-btn-ghost`; Save/Generate is primary, preview and other
  alternatives secondary.

## Gotchas

- **Chart resize:** `.sitestats-widget` is a grid item. Without `min-width: 0` it cannot shrink
  below its content, so charts overflow the card when the container narrows. The fix is part of
  the widget grid, not the chart component. `SakaiSiteStatsChart` already observes
  `.chart-frame` with a `ResizeObserver`.
- **Chart canvas:** the chart canvas lives in `sakai-sitestats-chart`'s shadow root, not directly
  under `sakai-sitestats-highlights` / `sakai-sitestats-report-panel`.
- **New message keys** are loaded by Sakai `ResourceLoader` from the `sitestats-bundle` jar; a
  running server needs a restart/redeploy to see them.
- The legacy `.panel` rule removed from `_sitestats.scss` was also satisfying a Samigo
  `@extend .panel`; the stale extend was removed.
- `sakai-tool-nav` remains only for the Server-wide report types (second-level sub-views).

## Key files

- Templates: `sitestats/sitestats-tool/src/webapp/WEB-INF/templates/`
- Shared header/actions/messages: `.../templates/fragments/common.html`
- Skin: `library/.../sass/modules/tool/sitestats/_sitestats.scss`
- Lit widgets: `webcomponents/.../packages/sakai-sitestats/src/`
- Dashboard wrapper: `webcomponents/.../packages/sakai-widgets/src/SakaiSiteStatsWidget.js`
- Strings: `sitestats/sitestats-bundle/src/resources/Messages*.properties`
- E2E: `e2e-tests/.../SiteStatsTest.java`
