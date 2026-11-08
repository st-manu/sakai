# Niobe tool navigation model

**Status:** working model, revised after reviewing the first four tool refactors.
**Scope:** a deliberately **superficial** survey of every module that still emits
`navIntraTool` / `actionToolBar` / `actionToolbar`, plus the tools already migrated.
**Goal:** settle the IA base before refactoring more tools, so each tool applies the same
navigation tree and the same surface composition instead of inventing another action row.

**The one rule:** places are navigation, actions are buttons, and not every action belongs in the
header. The missing axes are **layer** (tool / object / flow / nested tool) and **zone**
(page header / object header / list toolbar / table / action footer).

**Revision notes (this version):**

- Return/up is **R**, a navigation affordance, not an action in the header cluster.
- **P0 is not one role**: P0-S (surface), P0-O (object), P0-F (flow), P0-B (bulk).
- Actions are distributed by **zone**; the header is not a universal action container.
- Responsive overflow uses **priority tiers + container tiers**, not a server-side count.
- Floating action buttons are **not** a general P0 pattern; the portal FAB stack stays portal-owned.
- The first refactors (Polls, Announcements, Messages, Statistics) are navigation-good but
  **surface-inconsistent**; they need a parity pass before being treated as the final pattern.

The compact permanent contract lives in [`library/docs/sakai-ui-chrome.md`](../library/docs/sakai-ui-chrome.md).
The reusable per-tool prompt lives in
[`tool-navigation-refactor-prompt.md`](tool-navigation-refactor-prompt.md).

## 1. Method

1. Search the repo for the legacy navigation classes (excluding `target/`, `node_modules/`, e2e
   tests and the skin):
   `navIntraTool`, `actionToolBar`, `actionToolbar`.
2. Read the menu builder or template fragment for each representative tool: CHEF `MenuBuilder`,
   Velocity macros, JSF `*Headings.jsp`, Wicket `BasePage`, Thymeleaf `fragments/menus.html`,
   RSF page templates and the JS that fills empty toolbars.
3. Classify every visible item by **what happens when it is clicked**, not by its label or CSS.
4. Compare tools to find repeated structures. Record evidence, not opinions.

The search returns **32 top-level modules** still emitting the legacy classes. That is a lower
bound: some tools generate the menu from JavaScript and never put `navIntraTool` in a template.
The densest hot spots are Wiki (25 files), Tests & Quizzes (17), Messages/Forums (4) and Search (4).
Most other modules emit it from one or two files, which makes them cheaper to migrate.

This is not a full audit. It is a pattern map; the per-tool prompt produces the complete tree and
surface plan for one tool before that tool is changed.

## 2. What the tools contain

