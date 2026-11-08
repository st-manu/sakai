# Messages — JSF private messages reference

Messages is the first **JSF/JSP** tool with the Niobe navigation split; its surface parity pass is
still pending. Use it when touching the private messages views: the hard part is not the CSS, it is
keeping JSF command links, view state and the JSP include model working while replacing the flat
`navIntraTool`.

Chrome contract: [`library/docs/sakai-ui-chrome.md`](../library/docs/sakai-ui-chrome.md).
Playbook: [`sakai-ui-tool-migration.md`](sakai-ui-tool-migration.md).

## A1/P0/P2/P3 in Messages

| Item | Kind | Markup |
|------|------|--------|
| Folder list (home) | **A1** | View H1 (“Messages”); folders are data rows, not a segmented control |
| Message list / search results | **A1** | View H1 is the folder name or “Search”; **All folders** is the quiet R/A1 back link, not an action |
| Compose Message | **P0-S** | `.sakai-btn sakai-btn-primary` with a `si si-add` icon |
| New Folder | **P2** | `.sakai-btn sakai-btn-secondary` on home; always in the `…` on list/search |
| Settings | **P3** | `.sakai-btn sakai-btn-secondary` or `…` |
| Permissions | **P3** | `.sakai-btn sakai-btn-ghost` |
| Folder list | **A1** | The home view (`pvtMsgHpView`) is the only folder switcher; folder views expose **All folders** as the back link |
| Flow views (compose, reply, forward, settings, folder add/rename/delete, move, delete, permissions) | — | Header keeps the view H1 and a single **R** `.sakai-back-link`; form buttons stay in `.sakai-actions` |
| Message detail | — | Subject is the H1; Reply is P0-O, Reply all/Forward are the inline P1/P2 object actions, Move/FAQ/Delete live in the detail `…`, and previous/next message is a bottom pager |

`pvtToolHeader.jsp` is the shared header. Pages set request attributes before including it:

```jsp
<% request.setAttribute("pvtHeaderView", "list"); %>   // home | list | search | detail
<% request.setAttribute("pvtHeaderTitleKey", "pvt_pvtcompose"); %>
<% request.setAttribute("pvtHeaderBack", "compose"); %>
<%@ include file="/jsp/privateMsg/pvtToolHeader.jsp" %>
```

`pvtHeaderBack` is dispatched by `PrivateMessagesTool.processPvtMsgHeaderBack()` through a
`pvtHeaderBack` request parameter, so one link covers every return destination. The link reads
**Back to list**, except when the destination is the message detail (`pvtHeaderBack=detail`), where
it reads **Back**. `permissions` returns to the folder home (`pvtHeaderBack=home`).

> **R:** `pvtHeaderBack` renders as `.sakai-back-link` near the H1, not an action. In `list` and
> `search` views (no `pvtHeaderBack`) the same slot renders **All folders**, which returns to
> `pvtMsgHpView`. Both are quiet navigation, not secondary buttons.

On `list`/`search` the utilities exist only in the `…`, so the header uses
`sakai-tool-header__more--persistent`; on `home` they stay in `__secondary` and the `…` is the
narrow-container fallback.

## Layout contract

```
.portletBody
  header.sakai-tool-header
    .sakai-back-link-row                          ← R (Back) or All folders on list/search
    h1.sakai-tool-header__title                   ← folder, Search, subject or flow view
    .sakai-tool-header__actions                   ← Compose + utilities/overflow
  .sakai-table-toolbar
    .sakai-table-searchFilter + .sakai-table-viewFilter
  .sakai-table-wrap > table.sakai-table.sakai-table--hover
  .sakai-actions                                  ← bulk actions / form footer / object actions
```

The folder home is a `.sakai-table` with Folder, Messages, Unread and a trailing `…` menu. A folder
view keeps the folder name as the view heading and exposes **All folders** in the header to return to
`pvtMsgHpView`; the tool utilities live in the `…` overflow.

## Primitives and patterns used

