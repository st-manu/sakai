# Announcements — Velocity tool reference

Announcements is the **first Velocity tool with the navigation split** (Polls is the Thymeleaf reference); its surface parity pass is still pending. Use it when migrating the next CHEF/Velocity tool: the hard part there is not the CSS, it is emitting `sakai-*` markup without re-implementing the server side menu, permissions or flows.

Chrome contract: [`library/docs/sakai-ui-chrome.md`](../library/docs/sakai-ui-chrome.md). Playbook: [`sakai-ui-tool-migration.md`](sakai-ui-tool-migration.md).

## A1/P0/P2/P3 in Announcements

| Item | Kind | Markup |
|------|------|--------|
| List (home) | **A1** | View H1 (`gen.list.title`, i.e. “Announcement list”) — no segmented control (single exclusive view) |
| Add announcement | **P0-S** | `.sakai-btn-primary` with a `si si-add` icon |
| Reorder / Merge | **P2** | `.sakai-btn-secondary`; drop to `…` below wide |
| Options | **P3** | `…` overflow |
| Permissions | **P3** | `.sakai-btn-ghost`, same as Polls |
| Refresh | — | Dropped: `IsCurrent` menu entries and the legacy `doCancel` refresh are never rendered as actions |

Secondary views (add/edit, preview, bulk, options, reorder, merge, permissions) do not repeat the
A1/P0/P2/P3 cluster. They keep the header and expose a single **R** back link to the list. The
announcement detail view shows its object actions (new/edit/remove) and the footer owns
“Back to list”.

> **R:** `$backAction` renders as `.sakai-back-link` near the H1, not as a secondary button. The
> footer Cancel remains the flow exit. The My Workspace branch uses the canonical
> `sakai-table-toolbar` / `__filters` / `.sakai-table-pagerContainer` classes.

## Reading the server menu instead of duplicating it

`MenuBuilder` already decides which actions exist and whether they are enabled (permissions, reorder property, current tab). The template must not re-derive that. `announcements_macros.vm` walks `$menu.Items` and renders them:

```velocity
#parse("/vm/announcement/announcements_macros.vm")
#announcementsHeader($title "doNewannouncement" $menu "")   ## home: primary + utilities
#announcementsHeader($title "" "" "doCancel")               ## flow: return to list
```

* `doNewannouncement` → primary button.
* every other enabled, non-current, non-divider entry → secondary cluster + overflow panel.
* `$item.Url` entries render as plain links, `$item.Form` entries keep `buildQueryString()`.
* The URL is built exactly like `#chef_toolbar` does: `$sakai_ActionURL.reset().setParameter("sakai_action", $item.Action).toString()`.
* The rendering lives in the shared `#sakaiToolHeader($title $menu $primaryAction $backAction $backLabel $moreLabel $primaryIcon)`
  (`velocity/tool/src/templates/VM_chef_library.vm`), so other Velocity tools and the shared
  `permissions.vm` get the same heading, separator and action styling.
* `chef_announcements-*.vm` call the thin wrapper
  `#announcementsHeader($title $primaryAction $menu $backAction)`: menu + primary on the home view,
  `""` + `"doCancel"` on flow views.

Same macro also renders `#announcementsAlert($alertMessage)` (error banner) and `#announcementsEmptyState($view)`, so wording stays in the tool bundle.

## Layout contract

```
.portletBody.sakai-tool-body.sakai-announcements
  header.sakai-tool-header
    h1.sakai-tool-header__title            ← view name ("Announcement list"), not the tool name
    .sakai-tool-header__actions            ← P0/P1–P4 from $menu (home) or R (flows)
  .sakai-table-toolbar
    .sakai-table-toolbar__filters          ← #searchFilterPanel + #viewFilterPanel + __scope
    .sakai-table-pagerContainer            ← #pagerPanel: summary + icon buttons + page size
  .sakai-table-wrap > table.sakai-table.sakai-table--hover.sakai-table--stack
  .sakai-actions                           ← bulk Remove/Publish/Unpublish
```

The 365-day display option is not a page subtitle: it renders as `.sakai-table-toolbar__scope`
next to the view filter, where it reads as filter context.

* No `.navIntraTool`, no `.page-header`, no `container-fluid`.
* The synoptic (Home dashboard) branch keeps its compact list: it renders inside another tool and must not emit a tool header.

## Primitives and patterns used