| Tool (engine) | Navigation source | Current top-level items (abridged) | What it reveals |
|---|---|---|---|
| Assignments (Velocity) | `assignment_macros.vm` `navBarHREF`, `navBarOnClick`, `navBarTimesheet` | List, Add, By Student, Grade Report, Student View, Reorder, Options, Removed, Permissions; timesheet tabs | A1 + B + C + admin in one row; a second A2 row for time sheet; every item has the same weight |
| Gradebook (Wicket) | `BasePage.html`, `BasePage.java` | Gradebook, Quick Entry, Import/Export, Permissions, Settings | A1 + workflows + C; current is a link with a `current` class; inner tabs are a separate level |
| Tests & Quizzes (JSF) | 12 `*Headings.jsp`, `itemHeadings.jsp`, `poolList.jsp` | Assessments, Add, Templates, Question Pools, Event Log, Section Activity, Permissions, Restore; assessment breadcrumb; pool menu | global menu repeated on every authoring page; L4 nested tools; L2 object level |
| Site Info (Velocity) | `MenuBuilder.SiteInfoActiveTab` (15 values), `#toolbar($menu)` | Site Information, Edit Site Info, Manage Tools, Tool Order, Date Manager, Participants, Rosters, Groups, Link to Parent, External Tools, Access, Duplicate, Import, Import Archive, User Audit, Manage Overview | a hub with 15 A1; some entries launch L4 tools |
| Site Group Manager (Thymeleaf) | `fragments/menus.html` | Group List, Create Group, Create Joinable Set, Auto groups, Bulk creation | a mini-tool with its own A1; wizard steps reuse the same current |
| Wiki (Velocity) | `macros.vm` `commandlinks`, `searchBox` | Home, View, Edit, Info, History, Watch, Print + search | A2 object views, actions and D search in one row |
| Lessons (RSF) | `ShowPage.html` toolbar + bottom `navIntraTool` | Add content, More tools (modal), Remove, Layout, Reorder, Bulk edit, Title, Print, Print all, Show pages, Previous/Next | icon toolbar; utilities inside a modal; top/bottom duplication; portal sidebar owns the page tree |
| Resources (Velocity) | `sakai_resources_columns.vm` | Site, WebDAV, Permissions, Hierarchy + action select | pipe-separated links; bulk actions in a select |
| Sections (JSF) | `inc/navMenu.jspf` | Overview, Add Sections, Student/Member, Options + print/download | A1 + B + C; page actions separated |
| Signup (JSF) | `menu/signupMenu.jsp` | Meetings, Add, Permissions, Export | A1 + B + C; no A2 |
| Syllabus (JSF) | `syllabus/mainMenu.jsp` | Main, Bulk Add, Create/Edit, Redirect | A1 + P0/P3; small set |
| Forums (JSF) | `discussionForum/menu/forumsMenu.jsp` | Discussions, New Forum, Organize, Template Settings, Statistics, Pending Queue, Ranks, Watch | A1 + B + C + reports/queue; overloaded |
| Podcasts (JSF) | `podcastMenu.jsp` | Home, Add, Options, Permissions | classic A1 + B + C |
| Attendance (Wicket) | `BasePage.html` | Add, Homepage, Student Overview, Grading, Settings, Export | A1 + B + C; Add comes first |
| Chat (JSF) | `chatMenu.jsp` | Main, Add room, Manage tool / Change room, Permissions | A1 + B + C + a room picker |
| Statistics (Thymeleaf, migrated) | `fragments/common.html`, `server-wide.html` | Overview, Reports, User Activity, Preferences; Add; exports; Server-wide types | A1 views as secondary buttons; second-level tool nav |
| Messages (JSF, migrated) | `pvtToolHeader.jsp` | Folders, Compose, New Folder, Settings, Permissions; detail actions | A1 as data; P0/P3; flows have R |
| Announcements (Velocity, migrated) | `announcements_macros.vm` | List, Add, Reorder/Merge/Options, Permissions; return on flows | server menu; split is correct |
| Polls (Thymeleaf, migrated) | `fragments/common.html` | List, Add, Bulk, Permissions; return on flows | single A1 |
| Roster2, Feedback, Commons (JSP + JS) | empty `<ul id="…">` filled by JavaScript | generated at runtime | audit blind spot: the menu source is JS |
| Long tail (MS admin, Mailsender, Postem, Video training, Email templates, Delegated access, SCORM, LTI, Web, Search) | Thymeleaf `fragments/menus.html`, JSF/JSP menus, Velocity | mostly one home + create + options/permissions | same pattern; usually the easiest refactors |

## 3. Failure patterns

These are the recurring reasons the legacy row is hard to use. They are structural, not cosmetic.

| ID | Pattern | Evidence |
|---|---|---|
| F1 | **Flat soup.** Places, create actions, admin utilities and print/watch share one row and one visual weight. | Assignments, Wiki, Forums, Samigo |
| F2 | **The global menu is re-emitted on flow pages.** Actions that only make sense on the home view appear next to a form. | Samigo headings on every authoring page; Site Info `#toolbar($menu)` in confirm/import/edit templates |
| F3 | **The current item is a chip or a still-clickable “current” link.** It is not a selected destination with an honest state. | Gradebook `disableLink` adds `current` but keeps the link; Thymeleaf `current` spans |
| F4 | **No hierarchy between tool-level and object-level.** A selected assignment, assessment or wiki page exposes its tabs in the same row as the tool menu. | Assignments timesheet, Samigo item headings, Wiki Info/History |
| F5 | **Nested tools look like flat entries.** Question Pools, Manage Groups and Templates open a self-contained workspace with no return contract. | Samigo, Site Info → Site Group Manager |
| F6 | **Transient flows are peers.** Create, import, bulk edit and wizards sit next to destinations. | Signup Add, Syllabus Bulk Add, Site Group Create, Gradebook Quick Entry |
| F7 | **Search/filter/pager live inside navigation.** | Wiki `#searchBox()` inside `navIntraTool` |
| F8 | **Bulk/row actions move to the page header.** A select of actions applies to rows but reads as navigation. | Resources action select, Lessons toolbar |
| F9 | **The same idea has different labels.** Main / Home / List / Overview; Options / Settings / Template Settings; Participants / Student-Member. | All engines |
| F10 | **Two navigation rows with different meanings.** Top toolbar and bottom previous/next both use `navIntraTool`. | Lessons |
| F11 | **JavaScript-owned menus escape template audits.** | Roster2, Feedback, Commons |
| F12 | **Responsive behavior is all-or-nothing.** A server-side count hides every utility or shows every utility; two breakpoints decide the rest. | `#sakaiToolHeader` `utilityCount > 3`; tools that do not use the macro |
| F13 | **Title ownership is inconsistent.** Some pages repeat the tool name as an H1; some have no view H1 at all. | Site Info, Samigo, Lessons |
| F14 | **Permissions produce different states.** Some items are hidden, others disabled, with no explanation. | JSF `rendered` vs enabled flags |
| F15 | **Return is treated as an action.** New refactors add “Return to list” to the action cluster, competing with create/permissions and duplicating the breadcrumb or the form Cancel. | Announcements, Messages |
| F16 | **Every action is pushed into the header.** Object, flow and bulk actions are mixed with surface actions. | Gradebook, Messages, Polls flows |
| F17 | **A floating action is used to hide a crowded header.** The header stops being crowded, but a new overlay competes with content and portal chrome. | Risk in the next iteration, not a legacy pattern |

