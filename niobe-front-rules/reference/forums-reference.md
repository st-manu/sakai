# Forums (Discussions) — JSF reference

Forums is the second **JSF/JSP** tool in the Niobe migration after private Messages. It shares the
`msgcntr` webapp, the `ForumTool` bean and the message bundle, but it is a separate tool
(`sakai.forums`, label **Discussions**). Private messages are out of scope: see
[`messages-reference.md`](messages-reference.md).

Chrome contract: [`library/docs/sakai-ui-chrome.md`](../../library/docs/sakai-ui-chrome.md).
Playbook: [`sakai-ui-tool-migration.md`](../sakai-ui-tool-migration.md).

**Status:** Remediation pass applied (2026-11-08). Verified on TEST_001:

- **Organize P2:** wide → secondary only (`panel` priority-2 `display:none`); narrow → panel only.
  Root cause was overflow-item `a:not(.sakai-btn)…` specificity; fixed with `:where()` in
  `_sakai-overflow-menu.scss`. Forum/Topic Settings dual-mounted the same way.
- **Topic row `…`:** `td.sakai-table__actions` + `.sakai-row-actions` opacity `0` at rest (fine pointer).
- **Forms:** settings / permissions / compose / reply / revise use sakai-form-* + `.sakai-actions`
  (intentional inline `display` toggles remain for date/anonymous JS).
- **Flat / message cards / message detail:** Niobe chrome + card actions; print pages still legacy.
- **Statistics A3:** R + A1 By User|By Topic + `sakai-table`; drilldown body chrome still partial.

`forumsMenu.jsp` is removed; `forumsHeader.jsp` is the shared header. Remaining: print-friendly,
ranks/pending polish, authored/full-text stats card leftovers.

## Scope and engine

| Item | Value |
|------|-------|
| Module | `msgcntr/messageforums-app` (API `-api`, impl `-component-impl`, mapping `-hbm`, docs `-docs`) |
| Tool registration | `src/webapp/WEB-INF/tools/sakai.forums.xml` (`sakai.forums`, title **Discussions**) |
| Default view | `jsp/discussionForum/forumsOnly/dfForums.jsp` (`forumsMain` outcome) |
| Engine | JSF 2.3 / JSP with the custom `mf:*` components and `faces-config.xml` outcomes |
| Backing bean | `org.sakaiproject.tool.messageforums.DiscussionForumTool` (`ForumTool`) + `mfStatisticsBean` |
| Page shell | `<sakai:view>` renders the portal `div.portletBody`; most JSPs also link `/messageforums-tool/css/msgcntr.css` |
| Body class | `Mrphs-sakai-forums`; private Messages views in the same webapp also render under it |
| Skin | `library/src/skins/default/src/sass/modules/tool/forums/_forums.scss` (legacy) |
| Bundle | `msgcntr/messageforums-api/src/bundle/org/sakaiproject/api/app/messagecenter/bundle/Messages.properties` |
| E2E | `e2e-tests/src/test/java/org/sakaiproject/e2e/tests/ForumsTest.java`, `ForumThreadsSorterTest.java` |

`jsp/main.jsp` and `jsp/discussionForum/area/dfArea.jsp` belong to the legacy combined
`sakai.messagecenter` servlet and are not reachable through a registered tool. Treat them as dead
surfaces; do not migrate or link them.

## Current navigation (all sources)

`jsp/discussionForum/menu/forumsMenu.jsp` is included inside the page form on every Forums surface.
It is the only `navIntraTool actionToolbar` for Forums:

| Item | Role today | Rendered when | Action |
|------|-----------|---------------|--------|
| Discussions | section link | always | `action="forumsMain"` |
| New Forum | action | `ForumTool.newForum` | `processActionNewForum` |
| Organize | action | instructor | `processActionTemplateOrganize` |
| Template Settings | action | instructor | `processActionTemplateSettings` |
| Statistics & Grading | action | instructor | `processActionStatistics` |
| Statistics (student variant) | action | non-instructor | `mfStatisticsBean.processActionStatisticsUser` |
| Pending Messages (N) | action | `displayPendingMsgQueue` | `processPendingMsgQueue` |
| Ranks | action | instructor + `ranksEnabled` | `processActionViewRanks` |
| Notifications | action | always | `processActionWatch` |

The menu is emitted **above** the page H1. Each page marks itself current with JavaScript that adds
`.current` to `#forumsMainMenuLink` and replaces the link with plain text; the settings pages mark
`#forumsNewMenuLink` instead. The state is therefore real only when JavaScript runs and it lies on
every non-home surface.

