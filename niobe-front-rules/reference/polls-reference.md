# Polls — first tool UI reference (Thymeleaf)

Polls is the **first tool with the navigation split** for the A1/P0/P2/P3 intra-tool IA and `sakai-*` primitives. Its surface parity pass is still pending; use it as a draft, not as the final pattern.

Chrome contract: [`library/docs/sakai-ui-chrome.md`](../library/docs/sakai-ui-chrome.md). Full roadmap: [`sakai-ui-tool-migration.md`](sakai-ui-tool-migration.md).

## A1/P0/P2/P3 in Polls

| Item | Kind | Markup |
|------|------|--------|
| List (home) | **A1** | View H1 only — no segmented control (single exclusive view). Return via portal tool crumb. |
| Add | **P0-S** | `.sakai-btn-primary` in `.sakai-tool-header__actions`; repeated in the empty state |
| Bulk Creation | **P2** | `.sakai-btn-secondary` in `.sakai-tool-header__secondary` at wide width; menu item in `…` below wide (`data-priority="2"`) |
| Permissions | **P3** | Menu item in `…` at **every** width — never inline |

The A1/P0/P2/P3 cluster belongs to the **home view only**. Every other view (vote, results, import,
permissions, option forms) keeps `.sakai-tool-header` but drops the cluster: repeating
"Add/Permissions" there makes a global action read as an action on the current page.

The `…` becomes persistent (`.sakai-tool-header__more--persistent`) when the viewer owns a P3
action (Permissions), because P3/P4 always live in the overflow. Without a P3 the overflow is only
rendered below wide, where it carries the P2 item. Panel items carry `data-priority="1|2"` so a
P1/P2 item that is already visible in the header at that container width is hidden in the panel.

> **R:** R is navigation, not an action. Every non-list view renders it as `.sakai-back-link` above
> the H1, so "back to the list" is in the same place on vote, results, import, poll/option forms and
> permissions. Form footers keep their local `Cancel`/`Back` for the flow itself. This is a
> **deliberate exception** to the "one exit" guideline: the header R is the tool-wide return, the
> footer action is the local one; both are quiet (ghost/link), so they do not compete with the form's
> primary. The list has no toolbar or pager yet; that remains a deliberate minimal-list decision to
> revisit in the parity pass.

## Layout contract

```
.portletBody.sakai-tool-body
  .sakai-tool-header
    h1.sakai-tool-header__title
    .sakai-tool-header__actions   ← fragment toolActions (home only)
  banners / content
```

- No `.navIntraTool`.
- No duplicate tool-name title on single-tool pages.
- Shared actions: `polls/.../fragments/common.html` → `toolActions` (home only), with
  `toolSecondaryActions` (P2, visible at wide) and `toolOverflowActions` (P2 + P3) fragments.

## Primitives used

| Pattern | Classes |
|---------|---------|
| Header | `.sakai-tool-header`, `__title`, `__actions` |
| Buttons | `.sakai-btn` / `-primary` / `-secondary` / `-ghost` (also on `<a href>` — see `_sakai-btn.scss`) |
| Form footer | `.sakai-actions` (legacy `.act` aliased) — flex + `gap`; do not rely on child `margin-right` |
| Permissions | Shared `<sakai-permissions>` → `.sakai-permissions` / `__table` (not tool-local); same `.sakai-table` header, separators and hover as list tables |
| Banners | **`.sakai-banner.sakai-banner--success` / `--error` / `--warn` / `--info`** (content only; icon via CSS) |
| Forms | `.sakai-form-section` + `__title`, `.sakai-form-field` (the only field wrapper; `.sakai-form-group` is retired), `.sakai-form-label` (+ `.required`), `.sakai-form-control`, `.sakai-form-choice`, `.sakai-form-choice-group` (+ `--scroll`), `.sakai-form-help`, `.sakai-form-error`; group legends use `.sakai-form-label`, not a section title |
| Tables | `.sakai-table` (+ `--hover` / `--sm` / `--stack`), `.sakai-table-wrap`, `__select`, `__sort`, `__actions`, `__primary`, `__nowrap`; Polls uses non-striped tables (separators + hover); mark the important column with `__primary` so it absorbs extra width and keeps a 16rem desktop floor; the **list** table stacks on narrow containers with one rounded outer shell, single row separators and a `data-label` label/value grid (every cell carries `data-label` server-side); the **results** table keeps four narrow columns and scrolls inside `.sakai-table-wrap`; sortable headers carry `aria-sort` on the `<th>` with a `.sakai-table__print-label` so the control-free header still prints |
| Options (Polls) | `.sakai-polls-option-list` scrollable stack for many options; each option keeps inline Edit/Delete because the delete step is its own confirmation page and the list lives inside the poll form (not a data table) |
| Header tiers | Home only. ≥48rem container: Add + `.sakai-tool-header__secondary` (P2) + persistent `…` (P3). Narrower: Add + `…` (P2 + P3) |
| Row actions | Trailing `.sakai-table__actions` cell with a single `…` (`.sakai-overflow-menu`) containing Edit, exports and Delete — reveals on row hover/focus for fine pointers, always visible on touch; not stacked under the row title; the summary `aria-label` names the poll (`poll_actions_for`) |
| Tool-only layout | `.sakai-polls-*` for Polls-specific composition only; shared chrome stays in `components/` |