## 4. The model

### 4.1 Layers

| Layer | Owner | Meaning | Renderer |
|---|---|---|---|
| **L0 Portal** | Portal | Site → tool. The breadcrumb and sidebar already say where you are. | Portal chrome |
| **L1 Tool** | Tool | The tool's own peer destinations and its home. | `.sakai-tool-header` + `.sakai-tool-nav` |
| **L2 Object** | Tool | Views of the selected object (assignment, assessment, wiki page, folder, group). | Object header + `.sakai-segmented-control` / local breadcrumb |
| **L3 Flow** | Tool | Temporary task with a beginning and an end (create, edit, import, duplicate, reorder, wizard). | View H1 + form + `.sakai-actions` + one exit |
| **L4 Nested tool** | Tool | A self-contained workspace launched from a parent tool. It has its own L1. | Nested header + return to parent |

### 4.2 Roles

| Role | Meaning | Examples | Control and zone |
|---|---|---|---|
| **R** | Return/up navigation to the parent surface. Not an action. | Back to Assignments, Back to Site Info | Quiet back link / local breadcrumb, leading side of the page or object header. Never in the action cluster or `…`. |
| **A1** | Tool sections: peer destinations at L1. One is current. | List, By Student, Grade Report, Student View | `.sakai-tool-nav`, below the header. |
| **A2** | Object views: peer views of the selected object at L2. | Assignment / Time sheet, View / Info / History | `.sakai-segmented-control` or scoped object tabs. |
| **A3** | Nested tools at L4. | Question Pools, Manage Groups, Templates | Entry action in the parent + nested surface with its own header. |
| **P0-S** | Surface primary: create/do the main task of the current list/home. | Add assignment, Compose | Page header trailing; repeat in the empty state. |
| **P0-O** | Object primary: act on the selected object. | Edit, Reply | Object header, near the object title. |
| **P0-F** | Flow primary: commit the form. | Save, Submit, Generate | `.sakai-actions` at the end of the form. Never in the page header. |
| **P0-B** | Bulk primary: act on the current selection. | Publish selected, Delete selected | Selection bar / table footer. Never in the page header. |
| **P1** | Frequent secondary. Maximum one. | Preview, Duplicate | Header, visible from medium width. |
| **P2** | Occasional secondary. Maximum two. | Reorder, Merge, Bulk creation | Header, visible only at wide width; otherwise `…`. |
| **P3** | Utility. | Permissions, Options, Settings, Export, Print, Audit, Restore | Always `…`. |
| **P4** | Destructive. | Delete, Reset, Remove | `…`, separated, with confirmation. |
| **D** | Data controls. | Search, filter, sort, pager, select-all, bulk selection | `.sakai-table-toolbar` / table head / bulk bar. |
| **M** | Mode switch. | Preview as learner | Explicit switch + banner + exit; prefer portal “View Site As”. |

A tool does not need every role. It must not invent a role for an item that belongs to another.

### 4.3 Surfaces and zones

Every screen is one of five surfaces. Every control belongs to a zone. The surface decides which
zones exist; the zone decides what can appear there.