`jsp/discussionForum/area/dfArea.jsp` adds a second action row (`mf:forum_bar_link`: New Forum,
Template Settings, Organize, Statistics, Pending) and then includes `dfAreaInclude.jsp`. It is only
used by the unreachable `main.jsp`.

## Current tree

```
Discussions (A1 in practice)
  New Forum | Organize | Template Settings | Statistics & Grading | Notifications
  [pending queue if moderator] [ranks if enabled]
  H1 Discussions
  forum block (title link, New Topic | Forum Settings | More, description)
    topic rows (folder icon, title, unread/total, Topic Settings | More)
Forum detail
  same global menu
  local breadcrumb: Discussions / <forum>
  forum title + New Topic | Forum Settings | Grade
  topic rows (title, counts, Topic Settings | Duplicate Topic | Grade | Delete Topic)
Topic (Conversations)
  same global menu
  < Previous Topic / Next Topic in the page corner
  local breadcrumb: Discussions / <forum> / <topic> + up-arrow
  Start a New Conversation | Display Message Content | Topic Settings | Delete Topic | Print
  topic callout
  Move Thread(s)
  table: select | Conversation | Mark as Not Read | Authored By | Date
  duplicate Previous/Next Topic at the bottom
Topic (Flat view)
  same global menu
  breadcrumb + Previous/Next Topic
  Mark All as Not Read
  Start a New Conversation | Display Subject Only | Topic Settings | Delete Topic | Print
  threaded message table
  duplicate Previous/Next Topic at the bottom
Thread
  same global menu
  breadcrumb: Discussions / <forum> / <topic> / <subject>
  Previous/Next Conversation + Reply to Initial Message | Mark All as Not Read | Print
  View: by Conversation / by Date Ascending / by Date Descending / Unread
  message table/cards with Mark as Not Read | Reply | Email | Grade | Edit | Delete Message
  duplicate Previous/Next Conversation at the bottom
Message detail
  same global menu
  breadcrumb + Previous/Next Thread
  topic callout + message count
  Reply | Reply to Thread | Delete | Revise | Grade | Email | Permalink | Deny | Add comment | Approve
  single message + Previous/Next Message + Previous/Next Thread
Compose / reply / revise
  same global menu
  H3 "Start a Conversation" / "Reply" / "Revise Message" (not an H1)
  fields, attachments, Post + Cancel
Forum settings / topic settings
  same global menu (New Forum marked current on new forum)
  H1 "Forum Settings" / no dedicated H1 on the confirmation pages
  fields, availability, grading, permissions; Save / Save & Add Topic / Save Draft / Cancel
Template settings / organize / notifications
  same global menu
  H1 + instruction + sections; Save / Cancel
Statistics & Grading (A3 today rendered as a flat menu entry)
  same global menu
  local breadcrumb: Discussions / Statistics & Grading
  "Statistics & Grading by User Download | Statistics & Grading by Topic"
  wide table with sort links in column headers
  drilldowns: user, topic, authored messages, full text, display in thread
Pending Messages
  same global menu (queue marked current)
  local breadcrumb: Discussions / Messages Pending Approval
  instruction + table: select-all | Deny/Approve in the header | message + author + date + forum/topic + body
Ranks (when enabled)
  same global menu
  "Add Rank"; table of ranks; Delete Rank + Cancel
Print-friendly
  no tool header/menu; local breadcrumb only
```

### Current tree (browser baseline)

Captured 2026-11-08 against `http://localhost:8080/portal/site/TEST_001` as `admin`
(`Sakai Administrator`), forum **Foros**, topic **Tema**, message **Hola**.

- Home: global menu renders as two rows of pill buttons above the H1; forum and topic rows are
  inline link rows with pipes and Bootstrap dropdowns; no table, no toolbar, no empty state offered
  in this site.
- Forum: duplicate breadcrumb `Discussions / Foros` below the menu; another button row.
- Topic: five separate action groups (pager top right, breadcrumb + up arrow, four action buttons,
  print, Move Thread(s), table, pager bottom). The top pager and the action row visually collide at
  the current width in a 1440 px class viewport.
- Thread: Previous/Next Conversation overlaps Reply/Mark all/Print; the message action wall takes two
  rows inside the message card.
- Settings: New Forum opens a form whose H1 is **Forum Settings** and whose `…`-less action footer is
  below the permissions block; the menu marks **New Forum** current, not Discussions.
- Statistics: the A3 surface is entered from the flat menu; its own two views are inline links and
  the table has no toolbar.
- The existing portal/theme chrome is Niobe, but the tool body is still legacy: `table table-striped
  table-hover`, `.button`, `.itemNav`, `.specialLink`, `.instruction`, `alertMessage`, raw `ms-2`,
  inline styles, and `.portletBody` content unrelated to the header.