| Pattern | Classes / notes |
|---------|-----------------|
| Header | `.sakai-tool-header`, `__title`, `__actions`, `__secondary`, `__more`; utilities move into `…` by container width |
| Buttons | `.sakai-btn` / `-primary` / `-secondary` / `-ghost` / `-icon`; also on `<input type=submit>` |
| Table | `.sakai-table sakai-table--hover sakai-table--stack`, `.sakai-table-wrap`, `__primary`, `__nowrap`, `__select`, `__actions`; the shared body script fills `data-label` from the header for JSF tables |
| Select all | `.sakai-table__select` header cell with the checkbox and a `visually-hidden` label, matching Announcements and Polls |
| Tags | `.sakai-messages__subject-tags` inside the `__primary` subject cell; Label stays in its own column |
| Bulk actions | `.sakai-actions` after the table with `.ToggleBulk` submit buttons; `bulkops.js` toggles their `disabled` state |
| Search / view filter | `.sakai-table-toolbar`, `.sakai-table-searchFilter`, `.sakai-table-viewFilter`, `sakai-form-control sakai-form-control--sm` |
| Advanced search | `.sakai-messages__search-options`, `.sakai-form-section__title`, `.sakai-form-choice`, `.sakai-messages__search-extra.showed` |
| Forms | `.sakai-form-section` + `__title`, `.sakai-form-field`, `.sakai-form-label` (+ `.required`), `.sakai-form-control`, `.sakai-form-choice`, `.sakai-form-help`, `.sakai-messages__choice-group` (JSF radio table) |
| Banners | `.sakai-banner sakai-banner--error|--warn|--success` |
| Detail | `.sakai-messages__detail-summary`, `.sakai-messages__meta`, `.sakai-messages__body` |
| Empty state | `.sakai-messages__empty` + `__empty-text` and one action (Compose on the list, Clear Search on results) |
| Icons | `si si-folder`, `si si-add`, `si si-arrow-left`, `si si-attachment`, `si si-reply-fill`, `si si-cancel`, `si si-sliders`, `si si-three-dots` |
| Responsive | `@container sakai-tool` in `_messages.scss`; no viewport queries inside the tool |

## Form conventions

- Compose, reply, reply-all and forward use the same shell: `.sakai-form-section` for
  `Recipients`, `Message`, `Attachments` and `Tags`; `.sakai-form-field` for each label/control
  pair; `.sakai-form-choice` for the BCC, email-copy, read-receipt and schedule toggles.
- **Known layout debt:** Subject and Label still sit in the first (Recipients) section in the four
  compose flows. A follow-up moves them into the `Message` section or a dedicated details section;
  do not copy the current placement into new flows.
- The conditional schedule date is a `.sakai-form-subfield` nested in the scheduler
  `.sakai-form-field`; keep the `openDateSpan` ids because the JS toggles them.
- JSF `h:selectOneRadio layout="pageDirection"` renders a table. `.sakai-messages__choice-group`
  is the Messages adaptation: `display:block`, no margin, collapsed borders, compact cell padding
  and label-size text. It is used on its own — do not add `.sakai-form-choice-group`, which is a
  grid for plain inputs, and do not replace the JSF markup unless it is restructured.
- The recipient controls are `h:selectManyListbox` enhanced by Select2 (`addTagSelector`). They are
  not visible native multi-selects; keep the clear-selection link pattern and its
  `handleSelectionChange` toggle.
- Required labels use `.sakai-form-label.required`. The old `instruction` + `reqStarInline`
  required legend was removed; do not bring it back.
- Actions: Send/Save/Add and a delete confirmation are primary; Preview, Save Draft, Reply all and
  Forward are secondary; Cancel, Back and Return are ghost. On the detail, Move, FAQ and Delete live
  in the `…` (Delete after a separator); previous/next message is a bottom
  `.sakai-actions.sakai-messages__pager` row.
- No `max-width` wrapper around the compose or detail views; the form uses the tool width.

## Gotchas found while migrating

* **The tool body class is `Mrphs-sakai-forums` in the combined app.** The private messages views
  are rendered by the messageforums app, whose body class is not `Mrphs-sakai-messages`. The tool
  SCSS is scoped with `:is(.Mrphs-sakai-messages, .Mrphs-sakai-forums)`; the selectors inside are
  still private-message-specific (`#prefs_pvt_form`, `.sakai-messages__*`).
* **Do not put `rendered` based on request attributes on JSF action containers.** JSP scriptlets
  run in the render phase, but JSF decodes the restored component tree before the JSP runs again.
  A header action wrapped in `rendered="#{requestScope...}"` is skipped during decode and never
  fires. Wrap the **action cluster** in a JSP scriptlet `if` instead; use bean-backed `rendered`
  only for stable flags (`dispError`, `showSettingsLink`, `instructor`).
* **Header navigation links are `immediate="true"`.** They must not be blocked by validation of the
  message list/search form; the old `pvtMenu` did the same.
* **`input[type=submit].sakai-btn-*` needs its own rule.** The skin's generic
  `input[type=submit] { @extend .button_color; }` wins over `.sakai-btn-primary` on an `<input>`.
  `_sakai-btn.scss` now extends the submit/button/reset variants so `<h:commandButton>` keeps the
  primary/secondary/ghost colors.
* **Do not use `msgs[topic.topic.title]` in a tooltip for custom folders.** Standard folders
  (`pvt_received`, `pvt_sent`, …) have bundle keys; custom folders do not and render a
  `[missing key]` title. The link text already carries the folder name.
* **DataTables column indexes follow conditional columns.** The scheduled date column is only
  rendered in the Scheduled folder; the flat table's `columns` array in `pvtMsg.jsp` must use the
  same condition. `PrivateMessagesTool.calculateColumnClass()` must also match the rendered column
  count, or the `specialLink`/`date`/`addressee` classes shift to the wrong cells.