| Surface | H1 | Zones | Allowed | Exit |
|---|---|---|---|---|
| **Home / list** | The tool's home view name | Page header, list toolbar, table, empty state | R (if deep-linked), A1, P0-S, P1/P2/P3/P4, D, row actions | Portal |
| **Object detail** | The object name | Object header, content | R, A2, P0-O, P3/P4 object actions | R back to the parent |
| **Flow** | The task name (“Add assignment”, “Import”) | Page header (minimal), form, action footer | H1, optional quiet R, P0-F, P1/P2 alternatives, Cancel | Footer Cancel/Return; one exit |
| **Nested tool** | The nested surface name | Nested page header, nested list/detail | Its own R, A1, P0, P1–P4 | R to the parent surface |
| **Hub** (many peer settings) | The hub name | Page header, grouped navigation | Grouped A1, P3 | Portal |

| Zone | Owns | Must not contain |
|---|---|---|
| **Page header** | H1, R (leading), P0-S (trailing), P1/P2, P3/P4 overflow | Object actions, Save/Submit, bulk actions, search/filter |
| **Object header** | Object identity/meta, A2, P0-O, P3/P4 object utilities | Global Add, Permissions, list toolbar |
| **List toolbar** | Search, filter, scope, pager, select-all, bulk selection | Create actions, navigation, object actions |
| **Table / row** | Row data and row actions | Global actions |
| **Empty state** | The same P0-S, in context | A different primary action |
| **Action footer** | P0-F, Cancel/Return, bulk P0-B | Surface navigation, global utilities |
| **Nested page header** | Nested H1, R to parent, nested A1/P0 | Parent A1/P0 cluster |

**Coherence is not “everything in the same row”.** It is “the same kind of control always lives in
the same kind of zone”. That is what makes tools feel related without making every header identical.

### 4.4 Decision tree

Classify each item in this order. The first match wins.

1. Does it take the user **up to the parent surface**? → **R**.
2. Does it replace the whole tool content with a **peer destination**? → **A1**.
3. Does it switch the content **inside the currently selected object**? → **A2**.
4. Does it open a **self-contained workspace** with its own navigation? → **A3 / L4**.
5. Does it **commit a form**? → **P0-F**.
6. Does it act on **the selected object**? → **P0-O** (or P3/P4 for utilities/destructive).
7. Does it act on **the current selection**? → **P0-B**.
8. Is it **the main create/do action of the surface**? → **P0-S**.
9. Is it a **frequent secondary**? → **P1**.
10. Is it an **occasional secondary**? → **P2**.
11. Does it **configure, permission, export, print or maintain**? → **P3**.
12. Is it **destructive**? → **P4**.
13. Does it **filter, sort, page or select**? → **D**.
14. Does it **preview another role** without changing the task? → **M**.
15. None of the above? It is probably not navigation or an action. Find another place or remove it.

### 4.5 R — return is navigation

- R is a **quiet back link** or local breadcrumb, leading side of the page/object header. It is not
  a `sakai-btn-secondary` in the action cluster.
- The label names the **actual parent**: “Back to Assignments”, “Back to Site Info”, “Back to
  Announcements”. Do not use a generic “Return to list” when the parent is not a list.
- Preserve the origin when possible: the A1 view, filter, pager page or search that led to the
  detail/flow. A link to the list root is not a return.
- **Not every surface needs R.** The portal breadcrumb already owns site › tool. A flow with a
  footer Cancel has one clear exit; do not add a second competing Return in the header.
- **Flows:** the footer `Cancel`/`Return` is the exit. A header R is optional only for long flows
  and must read as navigation (link), not as a secondary action. Never have both a header “Return”
  button and a footer “Cancel” with the same effect.
- **Modals/offcanvas:** the close control is the exit; no page-level R inside the modal.
- **Nested tools:** R names the parent (“Back to Site Info”), not “Back”.
- **No dead ends:** every non-home surface has one obvious exit. R, the portal crumb or the footer
  Cancel can be that exit; exactly one should be visually primary.

### 4.6 P0 — primary by surface

- **P0-S** lives in the page header (trailing) and repeats in the empty state. One maximum.
- **P0-O** lives in the object header. It is not a global Add/Permissions.
- **P0-F** lives in the form footer. Save/Submit must not be in the page header.
- **P0-B** lives in the selection bar/footer. It must not appear until there is a selection.
- No surface has two P0s. If two actions compete, one is P1/P2.
- A detail or flow view may have **no** P0 in the page header; that is correct.

### 4.7 Responsive action tiers