## Diagnosis

1. **One menu for four jobs.** Sections, nested tool, object flows and utilities share
   `navIntraTool`; the current item is simulated with JavaScript.
2. **Wrong layer.** Statistics is an A3 nested workspace but is emitted as a peer action. Pending
   Messages is a moderator destination but is an action with a count. Ranks is a nested tool behind a
   flat entry. Organize/Template Settings/Notifications are flows, not sections.
3. **No object header.** Forum/topic identity, status, description, A2 views and object actions are
   mixed into table rows and inline action rows.
4. **Duplicate chrome.** Local breadcrumbs repeat `Discussions / …` that the portal already owns;
   previous/next controls are duplicated top and bottom; the home page has two action rows.
5. **Tables are not tables.** Home/forum lists are nested `h:panelGrid` blocks with pipe separators
   and “More” dropdowns; the conversations table has a per-row “Mark as Not Read” column; no
   `__primary`, no stacked labels, no toolbar, no selection bar.
6. **Forms are legacy.** `jsfFormTable`, `reqStarInline`, `<h2>/<h3>` for sections, `.act` footers,
   inline styles, `instruction` legends and a permissions include driven by jQuery accordion.
7. **Responsive is viewport/absolute.** `.itemNav { position:absolute; right:0 }` causes the overlap;
   `div.specialLink { max-width: calc(100% - 260px) }` reserves space for controls that no longer
   exist; media queries are `$phone` viewport queries, not container queries.
8. **Accessibility.** `role="menu"` without a keyboard model; current item is not `aria-current`;
   `.current` replaces the link with text; repeated ids (`openLinkBlock`, `showMessage`,
   `hideMessage`, `forumsMainMenuLink`) across rows; icon-only print uses an `sr-only` label (keep);
   disabled pager items are styled `<span>`s with no state text.
9. **Tokens and dead code.** Raw font sizes/margins, legacy classes, deprecated Bootstrap 4
   `pull-right`/`col-md-offset-*`, `table-responsive` wrappers, images for expand/collapse.
10. **i18n/timezone is already correct.** Dates use `ForumTool.userTimeZone` and
    `ForumTool.userLocale`; keep these conversions and do not switch to browser defaults.

## Target design

### Roles and zones

| Item | Role | Zone | Notes |
|------|------|------|-------|
| Discussions | **A1** | `.sakai-tool-nav` | Only when a second peer exists (moderators); otherwise the H1 is enough |
| Pending Messages (N) | **A1** | `.sakai-tool-nav` | Visible only to moderators; count in the label, not a badge-only state |
| New Forum | **P0-S** | Home header | Repeated in the empty state |
| New Topic | **P0-O** | Forum object header | Row `…` on the home forum block as the same action in context |
| Start a New Conversation | **P0-O** | Topic/flat object header | Replaces “Start a New Conversation” button wall |
| Reply to Initial Message | **P0-O** | Thread object header | Message-level Reply stays in each message card |
| Reply / Reply to Thread | **P0-O / P1** | Message object header | Reply primary; Reply to thread secondary |
| Organize | **P2** | Home header | Flow back to Discussions |
| Forum/Topic Settings | **P2** | Object header | Flow back to the object |
| Mark All as Not Read | **P2** | Thread header | Only when the topic allows it |
| Template Settings | **P3** | Home `…` | Flow |
| Statistics & Grading | **P3** | Home `…` | Entry to the A3 nested tool |
| Notifications | **P3** | Home `…` | Flow |
| Ranks | **P3** | Home `…` | Entry to the A3 nested tool, only when enabled |
| Print | **P3** | Topic/thread/message `…` | Opens the existing print-friendly URL |
| Duplicate | **P3** | Forum/topic `…` | Confirmation flow |
| Grade | **P3** | Forum/topic/message `…` | Opens the existing grade/statistics flow |
| Move Thread(s) | **P0-B** | Topic selection bar | Disabled until a thread is selected |
| Approve / Deny | **P0-B** | Pending selection bar | Bulk actions after a selection |
| Delete Forum/Topic/Message | **P4** | `…`, separated | Confirmation preserved |
| Sort / view | **D** | `.sakai-table-toolbar` | Thread sort, statistics sort, pager |
| Export/Download | **P3** | Statistics toolbar `…` or action row | Keep URL |
| Previous/next | object pagination | Bottom `.sakai-actions` row | Never in the page header |

### Target tree

