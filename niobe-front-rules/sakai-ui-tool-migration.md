# Future roadmap: tool-by-tool UI migration

**Status:** In progress — **Polls** is the first reference tool (Thymeleaf). Portal foundations (tokens, `sakai-*` primitives, chrome) are in place. The four reference refactors (Polls, Announcements, Messages, Statistics) are navigation-good but **surface-inconsistent**; a parity pass is required before treating them as the final pattern.

Portal chrome contract (slots, title ownership): [`library/docs/sakai-ui-chrome.md`](../library/docs/sakai-ui-chrome.md).
Navigation model (layers, roles, zones, decision tree, responsive tiers, evidence): [`navigation-model.md`](navigation-model.md).
Per-tool prompt: [`tool-navigation-refactor-prompt.md`](tool-navigation-refactor-prompt.md).

**Reference implementations:** [`polls-reference.md`](polls-reference.md) (Thymeleaf, single A1), [`announcements-reference.md`](announcements-reference.md) (Velocity, server menu → actions), [`messages-reference.md`](messages-reference.md) (JSF private messages) and [`sitestats-reference.md`](sitestats-reference.md) (Thymeleaf with several A1 views).

## Principle

Each tool adopts:

1. Tokens **L1/L2** (no new hex; no new tool-only color systems)
2. Chrome contract from [`library/docs/sakai-ui-chrome.md`](../library/docs/sakai-ui-chrome.md)
3. `sakai-*` primitives where UI is edited
4. **Sakai icon map** only (`si si-*`; `bi-*` lives only in `base/_icons.scss`)
5. **Intra-tool IA** from the section below (do not keep a flat `navIntraTool` grab-bag when the tool is touched)

## Tentative order

Revalidate after portal feedback. **Parity pass first:** the four references share the same
navigation split but not the same surface composition; align them with
[`navigation-model.md`](navigation-model.md) §5.8 before declaring the pattern done. **Full-refactor
pilot:** Assignments is the first tool that applies the whole tree and phase plan.

1. ~~**Polls**~~ — navigation split done; parity pass pending (Thymeleaf reference; see [`polls-reference.md`](polls-reference.md))
2. ~~**Announcements**~~ — navigation split done; parity pass pending (Velocity reference; see [`announcements-reference.md`](announcements-reference.md))
3. ~~**Statistics**~~ — navigation split done; A1 views still rendered as buttons; parity pass pending (see [`sitestats-reference.md`](sitestats-reference.md))
4. ~~**Messages**~~ — navigation split done; R/A1/back semantics and toolbar parity pending (JSF private messages; see [`messages-reference.md`](messages-reference.md)). The Discussions/forums side is still on `navIntraTool`.
5. Dashboard / Home (already Lit)
6. Conversations
7. **Assignments** — full-refactor pilot (navigation, tables, forms, rest; student-facing impact)
8. Gradebook, Resources, Lessons
9. Remaining tools (JSF / Wicket / Velocity) when touched for other work

## Title and page chrome (per tool)

Portal already owns:

| Layer | Owner | Tool must not… |
|-------|--------|----------------|
| Breadcrumb site › tool (+ reset on tool crumb) | Portal | Duplicate the tool name as a second “title” link |
| Role / View Site As | Portal | Re-implement role swap in the tool header |
| Portlet title on home / multi-tool | Portal | Rely on a portal H2 on single-tool pages |

Tool owns:

| Layer | Owner | Expectation |
|-------|--------|-------------|
| View-level heading (H1/H2) | Tool | Name the **current view** (“Assignments”, “Add assignment”, “Grade report”), not the tool again when the breadcrumb already says it |
| Intra-tool navigation / actions | Tool | Follow the roles and zones below; migrate off flat `navIntraTool` when editing that markup |

Legacy `.navIntraTool` stays as tools emit it today. Do **not** restyle it from the portal skin as a permanent design — migrate markup tool-by-tool using the model below.

## Intra-tool navigation — target model

Legacy `.navIntraTool` / `.actionToolBar` / `.actionToolbar` is one CSS class used for at least four
jobs: tool sections, object views, actions and data controls. Tool refactors must **split by layer,
role and zone**, not restyle the flat list forever.

Full evidence, zones, decision tree, responsive tiers and worked examples:
[`navigation-model.md`](navigation-model.md). Per-tool prompt:
[`tool-navigation-refactor-prompt.md`](tool-navigation-refactor-prompt.md).