| Pattern | Classes / notes |
|---------|-----------------|
| Header | `.sakai-tool-header`, `__title`, `__actions`, `__secondary`, `__more`; secondary utilities move into `…` only at narrow container widths |
| Buttons on forms | `.sakai-btn sakai-btn-primary` on `<button>` **and** `<input type=submit>` (the skin extends `.btn`) |
| Table | `.sakai-table sakai-table--hover sakai-table--stack`, `caption.visually-hidden`, `__select`, `__primary`, `__actions`, `__nowrap` |
| Sortable headers | `aria-sort` on `<th>` + `.sakai-table__sort` (+ `is-sorted-asc/desc`); the shared skin draws the arrow |
| Row actions | one `…` `.sakai-overflow-menu` in the trailing `__actions` cell (Edit / Remove). Never inline links under the title |
| Dense data | visibility range and release/retract go in a `.sakai-announcements__schedule` line under the subject instead of extra columns: the table stays inside the card and keeps the row menu reachable |
| Expanded body | second `<tr class="sakai-announcements__body-row">` that reads as part of the item: subject row loses its bottom border, body sits on the card surface with a leading accent |
| Bulk actions | `.sakai-actions` + `#announcement-*-button` ids kept for `announcements.js` and the e2e tests |
| Search / filter / pager | `.sakai-table-toolbar` + the shared `#searchFilterPanel`, `#viewFilterPanel` and `#pagerPanel` macros. The macros emit `.sakai-table-searchFilter`, `.sakai-table-viewFilter` and `.sakai-table-pagerContainer` (summary + icon buttons + page-size select), so the strip is identical in every Velocity tool that adopts it |
| Forms | `.sakai-form-section` + `__title`, `.sakai-form-field` (the only field wrapper; `.sakai-form-group` is retired), `.sakai-form-label` (+ `.required`), `.sakai-form-control`, `.sakai-form-choice`, `.sakai-form-choice-group`, `.sakai-form-help`, `.sakai-form-error`; group legends use `.sakai-form-label`, not a section title |
| Banners | `.sakai-banner sakai-banner--error|--warn|--info` (replaces `sak-banner-*`) |
| Icons | `si si-star-fill`, `si si-attachment`, `si si-three-dots`, `si si-edit`, `si si-trash`, `si si-chevron-*` |
| Responsive | `@container sakai-tool` in `_announcements.scss` only; note the skin root font-size is 14px, so `40rem` = 560px |

## Gotchas found while migrating

* `#toolbar($menu)` also handles text-field menu items and form query strings. The replacement macro keeps `$item.Form`, but tools that actually use form items need to extend it.
* Velocity macro arguments cannot contain a comma-separated method call safely — pre-compute `getFormattedMessage(...)` into a `#set` variable before calling `#announcementsHeader`.
* `details > summary` based row menus depend on the global `sakai-overflow-menu.js` (body bundle) to position the fixed panel; keep `.sakai-row-actions > .sakai-overflow-menu` inside `td.sakai-table__actions`.
* The bulk checkbox logic (`announcements.js`) delegates on `document` because the shared search macro swaps `tbody` rows: keep the `.announcement-select-checkbox`, `#announcement-select-all` and `#announcement-reset-button` hooks.
* Admin MOTD has `$motd` and renders no visibility radios: show the read-only "Public" note instead of an empty Access section.
* The nested `<label>` around the highlight checkbox was invalid HTML; it is now a single label.
* Group multi-selects (`selectedGroups`, `selectedRoles`) still render as native `<select multiple>`
  in the Velocity revise template. When that markup is next touched, move them to
  `.sakai-form-choice-group` with `--scroll`, matching Statistics and Polls.
* `Cancel`/`Back to list` are `.sakai-btn-ghost`; `Save`/`Post` is primary and preview is
  secondary.

## Key files

- Shared header macro: `velocity/tool/src/templates/VM_chef_library.vm` (`#sakaiToolHeader`)
- Shared permissions page: `velocity/tool/src/templates/permissions.vm`
- Announcements fragments: `announcement/announcement-tool/tool/src/webapp/vm/announcement/announcements_macros.vm`
- Templates: `vm/announcement/chef_announcements{,-revise,-metadata,-reorder,-preview,-customize,-merge,-bulk-operation}.vm`
- Skin: `library/.../sass/modules/tool/announcements/_announcements.scss`
- Strings: `announcement/announcement-api/api/src/bundle/announcement.properties`
- E2E: `e2e-tests/.../AnnouncementTest.java`