```
Discussions (A1 home; H1 only when no peer nav)
  A1 nav (moderators only): Discussions (current) | Pending Messages (N)
  header: H1 Discussions
          P0 New Forum | P2 Organize | … (Template Settings, Statistics & Grading, Notifications, Ranks)
  forum section
    forum header: title link + status tags + short description + counts
                  … (New Topic, Forum Settings, Grade, Duplicate, Delete)
    topics table (Topic | Messages | Unread | …)
    empty state: "No topics yet" + Create a topic
  empty state: "No forums yet" + New Forum
Forum
  R Back to Discussions (quiet link)
  object header: H1 <forum> + DRAFT/locked/availability tags + description
                 P0 New Topic | P2 Forum Settings | … (Grade, Duplicate, Delete)
  topics table (Topic | Messages | Unread | …)
  empty state: "No topics yet" + New Topic
Topic — A2 Conversations | Flat view
  R Back to <forum>
  object header: H1 <topic> + status tags + description
                 P0 Start a New Conversation | P2 Topic Settings | … (Print, Delete)
  A2: Conversations (current) | Flat view
  table toolbar: sort (Thread, Date ascending, Date descending, Unread)
  conversations table: select | Conversation (primary, unread badge) | Authored by | Date | …
  selection bar: Move Thread(s)
  bottom object pager: Previous Topic | Next Topic
Flat view
  same header/A2; Flat view current
  P0 Start a New Conversation | P2 Topic Settings | … (Print, Delete)
  message cards/threaded list + bottom pager
Thread
  R Back to <topic>
  object header: H1 <subject>
                 P0 Reply to Initial Message | P2 Mark All as Not Read | … (Print)
  D: sort/view control
  message cards: author/photo, date, read count, subject, body, rank, attachments
                 Reply (primary inline) + … (Mark as not read, Email, Grade, Edit, Delete)
  bottom object pager: Previous Conversation | Next Conversation
Message
  R Back to <thread> (or Back to <topic> when the thread head is the message)
  object header: H1 <subject> + author/date/read metadata + rank
                 P0 Reply | P1 Reply to Thread | … (Email, Grade, Edit, Permalink, Approve/Deny, Delete)
  body + attachments
  bottom pagers: Previous Message | Next Message, Previous Conversation | Next Conversation
Compose / Reply / Revise
  R Back to <topic> or Back to <thread>
  H1 Start a New Conversation / Reply / Revise Message
  sections: Message, Attachments, (moderation note)
  .sakai-actions: Post/Publish primary, Cancel ghost
Forum/Topic settings
  R Back to <forum> / <topic>
  H1 New Forum / Forum Settings or New Topic / Topic Settings
  sections: Details, Availability, Grading, Permissions
  .sakai-actions: Save primary, Save & Add Topic / Save Draft secondary, Cancel ghost
  Delete/Duplicate confirmation pages keep their banner + P4 action
Template Settings / Organize / Notifications
  R Back to Discussions
  H1 + sections + .sakai-actions (Save primary, Cancel ghost)
Statistics & Grading (A3)
  R Back to Discussions
  nested H1 Statistics & Grading
  A1: By User (current) | By Topic
  toolbar: Export/Download (P3) + sort controls (D)
  tables: name/id/authored/read/unread/percent; topic tables with grade column when configured
  drilldown: R Back to Statistics & Grading; H1 user or topic; authored/full-text/thread views
Pending Messages (A1)
  A1 nav: Discussions | Pending Messages (N) (current)
  H1 Messages Pending Approval
  selection table: select | Message (primary) | Author | Date | Forum / Topic
  bulk bar: Approve | Deny (P0-B)
  empty state: "No messages pending approval"
Ranks (A3, when enabled)
  R Back to Discussions
  nested H1 Ranks
  P0 Add Rank + ranks table (title, image, posts, …)
  Add/Edit/Delete rank flows keep their forms and confirmations
Print-friendly
  no app chrome; content only; `.sakai-no-print` on controls
```

### Surface contracts

**Home.** The H1 is the view (“Discussions”), not the tool repeated from the portal crumb. New Forum
is the only primary. Organize stays visible at wide width; the `…` always exists because Template
Settings, Statistics & Grading and Notifications are P3. The forum block is the object header for a
forum row: identity, status, short description and counts; topic rows sit in a real table below it.
This keeps the forum → topics grouping without nesting a `<table>` inside another `<table>`.

**Forum detail.** Object header owns New Topic. Forum Settings is P2, and Grade/Duplicate/Delete move
to the `…`. The topics table is the same component as the home topic table.

**Topic.** A2 is two peer views of the topic: Conversations and Flat view. The sort control is a data
control, not A2. Previous/next topic is object pagination at the bottom only. Keep the existing
`moveThreadPicker` dialog and `processMoveThread` flow, but trigger it from the selection bar and
disable it until a thread is selected.

