# Prompt — Niobe refactor audit

Run this **after** the full-tool refactor prompt. It is an exhaustive review of the changes, not a
second refactor.

**Default mode: audit only.** Do not modify product code. Produce a report with evidence and a
remediation plan. Only apply fixes if the user explicitly says **“fix”** or **“apply”**.

---

## Inputs

| Key | Value |
|---|---|
| `TOOL_NAME` | `{{optional — limit the audit to one tool; leave empty for the whole branch diff}}` |
| `BASE_REF` | `{{optional — target branch or merge base; discover from branch tracking if empty}}` |

If `BASE_REF` is empty, discover the target from `git branch -vv`, `git remote show`, or the branch
upstream. Ask once only if it cannot be discovered.

## Mission

Audit the current branch changes against `BASE_REF` and answer:

1. Does the refactor comply with the Niobe model and primitives?
2. Did any legacy Morpheus/Trinity/`navIntraTool` code survive, or did new legacy sneak in?
3. Are there classes, CSS variables, JS, templates, i18n keys or assets that are no longer used?
4. Did the refactor change behaviour, permissions, URLs or persistence by accident?
5. Are the tests and the Niobe documentation complete and truthful?

The long-term goal is that **Morpheus/Trinity CSS variables and classes disappear completely** as
each tool migrates, until Niobe is the only system left. The audit must distinguish:

- **tool-owned legacy** that can be removed now;
- **shared legacy** still used by other tools, which must be recorded in a ledger and removed only
  when its last consumer is gone;
- **new legacy** introduced by the refactor or by a rebase, which must be fixed immediately.

## Phase 0 — Establish the diff

1. Confirm the working tree state:
   `git status --short`, `git diff --stat`, `git diff --check`.
2. Find the merge base:
   `git merge-base HEAD <BASE_REF>`.
3. List changed, added and deleted files:
   `git diff --name-status <merge-base>...HEAD`.
4. If `TOOL_NAME` is set, filter to that tool's modules, templates, styles, JS, bundles, tests and
   docs. If not, audit the whole branch diff but group findings by tool/component.
5. Record the commit range and the exact SHAs in the report.

Do not start from assumptions. Read the diff.

## Phase 1 — Niobe compliance

Review **added and modified lines first**, then the whole touched surface.

### IA and navigation

- [ ] No `.navIntraTool`, `.actionToolBar`, `.actionToolbar` in touched markup.
- [ ] R is a quiet back link/breadcrumb, not a secondary button in the action cluster or `…`.
- [ ] No “Return to list” button where the portal crumb or footer Cancel already gives one exit.
- [ ] A1 peer sections use `.sakai-tool-nav`; current item has `aria-current="page"`.
- [ ] A2 object views use `.sakai-segmented-control` or scoped object tabs.
- [ ] P0-S in the page header/empty state; P0-O in the object header; P0-F in the form footer;
      P0-B in the selection bar. No Save/Submit or bulk in the page header.
- [ ] P1 max 1, P2 max 2, P3/P4 in `…`.
- [ ] No count-based `utilityCount`/`--collapsed`; priorities + container tiers.
- [ ] No empty `…`; no duplicate items between the header and the panel.
- [ ] Nested tools have their own H1, A1 and R to the parent; parent cluster hidden.
- [ ] Every non-home surface has one obvious exit.
- [ ] No duplicate tool/view title; the H1 names the current view.

### CSS and tokens

- [ ] No `!important` in touched Niobe rules.
- [ ] No visual `style="…"` and no visual properties set from JavaScript.
- [ ] No hardcoded hex/rgb/hsl; L1/L2 tokens (L3 only if justified).
- [ ] No `Mrphs-*` in touched files; no new Morpheus/Trinity classes or variables.
- [ ] No Font Awesome (`fa`, `fa-*`, `font-awesome`).
- [ ] Front-end consumes `si si-*` only; no direct `bi bi-*` outside
      `library/src/skins/default/src/sass/base/_icons.scss`.
- [ ] Every `si-*` used in markup/JS has a map entry in `_icons.scss`; no missing icon.
- [ ] The generic icon block is alphabetical and only contains used names; tool names are separate.
- [ ] One canonical name per purpose (`add`, `edit`, `close`, `remove`, `trash`, `print`, `share`,
      `settings`, `attachment`, `filter`, `all-sites`, `arrow-*`, `chevron-*`); no synonym drift.