### Roles

| Role | Meaning | Target UI / zone |
|------|---------|------------------|
| **R** | Return/up to the parent surface. Navigation, not an action. | Quiet back link / local breadcrumb, leading side of the header. Never in the action cluster or `…`. |
| **A1** | Tool sections: peer destinations at L1; one is current | `.sakai-tool-nav` below the header; current `aria-current="page"`. |
| **A2** | Object views: peer views of the selected object | `.sakai-segmented-control` or scoped object tabs. |
| **A3** | Nested tool: self-contained workspace | Entry action in the parent + nested header + own A1 + R. |
| **P0-S** | Surface primary: create/do the main task of the list/home | Page header trailing; repeat in the empty state. |
| **P0-O** | Object primary: act on the selected object | Object header, near the object title. |
| **P0-F** | Flow primary: commit the form | `.sakai-actions` at the end of the form. Never in the page header. |
| **P0-B** | Bulk primary: act on the current selection | Selection bar / table footer. Never in the page header. |
| **P1** | Frequent secondary (max 1) | Header, visible from medium width. |
| **P2** | Occasional secondary (max 2) | Header at wide width; otherwise `…`. |
| **P3** | Utility: options, permissions, export, print, audit, restore | Always `…`. |
| **P4** | Destructive: delete, reset, remove | `…`, separated, with confirmation. |
| **D** | Data controls: search, filter, sort, pager, select-all, bulk | `.sakai-table-toolbar` / table head / bulk bar. |
| **M** | Mode: preview another role or change the audience | Explicit switch + banner + exit; portal “View Site As” first. |

### Zones

| Zone | Owns | Must not contain |
|---|---|---|
| **Page header** | H1, R, P0-S, P1/P2, P3/P4 overflow | Object actions, Save/Submit, bulk actions, search/filter |
| **Object header** | Object identity, A2, P0-O, object P3/P4 | Global Add, Permissions, list toolbar |
| **List toolbar** | D: search, filter, scope, pager, select-all, bulk | Create actions, navigation, object actions |
| **Table / row** | Row data and row actions | Global actions |
| **Empty state** | The same P0-S, in context | A different primary action |
| **Action footer** | P0-F, Cancel/Return, bulk P0-B | Surface navigation, global utilities |
| **Nested page header** | Nested H1, R to parent, nested A1/P0 | Parent A1/P0 cluster |

### Rules

- **Places and actions never share a group.** A1 is navigation; P0/P1/P2/P3/P4 are actions.
- **R is navigation.** A “Return to list” button in the action cluster is not the model. Use a
  specific back link (“Back to Assignments”), preserve the origin, and do not duplicate the footer
  Cancel on flows. Do not add R everywhere: if the portal crumb or the footer Cancel already gives
  one clear exit, do not add another.
- **P0 is not one role.** P0-S, P0-O, P0-F and P0-B live in different zones. Save/Submit never goes
  in the page header; bulk actions never appear before a selection exists.
- **No new `.navIntraTool`.** New or touched markup uses `sakai-*`; the legacy class only remains
  until that tool is migrated.
- **No count-based collapse.** P1 max 1, P2 max 2; P3/P4 always in `…`. The server assigns
  priorities; CSS container queries decide visibility. Do not hide every secondary action for
  uniformity: P1/P2 stay visible at their tier.
- **No empty `…`.** Render it only when there is something to hide. A single P3 may stay in `…`
  because it is an admin utility; a single P1 must be visible or reclassified.
- **No dead ends.** Every non-home surface has one obvious exit: R, the portal tool crumb or the
  footer Cancel.
- **No duplicate titles.** The portal breadcrumb owns site › tool; the tool H1 names the view.
- **No general FAB.** The portal FAB stack is portal chrome. A sticky action bar inside the tool
  body is preferred for the narrow, content-light niche; no 2–3 s attention animation.
- **Labels:** verbs for actions, nouns for places. Do not rename one tool's concept in isolation.

### Responsive tiers

| Tier | Container | Visible in the header | In `…` |
|---|---|---|---|
| **Compact** | `< 36rem` | R + P0 | P1, P2, P3, P4 |
| **Medium** | `36rem–47.999rem` | R + P0 + P1 | P2, P3, P4 |
| **Wide** | `>= 48rem` | R + P0 + P1 + P2 | P3, P4 |