**Thread / message.** Message bodies are user HTML. Keep them inside a bounded
`.sakai-forums__message-body` and do not add a max-width wrapper around the view. Per-message
utilities go in a row `…`; Reply remains visible. The two pagers are separate object navigations and
belong at the bottom, not in the header.

**Flows.** One H1, one R, one `.sakai-actions`. Do not add a second Cancel next to R. Keep JSF ids
that JavaScript reads (`revise:availabilityRestricted:*`, `revise:saveandadd`, CKEditor ids,
`msgForum:df_move_message_commandLink`, `selectedTopicid`, `moveReminder`, `openDateSpan`).

**Statistics and ranks.** Treat both as A3: nested H1, their own A1 where they have peers (statistics
By User / By Topic), and R to Discussions. Do not repeat the parent A1 inside the nested header.

## Action placement

| Surface | P0 | P1 | P2 | `…` (P3/P4) | D / bulk |
|---------|----|----|----|-------------|----------|
| Home | New Forum | — | Organize | Template Settings, Statistics & Grading, Notifications, Ranks; Delete on forum rows | — |
| Forum | New Topic | — | Forum Settings | Grade, Duplicate, Delete Forum | topic counts |
| Topic | New Conversation | — | Topic Settings | Print, Delete Topic | sort, Move Thread(s) |
| Flat | New Conversation | — | Topic Settings | Print, Delete Topic | — |
| Thread | Reply to Initial | — | Mark All as Not Read | Print | sort |
| Message | Reply | Reply to Thread | — | Email, Grade, Edit, Permalink, Approve/Deny, Delete | message/thread pagers |
| Compose/reply/revise | Post/Publish (footer) | — | — | — | — |
| Forum/topic settings | Save (footer) | — | Save & Add Topic / Save Draft | Delete/Duplicate in the confirmation flow | availability/grading/permissions |
| Template/organize/notifications | Save (footer) | — | — | — | — |
| Statistics | — | — | — | Export/Download | sort |
| Pending | Approve/Deny (bulk) | — | — | — | select-all |
| Ranks | Add Rank | — | — | Delete Rank | — |

No general FAB. No attention animation. `…` is rendered only when it has at least one item; on Home it
is persistent because P3 always exists.

## Responsive plan

- The tool is a container (`.sakai-page-content` / `.sakai-tool-body` already set
  `container-type: inline-size`). Use `@container sakai-tool (...)` in `_forums.scss`; no viewport
  media queries inside the tool.
- Header: P0 and `…` stay visible at compact; P1/P2 live in `.sakai-tool-header__secondary` and are
  hidden below `48rem` by the shared header. Because Forums always has P3/P4, add
  `sakai-tool-header__more--persistent` so `…` remains at wide width.
- The forum block is a two-column grid at wide (identity + actions) and a single column at compact.
- Tables use `.sakai-table--stack`: JSF does not emit `data-label`, so the shared body script fills
  it from the visible `thead`. Mark the title cell `sakai-table__primary`.
- The conversations table keeps the checkbox and title at compact; author/date become labelled
  stacked lines; the row `…` stays reachable.
- Message cards switch from photo + body to a single column; actions wrap under the body.
- Permissions are a long choice group. At compact it becomes one column; keep the existing JSF
  select/checkbox ids so `permissions_header.js` and `disableFieldsBeforeSubmit()` keep working.
- Print: use `.sakai-no-print` on header, toolbars, pagers, row actions and selection bars. The
  print-friendly JSPs keep their own minimal layout.

## Phase plan

### Phase 1 — navigation and header

- Add `jsp/discussionForum/menu/forumsHeader.jsp`: shared `.sakai-tool-header` with
  `dfHeaderSurface`, `dfHeaderBack`, optional title key and scriptlet-guarded action clusters.
- Replace `forumsMenu.jsp` includes with the header on every reachable surface; delete the old menu
  once all includes are migrated. Keep `dfArea.jsp` untouched (unreachable).
- Add A1 `.sakai-tool-nav` for Discussions / Pending Messages (moderators only); use
  `aria-current="page"` on the current item and add the shared CSS rule for it.
- Add R links: back to Discussions, forum, topic, thread, statistics. Remove local breadcrumb `h3`s
  and the up-arrow duplicate.
- Move Statistics, Template Settings, Notifications, Ranks into the home `…`; move Pending into A1;
  make New Forum/New Topic/New Conversation the only header primaries.
- Fix page H1s: New Forum and New Topic get their own titles; delete/duplicate confirmation pages get
  clear H1s.
- Add bundle keys for back links and nested titles; keep existing labels/URLs.

