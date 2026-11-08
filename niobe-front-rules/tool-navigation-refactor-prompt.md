# Prompt — Niobe full tool refactor

Copy this file into the agent session and fill **one** value: `TOOL_NAME`. Everything else — modules,
engines, routes, test users, existing E2E and docs — is discovered from the repository. Do not ask
for module paths, view engine, E2E class, URL, users or scope; find them.

---

## Input

| Key | Value |
|---|---|
| `TOOL_NAME` | `{{e.g. Assignments}}` |

If the name is ambiguous, resolve it through the portal tool id, bundle keys or the tool registration
before Phase 0 ends. Ask only if two genuinely different tools share the name.

## Mission

Refactor **`TOOL_NAME`** completely to Niobe. This is **not** a navigation-only change:

- IA and navigation: R, A1/A2/A3, P0/P1–P4, D, M.
- Surface composition: list, object detail, flow, nested tool, hub.
- Tables, list toolbars, row actions, empty states, pagination, bulk actions.
- Forms, choices, required/errors, form footers.
- Detail views, banners, loading/error/empty states.
- Responsive behaviour, accessibility, print, i18n.
- Tests and documentation.

A tool may span **several modules and view engines**. Include all of them. If it contains more than
one surface or app (for example Messages private messages vs Discussions), include both unless the
user explicitly narrows the request; state the split in the plan.

The result must feel like one product, not like another tool with better CSS.

## Non-negotiables

**Browser access.** You may use Playwright only against `http://localhost:8080`.
`http://127.0.0.1:8080` is the same local instance and is also allowed. Do not test, crawl, fetch or
screenshot any other origin, including remote Sakai instances, staging servers, external docs or
third-party sites. If `localhost:8080` is not running, start the local environment documented in
`docker/README.md` or mark browser verification as **blocked** and list the exact flows to verify.

**Read and obey:**

1. `AGENTS.md`
2. `.cursor/rules/frontend.mdc`
3. `library/docs/sakai-ui-foundations.md`
4. `library/docs/sakai-ui-chrome.md`
5. `library/docs/sakai-ui-tokens.md`
6. `library/docs/sakai-ui-icons.md`
7. `niobe-front-rules/plan.md`
8. `niobe-front-rules/navigation-model.md`
9. `niobe-front-rules/sakai-ui-tool-migration.md`
10. The closest reference: `polls-reference.md`, `announcements-reference.md`,
   `sitestats-reference.md`, `messages-reference.md`. They are navigation-good drafts, not final
   surface patterns; note where they diverge.

**Preserve behaviour.** Do not change URLs, permissions, persistence, grade calculations, workflow
order, site copy/import semantics or business rules. This is an IA/UI refactor. If a change would
alter behaviour, stop and document it for approval.

**No new legacy.** Do not add `.navIntraTool`, `.actionToolBar` or `.actionToolbar` markup. Touched
markup uses `sakai-*`.

**R is navigation.** Return/up is a quiet back link, never a secondary action in the header cluster
or `…`. Do not duplicate the footer Cancel on a flow.

**No general FAB.** The portal FAB stack is portal chrome. Do not use a floating action as the
general home for P0; no 2–3 s attention animation.

**Design language.** Follow `library/docs/sakai-ui-foundations.md`. Use type, spacing, color,
radius, elevation, z-index, focus and motion tokens; no raw values. No external font imports. Every
interactive component defines rest/hover/active/focus/selected/disabled/loading/error/success/
read-only/dirty.

**No AI comments.** Do not add comments that restate what code does. Only non-obvious business
logic, complex hacks or critical warnings.

**No design-system forks.** Use shared primitives and tokens. Do not invent a tool-local copy of a
shared behaviour.

## Phase 0 — Discovery (no product edits)

### 0.1 Locate every module and surface

Find all modules, apps and engines that implement `TOOL_NAME`:

- `grep -ri` the tool name, bundle keys, tool id and route names across the repo;
- `pom.xml`, `web.xml`, Spring config, route/controller classes, `*Action.java`, `*Page.java`,
  `*Application.java`, `*Controller.java`, RSF producers;
- templates and fragments: `*Headings.jsp`, `fragments/menus.html`, `VM_chef_library.vm`,
  `ShowPage.html`, `*.vm`, `*.html`, `*.jsp`, `*.jspf`;
