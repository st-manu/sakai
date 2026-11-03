# Messages — JSF private messages reference

Messages is the first **JSF/JSP** tool migrated to the Niobe conventions. Use it when touching the
private messages views: the hard part is not the CSS, it is keeping JSF command links, view state
and the JSP include model working while replacing the flat `navIntraTool`.

Chrome contract: [`library/docs/sakai-ui-chrome.md`](../library/docs/sakai-ui-chrome.md).
Playbook: [`sakai-ui-tool-migration.md`](sakai-ui-tool-migration.md).

## A/B/C in Messages

| Item | Kind | Markup |
|------|------|--------|
| Folder list (home) | **A** | View H1 (“Messages”); folders are data rows, not a segmented control |
| Message list / search results | **A** | View H1 is the folder name or “Search”; the portal tool crumb owns the way home |
| Compose Message | **B** | `.sakai-btn sakai-btn-primary` with a `bi-plus-lg` icon |
| New Folder / Settings | **C** | `.sakai-btn sakai-btn-secondary`; with Permissions they stay inline up to three utilities |
| Permissions | **C** | `.sakai-btn sakai-btn-ghost` |
| Folder list | **A** | The home view (`pvtMsgHpView`) is the only folder switcher; folder views expose **All folders** in the header |
| Flow views (compose, reply, forward, settings, folder add/rename/delete, move, delete) | — | Header keeps the view H1 and a single **Back to list** action; form buttons stay in `.sakai-actions` |
| Message detail | — | Subject is the H1; object actions (Reply, Reply all, Forward, Move, FAQ, Delete) are the detail `.sakai-actions` |

`pvtToolHeader.jsp` is the shared header. Pages set request attributes before including it:

```jsp
<% request.setAttribute("pvtHeaderView", "list"); %>   // home | list | search | detail
<% request.setAttribute("pvtHeaderTitleKey", "pvt_pvtcompose"); %>
<% request.setAttribute("pvtHeaderBack", "compose"); %>
<%@ include file="/jsp/privateMsg/pvtToolHeader.jsp" %>
```

`pvtHeaderBack` is dispatched by `PrivateMessagesTool.processPvtMsgHeaderBack()` through a
`pvtHeaderBack` request parameter, so one link covers every return destination.

## Layout contract

```
.portletBody
  header.sakai-tool-header
    h1.sakai-tool-header__title                 ← folder, Search, subject or flow view
    .sakai-tool-header__actions                 ← Compose + All folders + utilities/overflow
  .sakai-table-toolbar
    .sakai-table-searchFilter + .sakai-table-viewFilter
  .sakai-table-wrap > table.sakai-table.sakai-table--hover
  .sakai-actions                                ← bulk actions / form footer / object actions
```

The folder home is a `.sakai-table` with Folder, Messages, Unread and a trailing `…` menu. A folder
view keeps the folder name as the view heading and exposes **All folders** in the header to return to
`pvtMsgHpView`; the tool utilities live in the `…` overflow.

## Primitives and patterns used

| Pattern | Classes / notes |
|---------|-----------------|
| Header | `.sakai-tool-header`, `__title`, `__actions`, `__secondary`, `__more`; folder views use `__actions--collapsed` so the overflow is always visible |
| Buttons | `.sakai-btn` / `-primary` / `-secondary` / `-ghost` / `-icon`; also on `<input type=submit>` |
| Table | `.sakai-table sakai-table--hover`, `.sakai-table-wrap`, `__primary`, `__nowrap`, `__select`, `__actions` |
| Select all | `.sakai-table__select` header cell with the checkbox and a `visually-hidden` label, matching Announcements and Polls |
| Tags | `.sakai-messages__subject-tags` inside the `__primary` subject cell; Label stays in its own column |
| Bulk actions | `.sakai-actions` after the table with `.ToggleBulk` submit buttons; `bulkops.js` toggles their `disabled` state |
| Search / view filter | `.sakai-table-toolbar`, `.sakai-table-searchFilter`, `.sakai-table-viewFilter`, `sakai-form-control sakai-form-control--sm` |
| Advanced search | `.sakai-messages__search-options`, `.sakai-form-section__title`, `.sakai-form-choice`, `.sakai-messages__search-extra.showed` |
| Forms | `.sakai-form-section` + `__title`, `.sakai-form-field`, `.sakai-form-label` (+ `.required`), `.sakai-form-control`, `.sakai-form-choice`, `.sakai-form-help`, `.sakai-messages__choice-group` (JSF radio table) |
| Banners | `.sakai-banner sakai-banner--error|--warn|--success` |
| Detail | `.sakai-messages__detail-summary`, `.sakai-messages__meta`, `.sakai-messages__body` |
| Icons | `bi bi-folder`, `bi bi-plus-lg`, `bi bi-chevron-*`, `bi bi-envelope*`, `bi bi-three-dots` |
| Responsive | `@container sakai-tool` in `_messages.scss`; no viewport queries inside the tool |

## Form conventions

- Compose, reply, reply-all and forward use the same shell: `.sakai-form-section` for
  `Recipients`, `Message`, `Attachments` and `Tags`; `.sakai-form-field` for each label/control
  pair; `.sakai-form-choice` for the BCC, email-copy, read-receipt and schedule toggles.
- The conditional schedule date is a `.sakai-form-subfield` nested in the scheduler
  `.sakai-form-field`; keep the `openDateSpan` ids because the JS toggles them.
- JSF `h:selectOneRadio layout="pageDirection"` renders a table. `.sakai-messages__choice-group`
  is the Messages adaptation: `display:block`, no margin, collapsed borders, compact cell padding
  and label-size text. Do not replace it with `.sakai-form-choice-group` unless the JSF markup is
  restructured to plain inputs.
- The recipient controls are `h:selectManyListbox` enhanced by Select2 (`addTagSelector`). They are
  not visible native multi-selects; keep the clear-selection link pattern and its
  `handleSelectionChange` toggle.
- Required labels use `.sakai-form-label.required`. The old `instruction` + `reqStarInline`
  required legend was removed; do not bring it back.
- Actions: Send/Save/Move/Add and a delete confirmation are primary; Preview, Save Draft,
  Reply All, Forward, Move, FAQ and the detail Delete are secondary; Cancel, Back and Return are
  ghost.
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
  rendered in the Scheduled folder; the `columns` array in `pvtMsg.jsp` must use the same condition.
  `PrivateMessagesTool.calculateColumnClass()` must also match the rendered column count, or the
  `specialLink`/`date`/`addressee` classes shift to the wrong cells.
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
* **Move uses one `h:selectOneMenu`.** The old per-folder `h:selectOneRadio` rendered a nested
  table per row and could not follow the shared form spacing; the single select keeps the current
  folder disabled and submits on change.
* **The recipients picker is the remaining forms exception.** Compose/reply/forward still use the
  legacy JSF `h:selectManyListbox` enhanced by Select2. The shared forms rule prefers
  `.sakai-form-choice-group` + `.sakai-form-choice` (or a shared picker); replace this control when a
  reusable recipient picker exists, not with a bespoke checkbox list.
* The rich-text editor is CKEditor; `sakai:inputRichText` ids are unchanged (`compose:subject`,
  `compose:list1`, …), so the existing e2e helpers and tag selectors keep working.

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