Exit: no `navIntraTool`/`actionToolbar` on reachable Forums pages; one R per surface; A1/A2/P0 in
their zones; every page has one H1 that names the view.

### Phase 2 — tables, rows and empty states

- ~~Home: replace the nested `h:panelGrid` forum blocks with a forum section (div) + one topic table;
  per-row `…` replaces pipe links and Bootstrap dropdowns.~~ (`dfAreaInclude.jsp` + `t:dataList`)
- ~~Forum detail: same topic table; remove the inline action links.~~ (`dfForumDetail.jsp`)
- ~~Organize: rebuild with nested `sakai-reorderer` (forums → topics), undo, and Save that persists
  `forumOrder` / `topicOrder_{forumId}`.~~ (`dfTemplateOrganize.jsp`, `forums-organize.js`)
- ~~Topic: rebuild the conversations table with select / Conversation (primary) / Authored by / Date /
  `…`; move sort to the toolbar; move “Mark as Not Read” into the row `…`; add the bulk selection
  bar for Move Thread(s).~~ (`dfAllMessages.jsp`; expand/collapse gifs and flat-view cards still legacy)
- Pending: table with select-all and bulk Approve/Deny bar.
- Statistics and ranks: align tables and sort controls with `.sakai-table`; keep the current sort
  actions and URLs.
- Home/forum empty states use `.sakai-forums__empty`; extend to conversations and pending.
- Remove remaining `specialLink` / duplicated bottom pager markup on topic/thread surfaces.

Exit: all list surfaces use `.sakai-table` / `--stack`; row actions live in `…`; empty states have
one action; bulk actions are disabled until selection.

### Phase 3 — forms

- Forum settings (new/edit), topic settings (new/edit), delete/duplicate confirmation pages,
  template settings, organize, notifications, ranks add/edit/delete, compose/reply/revise.
- Convert `jsfFormTable`/`panelGrid` to `.sakai-form-section` + `.sakai-form-field` +
  `.sakai-form-label` and `.sakai-form-choice`; required labels use `.required`; errors use
  `.sakai-form-error` / `.sakai-banner--error`.
- Wrap each form footer in `.sakai-actions`; primary Save/Post, secondary Save & Add Topic /
  Save Draft, ghost Cancel. Keep `.act` only where JavaScript depends on it, and migrate the JS.
- Preserve CKEditor ids, datepicker ids, `openDateSpan`, group/grade selectors, permissions ids and
  `disableFieldsBeforeSubmit()`.
- Remove `reqStarInline`, `instruction` legends, `.messageInstruction` and inline styles.

Exit: every flow has sections, labelled fields, one primary in the footer and one exit; no raw
spacing/colour values.

### Phase 4 — nested tools

- Statistics: nested H1, R to Discussions, A1 By User / By Topic, toolbar with export and sort,
  drilldowns with their own R. Preserve every `mfStatisticsBean` outcome and the grade column.
- Ranks: nested H1, R, Add Rank primary, table and confirmation flows.
- Pending: A1 destination with its own table/bulk bar; no queue count in the page title.
- Keep grade-entry dialogs and `sakai-rubric-student-preview-button` integration unchanged.

Exit: A3 workspaces read as self-contained; their A1 never mixes with parent actions; every
drilldown has one R.

### Phase 5 — detail, print, polish, tests and docs

- Thread and message card layout (photo, rank, attachments, actions `…`); keep permalink and mailto.
- Print-friendly pages and `.sakai-no-print` coverage.
- Replace remaining legacy classes/icons in touched files; remove `pull-right`, `ms-2`,
  `col-md-offset-*`, `text-muted`, inline styles and image expand/collapse.
- Verify light/dark, L0 brand, compact/medium/wide, keyboard and reduced motion.
- Playwright: extend `ForumsTest` (open `…` before Statistics/Delete Topic), add home/topic/thread
  assertions, role checks, empty state, and one preserved-URL check.
- Update this reference, the roadmap and the README.

## Primitives and patterns