- [ ] No raw Bootstrap Icons glyph codepoints in `content:` for touched UI; use `si si-*`.
- [ ] Bootstrap is used for components only (`modal`, `offcanvas`, `collapse`, `dropdown`) and
      behind `sakai-*` where a shared primitive exists; no raw Bootstrap look in new work.
- [ ] No Bootstrap layout/spacing utilities in edited markup (`d-flex`, `d-md-none`,
      `align-items-*`, `justify-content-*`, `ms-*`, `me-*`, `p-*`, `gap-*`, `w-100`, `flex-*`, …).
- [ ] Tool layout uses `@container sakai-tool`, not viewport media queries inside the tool.
- [ ] No tool-local copy of a shared `sakai-*` primitive.
- [ ] Responsive tiers implemented; long labels/translations do not overflow.
- [ ] No general FAB; if one exists, it is the narrow, content-light niche and not a duplicate P0.
- [ ] No 2–3 s attention animation; `prefers-reduced-motion` respected.

### Design language and foundations

- [ ] Typography uses role tokens (`--sakai-text-*`), not raw `font-size`, `line-height` or
      `font-weight` values.
- [ ] No external font imports; the font family is tokenized and self-hosted/system.
- [ ] Spacing uses `--sakai-space-*` and semantic aliases; no raw px/rem for padding, margin or gap
      unless it is documented geometry.
- [ ] Color uses semantic roles (`--sakai-surface-*`, `--sakai-text-*`, `--sakai-border-*`,
      `--sakai-interactive-*`, `--sakai-status-*`), not numbered palette steps in new code.
- [ ] On-interactive text is contrast-tested against the brand; not hardcoded white.
- [ ] Radius, border, elevation, z-index, focus ring, icon size and motion use tokens.
- [ ] Interaction states are defined: rest, hover, active, focus, selected, disabled, loading,
      error, success, read-only, dirty/unsaved.
- [ ] Status is text/icon + text, never color-only.
- [ ] Density is comfortable or compact; no third density invented by a tool.
- [ ] Content follows the voice rules: sentence case, verbs for actions, empty state with action,
      error with next step, confirmation names the object.
- [ ] Theming stays inside L0; no L2/L3 per-tool overrides, no arbitrary skin CSS.
- [ ] `library/docs/sakai-ui-foundations.md` and `sakai-ui-tokens.md` still describe the code.

### Components, tables, forms, states

- [ ] Buttons use `.sakai-btn` / `-primary` / `-secondary` / `-ghost` / `-icon`.
- [ ] Actions use `.sakai-actions` only for P0-F/P0-B or inline section actions, not as a universal
      `navIntraTool` replacement.
- [ ] Tables use `.sakai-table`, `--stack`, `__primary`, `__nowrap`, `data-label`, row `…` menus,
      toolbar (D), empty state, pager and bulk actions.
- [ ] Forms use `.sakai-form-section` / `__title`, `.sakai-form-field`, `.sakai-form-label`
      (+ `.required`), `.sakai-form-control`, `.sakai-form-choice`, `.sakai-form-choice-group`
      (+ `--scroll`), `.sakai-form-help`, `.sakai-form-error`.
- [ ] No `.sakai-form-group`, `instruction`, `reqStarInline`, native `<select multiple>`.
- [ ] Banners use `.sakai-banner--info|success|warn|error`, not `sak-banner-*` or `alertMessage`.
- [ ] Overflow menus use `.sakai-overflow-menu` and the shared positioning script.
- [ ] Permissions use the shared matrix; no tool-local duplicate.

### Accessibility, JS, i18n, print

- [ ] Keyboard-only pass: A1, R, P0, P1/P2, `…`, row actions.
- [ ] Visible `:focus-visible`; no focus traps.
- [ ] Accessible names on icon-only controls; no `title`-only names.
- [ ] Honest roles; no fake `menu`/`menubar` without a keyboard model.
- [ ] `aria-current`/`aria-selected`/`aria-expanded` are correct and not contradictory.
- [ ] Status/counts include text.
- [ ] No new jQuery; no global side channels; no visual mutations from JS.
- [ ] Existing form ids, CSRF fields, hidden inputs and JS hooks preserved.
- [ ] Bundle keys exist; no hardcoded UI strings; locale/timezone resolved by Sakai.
- [ ] `.sakai-no-print` on chrome that must not print.

