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

### 2.2. Responsive Design Based on Containers (Container Queries)

The portal uses traditional *Media Queries* because it controls the entire viewport. However, **tools must use Container Queries** (`@container sakai-tool (...)`).

* **Why?** A tool does not know if the portal's sidebar is open or closed. Its layout must react to the available space within its `.sakai-page-content`, not to the total screen width.

### 2.3. Zero Font Awesome, Only Bootstrap Icons

Font Awesome is abandoned in favor of **Bootstrap Icons**.

* Direct use: `bi bi-*` classes.
* Semantic use: `si si-sakai-*` (mapped in `base/_icons.scss`).

## 3. Design Ecosystem: Tokens (`sakai-ui-tokens`)

Sakai's color and typography are managed using custom CSS variables in semantic layers. **No tool may define hardcoded hexadecimal (hex) colors in isolation.**

| Layer | SCSS File | Audience | Purpose |
|-------|-----------|----------|---------|
| **L0 Brand** | `tokens/_brand.scss` | Institutions | Here institutions customize their brand. It defines the logo, primary color, border radii, and base background. |
| **L1 Semantic** | `tokens/_semantic.scss` | Product UI | Semantic variables that consume L0. Ex: `--sakai-text-primary`, `--sakai-bg-surface`, `--sakai-border-color`. |
| **L2 Components** | `tokens/_components.scss` | Components | Specific configuration for buttons, banners, cards (`sakai-btn-*`, `sakai-card`). |
| **L3 Portal** | `tokens/_portal.scss` | Portal Chrome | Exclusive for the portal structure (sidebar, header, content card). |

Tools in the process of migration must consume the L1/L2 layers. Legacy variables will be temporarily kept in `_legacy-light.scss` until Morpheus is completely unplugged across all tools.

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

The biggest problem with legacy tools is the `.navIntraTool` class, a catch-all that mixes tabs, action buttons, and configuration menus.

Any tool migrated to Niobe **must break down its navigation using the A/B/C taxonomy**:

| Type | Meaning | Target UI | Example |
|------|---------|-----------|---------|
| **A. Exclusive views** | Mutually exclusive sections (tabs). Only one is current. | `.sakai-tool-nav` or `.sakai-segmented-control`. | List, Student View, Grades. |
| **B. Primary actions** | The main task of the current view. | `.sakai-btn-primary` button in the header's actions area. | "+ Add", "Create". |
| **C. Secondary utilities** | Configuration, permissions, reorder, trash. | Overflow menu (`...`) or quiet secondary group. | Permissions, Options. |

### 5.1. Header Structure (Layout Contract)

```html
<div class="sakai-tool-body">
  <div class="sakai-tool-header">
    <h1 class="sakai-tool-header__title">View Title</h1>
    <div class="sakai-tool-header__actions">
      <!-- B and C buttons here -->
    </div>
  </div>
  <!-- If applicable, A navigation here: .sakai-tool-nav -->
  
  <!-- Tool content -->
</div>
```

## 6. Component Primitives (`sakai-*`)

To standardize the UI and avoid loose utilities, all tool markup must migrate to use Sakai's core primitives defined in `sass/components/`:

* **Buttons:** `.sakai-btn`, `.sakai-btn-primary`, `.sakai-btn-secondary`, `.sakai-btn-ghost`, `.sakai-btn-icon`. *(Note: ensure consistent styles on both* `*<button>*` *and* `*<a>*`*)*.
* **Forms:** `.sakai-form-group`, `.sakai-form-label`, `.sakai-form-control`. Footer actions use `.sakai-actions` (applies `gap` via flexbox, not individual margins).
* **Tables:** `.sakai-table` (supports `--striped`, `--hover`, `--stack` modifiers).
* **Banners:** `.sakai-banner` with `--info`, `--success`, `--warn`, `--error` modifiers. These replace the old `sak-banner-*`.
* **Row Menus:** `.sakai-row-actions__link` and overflow menus to avoid cluttering data tables with massive buttons.

## 7. JavaScript and Web Components Development Guide

* **Zero jQuery in new code:** If legacy code is touched, it must be refactored to modern DOM APIs (Vanilla JS ES6+) whenever the change is reasonable and manageable. New tools must not add jQuery dependencies.
* **Web Components (Lit):** Remains the strategic direction for creating reusable and interactive UI components (e.g., date pickers, complex modals, user selectors).
* **Light DOM by default (Niobe Approach):** To ensure components automatically inherit `.sakai-*` primitives and Bootstrap styles without duplicating stylesheets, **it is recommended to render Lit components in the Light DOM** (using `createRenderRoot() { return this; }`).
* **Restricted Shadow DOM:** Use Shadow DOM only in very low-level components or third-party widgets where strict isolation is mandatory.
* **DOM Queries:** Always use `renderRoot` in Lit, never `shadowRoot` directly (as it will fail if the component adopts the Light DOM).
* **State and Encapsulation:** Minimize the use of global variables attached to `window`. Keep Lit's internal state prefixed with `_` and expose only intended APIs.

## 8. Migration Process (tool-by-tool)

The migration will not happen all at once, but progressively. The **Polls** tool is our reference implementation.

### Mandatory checklist to migrate a tool:


1. **Analyze navigation:** List all current `navIntraTool` items and classify them into **A, B, or C**.
2. **Restructure header:** Implement `.sakai-tool-header` and remove the duplicate tool title if it exists.
3. **Clean Bootstrap:** Remove Bootstrap utilities (`d-flex`, `mt-2`, etc.) from templates and move the layout to the tool's specific SCSS, using `sakai-*` primitives or *container queries*.
4. **Update icons:** Replace FontAwesome with Bootstrap Icons (`bi-*`).
5. **Colors:** Verify that the tool does not declare *hardcoded* colors. Always consume L1/L2 tokens.
6. **Tests:** Update E2E Playwright selectors and check key flows. Do not mix business logic or permission refactoring in a purely UI-focused PR.