# Polls — first tool UI reference (Thymeleaf)

Polls is the **first migrated tool** for the A/B/C intra-tool IA and `sakai-*` primitives. Use this page when migrating the next tool.

Chrome contract: [`library/docs/sakai-ui-chrome.md`](../library/docs/sakai-ui-chrome.md). Full roadmap: [`sakai-ui-tool-migration.md`](sakai-ui-tool-migration.md).

## A/B/C in Polls

| Item | Kind | Markup |
|------|------|--------|
| List (home) | **A** | View H1 only — no segmented control (single exclusive view). Return via portal tool crumb. |
| Add | **B** | `.sakai-btn-primary` in `.sakai-tool-header__actions` (hidden when current) |
| Bulk Creation | **B** | `.sakai-btn-secondary` |
| Permissions | **C** | `.sakai-btn-ghost` (no overflow yet — one utility) |

## Layout contract

```
.portletBody.sakai-tool-body
  .sakai-tool-header
    h1.sakai-tool-header__title
    .sakai-tool-header__actions   ← fragment toolActions(current)
  banners / content
```

- No `.navIntraTool`.
- No duplicate tool-name title on single-tool pages.
- Shared actions: `polls/.../fragments/common.html` → `toolActions(current)`.

## Primitives used

| Pattern | Classes |
|---------|---------|
| Header | `.sakai-tool-header`, `__title`, `__actions` |
| Buttons | `.sakai-btn` / `-primary` / `-secondary` / `-ghost` (also on `<a href>` — see `_sakai-btn.scss`) |
| Form footer | `.sakai-actions` (legacy `.act` aliased) — flex + `gap`; do not rely on child `margin-right` |
| Permissions | Shared `<sakai-permissions>` → `.sakai-permissions` / `__table` (not tool-local); row owns stripe/hover |
| Banners | **`.sak-banner-success` / `-error` / `-warn` / `-info`** (established Sakai banners; keep these in tools) |
| Forms | `.sakai-form-group`, `.sakai-form-label`, `.sakai-form-control` |
| Tables | `.sakai-table` (+ `--striped` / `--hover` / `--sm` / `--stack`), `__select`, `__sort`, `.sakai-table-wrap`; list sort via `polls-list-sort.js` (`data-order`) |
| Options (Polls) | `.sakai-polls-option-list` scrollable stack for many options |
| Header | Wide: Add + `.sakai-tool-header__secondary`. Narrow: Add + `.sakai-tool-header__more` |
| Row actions | `.sakai-row-actions__link` + `…` (`.sakai-overflow-menu`) — not a strip of secondary buttons |
| Tool-only layout | `.sakai-polls-*` for Polls-specific composition only; shared chrome stays in `components/` |

Responsive content uses `@container sakai-tool` in Polls SCSS, not viewport breakpoints.

**Gotcha:** Legacy skin styles `a[href].btn-primary` as a real button, but not secondary/ghost. Always include `a[href].sakai-btn-*` rules in the button primitive or anchors look like the old navIntraTool links.

## Checklist for the next tool

1. List every current `navIntraTool` (or equivalent) entry → tag **A / B / C**.
2. Emit `.sakai-tool-header` + view H1; put B/C in `__actions` (overflow for many C / narrow).
3. If multiple A views: `.sakai-tool-nav` / `.sakai-segmented-control` (Polls did not need this).
4. **Row actions:** discreet text/link for the frequent action + `…` for everything else (never a strip of full-size buttons in each row).
5. Convert edited markup: buttons, banners (`sak-banner-*`), forms, tables → `sakai-*`.
6. Drop Bootstrap layout/spacing utilities from edited templates; layout in tool SCSS.
7. Icons: Bootstrap Icons only.
8. Update Playwright selectors.
9. No URL / permission / flow changes in a UI-only PR.

## Key files

- Fragment: `polls/tool/src/main/webapp/WEB-INF/templates/fragments/common.html`
- Templates: `polls/tool/src/main/webapp/WEB-INF/templates/polls/*.html`
- Skin: `library/.../components/_sakai-tool-header.scss`, `_sakai-table.scss`, `modules/tool/polls/_polls.scss`
- E2E: `e2e-tests/.../PollTest.java`