| Pattern | Classes / notes |
|---------|-----------------|
| Header | `.sakai-tool-header`, `__title`, `__actions`, `__secondary`, `__more--persistent` |
| Back | `.sakai-back-link-row` + `.sakai-back-link` with `si si-arrow-left`; never a button |
| Sections | `.sakai-tool-nav` + `__item` + `__btn`; current item `is-active` + `aria-current="page"` |
| Object views | `.sakai-segmented-control` + `__item` + `__btn` (Conversations / Flat view) |
| Buttons | `.sakai-btn` / `-primary` / `-secondary` / `-ghost` / `-icon`; works on `<input type=submit>` |
| Overflow | Shared `<details class="sakai-overflow-menu">`; no per-tool positioning |
| Table | `.sakai-table sakai-table--hover sakai-table--stack`, `.sakai-table-wrap`, `__primary`, `__select`, `__actions` |
| Toolbar | `.sakai-table-toolbar`, `sakai-form-control sakai-form-control--sm` |
| Bulk | `.sakai-actions` / selection bar; JS toggles `disabled` |
| Empty | Shared empty-state component with one action |
| Tags | Status as text + `si si-*`: draft, locked, unavailable, moderated, unread |
| Forms | `.sakai-form-section`, `__title`, `.sakai-form-field`, `.sakai-form-label`, `.sakai-form-choice`, `.sakai-form-help`, `.sakai-form-error` |
| Actions | `.sakai-actions` footer; primary/secondary/ghost/overflow order |
| Icons | `si si-add`, `si si-arrow-left`, `si si-three-dots`, `si si-folder`, `si si-folder-fill`, `si si-locked`, `si si-calendar-x`, `si si-print`, `si si-reply-fill`, `si si-reply-all-fill`, `si si-edit`, `si si-trash`, `si si-envelope`, `si si-link`, `si si-award`, `si si-table`, `si si-check`, `si si-cancel` |
| Responsive | `@container sakai-tool` only |

## Gotchas

- **JSF `rendered` is evaluated at render, not decode.** Wrap action clusters in JSP scriptlet `if`
  as `pvtToolHeader.jsp` does; use bean-backed `rendered` only for stable flags (`instructor`,
  `newForum`, `displayPendingMsgQueue`, `ranksEnabled`). A header action hidden by a request-scoped
  `rendered` will never fire.
- **Header links are `immediate="true"`.** They must not be blocked by the settings/message form
  validation.
- **One form per page.** The header is included inside the existing `<h:form>`; do not create a
  second form for the header or nest forms.
- **`forumsMenu.jsp` is included inside forms.** Replacing it is safe only if the new header stays
  inside the same form and keeps the bean actions.
- **`action=` vs `actionMethod=`.** Most nav uses outcomes (`forumsMain`, `dfForums`); object links
  use methods with `f:param`. Keep the observed outcomes and parameters so URLs and back-stack
  behaviour do not change.
- **Duplicate HTML ids per row.** `openLinkBlock`, `showMessage`, `hideMessage`,
  `forum_extended_show2` and `fullTopicDescription` repeat inside `h:dataTable` rows. When touching
  these, switch to classes/`data-*` hooks, or make ids unique with the row id. Do not add more
  duplicate ids.
- **Nested tables.** The home/forum lists currently nest `h:panelGrid` and `h:dataTable` inside an
  outer `h:dataTable`. Replace the outer table with a div-based forum section and keep one real
  topic table per forum; do not emit `<table>` inside `<table>`.
- **JSF tables do not emit `data-label`.** Add `sakai-table--stack` and let the shared body script
  copy the `thead` text; mark the title cell `__primary`.
- **`itemNav` is cloned by JavaScript in the thread view.** `dfViewThread.jsp` clones
  `.itemNav` into the form and adds `<br/><br/>`; remove that script when the pager moves to the
  bottom, or it will duplicate the new pager.
- **`input[type=submit].sakai-btn-*` needs the shared rule.** `<h:commandButton>` renders an input;
  the skin already extends submit/button/reset variants. Do not add a tool-local override.
- **`dfViewMessage.jsp` starts with a literal `//` before the taglib directive.** It prints stray
  text. Remove that prefix when touching the file and confirm the taglib still applies.
- **`dfViewMessage` uses `prependId="false"`.** Its ids are global; header/action changes must not
  introduce duplicate ids.
- **Move threads depends on ids and hidden links.** Keep `msgForum:df_move_message_commandLink`,
  `hidden_move_message_commandLink`, `selectedTopicid`, `moveReminder`, and the
  `enableDisableMoveThreadLink()` contract when replacing the trigger. Preserve the dialog.
- **Permissions include is jQuery-driven.** Keep `permissions_include.jsp` ids and the
  `disableFieldsBeforeSubmit()` selectors (`revise:perm*:level`) unless you also migrate the JS.
- **Settings pages have no menu state of their own.** New Forum currently marks the New Forum menu
  item current. The header must use the page H1 (“New Forum”) and no A1 current item.
- **Availability dates are formatted by the bean.** Use `formattedOpenDate`/`formattedCloseDate`;
  do not format with the browser locale.
- **Date/time columns already use `ForumTool.userTimeZone`/`userLocale`.** Keep
  `<f:convertDateTime>` and the same pattern; do not replace with `toLocaleString()`.