The overflow panel must not repeat actions already visible at that width. Use `data-priority` on
panel items and container rules, or an equivalent shared renderer. One renderer per engine.

### Layout (single-tool page)

```
┌─ .sakai-page-content ─────────────────────────────────────┐
│  [portal: role + View Site As]                            │  ← .sakai-page-chrome
│                                                           │
│  [← R] [view heading — tool]        [P0-S] [P1/P2] [ … ]  │  ← .sakai-tool-header
│  [sakai-tool-nav — A1 peers, 2–5 only]                    │
│  [object header + segmented — A2, detail only]            │
│  [sakai-table-toolbar — D, list only]                     │
│  … tool body …                                            │
│  [sakai-actions — P0-F / bulk P0-B]                       │
└───────────────────────────────────────────────────────────┘
```

### Mapping from common legacy patterns

| Legacy pattern | Typical tools | Migration |
|----------------|---------------|-----------|
| Flat `navIntraTool` mixing list + Add + Options + Permissions | Assignments, many Velocity tools | Split R/A1/P0/P1–P4/D; Polls and Announcements are drafts, not final references |
| `navIntraTool` as page tabs only | Gradebook (`BasePage`), some Samigo headings | Replace with `.sakai-tool-nav`; little or no actions in that row |
| Global menu repeated on every page | Samigo headings, Site Info `#toolbar($menu)` | Emit the surface cluster once; flow/detail pages get R and their own P0 |
| Nested tool as a flat entry | Question Pools, Templates, Manage Groups | Treat as L4: nested H1 + own A1 + R to parent |
| “Return to list” as a secondary button | Fixed in Polls, Announcements, Messages | R is `.sakai-back-link`: quiet back link, specific parent, preserve origin |
| Two navigation rows (top and bottom) | Lessons | Keep one header nav; previous/next is object pagination in an action row |
| Search / filter inside nav | Wiki | Move to `.sakai-table-toolbar` (D) |
| Icon / button toolbar in `navIntraTool` | Lessons | Explicit toolbar of `.sakai-btn` / `.sakai-btn-icon`; drop `navIntraTool` |
| More than five peers | Site Info (15) | Grouped hub/nav; do not render a 15-item row |
| Count-based `>3` collapse | Retired | `#sakaiToolHeader` uses P1/P2/P3/P4 + container tiers only |
| JSF `ToolBarRenderer` → `<ul class="navIntraTool actionToolbar">` | JSF tools | Same model; one shared heading fragment when several JSF tools migrate together |

### What a tool PR must deliver

A full refactor is not only navigation. Each tool must deliver, in the approved phase order:

1. **Current tree and inventory:** every navigation item, action, table, form and state, with its
   source and role.
2. **Target design:** R/A1/A2/A3/P0/P1–P4/D/M, zones, surfaces, responsive tiers, and a phase plan.
   Get it approved **before** editing product code; record it in
   `niobe-front-rules/<tool>-reference.md`.
3. **Navigation phase:** header, R, A1/A2, P0-S/P0-O, breadcrumbs, nested tool returns, no
   `navIntraTool`.
4. **Tables phase:** list toolbar (D), columns, `__primary`, row actions, stacked behavior, empty
   state, pagination, bulk actions.
5. **Forms phase:** `.sakai-form-section` / `.sakai-form-field`, choices, required/errors, `.sakai-actions`
   with P0-F and Cancel.
6. **Rest phase:** detail views, banners, loading/error/empty states, icons, tokens, print,
   responsive polish.
7. **Playwright:** at least one flow per changed surface, permissions by role, narrow/medium/wide
   containers, keyboard/axe, and a regression pass for preserved URLs.
8. **Documentation:** complete the tool reference, update this roadmap, and add a model exception
   only if the tool genuinely needs one.

### Reference parity pass

The four references are navigation-good drafts. Before they are treated as the final pattern:

- **All four:** R is a `.sakai-back-link`; keep one exit per flow; align empty states, toolbar and
  action labels.
- **Polls:** decide whether the list needs a toolbar/empty state.
- **Announcements:** the My Workspace toolbar uses the canonical
  `sakai-table-toolbar` / `__filters` markup; R is done.
- **Messages:** define “All folders” as A1/R, not a generic utility; align the list toolbar and
  empty state.
- **Statistics:** move A1 views to `.sakai-tool-nav`; R and back links are done; keep Add/exports
  in the action cluster.