- JavaScript that fills empty toolbars or builds menus;
- registrations in `reference/`, `site-manage`, `portal`, `webapi` or tool bundles;
- existing E2E under `e2e-tests/src/test/java/org/sakaiproject/e2e/tests/`; read
  `SakaiHelper`/`SakaiEnvironment` for users, login and tool click helpers;
- demo credentials and local setup in `docker/README.md`, `e2e-tests/README.md`, fixtures and
  existing tests.

Write the module/engine matrix:

| Module | Engine | Entry point | Templates | JS | Tests |
|---|---|---|---|---|---|
| | | | | | |

If the tool has more than one app or surface, list each and say which one this refactor covers.

### 0.2 Build the inventory

For every visible item, record:

| Field | Meaning |
|---|---|
| Label | Visible string and bundle key |
| Source | File and function/macro/component |
| Destination | URL, action, view, object, nested tool |
| Role | R / A1 / A2 / A3 / P0-S / P0-O / P0-F / P0-B / P1 / P2 / P3 / P4 / D / M / row action |
| Zone | Page header / object header / list toolbar / table / empty state / action footer / nested header |
| Current state | Link, current chip, disabled, hidden by permission, JS-generated |
| Scope | Tool, object, row, form, global |
| Permission | Who sees it and what happens when they cannot |
| Frequency | Primary task, occasional, admin |
| Notes | Duplication, dead end, ambiguity, mobile behaviour |

Classify by **what the click does**, not by label or CSS.

Also inventory:

- tables, columns, row actions, pagination, empty states;
- forms, sections, fields, choices, required/error handling, footers;
- banners, loading, error and empty states;
- current responsive behaviour (viewport vs container, count-based collapse, `…`, FABs);
- current return paths (breadcrumb, back link, footer Cancel, “Return to list” button).

### 0.3 Draw the current tree

Produce a text tree of the tool as users experience it today. Include:

- L0 portal context and L1 home;
- every A1 destination;
- object detail and its A2 views;
- flows and their exits;
- nested tools and their internal A1;
- R/return paths and where they currently live;
- P0-S/P0-O/P0-F/P0-B;
- D controls and row actions;
- permission-dependent items and the second navigation row, if any.

Example shape:

```
Assignments
├─ Home: List
│  ├─ Add assignment          P0-S
│  ├─ Reorder                 P2
│  ├─ Options                 P3
│  └─ Permissions             P3
├─ By Student                 A1
├─ Grade Report               A1
├─ Student View               A1
├─ Removed Assignments        A1 admin
└─ Assignment detail
   ├─ Back to Assignments     R (currently: Return to list button?)
   ├─ Assignment / Time sheet A2
   ├─ Edit                    P0-O
   ├─ Preview                 P1
   └─ Save/Cancel             P0-F in footer
```

### 0.4 Walk the tool in the browser

Use Playwright against `localhost:8080` only. Discover the login and tool entry from the existing
E2E helpers; do not ask for credentials unless they cannot be found.

- Log in as every relevant role (instructor, student, admin if available).
- Visit the home and every A1 destination.
- Open one object detail and every A2 view.
- Start one flow, save/cancel, and verify the exit.
- Open the nested tool and return to the parent.
- Test compact, medium and wide **containers** (resize viewport and toggle the portal sidebar).
- Check keyboard order, `aria-current`, visible focus, the `…`, R and the empty state.
- Check `prefers-reduced-motion` if there is any animation.
- Record the real click count for the primary task and the most common secondary task.

Store optional screenshots under `niobe-front-rules/screenshots/` and link them from the tool
reference.

### 0.5 Diagnose

Report only what actually occurs, with evidence:

- navigation: F1–F17 in `navigation-model.md` §3 (flat soup, repeated menu, current chip, nested
  tool as item, flow as peer, search in nav, return as action, count-based collapse, FAB risk);
- surface consistency: header/list/toolbar/table/forms/empty/return labels/icons differ from the
  reference pattern;
- tables: missing `__primary`, row actions, stacked layout, empty state, pager, bulk;
- forms: legacy field wrappers, native multi-select, missing `.sakai-actions`, wrong button weight;
- responsive: all-or-nothing overflow, empty `…`, viewport queries, FAB overlay;
- accessibility: keyboard, focus, names, `aria-current`, fake menu, contrast;
- i18n: long labels, missing keys, hardcoded text;
- print: chrome that should be `.sakai-no-print`.

### 0.6 Output

End Phase 0 with:

1. module/engine matrix;
2. inventory;
3. current tree;
4. browser findings;
5. diagnosis;
6. risks and unknowns.

