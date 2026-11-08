# Plan

## 1. Introduction: Unplugging Morpheus

For years, the Sakai interface has been governed by the Morpheus architecture. While it modernized the platform at the time by making it *responsive*, over the years it has become outdated and generated enormous technical debt.

It seemed that Trinity was going to revamp the platform. However, it was only half a coat of paint over the same old foundations that failed to solve the core problem of cohesion and layout. The portal was reinvented, but the tools remained anchored in the past and without a design guide, which has meant that, over time, each tool implemented its own flows that complicate the user experience.

It is time to completely unplug Morpheus from Sakai, and to reinvent Trinity.

Niobe is not just a theme, it is a new design system and the establishment of global design foundations. Inspired by the modern standards of current LMS platforms (cleaner, more focused, and faster interfaces), Niobe must change how Sakai looks, but above all, how it is built.

### 1.1. The Niobe Vision

* The user experience must be unified. Moving from *Assignments* to *Lessons* or *Polls* should not feel like jumping between different applications. Sakai is a robust LMS that offers the institutions that use it a large catalog of tools, saving them from having to use different LTIs. Let's focus on this and make Sakai feel like an all-in-one, integrated, and cohesive platform.
* The portal must dictate the main layout (sidebar, breadcrumbs, content area). It must even lay the foundations for common elements across tools (titles, navigation, actions, tables). The tools will live inside a card and yield control of the environment.
* HTML templates define semantics and logical components. CSS defines the layout. Customizing the Sakai skin has become a nightmare due to the large number of simple Bootstrap utility classes, which add no functionality, injected into the HTML. Under Niobe standards, the use of "Bootstrap soup" must be banned. Styles must consume Sakai variables, not styles imposed by Bootstrap. Sakai is an LMS where the institution has full control; let's not yield to Bootstrap design that may become obsolete over time.

This document was born as the official brand, UI/UX design, and frontend development guide for the project.

## 2. Frontend Architecture Principles

### 2.1. Goodbye to Bootstrap Utilities

Although Sakai continues to use **Bootstrap 5.3** under the hood for complex component logic (modals, offcanvas, dropdowns), **the use of Bootstrap utility classes for layout and spacing in new markup is strictly prohibited** (e.g., `d-flex`, `mt-4`, `p-2`, `w-100`, `gap-3`).

Instead, all layout must be expressed using Sakai's own classes (`.sakai-*`) defined in the centralized SCSS files, utilizing the variables and mixins of the Niobe system.

### 2.1.1. Professional CSS (no `!important`, no inline visuals)

Niobe-owned SCSS and templates must stay maintainable for institutional skins:

* Do **not** use `!important` in new or touched Sakai rules. Raise specificity or narrow selectors instead.
* Do **not** put visual presentation in HTML `style="…"` attributes, and do not assign visual properties (`color`, `display`, `height`, `margin`, …) from JavaScript.
* Dynamic geometry (e.g. a rail flyout’s viewport coordinates) may set **CSS custom properties** on a host element; all other presentation remains in SCSS.

Canonical copies: `.cursor/rules/frontend.mdc`, `AGENTS.md`, `library/docs/sakai-ui-chrome.md`.

### 2.2. Responsive Design Based on Containers (Container Queries)

The portal uses traditional *Media Queries* because it controls the entire viewport. However, **tools must use Container Queries** (`@container sakai-tool (...)`).

* **Why?** A tool does not know if the portal's sidebar is open or closed. Its layout must react to the available space within its `.sakai-page-content`, not to the total screen width.

### 2.3. Sakai icon map (`si`) over Bootstrap Icons

Font Awesome is abandoned. Front-end code consumes the Sakai icon map, not Bootstrap Icons directly.

* Use `si si-*` classes.
* `bi-*` lives only in `base/_icons.scss` as the central map; changing an icon is a one-line map change.
* Semantic tool names use `si si-sakai-*` (mapped in `base/_icons.scss`).

### 2.4. Accessibility baseline

Renovated portal and tools must be usable with keyboard and screen readers: real buttons vs links, clear accessible names, honest ARIA state (`aria-expanded` / `aria-current` / `aria-pressed`), status as text not icon-only, no fake `menu`/`menubar` without a keyboard model, and visible focus. Canonical rules: `.cursor/rules/frontend.mdc`, `AGENTS.md`, `library/docs/sakai-ui-chrome.md`. Full baseline and state matrix: [`library/docs/sakai-ui-foundations.md`](../library/docs/sakai-ui-foundations.md).