- **Statistics sort links are command links in `thead`.** Move them to a toolbar or keep them as
  buttons inside `th` with `aria-sort` on the column header; do not fake sortable headers with
  `href="#"` alone.
- **The statistics “Download” label is misspelled in the bundle (`stat_explort_table`).** Keep the
  key, fix the visible text if it is in scope; do not rename the key without checking the bean.
- **No search.** `processActionSearch` exists but the search bar include is commented out. Do not
  add a search toolbar in this refactor.
- **Legacy `.specialLink` max-width.** `div.specialLink { max-width: calc(100% - 260px) }` is the
  reason content looks inset; remove it with the markup that uses it, not by overriding with
  `!important`.
- **No Docker/browser assumption in CI.** Playwright is the verification path; the local server may
  not be available. Do not claim browser results that were not captured.

## Tests

Existing coverage to keep green:

- `ForumsTest` creates a course with `sakai.forums`, creates a forum and topic, opens Statistics by
  Topic, deletes a topic, and checks Lessons links. It will need to open `…` before clicking
  **Statistics & Grading** and **Delete Topic**.
- `ForumThreadsSorterTest` exercises `data-sakai-forum-sort` on a synthetic table; keep those hooks
  on the conversations header.
- `SharedToolComponentsTest` covers the gradebook selector/rubric integration used by forum settings;
  keep the `sakai-gradebook-item-selector` and rubric components wired.

Add:

1. Home: H1, New Forum, `…` items, A1 only for moderators, empty state.
2. Forum: New Topic, Forum Settings, row `…`, delete/duplicate confirmations.
3. Topic: A2 Conversations/Flat view, sort, select + Move Thread(s) disabled/enabled.
4. Thread/message: Reply, per-message `…`, mark not read, permalink, print.
5. Student role: no settings/organize/statistics/ranks; statistics student variant still opens.
6. Narrow/medium/wide containers: header actions move to `…`, tables stack, no overlap.
7. Keyboard: A1 `aria-current`, `…` opens with Enter/Space and closes with Escape, focus returns.
8. Reduced motion: no attention animation; print: `.sakai-no-print` hides controls.

## Key files

- Navigation today: `msgcntr/messageforums-app/src/webapp/jsp/discussionForum/menu/forumsMenu.jsp`
- Home: `.../jsp/discussionForum/forumsOnly/dfForums.jsp`, `.../includes/dfAreaInclude.jsp`
- Forum: `.../jsp/discussionForum/forum/dfForumDetail.jsp`, `dfForumSettings.jsp`
- Topic: `.../jsp/discussionForum/message/dfAllMessages.jsp`, `dfFlatView.jsp`,
  `dfViewThread.jsp`, `dfViewMessage.jsp`, `moveThreadPicker.jsp`
- Composer: `.../jsp/dfCompose.jsp`, `dfMessageReply.jsp`, `dfMessageReplyThread.jsp`,
  `dfMsgRevise.jsp`
- Settings: `.../jsp/dfReviseForumSettingsAttach.jsp`, `dfReviseTopicSettingsAttach.jsp`,
  `.../discussionForum/topic/dfTopicSettings.jsp`, `.../permissions/permissions_include.jsp`
- Templates/notifications: `.../discussionForum/area/dfTemplateSettings.jsp`,
  `dfTemplateOrganize.jsp`, `dfWatchSettings.jsp`
- Statistics: `.../discussionForum/statistics/*.jsp`
- Pending/ranks: `.../discussionForum/message/dfPendingMessages.jsp`,
  `.../discussionForum/area/dfViewAllRanks.jsp`, `dfAddRank.jsp`, `dfEditRank.jsp`
- Navigation graph: `.../WEB-INF/faces-config.xml`
- Bean: `.../src/java/org/sakaiproject/tool/messageforums/DiscussionForumTool.java`
- Skin: `library/src/skins/default/src/sass/modules/tool/forums/_forums.scss` (replace/extend)
- Shared header pattern: `.../jsp/privateMsg/pvtToolHeader.jsp`
- Reference doc: this file

## Exceptions

- **Home groups forums and topics instead of one flat table.** Forums own topics; a single flat
  table would lose the grouping and force a redundant forum column. Keep one forum section per
  forum with one topic table, and let the section header carry the forum actions.
- **Statistics and ranks are A3.** They are not A1 peers of Discussions even though the legacy menu
  shows them beside it. Their entry is P3 and their own navigation starts inside the nested tool.
- **No functional search.** Do not invent one; the bean action exists but the UI was removed.
- **The Message detail keeps two pagers** (message and thread) because both are real object
  navigations; place both in the bottom action area, not in the header.