The current implementation is a good base (container queries, flex wrap, shared overflow), but its
policy is not correct: a server-side `utilityCount > 3` makes the header all-or-nothing and
engine-specific. Replace it with **priority tiers + container tiers**.

| Tier | Container | Visible in the header | In `…` |
|---|---|---|---|
| **Compact** | `< 36rem` | R + P0 | P1, P2, P3, P4 |
| **Medium** | `36rem–47.999rem` | R + P0 + P1 | P2, P3, P4 |
| **Wide** | `>= 48rem` | R + P0 + P1 + P2 | P3, P4 |

Rules:

- **P1 max 1, P2 max 2.** Anything beyond those caps is P3 (utility) or is removed.
- **P3/P4 never appear inline.** They always live in `…`.
- The `…` is rendered only when it has something to show:
  - P3/P4 exist → visible at every width.
  - Only P1/P2 exist → visible below wide; hidden at wide.
  - No P1/P2/P3/P4 → no `…`.
- Do **not** use a server-side count to decide the layout. The server assigns priorities; CSS
  container queries decide visibility.
- The overflow panel must not duplicate actions already visible in the header. Use
  `data-priority` on the panel items and container rules to hide P1/P2 in the panel when they are
  visible in the header.
- Panel order: P2 (when hidden) → P3 → separator → P4.
- Do **not** hide every secondary action for the sake of uniformity. Uniformity is predictable zones
  and priority, not a permanently collapsed header. P1/P2 stay visible at their tier; P3/P4 live in
  `…`.
- Long labels and translations must be tested. If a P1 does not fit, it may wrap; it must not push
  the title off-screen or create horizontal scroll.
- One shared renderer per engine (Velocity, Thymeleaf, JSF, Wicket). If each tool reimplements the
  priority logic, the behavior diverges again.
- The current `.sakai-tool-header__actions--collapsed` / `utilityCount` approach is retired.

### 4.8 Floating actions and FABs

The portal FAB stack (`sakai-portal-fabs`: presence + jump-to-top) is **portal chrome**. Tools must
not inject actions into it.

- **No general FAB for P0.** A FAB is a mobile-first pattern for one dominant action in a
  content-light surface, not a universal replacement for the header.
- **Niche only:** narrow container, list surface, one dominant create action, content-light. Not on
  detail, flow, hub, nested tool, bulk selection, or destructive actions.
- **Prefer a sticky action bar inside `.sakai-tool-body`** over a viewport-fixed FAB. It respects
  ownership, iframes, print and content bounds.
- **No 2–3 second attention animation.** If a P0 needs an animation to be noticed, it is not a P0.
  Auto-playing attention seekers are distracting and fail `prefers-reduced-motion`.
- If a tool truly needs a floating action, it must: not duplicate the header P0; keep content
  clearance; hide on print and when a modal/offcanvas is open; use an icon + text pill with a
  contrast-checked primary token; and use the portal slot if the tool is in an iframe.
- **FABs are not a cleanup strategy.** If the header is crowded, move object/flow/bulk actions to
  their zones and reduce or merge utilities first.

### 4.9 Nested tool contract

A nested tool is a surface, not an item in the parent's A1 row.

```
Parent tool (L1)
  header: parent H1 + parent actions
  entry action: “Manage groups” (P2/P3, not A1)
    └─ Nested tool (L4)
         header: nested H1 + R “Back to Site Info”
         nav: nested A1 (Group List, Create group, …)
         actions: nested P0/P1/P2/P3/P4
```

Requirements:

* The nested surface has its own H1 and its own A1 navigation.
* The parent's A1/P0/P1–P4 cluster is hidden while the nested tool is open.
* R names the parent destination, not “Back”.
* The nested tool's current item follows the same `aria-current` rule.
* Step wizards inside the nested tool are L3 flows: show “Step 2 of 4”, not a peer tab.

### 4.10 Object navigation contract

Object views (A2) are not tool sections. They belong under the object heading, after the object's
identity is clear.

* Use `.sakai-segmented-control` when the switch is in-place (panels without a page reload).
* Use `.sakai-tool-nav` scoped to the object when each view has its own URL and can be bookmarked.
* Do not put the object name in every tab label; the object H1 already names it.
* Previous/next is object pagination, not navigation: place it at the bottom in an action row, not
  in the header.

## 5. Worked examples

### 5.1 Assignments (pilot)