Do not edit product code.

## Phase 1 — Target design and phase plan (STOP)

Design the whole tool before implementing any phase.

### 1.1 Target tree

Use the final roles from `navigation-model.md`:

- **R** return/up: navigation, quiet back link, specific parent label, preserve origin.
- **A1** tool sections; **A2** object views; **A3** nested tool.
- **P0-S** surface primary; **P0-O** object primary; **P0-F** flow primary; **P0-B** bulk primary.
- **P1** frequent secondary (max 1); **P2** occasional secondary (max 2).
- **P3** utility; **P4** destructive.
- **D** data controls; **M** mode.

For every node state its role, surface, zone, primitive, and whether it is new/kept/moved/merged/
demoted/removed.

### 1.2 Surface composition

Define each surface that exists:

| Surface | Header | Navigation | Actions | Data/forms | Exit |
|---|---|---|---|---|---|
| List | H1, R, P0-S, P1/P2, P3/P4 | A1 | P0-S, P1/P2, P3/P4 | D, table, row actions, empty state, pager, bulk | Portal |
| Object detail | Object H1, R | A2 | P0-O, object P3/P4 | Object body | R |
| Flow | Task H1 | optional quiet R | P0-F + Cancel in footer | Form sections | Footer Cancel/Return |
| Nested tool | Nested H1, R | own A1 | own P0/P1–P4 | own content | R to parent |
| Hub | Hub H1 | grouped A1 | P3 | grouped links | Portal |

If a surface does not exist, say so. Do not invent one.

### 1.3 Action placement

- R is a **back link/breadcrumb**, not an action; no “Return to list” button in the cluster.
- **Do not add R everywhere.** If the portal tool crumb or the footer Cancel already provides one
  clear exit, do not add another. R is for depth (object/flow/nested) where the portal crumb does not
  say where the parent is.
- P0-S in the page header and the empty state; one maximum.
- P0-O in the object header; not the page header.
- P0-F in the form footer; never in the page header.
- P0-B in the selection bar/footer; not before a selection exists.
- P1 max 1, P2 max 2; P3/P4 always in `…`.
- No two P0s on one surface. If two compete, one is P1/P2.
- On flows, the footer Cancel is the exit; do not duplicate it with a header Return.

### 1.4 Responsive and overflow

Use container queries, not viewport media queries inside the tool:

| Tier | Container | Visible in the header | In `…` |
|---|---|---|---|
| Compact | `< 36rem` | R + P0 | P1, P2, P3, P4 |
| Medium | `36rem–47.999rem` | R + P0 + P1 | P2, P3, P4 |
| Wide | `>= 48rem` | R + P0 + P1 + P2 | P3, P4 |

- P1 max 1, P2 max 2; anything beyond is P3 or removed.
- Do not hide every secondary action for uniformity; P1/P2 stay visible at their tier.
- The server assigns priorities; CSS decides visibility. No `utilityCount`/`--collapsed`.
- No empty `…`; no duplicate items in the panel; order P2 (when hidden) → P3 → separator → P4.
- Test long labels and `prefers-reduced-motion`.
- **No general FAB.** The portal FAB stack is portal chrome. If you propose a floating action for a
  narrow, content-light list, justify the niche, keep it inside the tool body as a sticky bar where
  possible, do not duplicate the header P0, keep content clearance, hide it on print/modals, and
  use no 2–3 s attention animation.

### 1.5 Tables, forms and states

- Tables: D in `.sakai-table-toolbar`; `__primary`, `__nowrap`, row actions, `--stack`, empty state,
  pager, bulk actions.
- Forms: `.sakai-form-section` / `.sakai-form-field`, choices, required/errors, `.sakai-actions`
  with P0-F and Cancel.
- States: banners, loading, error, empty; no legacy `alertMessage`/`instruction`. Every
  interactive component defines rest/hover/active/focus/selected/disabled/loading/error/success/
  read-only/dirty.
- Typography/spacing/color: role tokens, no raw font sizes/weights/line-heights, no raw spacing,
  no numbered palette steps, no hardcoded status colors.
- Shape/motion: radius/elevation/z-index/focus/motion tokens; no raw durations, shadows or z-index;
  reduced motion respected.
- Content: sentence case, verbs for actions, empty state with action, error with next step,
  confirmation names the object; locale/timezone via Sakai.