## Phase 2 — Legacy and dead-code sweep

Run these searches on the touched files first, then on the tool's whole surface. Use the diff to
separate new/touched legacy from pre-existing legacy.

```bash
grep -rn "navIntraTool\|actionToolBar\|actionToolbar" <files>
grep -rn "Mrphs-\|Morpheus\|Trinity\|--Mrphs\|--morpheus\|--trinity" <files>
grep -rn "fa-\|font-awesome" <files>
grep -rn "!important" <files>
grep -rn "style=" <files>
grep -rn "d-flex\|d-block\|d-none\|mt-\|mb-\|ms-\|me-\|p-\|px-\|py-\|gap-\|w-100\|h-100\|justify-content-\|align-items-\|flex-" <files>
grep -rn "alertMessage\|instruction\|reqStarInline\|sakai-form-group\|sakai-table-toolBar\|sakai-table-filterContainer" <files>
```

Raw design values in touched Niobe files are also a finding:

```bash
grep -rn "font-size:\s*[0-9]\|font-weight:\s*[0-9]\|line-height:\s*[0-9]" <changed scss/templates>
grep -rn "padding:\s*[0-9]\|margin:\s*[0-9]\|gap:\s*[0-9]" <changed scss/templates>
grep -rn "border-radius:\s*[0-9]\|box-shadow:\s*[0-9]\|transition:.*[0-9]\|z-index:\s*[0-9]" <changed scss>
grep -rn "#[0-9a-fA-F]\{3,6\}\|rgba\?(" <changed scss/templates>
```

Classify each as a token that should exist, a documented geometry exception, or legacy.

For each hit, classify:

- **new legacy** — added or touched by this refactor: must be fixed now;
- **tool-owned legacy** — can be removed now if no other consumer;
- **shared legacy** — still used by other tools/modules: record and defer.

### Unused classes and CSS variables

1. For every class removed from markup, check all consumers:
   `grep -rn "class-name" --exclude-dir=target --exclude-dir=node_modules .`
   Include JS strings, Java, Velocity, JSP, Thymeleaf, RSF and Lit.
2. For every CSS variable, check definitions and references:
   `grep -rn -- "--variable-name" ...`
3. A selector/variable with zero references outside its definition is a **removal candidate**.
4. A shared selector/variable with other consumers is **not removable**; add it to the ledger.
5. Check `_index.scss`, `tool.scss`, bundle entry points and per-tool imports for dead files.
6. Do not delete a shared selector just because one tool stopped using it.

### Unused JS, templates, i18n and assets

- JS functions, IDs, event handlers and bundle entries no longer referenced.
- Templates/includes no longer included by any page.
- Bundle keys no longer referenced (check all bundles and formatted keys).
- Images/icons no longer referenced.
- Dead CSS files or imports.
- Duplicate selectors or rules after the refactor.

### Legacy ledger

Produce a ledger for everything that cannot be removed yet:

| Symbol / file | Type | References | Consumers | Owner | Removable now? | Condition / follow-up |
|---|---|---|---|---|---|---|
| `--Mrphs-…` | CSS var | 12 | portal, tool X | portal | no | remove when tool X migrates |
| `.navIntraTool` | class | 40 | tools A, B | migration | no | per-tool refactor |
| `fa-…` | icon | 3 | tool C | tool C | yes | remove in this refactor |

The ledger is the roadmap for “Niobe in all its splendour”: it tells us what is left and what
blocks its removal.

## Phase 3 — Behaviour and diff review