```
Assignments
├─ A1 List (home)                    → P0-S Add, P2 Reorder, P3 Options, P3 Permissions
├─ A1 By Student
├─ A1 Grade Report
├─ A1 Student View
├─ A1 Removed Assignments (admin)
└─ L2 Assignment detail
   ├─ R ← Assignments (preserves the A1 view/filter)
   ├─ A2 Assignment / Time sheet
   ├─ P0-O Edit, P1 Preview
   └─ P3/P4 object utilities in …
```

A flow (edit/create) puts Save/Cancel in `.sakai-actions`; it does not repeat the global cluster and
does not add a “Return to list” button in the header.

### 5.2 Tests & Quizzes (Samigo)

```
Tests & Quizzes
├─ A1 Assessments (home)             → P0-S Add, P3 Permissions
├─ A3 Question Pools                 → nested tool with its own A1
├─ A3 Templates                      → nested tool with its own A1
├─ P3 Event Log, P3 Section Activity, P3 Restore (admin)
└─ L2 Assessment editor
   ├─ R ← Assessments / Questions (local breadcrumb)
   ├─ P0-F Save in the form footer
   └─ P3/P4 object utilities
```

The global menu must be emitted once, not by every `*Headings.jsp`. Question Pools and Templates
are surfaces, not flat entries. The assessment breadcrumb is L2, not the portal breadcrumb.

### 5.3 Site Info

```
Site Info (hub)
├─ Group “Site”        → Site Information, Edit Site Information, Manage Overview
├─ Group “Tools”       → Manage Tools, Tool Order, External Tools
├─ Group “People”      → Manage Participants, Add Participants, Edit Class Rosters, Manage Groups
└─ Group “Access/data” → Manage Access, Link to Parent, Duplicate, Import, Import Archive, Audit
```

15 peers cannot be a tab row. Manage Groups opens Site Group Manager, an L4 tool with its own A1.
The grouping is a proposal, not a mandate; validate it before implementation.

### 5.4 Gradebook

```
Gradebook
├─ A1 Gradebook (home)     → no P0-S, P3 Settings, P3 Permissions
├─ L3 Quick Entry          → flow with one return when done
├─ L3 Import / Export      → flow with steps, one return
└─ L2 Gradebook inner tabs → A2 views of the gradebook
```

Quick Entry and Import/Export are workflows, not peers. Settings is P3. The current item must not be
a clickable “current” link.

### 5.5 Wiki

```
Wiki
├─ A1 Home
└─ L2 Page
   ├─ R ← Wiki
   ├─ A2 View, Info, History
   ├─ P0-O Edit
   ├─ P3 Watch, Print
   └─ D search
```

Edit is an object action, not a view. Info/History are object views. Search is D.

### 5.6 Lessons

```
Lessons
├─ portal sidebar: page tree (L1/L2 hybrid)
├─ page header: P0-S Add content, P3 More tools (overflow), P3 Print
└─ page bottom: previous/next (object pagination)
```

The portal already owns the page tree. Do not duplicate it in a tool nav. A modal is a valid
overflow for secondary tools when the set is large, but it must not become the home of primary
actions.

### 5.7 Statistics (retrofit)

The current migration renders the other A1 views as secondary buttons in the action cluster. That
blurs places and actions. When Statistics is next touched:

* Move Overview / Reports / User Activity / Preferences to `.sakai-tool-nav`.
* Keep Add and exports in the action cluster (Add is P0-S, exports are P3).
* Keep Server-wide report types as a second-level `.sakai-tool-nav` (they are A2, not A1).
* Replace “Return to reports” buttons with R where they are navigation; keep form Cancel in the
  footer.

### 5.8 Current reference implementations: verdict

| Tool | Navigation split | Surface consistency | What remains |
|---|---|---|---|
| Polls | Good: one A1, P0-S (also in the empty state), P3 permissions in a persistent `…`, header R on every non-list view (unified return) | Partial: no list toolbar/pager; flows also keep a footer Cancel/Back (accepted exception); option rows keep inline actions by design | Parity pass: decide whether the list needs a toolbar/pager; decide whether R or the footer action should be the single flow exit |
| Announcements | Good: server menu → P0/P3, flows return | Partial: two toolbar markup variants; “Return to List” as secondary action | Parity pass: one toolbar markup; R as back link; align labels |
| Messages | Good: folders as data, Compose P0-S, P3 utilities in a persistent `…` on list/search, R as a back link (All folders in the list/search R slot), detail P0-O with P3/P4 in `…`, empty states and a bottom message pager | Partial: the recipient picker is still the Select2 `h:selectManyListbox`; flow views keep a footer Cancel next to R | Parity pass: replace the recipient picker when a shared control exists; decide whether the footer Cancel should stay |
| Statistics | Partial: A1 as secondary buttons | Low: places mixed with actions | Move A1 to `.sakai-tool-nav`; R for report flows |