- Icons/tokens/print/i18n: `si si-*` only (map in `base/_icons.scss`), L1/L2 tokens,
  `.sakai-no-print`, bundle keys.

### 1.6 Phase plan

Propose the phase breakdown **for this tool**. Use this default as a starting point, not a mandate:

1. **Navigation design** (this phase).
2. **Navigation implementation**: header, R, A1/A2, P0-S/P0-O, nested returns, remove
   `navIntraTool`.
3. **Tables**: list toolbar, columns, row actions, stacked, empty, pager, bulk.
4. **Forms**: sections, fields, choices, errors, footer actions.
5. **Rest**: detail, nested tool, banners, states, icons, tokens, print, responsive polish.

Adapt it when the tool is large:

- many A1 views → split by view group or surface;
- many engines → split by module/engine;
- many tables/forms → split by table/form;
- a small tool → combine tables + forms or navigation + tables.

Every phase must be independently shippable and testable. State dependencies, risk and the
verification for each phase.

### 1.7 Documentation first

Create `niobe-front-rules/<tool-slug>-reference.md` with:

- current tree (before);
- target tree and surface contracts;
- mapping table current → target;
- zones/priorities/responsive plan;
- phase plan;
- primitives and shared code;
- gotchas and risks;
- key files and tests;
- deliberate exceptions with follow-up.

This file is part of the proposal, not an afterthought.

### 1.8 Stop for approval

End Phase 1 with:

1. the target tree in one screen;
2. the phase plan and why it is split that way;
3. the riskiest decisions (R, P0 placement, grouping, removals, FAB, nested tool);
4. the files you expect to change;
5. the explicit question: **“Approve this design and phase plan?”**

Do not edit product code before approval. Record the approval in the reference doc.

## Phase 2 — Execute the approved phases

Execute one phase at a time. For each phase:

1. Re-read the approved target for that phase.
2. Implement only that phase.
3. Run its tests and the regression checks for preserved behaviour.
4. Update the tool reference with what changed and any deviation.
5. Report the result; do not start the next phase if the previous one fails.

### Navigation phase

- Implement R as a back link, not an action; specific parent label; preserve origin.
- Implement A1 in `.sakai-tool-nav`, A2 in segmented/object tabs.
- Implement P0-S in the page header/empty state and P0-O in the object header.
- Remove `.navIntraTool` and the old action row.
- No Save/Submit, bulk or object actions in the page header.
- No new `Return to list` button; use R.
- Nested tools get their own H1, A1 and R.

### Tables phase

- D in `.sakai-table-toolbar`; search/filter/scope/pager in the standard blocks.
- `.sakai-table` + `--stack`; `__primary`, `__nowrap`, `data-label`, `aria-sort`.
- One `…` row menu in the trailing `__actions` cell; no strip of buttons.
- Empty state with the same P0-S; bulk actions in `.sakai-actions`.
- Preserve server-rendered/JSF table hooks and DataTables column indexes.

### Forms phase

- `.sakai-form-section` + `__title`, `.sakai-form-field`, `.sakai-form-label` (+ `.required`),
  `.sakai-form-control`, `.sakai-form-choice`, `.sakai-form-choice-group` (+ `--scroll`),
  `.sakai-form-help`, `.sakai-form-error`.
- No native `<select multiple>`; no `.sakai-form-group`; no `instruction`/`reqStarInline`.
- Close with `.sakai-actions`: P0-F primary, alternatives secondary, Cancel/Return ghost, overflow
  last.
- Preserve ids, CSRF fields, JS hooks and validation.

### Rest phase

- Object detail, nested tools, banners, loading/error/empty states.
- Icons, tokens, print, responsive polish.
- Typography, spacing, color roles, radius, elevation, motion and interaction states aligned with
  `sakai-ui-foundations.md`.
- Remove dead legacy CSS/JS only after the last consumer is gone.
- Update screenshots and docs.

## Phase 3 — Verification

Run continuously per phase, then once for the whole tool.

### Browser and E2E

```bash
export PLAYWRIGHT_BASE_URL=http://localhost:8080
mvn -P e2e -Dtest=<discovered-test-class> test
```

Cover:

- every A1 destination or the most important plus the return path;
- one P0-S, one P1/P2, one P3/P4 overflow;
- one object detail with A2 and R;
- one flow start → save/cancel → exit;
- nested tool entry → R, if applicable;
- instructor vs student permissions;
- compact/medium/wide containers, no clipped menu, no dead end;
- empty state primary action.