Responsive content uses `@container sakai-tool` in Polls SCSS, not viewport breakpoints.

Table row menus are lifted to a fixed layer by the shared `sakai-overflow-menu.js` in the global body bundle (custom properties `--sakai-overflow-panel-top` / `--sakai-overflow-panel-left`), so opening one keeps the table wrap's horizontal scroll and never lets the table spill out of the card. The shared script also closes any other open menu, so tools do not implement their own `toggle` orchestration.

The list sorts client-side (`js/polls-list-sort.js`) on the `data-order` value of each cell. The
initial sort is **Closing, descending**, which mirrors the server order in `PollController`; the
`<th>` carries `aria-sort` and the button is `.sakai-table__sort`.

The bulk bar (`#poll-bulk-actions`) is a `.sakai-actions` footer that stays `hidden` until at least
one poll is selected, matching the "P0-B never appears before a selection exists" rule.

**Form conventions:** the public-poll checkbox, result visibility and orphan handling use
`.sakai-form-choice` inside `.sakai-form-choice-group`; the groups list uses
`.sakai-form-choice-group--scroll` instead of a native `<select multiple>`. `Cancel`/`Back` are
`.sakai-btn-ghost`; `Save` is primary and preview/import alternatives are secondary.

**Gotcha:** Legacy skin styles `a[href].btn-primary` as a real button, but not secondary/ghost. Always include `a[href].sakai-btn-*` rules in the button primitive or anchors look like the old navIntraTool links.

## Checklist for the next tool

1. List every current `navIntraTool` (or equivalent) entry → tag **R / A1 / A2 / P0 / P1 / P2 / P3 / P4 / D / M**.
2. Emit `.sakai-tool-header` + view H1; put R, P0 and P1–P4 in their zones (P1 max 1, P2 max 2, P3/P4 in `…`).
3. If multiple A1 views: `.sakai-tool-nav` (Polls did not need this). A2 object views use `.sakai-segmented-control` only when the switch is in place.
4. **Row actions:** a single `…` overflow menu in a trailing `.sakai-table__actions` cell (Edit plus secondary/destructive actions). Never a strip of full-size buttons or stacked links under the title.
5. Convert edited markup: buttons, banners (`sak-banner-*` → `sakai-banner sakai-banner--*`), forms, tables → `sakai-*`.
6. Drop Bootstrap layout/spacing utilities from edited templates; layout in tool SCSS.
7. Icons: `si si-*` only; `bi-*` lives only in the central `base/_icons.scss` map.
8. Update Playwright selectors.
9. No URL / permission / flow changes in a UI-only PR.

## Key files

- Fragment: `polls/tool/src/main/webapp/WEB-INF/templates/fragments/common.html`
- Templates: `polls/tool/src/main/webapp/WEB-INF/templates/polls/*.html`
- Row menu positioning: `webcomponents/tool/src/main/frontend/bundle-entry-points/sakai-overflow-menu.js` (global body bundle)
- Skin: `library/.../components/_sakai-tool-header.scss`, `_sakai-table.scss`, `modules/tool/polls/_polls.scss`
- E2E: `e2e-tests/.../PollTest.java`