**They are valid splits of `navIntraTool`, not yet instances of one surface pattern.** Use them as
drafts; do not declare the pattern finished until the parity pass.

## 6. Consequences for the design system

| Area | Current state | Needed |
|---|---|---|
| `#sakaiToolHeader` | Takes a title, a CHEF menu, one primary action and one back action. Every non-primary entry becomes a utility. | A **R** slot (leading back link), a **P0-S** slot, and typed **P1/P2/P3/P4** entries. A1 stays outside the header. |
| CHEF `MenuEntry` | Has title, action, url, form, enabled, current. No kind or priority. | `kind` (R/A1/A2/A3/P0/P1/P2/P3/P4/D/M) or separate lists. Do not infer from `doX` names. |
| JSF headings | Each page includes a full `*Headings.jsp`. | One shared heading fragment driven by the surface and its zones. |
| Wicket `BasePage` | Flat `ul` with `disableLink`. | A1 nav component + typed page links; current uses `aria-current`. |
| Thymeleaf menus | `fragments/menus.html` with `current` string. | Same priority model; group >5 peers. |
| `.sakai-tool-nav` | Exists; styles anchors and `aria-selected`/`.active`. | Navigation semantics: current item with `aria-current="page"`, grouped variant, narrow-width behavior. |
| `.sakai-tool-header` | Handles title + actions + overflow + R slot. | No `--collapsed`/`utilityCount`; R uses `.sakai-back-link`. |
| `.sakai-actions` | Action row for form footers and inline actions. | Keep for **P0-F/P0-B**, not as the universal replacement for `navIntraTool`. |
| Return primitive | Shared `.sakai-back-link` with `si si-arrow-left` and a specific parent label. | Implemented; do not render R as a secondary button. |
| Object breadcrumb | Tools invent local breadcrumbs (Samigo). | A compact object trail under the tool header, distinct from the portal breadcrumb. |
| Responsive overflow | Binary, count-based, engine-specific. | Priority tiers + container tiers; one shared renderer per engine. Thymeleaf/Sakai CSS: `.sakai-tool-header__more--persistent` plus `data-priority="1\|2"` panel items. |
| Floating actions | Portal FAB stack for presence + jump. | Tools do not inject into it; use a sticky action bar inside the tool body for the narrow niche. |
| JS-generated menus | Roster2, Feedback, Commons. | Audit the JS source and render `sakai-*` markup; do not leave an empty `navIntraTool`. |

## 7. Hypotheses to validate

| ID | Hypothesis | How to validate |
|---|---|---|
| H1 | Most tools fit in ≤5 A1 views; Site Info and Samigo are the exceptions that need a hub/nested tool. | Count A1 per tool during the per-tool audit. |
| H2 | Assignments is the best full-refactor pilot because it covers A1/A2/R/P0-O/P0-F/P0-B/P3. | Run the prompt on Assignments first; record surprises. |
| H3 | Users read tabs as places and buttons as actions; mixed chip rows cause misclicks. | Task-based Playwright walkthrough + short usability check with 3–5 users. |
| H4 | The portal sidebar is the right home for the Lessons page tree; duplicating it is noise. | Compare current Lessons navigation with the sidebar tree. |
| H5 | One typed shared header removes most duplication in Samigo and Site Info. | Prototype the fragment on one Samigo page; count removed includes. |
| H6 | Overflow above three utilities is sufficient; no tool needs a custom utility grouping. | Audit the tools with >3 P3 entries. |
| H7 | Nested tools need a return contract more than a visual restyle. | Test Question Pools and Manage Groups with a first-time user. |
| H8 | JS-generated menus are the highest-risk blind spot. | Audit Roster2, Feedback and Commons source; add a runtime check. |
| H9 | R as navigation reduces header noise and dead ends compared with a “Return to list” button. | A/B a flow with R vs header button; measure task success and clicks. |
| H10 | Distributing actions by zone improves perceived consistency more than one action row. | Compare the four references after the parity pass with a task-based test. |
| H11 | Priority tiers + container tiers beat count-based collapse at 360/504/672/1200 widths. | Visual regression + click-path test at those widths with 1/3/6 utilities. |
| H12 | FABs do not generalize in data-heavy LMS pages. | Prototype on one narrow list; check overlap, keyboard order and task success. |