- [ ] No conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`).
- [ ] No debug code, `console.log`, commented-out blocks, TODO/FIXME added by the refactor.
- [ ] No obvious, redundant or conversational comments added (section banners, file-purpose headers, line-by-line “what” comments). Comments only for non-obvious business rules, workarounds or critical warnings.
- [ ] No accidental deletion of business logic, validation, permissions or persistence.
- [ ] URLs, action names, form ids, CSRF fields, hidden inputs and JS hooks unchanged unless
      explicitly approved.
- [ ] Permissions still hide/disable the same actions.
- [ ] Workflow order and site copy/import semantics unchanged.
- [ ] Tests updated, not weakened or skipped; no mock of the tool under test.
- [ ] No unrelated tool changes in the diff.
- [ ] `git diff --check` is clean.

## Phase 4 — Verification

Run what the change requires:

```bash
export PLAYWRIGHT_BASE_URL=http://localhost:8080
mvn -P e2e -Dtest=<test-class> test
```

- Playwright: changed surfaces, roles, compact/medium/wide containers, keyboard/axe.
- Module build/tests for Java changes.
- `npm run lint` / `npm run bundle` if frontend JS/SCSS changed.
- Light, dark, L0 brand, print, long labels.
- If the server is unavailable, mark browser verification as **blocked** and list the flows.

Do not claim a check you did not run.

## Phase 5 — Report

Write a report with:

1. **Verdict:** pass / pass with findings / blocked.
2. **Scope:** branch, base SHA, commit range, tool(s), files.
3. **Findings table:**

| Severity | Category | File:line | Evidence | Impact | Fix |
|---|---|---|---|---|---|
| blocker/major/minor/nit | nav/css/component/a11y/js/i18n/test/docs/legacy | | | | |

4. **Niobe checklist:** pass/fail per section, with evidence.
5. **Legacy ledger:** removable now vs deferred, with consumers.
6. **Unused assets:** classes, variables, JS, templates, i18n, images.
7. **Behaviour risks:** anything that could change URLs, permissions, persistence or flows.
8. **Docs accuracy:** does `<tool>-reference.md` match the code? Is the roadmap updated?
9. **Tests run / blocked.**
10. **Recommended remediation order:** blockers → major → minor → nits; include exact files.

Severity guide:

- **Blocker:** breaks a flow, permission, data, accessibility baseline, or leaves new legacy that
  violates the contract.
- **Major:** wrong zone/priority, missing R/P0, duplicate exit, broken responsive overflow, unreadable
  contrast, missing test for a changed surface.
- **Minor:** inconsistent label/icon, missing doc detail, dead CSS selector.
- **Nit:** formatting, ordering, wording.

## Fix mode (only if the user says “fix” or “apply”)

1. Work findings in severity order.
2. Fix only the audited scope; do not start unrelated refactors.
3. Preserve behaviour and tests.
4. Re-run the relevant checks after each fix.
5. Update the report and the tool reference.
6. Do not remove shared legacy while other consumers exist; update the ledger instead.

## Definition of done

- [ ] Diff scope and SHAs recorded.
- [ ] Niobe checklist complete with evidence.
- [ ] New legacy fixed or reported as blocker.
- [ ] Tool-owned legacy removed or explicitly deferred.
- [ ] Shared legacy recorded in the ledger with consumers and removal condition.
- [ ] Unused classes/variables/JS/templates/i18n/assets listed with reference counts.
- [ ] Behaviour/permissions/URLs/persistence verified.
- [ ] Tests run or blocked with reasons.
- [ ] Docs accuracy checked.
- [ ] Report written; no product code changed in audit mode.

## Appendix A — Report template

```markdown
# Niobe audit — {{TOOL_NAME or branch}}

- Branch:
- Base ref / merge base:
- Commit range:
- Audit mode: report only / fix

## Verdict

## Findings

| Severity | Category | File:line | Evidence | Impact | Fix |
|---|---|---|---|---|---|

## Niobe checklist

## Legacy ledger

| Symbol/file | Type | References | Consumers | Removable now? | Follow-up |
|---|---|---|---|---|---|

## Unused assets

## Behaviour risks

## Docs accuracy

## Tests run / blocked

## Remediation order
```

## Appendix B — Quick commands

```bash
git status --short
git diff --check
git merge-base HEAD <BASE_REF>
git diff --name-status <merge-base>...HEAD
git diff --stat <merge-base>...HEAD
git log --oneline <merge-base>..HEAD
git diff <merge-base>...HEAD -- <path>
```