* **The threaded table uses `columnDefs`, not a conditional `columns` array.** The hierarchy
  component changes the rendered column count per folder; a `columns` array that does not match it
  appends empty cells and triggers `Requested unknown parameter '7'`. Keep the fixed select /
  attach / reply indexes non-sortable and let DataTables detect the remaining columns.
* **The search results page (`pvtMsgEx.jsp`) has two table wrappers.** Keep both `h:panelGroup`
  closing tags when adding the `sakai-table-wrap`; an unbalanced wrapper breaks JSP compilation.
* **The reply-all view keeps the `pvtMsgForward` form id.** Its JS, BCC field and schedule ids
  were copied from forward; changing only the form id breaks every `getElementById` call. Keep
  the ids aligned with the form.
* **Legacy `legend` styling leaks into the shared primitives.** Morpheus sets
  `legend { display:inline-block; padding:.5em; ... }`. `.sakai-form-label` and
  `.sakai-form-section__title` reset display, width, margin, padding, border and float; without
  that reset a group legend looks like a section title and vice versa.
* **`.sakai-messages__detail` and `.sakai-messages__compose` were width wrappers only.** They
  were removed together with their `max-width`; do not re-add them around new views.
* The anonymous warning uses `.sakai-banner sakai-banner--warn`; `.information` and
  `alertMessage` were legacy classes with no styles left.
* **JSF tables do not render `data-label`.** Add `.sakai-table--stack` to the table and let the
  shared body script copy the visible `thead` text into each `td`; the subject column is marked
  `sakai-table__primary` from its `headerClass`, so it renders as the row title without a label.
  Empty status cells are hidden by the same script.
* **The header `…` menu is viewport-clamped.** On narrow containers the actions are left-aligned,
  so a `right: 0` panel would open off-screen. The shared overflow script positions both table and
  header menus; the CSS also falls back to `left: 0` on narrow containers.
* **Move uses one `h:selectOneMenu`.** The old per-folder `h:selectOneRadio` rendered a nested
  table per row and could not follow the shared form spacing; the single select keeps the current
  folder disabled and submits on change.
* **The recipients picker is the remaining forms exception.** Compose/reply/forward still use the
  legacy JSF `h:selectManyListbox` enhanced by Select2. The shared forms rule prefers
  `.sakai-form-choice-group` + `.sakai-form-choice` (or a shared picker); replace this control when a
  reusable recipient picker exists, not with a bespoke checkbox list.
* The rich-text editor is CKEditor; `sakai:inputRichText` ids are unchanged (`compose:subject`,
  `compose:list1`, …), so the existing e2e helpers and tag selectors keep working.
* **The compose action is the stable e2e hook.** `pvtToolHeader.jsp` renders it as
  `.sakai-messages__compose-link` (the old `#messagesComposeMenuLink` span in `pvtMenu.jsp` is
  gone). Use that class, not the JSF client id, because the header is included inside each
  page's form.
* **Reply notifications are `messages.reply` events.** `SakaiNotifications` decorates them with
  the `message_received` string; the notification opens the reply detail view. E2E:
  `MessagesReplyNotificationTest`, which uses `#messages-group`,
  `li.sakai-notifications__item` and `.sakai-notifications__message`. Niobe groups are expanded
  by default, so the test must not click the group toggle.

- **The header `…` is persistent on list/search.** Those views have no `__secondary` cluster, so
  New Folder, Settings and Permissions only exist in the overflow; `pvtToolHeader.jsp` adds
  `sakai-tool-header__more--persistent` there. On `home` the utilities stay in `__secondary` and
  the `…` is the narrow fallback.
- **The empty-state Compose link must not reuse `.sakai-messages__compose-link`.** E2E strict
  locators assume one compose link per page; the empty state uses
  `.sakai-messages__empty-action`.
- The compose/reply `hidden` attribute works because Bootstrap reboot ships
  `[hidden] { display: none !important; }`. Do not replace it with a tool-local display rule.

## Key files

- Shared header: `msgcntr/messageforums-app/src/webapp/jsp/privateMsg/pvtToolHeader.jsp`
- List toolbar: `.../jsp/privateMsg/msgHeader.jsp`
- Views: `pvtMsgHpView.jsp`, `pvtMsg.jsp`, `pvtMsgEx.jsp`, `pvtMsgDetail.jsp`,
  `compose.jsp`, `pvtMsgReply.jsp`, `pvtMsgReplyAll.jsp`, `pvtMsgForward.jsp`,
  `pvtMsgSettings.jsp`, `pvtMsgFolder*.jsp`, `pvtMsgMove.jsp`, `pvtMsgDelete.jsp`
- Navigation helper: `PrivateMessagesTool.processPvtMsgHeaderBack()`
- Skin: `library/.../sass/modules/tool/messages/_messages.scss`
- Strings: `msgcntr/messageforums-api/src/bundle/.../Messages.properties`
- E2E: `e2e-tests/.../MessagesTest.java`, `MessagesSearchTest.java`, `TagsTest.java`