## 3. Design Language and Tokens

Niobe is a design language, not a color swap. The full principles, visual language, states,
theming contract and checklist live in
[`library/docs/sakai-ui-foundations.md`](../library/docs/sakai-ui-foundations.md). The token
reference is [`library/docs/sakai-ui-tokens.md`](../library/docs/sakai-ui-tokens.md).

### 3.1. Principles

1. **Calm by default, content first.** Chrome recedes; course, task and data lead.
2. **Predictable zones.** The same kind of control always lives in the same kind of place.
3. **Institutional, not generic.** The institution owns the brand; Niobe owns structure,
   typography, spacing and interaction.
4. **Accessible by construction.** Contrast, focus, keyboard, target size, semantics and reduced
   motion are part of the component.
5. **Dense but breathable.** Data-heavy screens may be compact; rhythm stays clear.
6. **One system, many tools.** Moving between tools should feel like moving between rooms.
7. **Functional motion only.** Motion explains change; it never decorates or demands attention.

### 3.2. Visual language

- **Surfaces:** canvas, card, raised, sunken, overlay. One border + restrained shadow, no decorative
  card-in-card.
- **Color:** brand for primary action/selection; neutral for structure; status only for status.
  Contrast is a requirement (4.5:1 text, 3:1 UI).
- **Typography:** display / h1 / h2 / h3 / body / body-sm / label / caption / code. Use roles, not
  ad-hoc sizes. Headings sentence case. No external font imports.
- **Density:** comfortable by default; compact for data-heavy tables/admin lists. Density changes
  row height and gaps, not font size or touch targets.
- **Motion:** short, functional, optional; no looping/bouncing/attention animations; respect
  `prefers-reduced-motion`.
- **Shape:** soft rectangles, 1px borders, moderate radii; pills only for tags/chips/segments.

### 3.3. Token layers

| Layer | SCSS File | Audience | Purpose |
|-------|-----------|----------|---------|
| **T0 Primitives** | generated palette/scales | System only | Raw palette and scales; never consumed by a tool. |
| **L0 Brand** | `tokens/_brand.scss` | Institutions | Logo, brand HSL, optional self-hosted font, logo sizes, radius personality. |
| **L1 Semantic** | `tokens/_semantic.scss` | Product UI | Surface, text, border, interactive, status, focus, type and spacing roles. |
| **L2 Components** | `tokens/_components.scss` | Components | Buttons, forms, tables, banners, cards, modals, menus. |
| **L3 Regions** | `tokens/_portal.scss` / `tokens/tools/` | Portal/tool region | Region-specific only; never a second design system. |
| **Legacy** | `tokens/_legacy-light.scss` | Migration only | No new consumers; track in the legacy ledger. |

New code consumes **roles**, not numbered palette steps. The numbered vars
(`--sakai-background-color-*`, `--sakai-text-color-*`, `--infoBanner-*`, …) are migration aliases.

### 3.4. Typography and spacing

- Type roles: `--sakai-text-display/h1/h2/h3/body/body-sm/label/caption/code` with size, line height
  and weight. No `font-size: 1.375rem` in a component.
- Spacing scale (4px base): `0, 4, 8, 12, 16, 24, 32, 40, 48, 64` → `--sakai-space-0..9`.
  Section 24px, field 16px, inline 8px.
- Spacing is a system scale, not a brand knob. Institutional overrides of spacing are unsupported.
- Radius: xs/sm/md/lg/xl/pill. One border + subtle shadow; no decorative elevation.

### 3.5. States and motion

Every interactive component defines rest, hover, active, focus, selected, disabled, loading, error,
success, read-only and dirty/unsaved. Status is text/icon + text, never color-only.

Motion uses `--sakai-motion-fast/base/slow` and standard easings; no hardcoded durations; reduced
motion disables non-essential animation.

### 3.6. Theming contract

**Supported (L0 only):** logo/icon light/dark, brand HSL, optional self-hosted font family, logo
dimensions/opacity, radius personality, page/card background when the brand requires it.

**Not supported:** spacing, type sizes, line heights, z-index, motion, semantic roles, L2/L3
per-tool overrides, arbitrary skin CSS. If an institution needs a change outside L0, it becomes a
supported token or component variant in Niobe.