Use existing helpers in `e2e-tests/src/test/java/org/sakaiproject/e2e/support/`. Add `data-*` hooks
only when a stable selector is missing. Do not mock the tool under test.

### Accessibility

- Keyboard-only pass on A1, R, P0, P1/P2, `…` and row actions.
- Visible `:focus-visible`.
- `aria-current="page"` on the active A1; no contradictory `aria-selected`.
- Accessible names on icon-only controls; no `title`-only names.
- Honest roles; no fake `menu`/`menubar` without a keyboard model.
- Status/counts include text.
- Headings ordered; one view H1.

### Visual and responsive

- Light, dark, L0 brand customization.
- Container widths: compact, medium, wide; long German labels.
- No horizontal scroll; no overlapping FAB; no clipped `…`.
- Print: `.sakai-no-print` on chrome.
- `prefers-reduced-motion` respected.

### Regression

- Old URLs still work.
- Permissions still hide the same actions.
- Forms still validate and persist.
- JS hooks and DataTables still work.
- No new console errors.

If the server is unavailable, state exactly which checks were blocked. Do not claim a browser
verification you did not run.

## Phase 4 — Documentation (mandatory)

Documentation is part of the refactor, not a follow-up.

### 4.1 Tool reference

`niobe-front-rules/<tool-slug>-reference.md`:

- current tree (before);
- target tree and surface contracts;
- mapping table;
- zones/priorities/responsive plan;
- phase log: what shipped in each phase;
- primitives and shared code;
- gotchas and engine traps;
- key files (templates, Java, SCSS, JS, bundles, tests);
- Playwright coverage;
- exceptions and follow-ups;
- screenshots, if captured.

### 4.2 Roadmap

`niobe-front-rules/sakai-ui-tool-migration.md`:

- mark the tool status and link the reference;
- update the order if the phase plan changed it;
- add any new pattern, primitive or exception.

### 4.3 Model and contract

- `niobe-front-rules/navigation-model.md`: only if the tool reveals a new surface/role or a genuine
  exception; add evidence, not a rewrite to fit one tool.
- `library/docs/sakai-ui-chrome.md`: only if the public contract changes.
- `AGENTS.md` / `.cursor/rules/frontend.mdc`: only for a repo-wide rule.

### 4.4 Links and PR

- `niobe-front-rules/README.md` lists the tool reference.
- The tool reference links the model, prompt and E2E.
- PR description: current tree, target, phases shipped, what changed, what did not, tests run,
  docs links, blocked verification.

## Definition of done

- [ ] All modules/engines for `TOOL_NAME` discovered and listed.
- [ ] Current tree and inventory recorded with evidence.
- [ ] Target design and phase plan approved before implementation.
- [ ] Every item classified R/A1/A2/A3/P0-S/P0-O/P0-F/P0-B/P1/P2/P3/P4/D/M.
- [ ] R is a back link, not an action; no duplicate footer Cancel.
- [ ] P0-S/P0-O/P0-F/P0-B are in their zones; no Save/Submit or bulk in the page header.
- [ ] No `navIntraTool` in touched markup.
- [ ] A1 current uses `aria-current`; A2 uses the right control.
- [ ] Tables, toolbars, row actions, empty states and pagination aligned.
- [ ] Forms use the shared sections/fields/choices/errors and `.sakai-actions`.
- [ ] Responsive tiers implemented; no count-based collapse; no empty `…`.
- [ ] No general FAB; no 2–3 s attention animation.
- [ ] Light/dark/brand/print/long labels verified.
- [ ] Playwright covers changed surfaces and permissions.
- [ ] Tool reference complete and linked.
- [ ] Roadmap updated; model/chrome/AGENTS updated only if the contract changed.
- [ ] No URL, permission, persistence or workflow behaviour changed.
- [ ] Blocked verification listed explicitly.

## Appendix A — Inventory template

```markdown
| Label | Bundle key | Source | Destination | Role | Zone | Current state | Scope | Permission | Notes |
|---|---|---|---|---|---|---|---|---|---|
|  |  |  |  |  |  |  |  |  |  |
```

## Appendix B — Tree template

```text
{{TOOL_NAME}}
├─ A1 {{home}}                     → P0-S {{primary}}, P1/P2 {{secondary}}, P3 {{utilities}}
├─ A1 {{peer}}
├─ A3 {{nested tool}}              → own A1 + R {{parent}}
└─ L2 {{object detail}}
   ├─ R ← {{parent}}
   ├─ A2 {{view}}
   ├─ P0-O {{object primary}}
   └─ P3/P4 {{object utilities}}
```

