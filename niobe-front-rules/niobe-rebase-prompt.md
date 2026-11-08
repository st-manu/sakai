# Prompt — Niobe rebase

Run this whenever the Niobe branch needs to be rebased onto the current target branch. Rebase brings
new code, bug fixes and tests; it also brings **silent semantic conflicts** where there is no text
conflict but the target introduced a pattern that contradicts Niobe. The rebase must preserve both
the target behaviour and the Niobe invariants.

**Rebase is not just conflict resolution. It is a semantic merge.**

---

## Inputs

| Key | Value |
|---|---|
| `TARGET_BRANCH` | `{{e.g. master / 27.x}}` |
| `REMOTE` | `{{optional — default origin}}` |

Everything else — Niobe invariants, changed files, tests, modules — is discovered from the
repository.

## Mission

Rebase the current Niobe branch onto `<REMOTE>/<TARGET_BRANCH>` without breaking:

- target behaviour, bug fixes, security and data changes;
- Niobe IA/navigation, surface composition, tokens, primitives and accessibility;
- tests, URLs, permissions and persistence.

After the rebase, the branch must contain all target changes **and** all Niobe changes, with no lost
hunk, no reintroduced legacy and no silent UI regression.

## Phase 0 — Preflight

### 0.1 Clean and back up

1. `git status --short` — the tree must be clean. If not, commit or stash with the user's approval.
2. Record the current HEAD and branch:
   `git rev-parse HEAD`, `git branch --show-current`.
3. Create a backup branch:
   `git branch niobe-backup-<YYYYMMDD-HHMM> HEAD`.
4. Record the backup name in the rebase log.

### 0.2 Fetch and inspect the target

1. `git fetch <REMOTE> <TARGET_BRANCH>`.
2. `TARGET=<REMOTE>/<TARGET_BRANCH>`; `BASE=$(git merge-base HEAD "$TARGET")`.
3. Inspect what is coming:
   - `git log --oneline "$BASE".."$TARGET"`;
   - `git diff --stat "$BASE".."$TARGET"`;
   - `git diff --name-status "$BASE".."$TARGET"`.
4. Identify target changes that touch files Niobe also changed. Those are the **silent conflict
   candidates** even if Git does not report a conflict.

### 0.3 Baseline

Run the relevant baseline before rebasing:

- module build/tests;
- Playwright smoke for the Niobe surfaces touched by the branch;
- `git diff --check`.

If the baseline already fails, record it. Do not blame the rebase for a pre-existing failure.

### 0.4 Read the invariants

Re-read:

- `niobe-front-rules/navigation-model.md`
- `library/docs/sakai-ui-chrome.md`
- `niobe-front-rules/<tool>-reference.md` for every tool in the branch
- `AGENTS.md` and `.cursor/rules/frontend.mdc`

You need them to resolve conflicts semantically, not just textually.

## Phase 1 — Rebase

### 1.1 Start

```bash
git rebase "$TARGET"
```

Optional, for repeated conflicts:

```bash
git config rerere.enabled true
```

### 1.2 Conflict resolution rules

For every conflict:

1. Read **both** sides. Do not resolve from the diff alone.
2. Identify the target intent: bug fix, new field, new permission, new route, new test, rename,
   deletion.
3. Identify the Niobe intent: R/A1/A2/P0/zones, tokens, primitives, container queries, accessibility.
4. Combine both. In general:
   - **target wins on behaviour**: data, permissions, validation, security, workflow, URLs.
   - **Niobe wins on presentation and IA**: markup structure, classes, tokens, navigation, action
     zones, responsive tiers.
   - **if target adds a new UI element**, apply Niobe to it rather than preserving the old pattern.
   - **if target removes or renames a file**, update every Niobe reference, import, test and doc.
5. Never use `git checkout --ours` / `--theirs` on a whole file unless you have verified the file has
   only one side's intent. Never accept a conflict marker.