Dark mode defines the same semantic roles, checks contrast and uses border + lower shadow. No
per-tool dark themes.

### 3.7. Legacy and governance

Legacy variables remain in `_legacy-light.scss` only until their last consumer is gone. Every
legacy class/variable must be in the legacy ledger with consumers and a removal condition. A token
is added at the right layer, consumed by the component, documented (states/anatomy/a11y), and
removed only when the ledger shows zero consumers. Visual regression and contrast checks belong in
CI.

## 4. The Portal: Structure and "Chrome"

The structural layout of the Niobe portal adopts a modern approach:


1. **Full-height Sidebar:** Contains institutional branding, user profile (drawer), and site/tool navigation.
2. **Main Canvas:** Light gray area that houses the top toolbar (breadcrumbs + utilities) and the content card.
3. **Content Card (**`.sakai-page-content`**):** The main white container where the tool lives.

### 4.1. Title and Ownership Contract (Title Ownership)

To avoid visual redundancy, titles are strictly divided:

* **Breadcrumb (Portal Toolbar):** Shows *Where you are* (Site › Tool). Owned by the Portal.
* **Portlet Title (Home/Multi-tool):** Only appears if there are multiple tools on the same page.
* **View Heading (**`H1`/`H2`**):** Owned by the tool. It must name the **current view** (e.g., "Add assignment", "Grade report"), **NOT** repeat the tool name.

## 5. Tool Anatomy (Intra-tool IA)

The biggest problem with legacy tools is the `.navIntraTool` class, a catch-all that mixes
destinations, actions and configuration in one row of equal chips. The old A/B/C taxonomy
classifies a control, but not the layer it belongs to. The full model, evidence and worked examples
live in [`navigation-model.md`](navigation-model.md).

### 5.1. Layers

| Layer | Owner | Meaning |
|-------|-------|---------|
| **L0 Portal** | Portal | Site › tool: breadcrumb and sidebar. Already answers “where am I”. |
| **L1 Tool** | Tool | The tool's home and peer destinations. |
| **L2 Object** | Tool | Views of the selected object (assignment, assessment, page, folder). |
| **L3 Flow** | Tool | Temporary task with save/cancel: create, edit, import, wizard. |
| **L4 Nested tool** | Tool | Self-contained workspace launched from a parent; it has its own L1. |

### 5.2. Roles

| Role | Meaning | Target UI / zone |
|------|---------|------------------|
| **R Return** | Go up to the parent surface. Navigation, not an action. | Quiet back link / breadcrumb, leading side of the header. Never in the action cluster or `…`. |
| **A1 Tool sections** | Peer destinations at L1; one is current. | `.sakai-tool-nav` (2–5). More than 5 needs grouping. |
| **A2 Object views** | Peer views of the selected object. | `.sakai-segmented-control` or object tabs. |
| **A3 Nested tool** | Self-contained workspace. | Entry action + nested header + own A1 + R. |
| **P0-S Surface** | Main create/do action of the list/home. | Page header trailing; repeat in the empty state. |
| **P0-O Object** | Main action on the selected object. | Object header. |
| **P0-F Flow** | Save/Submit the form. | `.sakai-actions` at the end of the form. Never in the page header. |
| **P0-B Bulk** | Act on the current selection. | Selection bar / table footer. |
| **P1 Frequent** | Frequent secondary (max 1). | Header, visible from medium width. |
| **P2 Occasional** | Occasional secondary (max 2). | Header at wide width; otherwise `…`. |
| **P3 Utility** | Options, permissions, export, print, audit. | Always `…`. |
| **P4 Destructive** | Delete, reset, remove. | `…`, separated, with confirmation. |
| **D Data controls** | Search, filter, sort, pager, select-all, bulk. | `.sakai-table-toolbar` / table head / bulk bar. |
| **M Mode** | Preview another role or change the audience. | Explicit switch + banner + exit. |

### 5.3. Zones

| Zone | Owns | Must not contain |
|---|---|---|
| **Page header** | H1, R, P0-S, P1/P2, P3/P4 overflow | Object actions, Save/Submit, bulk actions, search/filter |
| **Object header** | Object identity, A2, P0-O, object P3/P4 | Global Add, Permissions, list toolbar |
| **List toolbar** | D: search, filter, scope, pager, select-all, bulk | Create actions, navigation, object actions |
| **Table / row** | Row data and row actions | Global actions |
| **Empty state** | The same P0-S, in context | A different primary action |
| **Action footer** | P0-F, Cancel/Return, bulk P0-B | Surface navigation, global utilities |
| **Nested header** | Nested H1, R to parent, nested A1/P0 | Parent A1/P0 cluster |