Do not add a new pattern in one tool and call it the reference without updating this list.

### Out of scope for portal-only PRs

- Rewriting every tool’s `navIntraTool` in one change
- Changing tool URLs / modes / permission gates while “just” restyling
- Treating chip CSS on `.navIntraTool` as the migrated design

## Checklist per tool PR

1. Replace ad-hoc Bootstrap utilities with `sakai-*` where markup is edited
2. Colors → only L1/L2 (or L3 under `tokens/tools/` if truly tool-specific)
3. Font Awesome/direct BI → `si si-*` via the central map
4. Remove `Mrphs-*` in files you touch (keep aliases at the skin layer until gone)
5. Respect [title ownership](../library/docs/sakai-ui-chrome.md#title-ownership): no duplicate tool title; view heading owned by the tool
6. **Current tree:** record every navigation item, action, table, form and state; classify
   R/A1/A2/A3/P0-S/P0-O/P0-F/P0-B/P1/P2/P3/P4/D/M (see above)
7. **Target design + phase plan:** get the tree, zones, surface composition and phase order approved
   before editing product code
8. **Navigation:** R as a back link (not an action); A1/A2 in the right nav; P0-S/P0-O in their
   zones; no Save/Submit or bulk actions in the header; no new `navIntraTool`
9. **Tables:** D in `.sakai-table-toolbar`; `__primary`, row actions, stacked behavior, empty state
   and pagination aligned with the reference pattern
10. **Forms:** `.sakai-form-section` / `.sakai-form-field`, choices, required/errors, `.sakai-actions`
    with P0-F and Cancel
11. **Responsive:** priority tiers + container queries; no count-based collapse; no empty `…`;
    no general FAB; test compact/medium/wide
12. **Accessibility:** keyboard, focus, `aria-current`, accessible names, no fake menu without a
    keyboard model
13. **Tests:** Playwright for each changed surface, permissions by role, and preserved URLs
14. **Verify** light + dark + L0 brand customization + print
15. **Document:** complete `niobe-front-rules/<tool>-reference.md`, update this roadmap, and add a
    model exception only if the tool genuinely needs one

## Forms checklist

1. `.sakai-form-section` + `__title` names a section; `.sakai-form-label` names a field or choice
   group. Group legends use `.sakai-form-label`, not a section title.
2. One `.sakai-form-field` per field (`.sakai-form-group` is retired). Checkboxes and radios use
   `.sakai-form-choice-group` with `.sakai-form-choice` rows; `--scroll` for long lists. Replace
   native `<select multiple>` with a choice group.
3. Required labels carry `.sakai-form-label.required`; field errors use `.sakai-form-error`. Do not
   reintroduce `instruction` / `reqStarInline`.
4. Close every form with `.sakai-actions`: primary save/confirm, secondary alternatives, ghost
   cancel/back/return, overflow (`…`) last. The current view is never an action.
5. No per-form `max-width` or dividers. Consecutive grids separate through
   `.sakai-form-grid + .sakai-form-grid`; a section after a grid/field through
   `.sakai-form-grid + .sakai-form-section` / `.sakai-form-field + .sakai-form-section`.
6. Check the legacy `legend` reset: a `<legend class="sakai-form-label">` must render like a
   `<label>`, and a section title must not inherit `inline-block`/padding.

## Tables and overflow checklist

1. Data tables use `.sakai-table--stack` and `data-label`; the primary cell carries
   `.sakai-table__primary` and renders as the row title without a label.
2. Server-rendered/JSF tables only need `--stack`: the shared body script copies the visible
   `thead` text into `data-label` and hides empty status cells.
3. Header and row `…` menus use the shared overflow script; it clamps them inside the viewport.
   Do not position them manually or duplicate the logic per tool.

## After portal (also future)

- Repo-wide Font Awesome webfont / Lit FA purge
- Remaining `Mrphs-*` purge
- Per-tool L3 token files under `sass/tokens/tools/`
- Broader Lit adoption of a curated `sakai-tokens.css` instead of copying all document stylesheets
- Optional shared JSF/Wicket fragment for “tool header = R + views + P0/P1–P4”; Velocity already has
  `#sakaiToolHeader()` in `VM_chef_library.vm` but it only renders a heading and menu actions today
- Modernise presence list fragment HTML (still AJAX-loaded) when that endpoint is next touched
