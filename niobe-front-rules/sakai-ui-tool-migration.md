# Future roadmap: tool-by-tool UI migration

**Status:** In progress — **Polls** is the first reference tool (Thymeleaf). Portal foundations (tokens, `sakai-*` primitives, chrome) are in place; migrate remaining tools when touched.

Portal chrome contract (slots, title ownership): [`library/docs/sakai-ui-chrome.md`](../library/docs/sakai-ui-chrome.md).

**Reference implementation:** [`polls-reference.md`](polls-reference.md) (A/B/C + primitives checklist).

## Principle

Each tool adopts:

1. Tokens **L1/L2** (no new hex; no new tool-only color systems)
2. Chrome contract from [`library/docs/sakai-ui-chrome.md`](../library/docs/sakai-ui-chrome.md)
3. `sakai-*` primitives where UI is edited
4. **Bootstrap Icons** only (`bi` / `si`)
5. **Intra-tool IA** from the section below (do not keep a flat `navIntraTool` grab-bag when the tool is touched)

## Tentative order

Revalidate after portal feedback:

1. ~~**Polls**~~ — **done** (Thymeleaf reference; see [`polls-reference.md`](polls-reference.md))
2. Dashboard / Home (already Lit)
3. Conversations
4. **Assignments** (high student-facing impact; worst `navIntraTool` mix — next Velocity reference)
5. Gradebook, Resources, Lessons
6. Remaining tools (JSF / Wicket / Velocity) when touched for other work

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
| Intra-tool navigation / actions | Tool | Follow taxonomy below; migrate off flat `navIntraTool` when editing that markup |

Legacy `.navIntraTool` stays as tools emit it today. Do **not** restyle it from the portal skin as a permanent design — migrate markup tool-by-tool using the taxonomy below.

## Intra-tool navigation — target model

Legacy `.navIntraTool` / `.actionToolBar` / `.actionToolbar` is one CSS class used for at least three jobs. Tool-by-tool migration must **split by semantics**, not restyle the flat list forever.

### Taxonomy (classify every item before markup)

| Kind | Meaning | Examples (Assignments) | Target UI |
|------|---------|------------------------|-----------|
| **A. Exclusive views** | Mutually exclusive places inside the tool; one is “current” | List, Assignments by Student, Grade Report, Student View | `.sakai-tool-nav` or `.sakai-segmented-control` (underline / segmented tabs). Current item is not a link styled as a chip — it is the selected segment. |
| **B. Primary actions** | Create / do the main task | Add | `.sakai-btn-primary` (or secondary) in an **actions** cluster, typically trailing (end of the tool header row). Not in the same control group as views. |
| **C. Secondary / admin utilities** | Configure, maintain, destroy, permissions | Options, Permissions, Reorder, Trash | Overflow menu (“…”) or a quiet secondary group; never equal visual weight to (A) or (B). |

If a tool only has (A), a single segmented control is enough. If it only has one (A) home view (Polls), the view H1 is enough — no segmented control required. If it only has icon actions (Lessons-style toolbar), use icon buttons / `.sakai-btn-icon` — do not force segmented tabs.

### Layout (single-tool page)

```
┌─ .sakai-page-content ─────────────────────────────────────┐
│  [portal: role + View Site As]                            │  ← .sakai-page-chrome
│                                                           │
│  [view heading — tool]              [primary actions]     │  ← .sakai-tool-header
│  [sakai-tool-nav / segmented — views only]                │
│  … tool body …                                            │
│  (utilities in … menu or foot of header, not mixed in A)  │
└───────────────────────────────────────────────────────────┘
```

- **Position:** still at the top of the tool body (correct). Do not move intra-tool nav into the portal toolbar or breadcrumb.
- **Portal:** must not invent a second global chrome that “owns” `navIntraTool`. Tools emit the markup; portal only provides primitives (`sakai-tool-header`, `sakai-tool-nav` / segmented / buttons) for tools that migrate.

### Mapping from common legacy patterns

| Legacy pattern | Typical tools | Migration |
|----------------|---------------|-----------|
| Flat `navIntraTool` mixing list + Add + Options + Permissions | Assignments, Announcements, many Velocity tools | Split A / B / C as above; Polls is the Thymeleaf reference; Assignments is the next Velocity reference |
| `navIntraTool` as page tabs only | Gradebook (`BasePage`), some Samigo headings | Replace with `.sakai-tool-nav` / segmented; little or no (B)/(C) in that row |
| Icon / button toolbar in `navIntraTool` | Lessons | Prefer explicit toolbar of `.sakai-btn` / `.sakai-btn-icon`; drop `navIntraTool` class when markup is rewritten |
| JSF `ToolBarRenderer` → `<ul class="navIntraTool actionToolbar">` | JSF tools | Same taxonomy when the renderer or the page is next touched; prefer shared fragment later if several JSF tools migrate together |

### What a tool PR must deliver for nav

When a PR edits a tool’s top nav (or checklist item 7 below):

1. List every current `navIntraTool` entry and tag it A, B, or C.
2. Markup: (A) → `sakai-tool-nav` / `sakai-segmented-control` (omit if only one home view); (B)/(C) → `.sakai-tool-header__actions` buttons.
3. View heading reflects the active (A) view (or the (B) flow, e.g. “Add assignment”).
4. Do not keep a parallel portal tool title on single-tool pages.
5. Playwright: cover switching at least one (A) view and one (B) action if both exist.

### Out of scope for portal-only PRs

- Rewriting every tool’s `navIntraTool` in one change
- Changing tool URLs / modes / permission gates while “just” restyling
- Treating chip CSS on `.navIntraTool` as the migrated design

## Checklist per tool PR

1. Replace ad-hoc Bootstrap utilities with `sakai-*` where markup is edited
2. Colors → only L1/L2 (or L3 under `tokens/tools/` if truly tool-specific)
3. Font Awesome → `bi` / `si`
4. Remove `Mrphs-*` in files you touch (keep aliases at the skin layer until gone)
5. Respect [title ownership](../library/docs/sakai-ui-chrome.md#title-ownership): no duplicate tool title; view heading owned by the tool
6. **Intra-tool nav:** classify A/B/C and migrate off flat `navIntraTool` when that markup is in scope (see above)
7. Container queries for responsive tool layouts (`@container sakai-tool`), not viewport-only
8. Add/update Playwright coverage for changed flows
9. Verify light + dark + L0 brand customization

## After portal (also future)

- Repo-wide Font Awesome webfont / Lit FA purge
- Remaining `Mrphs-*` purge
- Per-tool L3 token files under `sass/tokens/tools/`
- Broader Lit adoption of a curated `sakai-tokens.css` instead of copying all document stylesheets
- Optional shared Velocity/JSF/Wicket fragment for “tool header = views + actions” once two or three tools share the same A/B/C layout
- Modernise presence list fragment HTML (still AJAX-loaded) when that endpoint is next touched