## 8. Migration sequence

1. **Update the contract** (this model + chrome + prompt).
2. **Parity pass on the four references** (Polls, Announcements, Messages, Statistics) so they
   follow the same R/P0/zone/overflow rules. This is the missing step that explains why they still
   feel different.
3. **Assignments full refactor** as the pilot: navigation, tables, forms, rest, docs.
4. **Gradebook / Attendance** (Wicket): typed page links and workflows.
5. **Samigo** (JSF): nested tools, repeated headings and object breadcrumbs.
6. **Site Info / Site Group Manager** (hub + nested tool + Thymeleaf).
7. **Wiki / Resources**: object views and D search/bulk.
8. **Lessons**: portal sidebar + page toolbar; avoid duplication.
9. **Long tail** when a tool is touched for other work.

Do not start a refactor without the current tree, the target design, the phase plan and the doc.

## 9. Open decisions

1. **R ownership:** tool-owned back link vs portal breadcrumb extension. Recommendation: tool-owned
   quiet back link, because the portal breadcrumb stays site › tool.
2. **R label:** specific parent name vs generic “Back”. Recommendation: specific name; preserve
   origin state where possible.
3. **P1/P2 caps:** 1 and 2. Recommendation: keep those caps; move anything beyond to P3 or remove it.
4. **More than five A1:** grouped tab row vs a landing hub. Recommendation: hub for settings-heavy
   tools (Site Info), grouped nav for data-heavy tools.
5. **Floating actions:** sticky tool-level action bar vs portal FAB slot. Recommendation: sticky
   bar in the tool body; portal slot only for a future iframe-safe API.
6. **Back-link primitive:** new `.sakai-back-link` vs object breadcrumb. Recommendation: one shared
   quiet link with `si si-arrow-left`, used in page and object headers.

## 10. Evidence index

* `assignment/tool/src/webapp/vm/assignment/assignment_macros.vm`
* `gradebookng/tool/src/java/org/sakaiproject/gradebookng/tool/pages/BasePage.html`
* `gradebookng/tool/src/java/org/sakaiproject/gradebookng/tool/pages/BasePage.java`
* `samigo/samigo-app/src/webapp/jsf/author/allHeadings.jsp`
* `samigo/samigo-app/src/webapp/jsf/author/item/itemHeadings.jsp`
* `samigo/samigo-app/src/webapp/jsf/questionpool/poolList.jsp`
* `site-manage/site-manage-tool/tool/src/java/org/sakaiproject/site/tool/MenuBuilder.java`
* `site-manage/site-group-manager/src/main/webapp/WEB-INF/templates/fragments/menus.html`
* `rwiki/rwiki-tool/tool/src/webapp/WEB-INF/vm/macros.vm`
* `lessonbuilder/tool/src/webapp/templates/ShowPage.html`
* `content/content-tool/tool/src/webapp/vm/content/sakai_resources_columns.vm`
* `sections/sections-app/src/webapp/inc/navMenu.jspf`
* `signup/tool/src/main/webapp/signup/menu/signupMenu.jsp`
* `syllabus/syllabus-app/src/webapp/syllabus/mainMenu.jsp`
* `msgcntr/messageforums-app/src/webapp/jsp/discussionForum/menu/forumsMenu.jsp`
* `msgcntr/messageforums-app/src/webapp/jsp/privateMsg/pvtToolHeader.jsp`
* `podcasts/podcasts-app/src/webapp/podcasts/podcastMenu.jsp`
* `attendance/tool/src/java/org/sakaiproject/attendance/tool/pages/BasePage.html`
* `chat/chat-tool/tool/src/webapp/jsp/chatMenu.jsp`
* `polls/tool/src/main/webapp/WEB-INF/templates/fragments/common.html`
* `announcement/announcement-tool/tool/src/webapp/vm/announcement/chef_announcements.vm`
* `announcement/announcement-tool/tool/src/webapp/vm/announcement/announcements_macros.vm`
* `sitestats/sitestats-tool/src/webapp/WEB-INF/templates/fragments/common.html`
* `velocity/tool/src/templates/VM_chef_library.vm` (`#sakaiToolHeader`)
* `library/src/skins/default/src/sass/components/_sakai-tool-header.scss`
* `library/src/skins/default/src/sass/modules/tool/_menu.scss`