6. After resolving: `git add <files>`, run the targeted check, `git rebase --continue`.
7. If a conflict is too complex or ambiguous, `git rebase --abort`, document the exact conflict and
   ask. Do not leave a half-rebased tree.

### 1.3 Checks during the rebase

After each resolved commit, at minimum:

- `git diff --check`;
- search the resolved files for conflict markers;
- compile/test the module if the commit changes Java/JS/SCSS;
- run the affected Playwright flow if the commit changes a surface.

Do not wait until the end to discover a broken commit.

## Phase 2 — Silent semantic conflicts

Git will not flag these. Audit them explicitly.

### 2.1 Target changes in Niobe-touched files

For every target commit that touches a file Niobe refactored:

```bash
git log -p "$BASE".."$TARGET" -- <file>
```

Check whether the target added:

- a new navigation item or menu entry (did it get an R/A1/A2/P0 role?);
- a new form field or action (did it land in the right zone?);
- a new table column or row action (does it use `sakai-table`?);
- a new permission or role gate (is it preserved?);
- a new URL, route or modal (does it have an exit?);
- a new CSS rule/variable (does it use Niobe tokens?);
- a new test selector for old markup (update it to Niobe or add a stable hook).

### 2.2 New legacy introduced by the target

Run on the **target-side added lines** and on the resolved files:

```bash
grep -rn "navIntraTool\|actionToolBar\|actionToolbar" <files>
grep -rn "Mrphs-\|Morpheus\|Trinity\|--Mrphs\|--morpheus\|--trinity" <files>
grep -rn "fa-\|font-awesome" <files>
grep -rn "!important\|style=" <files>
grep -rn "d-flex\|d-block\|d-none\|mt-\|mb-\|ms-\|me-\|p-\|px-\|py-\|gap-\|w-100\|h-100\|justify-content-\|align-items-\|flex-" <files>
grep -rn "alertMessage\|instruction\|reqStarInline\|sakai-form-group\|sakai-table-toolBar\|sakai-table-filterContainer" <files>
```

Classify:

- target changes in **unmigrated tools**: acceptable legacy for now; record in the ledger.
- target changes in **migrated tools**: must follow Niobe now; fix or record a blocker.
- new legacy in a shared file used by migrated tools: inspect and fix.

### 2.3 Common silent regressions

- Target fixes a bug in a template line Niobe rewrote; the fix is lost because there was no conflict.
- Target adds a field/action in a block Niobe replaced; the new item is missing.
- Target renames a CSS variable/class; Niobe still references the old name.
- Target adds an i18n key; Niobe renamed the key or removed its usage.
- Target adds a test for `navIntraTool`; the test passes only because the old markup survived.
- Target changes a tool id/module path; Niobe docs and imports point to the old path.
- Target adds a table column; the DataTables column index or `data-label` mapping is now wrong.
- Target adds a permission gate; the Niobe action is visible to the wrong role.
- Target adds a modal/offcanvas; it lacks the Niobe close/return contract.
- Target adds a JS bundle entry; the old bundle still loads the removed code.
- Target adds a direct `bi bi-*` icon; the front-end must use `si si-*` and the icon must be in the
  central map.

### 2.4 Shared files

For shared files (portal chrome, skin, `VM_chef_library.vm`, `sakai-table`, `sakai-actions`,
`AGENTS.md`, docs), check every consumer. Do not delete or change a shared symbol based on one tool.

## Phase 3 — Verification

### 3.1 Compare the rebase

- `git range-diff <old-base>..<old-head> <new-base>..HEAD` to see how the Niobe commits changed.
  Save `<old-base>`/`<old-head>` before the rebase; `<new-base>` is the new merge base.
- `git diff "$TARGET"...HEAD` to review the Niobe delta on top of the target.
- `git log --oneline "$TARGET"..HEAD` to confirm the Niobe commits are intact.

### 3.2 Build and tests

- Compile/test every module touched by the rebase.
- Run Playwright for the Niobe surfaces affected by target changes:
  - navigation and R;
  - list/table/toolbar;
  - forms;
  - nested tools;
  - permissions by role;
  - compact/medium/wide containers.