### 5.4. Placement rules

* **Places and actions never share a group.** A1 is navigation; P0/P1/P2/P3/P4 are actions.
* **R is navigation.** A “Return to list” button is not the model. Use a specific back link
  (“Back to Assignments”), preserve the origin, and do not duplicate the footer Cancel on flows.
  Do not add R everywhere: one clear exit is enough.
* **P0 is not one role.** P0-S/P0-O/P0-F/P0-B live in different zones. Save/Submit never goes in
  the page header; bulk actions never appear before a selection exists.
* **0 A1 peers:** the view H1 is enough. **2–5:** `.sakai-tool-nav`. **More than 5:** grouped hub or
  grouped nav, decided before markup.
* **Current view:** selected item with `aria-current="page"`. Never a dead chip or a disabled link.
* **Flow views** keep the H1 and one exit; they do not repeat the home cluster. The footer
  `Cancel`/`Return` is the exit; a header R is optional for long flows and must be a quiet link.
* **Detail views** own their object actions; they do not repeat global create/permissions.
* **Nested tools** hide the parent cluster, render their own H1 + A1 + R to the parent.
* **D stays in the list toolbar.** Search/filter/pager/bulk are not navigation.
* **M is explicit.** Prefer the portal “View Site As”; otherwise show a banner and a clear exit.
* **No dead ends.** Every non-home surface has exactly one obvious exit.
* **No duplicate title.** Portal breadcrumb owns site › tool; the tool H1 names the view.
* **No general FAB.** The portal FAB stack is portal chrome. Prefer a sticky action bar inside the
  tool body for the narrow, content-light niche; no 2–3 s attention animation.

### 5.5. Responsive tiers

| Tier | Container | Visible in the header | In `…` |
|---|---|---|---|
| **Compact** | `< 36rem` | R + P0 | P1, P2, P3, P4 |
| **Medium** | `36rem–47.999rem` | R + P0 + P1 | P2, P3, P4 |
| **Wide** | `>= 48rem` | R + P0 + P1 + P2 | P3, P4 |

P1 max 1, P2 max 2. The server assigns priorities; CSS container queries decide visibility. The
overflow panel must not repeat actions already visible at that width. Retire the count-based
`utilityCount`/`--collapsed` logic. Do not hide every secondary action for uniformity: P1/P2 stay
visible at their tier.

### 5.6. Header Structure (Layout Contract)

```html
<div class="sakai-tool-body">
  <header class="sakai-tool-header">
    <a class="sakai-back-link" href="…">Back to Assignments</a>
    <h1 class="sakai-tool-header__title">View title</h1>
    <div class="sakai-tool-header__actions">
      <!-- P0-S, P1/P2, P3/P4 overflow -->
    </div>
  </header>
  <nav class="sakai-tool-nav" aria-label="Views">
    <!-- A1 destinations, current item not a link -->
  </nav>
  <!-- Object header + segmented control (A2), table toolbar (D), content -->
</div>
```

`.sakai-back-link` is a proposed shared primitive; until it exists, use the section/object
breadcrumb or a quiet link with `si si-arrow-left`.

### 5.7. Before refactoring a tool

1. Build the **current tree and inventory** with evidence (templates, menu builder, JS, tables,
   forms, states).
2. Classify every item with the decision tree in `navigation-model.md`.
3. Propose the **target design**: R/A1/A2/A3/P0/P1–P4/D/M, zones, surfaces, responsive tiers.
4. Propose the **phase plan** (default: navigation → tables → forms → rest; split by surface when
   the tool is large).
5. Write it in `niobe-front-rules/<tool>-reference.md` and get approval.
6. Only then change markup, styles, JavaScript and tests per phase. Use
   [`tool-navigation-refactor-prompt.md`](tool-navigation-refactor-prompt.md) as the per-tool prompt.

## 6. Component Primitives (`sakai-*`)

To standardize the UI and avoid loose utilities, all tool markup must migrate to use Sakai's core primitives defined in `sass/components/`:

* **Buttons:** `.sakai-btn`, `.sakai-btn-primary`, `.sakai-btn-secondary`, `.sakai-btn-ghost`, `.sakai-btn-icon`. *(Note: ensure consistent styles on both* `*<button>*` *and* `*<a>*`*)*.
* **Forms:** `.sakai-form-section` (+ `__title` / `__intro`), `.sakai-form-field`, `.sakai-form-label` (+ `.required`), `.sakai-form-control`, `.sakai-form-choice`, `.sakai-form-choice-group` (+ `--scroll`), `.sakai-form-help`, `.sakai-form-error`. Footer actions use `.sakai-actions` (applies `gap` via flexbox, not individual margins); primary save/confirm, secondary alternatives, ghost cancel/back/return, overflow last.
* **Tables:** `.sakai-table` (supports `--striped`, `--hover`, `--stack` modifiers).
* **Banners:** `.sakai-banner` with `--info`, `--success`, `--warn`, `--error` modifiers. Same API as old `sak-banner-*` (content only; icon via CSS by type).
* **Row Menus:** `.sakai-row-actions__link` and overflow menus to avoid cluttering data tables with massive buttons.

## 7. JavaScript and Web Components Development Guide

* **Zero jQuery in new code:** If legacy code is touched, it must be refactored to modern DOM APIs (Vanilla JS ES6+) whenever the change is reasonable and manageable. New tools must not add jQuery dependencies.
* **Web Components (Lit):** Remains the strategic direction for creating reusable and interactive UI components (e.g., date pickers, complex modals, user selectors).
* **Light DOM by default (Niobe Approach):** To ensure components automatically inherit `.sakai-*` primitives and Bootstrap styles without duplicating stylesheets, **it is recommended to render Lit components in the Light DOM** (using `createRenderRoot() { return this; }`).
* **Restricted Shadow DOM:** Use Shadow DOM only in very low-level components or third-party widgets where strict isolation is mandatory.
* **DOM Queries:** Always use `renderRoot` in Lit, never `shadowRoot` directly (as it will fail if the component adopts the Light DOM).
* **State and Encapsulation:** Minimize the use of global variables attached to `window`. Keep Lit's internal state prefixed with `_` and expose only intended APIs.

## 8. Migration Process (tool-by-tool)

The migration is a **full tool refactor**, not a nav restyle. It happens in approved phases, because
a large tool may need to split navigation, tables and forms by surface. **Polls**,
**Announcements**, **Messages** and **Statistics** are navigation-good drafts; they still need a
surface parity pass before they are treated as the final pattern.

### Mandatory checklist to refactor a tool

1. **Current inventory:** build the current tree and list every navigation item, action, table,
   form and state with evidence. Classify each with the decision tree in
   [`navigation-model.md`](navigation-model.md) (R/A1/A2/A3/P0/P1–P4/D/M).
2. **Target design:** propose the tree, zones, surfaces, responsive tiers and phase plan. Get it
   approved **before** editing product code; record it in
   `niobe-front-rules/<tool>-reference.md`.
3. **Navigation phase:** implement R as a back link, A1/A2 in the right nav, P0-S/P0-O in their
   zones; remove `navIntraTool`; do not put Save/Submit or bulk actions in the header.
4. **Tables phase:** list toolbar (D), columns, `__primary`, row actions, stacked behavior, empty
   state, pagination and bulk actions.
5. **Forms phase:** `.sakai-form-section` / `.sakai-form-field`, choices, required/errors,
   `.sakai-actions` with P0-F and Cancel.
6. **Rest phase:** detail views, nested tools, banners, loading/error/empty states, icons, tokens,
   print, responsive polish.
7. **Clean Bootstrap:** remove utilities from edited templates; layout in tool SCSS with
   `@container sakai-tool`.
8. **Icons and colors:** `si si-*` only (central map); L1/L2 tokens, no hardcoded hex.
9. **Accessibility and responsive:** keyboard, focus, `aria-current`, accessible names; compact /
   medium / wide containers; no general FAB; no auto attention animation.
10. **Tests:** Playwright for each changed surface, permissions by role, preserved URLs; no mixing
    business-logic or permission refactoring in a UI-only phase.
11. **Document:** complete the tool reference, update the roadmap, and add a model exception only if
    the tool genuinely needs one. A PR without this documentation is incomplete.