## Appendix C — Tool reference template

```markdown
# {{TOOL_NAME}} — Niobe reference

Modules/engines: … · Status: … · Prompt: tool-navigation-refactor-prompt.md
Model: navigation-model.md · Chrome: library/docs/sakai-ui-chrome.md

## Current tree (before)
## Target tree and surfaces
## Mapping
## Zones and priorities
## Responsive plan
## Phase log
## Primitives and shared code
## Gotchas
## Key files
## Playwright coverage
## Exceptions and follow-ups
```

## Appendix D — Roles and zones quick reference

| Role | Where |
|---|---|
| R return/up | Quiet back link/breadcrumb, leading side; never the action cluster |
| A1 tool section | `.sakai-tool-nav` |
| A2 object view | `.sakai-segmented-control` or object tabs |
| A3 nested tool | Nested header + own A1 + R |
| P0-S surface primary | Page header + empty state |
| P0-O object primary | Object header |
| P0-F flow primary | `.sakai-actions` footer |
| P0-B bulk primary | Selection bar/footer |
| P1/P2 secondary | Header priority tiers |
| P3 utility | `…` |
| P4 destructive | `…`, separated |
| D data controls | `.sakai-table-toolbar` |
| M mode | Explicit switch + banner + exit |

## Appendix E — Responsive tiers

| Tier | Container | Visible in the header | In `…` |
|---|---|---|---|
| Compact | `< 36rem` | R + P0 | P1, P2, P3, P4 |
| Medium | `36rem–47.999rem` | R + P0 + P1 | P2, P3, P4 |
| Wide | `>= 48rem` | R + P0 + P1 + P2 | P3, P4 |

P1 max 1, P2 max 2. P3/P4 always overflow. No empty `…`. No duplicate items in the panel.

## Appendix F — Engine guardrails

**Velocity / CHEF**

- `MenuBuilder` decides items and permissions; the template must not re-derive them.
- `#sakaiToolHeader` renders a heading plus menu actions; it does not yet render R, A1 peers or the
  P1/P2/P3/P4 model. Emit the missing pieces explicitly until the macro gains typed slots.
- Preserve `$item.Form`/`buildQueryString()`; `doCancel` is not an action.

**JSF**

- `rendered` is evaluated at render, not decode; use a JSP scriptlet or a bean flag for action
  clusters that must fire.
- Header navigation links need `immediate="true"` so validation does not block them.
- Preserve form/client ids and `f:param` values used by JS.
- `h:selectOneRadio layout="pageDirection"` renders a table; use the tool's compact choice class.

**Wicket**

- Use `BookmarkablePageLink` and `isVisible()` as the permission/role gate.
- The current link must expose `aria-current="page"` and must not look disabled while remaining
  clickable.
- Do not hide a required destination with CSS; remove it from the model.

**Thymeleaf**

- Menus live in `fragments/menus.html` with a `current` key. Render the current item as text, not a
  link.
- Use `th:classappend`; no visual state in `th:style`.

**RSF**

- Keep `rsf:id` values used by producers and JavaScript.
- Reflect navigation changes in the producer, not only the template.

**JSP / JavaScript-generated menus**

- If the template is an empty `<ul class="navIntraTool">`, the menu is built in JS. Audit the JS
  templates and render `sakai-*` markup from there.

**Lit**

- Light DOM by default; query with `renderRoot`, not `shadowRoot`.
- Use Sakai tokens and `@container sakai-tool`; do not copy document styles into the component.

## Appendix G — Phase plan template

```markdown
| Phase | Scope | Surfaces | Depends on | Verification | Docs |
|---|---|---|---|---|---|
| 1 | Target design | all | discovery | review | reference draft |
| 2 | Navigation | header, A1/A2, R, P0-S/O, nested | 1 | Playwright nav + a11y | reference nav |
| 3 | Tables | list, toolbar, row actions, empty, pager, bulk | 2 | Playwright list + widths | reference tables |
| 4 | Forms | create/edit/import/permissions/options | 2 | Playwright form + validation | reference forms |
| 5 | Rest | detail, banners, states, icons, tokens, print | 2–4 | full matrix | reference complete |
```

Split a phase by surface or engine when the tool is large. Say why. Every phase must be
independently shippable and testable.