- Run the **audit prompt** (`niobe-refactor-audit-prompt.md`) on the rebased branch.
- Check `git diff --check`; no conflict markers.
- Check no duplicate imports, functions, CSS rules, i18n keys or bundle entries.
- Check no lost target bug fix: compare target-side commits with the resolved files.

If the server is unavailable, mark browser verification as blocked and list the flows. Do not force
push on unverified UI changes.

### 3.3 Behaviour regression

- URLs still work.
- Permissions still gate the same actions.
- Forms still validate and persist.
- JS hooks, DataTables and file pickers still work.
- No new console errors.
- Print, dark mode, brand tokens, long labels.

## Phase 4 — Documentation

Update `niobe-front-rules/rebase-log.md` (create it if missing):

```markdown
## <YYYY-MM-DD> — <TARGET_BRANCH> @ <target SHA>

- Previous HEAD / backup branch:
- New HEAD:
- Conflicts resolved:
- Silent conflicts found and fixed:
- Target changes that need a follow-up:
- Tests run / blocked:
- Legacy ledger changes:
```

Update the tool reference if the target changed a surface, action, permission or test. Update the
legacy ledger if the target introduced or removed legacy.

## Phase 5 — Push

Only after verification and explicit approval:

```bash
git push --force-with-lease <REMOTE> <branch>
```

- Never force push to the target branch.
- Never use plain `--force`.
- If the branch is shared, coordinate before rewriting history.
- Keep the backup branch until the user confirms the rebase is good.

## Conflict resolution matrix

| Situation | Target | Niobe | Resolution |
|---|---|---|---|
| Business logic, validation, security | wins | — | Take target; re-apply Niobe markup around it. |
| Data model, permissions, workflow | wins | — | Take target; keep Niobe UI and action zones. |
| Markup structure, classes, tokens | — | wins | Take Niobe; port target's new fields/actions into it. |
| New view/action/form from target | behaviour wins | pattern wins | Add it with the Niobe role and zone; test it. |
| Target removes/renames a file | wins | — | Update Niobe imports, tests, docs, references. |
| Target adds legacy in an unmigrated tool | wins for now | — | Keep, record in ledger; do not block the rebase. |
| Target adds legacy in a migrated tool | — | wins | Fix now or record a blocker; do not ship new legacy. |
| Target adds a test for old markup | behaviour wins | pattern wins | Update the test to the Niobe selector or add a stable hook. |

## Definition of done

- [ ] Backup branch exists; HEAD recorded.
- [ ] Target fetched; merge base and target diff inspected.
- [ ] Baseline recorded before the rebase.
- [ ] Rebase completed with no conflict markers.
- [ ] No target bug fix, field, permission or test lost.
- [ ] No new `navIntraTool`/Morpheus/Trinity/FA/Bootstrap-utility legacy in migrated tools.
- [ ] Niobe R/A1/A2/P0/zones/tokens/responsive preserved.
- [ ] Audit prompt run on the rebased diff.
- [ ] Build/tests/Playwright run or blocked with reasons.
- [ ] Rebase log updated.
- [ ] Force push only with `--force-with-lease` and approval.

## Appendix — Commands

```bash
git status --short
git branch --show-current
git rev-parse HEAD
git branch niobe-backup-$(date +%Y%m%d-%H%M) HEAD
git fetch origin <TARGET_BRANCH>
BASE=$(git merge-base HEAD origin/<TARGET_BRANCH>)
git log --oneline "$BASE"..origin/<TARGET_BRANCH>
git diff --stat "$BASE"..origin/<TARGET_BRANCH>
git diff --name-status "$BASE"..origin/<TARGET_BRANCH>
git rebase origin/<TARGET_BRANCH>
git range-diff <old-base>..<old-head> <new-base>..HEAD
git diff --check
git push --force-with-lease origin <branch>
```
