# Prompt — Niobe commit organizer

Run this after a tool/component refactor is complete and verified. Its job is to rewrite the Niobe
commit range into a small, meaningful set of commits — **one per tool/component** — plus a final
documentation commit.

**Commit format:** `Niobe: <summary>` — one line, no body, no description, no trailers.
**Author:** the user only, for every Niobe commit. Target/base commits keep their original authors.
**Documentation:** always the last commit.

---

## Inputs

| Key | Value |
|---|---|
| `TARGET_BRANCH` | `{{e.g. master / 27.x}}` |
| `AUTHOR_NAME` | `{{optional — default git config user.name}}` |
| `AUTHOR_EMAIL` | `{{optional — default git config user.email}}` |
| `DOCS_SUMMARY` | `{{optional — default docs}}` |

If `AUTHOR_NAME`/`AUTHOR_EMAIL` are empty, use the current git config. If the config is missing or
does not belong to the user, ask once.

## Mission

Rewrite **only the Niobe commit range on top of the target branch** so the branch ends with:

1. one commit per tool/component, e.g. `Niobe: polls`, `Niobe: login`, `Niobe: presence panel`,
   `Niobe: calendar widget`, `Niobe: announcements`;
2. one optional shared-foundation commit, e.g. `Niobe: core` or `Niobe: portal chrome`;
3. one final `Niobe: docs` commit.

Do not rewrite target/base commits. Do not squash unrelated tools together just to reduce the count.
Do not split one tool into many commits.

## Phase 0 — Preflight

1. Confirm the tree is clean: `git status --short`.
2. Confirm the branch is rebased on the target:
   `git log --oneline <TARGET>..HEAD`.
   The range must contain only Niobe commits. If it contains target commits, run the rebase prompt
   first.
3. Create a backup branch:
   `git branch niobe-backup-<YYYYMMDD-HHMM> HEAD`.
4. Record the current HEAD and backup name.
5. Run the relevant tests/build on the current tree. The final tree must be identical; if the
   baseline is broken, record it before rewriting history.

## Phase 1 — Inventory and grouping proposal (STOP)

### 1.1 Inventory

For every commit in `<TARGET>..HEAD`:

```bash
git log --reverse --format='%h%x09%an%x09%s' <TARGET>..HEAD
git show --stat --oneline <sha>
```

Record the files and the tool/component each commit belongs to. Use paths, bundle keys, templates and
module names, not the commit message alone.

### 1.2 Grouping rules

- **One commit per tool/component.** Examples:
  - `Niobe: polls`
  - `Niobe: announcements`
  - `Niobe: messages`
  - `Niobe: statistics`
  - `Niobe: login`
  - `Niobe: presence panel`
  - `Niobe: calendar widget`
  - `Niobe: site info`
  - `Niobe: portal chrome`
- **Shared foundation:** one `Niobe: core` commit for tokens, primitives, shared CSS/JS, or portal
  chrome that is not owned by one tool. Do not split it into dozens of micro-commits unless the user
  asks.
- **Order:** `Niobe: core` first (if it exists), then tool/component commits, then `Niobe: docs`
  last.
- **Tests:** the E2E/unit tests for a tool go in that tool's commit.
- **Documentation:** `niobe-front-rules/`, `library/docs/`, `AGENTS.md`, `.cursor/rules/` always go
  in the final `Niobe: docs` commit. Do not mix docs into tool commits.
- **Shared files:** if a file genuinely belongs to several groups, assign it to `core` or the tool
  that owns the primitive; document the decision. Split by hunk only when the file contains
  independent changes.
- **No merge commits** in the Niobe range. Flatten them into the owning group.

### 1.3 Proposal

Produce a table:

| Group | Commit message | Files | Source commits | Notes |
|---|---|---|---|---|
| polls | `Niobe: polls` | `polls/...`, `e2e-tests/.../PollTest.java` | abc123, def456 | |
| core | `Niobe: core` | `library/.../components`, `webcomponents/...` | ... | shared primitives |
| docs | `Niobe: docs` | `niobe-front-rules/`, `library/docs/` | ... | last |

State the expected final commit count. Stop and ask for approval before rewriting history.

## Phase 2 — Rewrite history

Choose the safest method for the shape of the range.

### Option A — Soft reset and recommit (preferred for regrouping)

This preserves the final tree exactly and gives full control over groups.

```bash
git reset --soft <TARGET>
git restore --staged .
```

Then, for each approved group:

```bash
git add <group paths>
GIT_COMMITTER_NAME="<AUTHOR_NAME>" GIT_COMMITTER_EMAIL="<AUTHOR_EMAIL>" \
  git commit --author="<AUTHOR_NAME> <AUTHOR_EMAIL>" -m "Niobe: <summary>"
```

- Stage only that group's files. Use `git add -p` for a file shared by two groups.
- Do not include docs in a tool commit.
- Do not include another tool's files.
- Commit message is exactly one line; no `-m` body, no `--signoff`, no trailers.

### Option B — Interactive rebase (preferred when commits are already grouped)

```bash
git rebase -i <TARGET>
```

Use `reword` for the message, `squash`/`fixup` for same-group commits, and reorder by group. Then
amend author if needed:

```bash
git commit --amend --no-edit --author="<AUTHOR_NAME> <AUTHOR_EMAIL>"
```

Do not use `drop` unless the change is genuinely gone; verify the tree afterwards.

### Message rules

- Exactly: `Niobe: <summary>`.
- Lowercase summary, no trailing period.
- No body, no bullet list, no “Generated with …”, no co-author trailers.
- The summary names the tool/component, not the phase: `Niobe: polls`, not `Niobe: refactor polls
  navigation and tables`.
- Documentation commit: `Niobe: docs` (or the approved `DOCS_SUMMARY`).

### Author rules

- Every Niobe commit: author and committer = the user.
- Target/base commits: leave their authors unchanged.
- Verify:
  `git log --format='%h|%an <%ae>|%cn <%ce>|%s' <TARGET>..HEAD`.

## Phase 3 — Verification

### 3.1 Tree identity

The rewritten history must produce exactly the same tree as the backup:

```bash
git diff <backup-branch> HEAD
```

It must be empty. If not, stop and restore the backup.

### 3.2 Commit hygiene

- `git log --oneline <TARGET>..HEAD` — one commit per approved group.
- `git log -1 --format=%s` — `Niobe: docs` (if docs exist).
- `git log --format='%s%n%b' <TARGET>..HEAD` — every subject starts with `Niobe: `; every body is
  empty.
- `git log --format='%an <%ae>' <TARGET>..HEAD` — all Niobe commits by the user.
- `git log --merges <TARGET>..HEAD` — no merge commits.
- `git show --stat <sha>` — each commit only touches its group.
- `git status --short` — clean.

### 3.3 Tests

Run the same checks as the baseline on the final tree. The tree is identical, but confirm:
module build/tests, Playwright for the touched tools, `git diff --check`.

### 3.4 Docs last

If documentation changed, the tip must be `Niobe: docs`. If there are no docs changes, say so and
skip the docs commit.

## Phase 4 — Push

Only after verification and explicit approval:

```bash
git push --force-with-lease <REMOTE> <branch>
```

- Never force push to the target branch.
- Never use plain `--force`.
- Keep the backup branch until the user confirms.
- If the branch is shared, coordinate before rewriting history.

## Failure handling

If anything goes wrong:

1. `git rebase --abort` if a rebase is in progress.
2. `git reset --hard <backup-branch>`.
3. Report the exact failure and the backup name.
4. Do not push a partially rewritten history.

## Examples

| Original commits | Final |
|---|---|
| `polls nav`, `polls table`, `polls forms`, `polls e2e` | `Niobe: polls` |
| `announcements header`, `announcements docs` | `Niobe: announcements` + `Niobe: docs` |
| `login chrome`, `login tokens` | `Niobe: login` |
| `presence panel`, `presence panel css` | `Niobe: presence panel` |
| `shared tokens`, `shared primitives`, `portal chrome` | `Niobe: core` |
| docs commits spread through the range | one final `Niobe: docs` |

## Definition of done

- [ ] Backup branch created and recorded.
- [ ] Niobe range confirmed on top of the target.
- [ ] Grouping table approved.
- [ ] One commit per tool/component; no mixed tools.
- [ ] Final `Niobe: docs` commit if docs changed.
- [ ] Every subject matches `Niobe: <summary>`; no bodies.
- [ ] Every Niobe commit authored/committed by the user.
- [ ] Target commits untouched.
- [ ] `git diff <backup> HEAD` empty.
- [ ] No merge commits.
- [ ] Tests/build re-run on the final tree.
- [ ] Force push with lease only after approval.

## Appendix — Commands

```bash
git status --short
git branch niobe-backup-$(date +%Y%m%d-%H%M) HEAD
git log --reverse --format='%h%x09%an%x09%s' <TARGET>..HEAD
git show --stat --oneline <sha>
git reset --soft <TARGET>
git restore --staged .
git add <group paths>
GIT_COMMITTER_NAME="<name>" GIT_COMMITTER_EMAIL="<email>" \
  git commit --author="<name> <email>" -m "Niobe: <summary>"
git diff <backup-branch> HEAD
git log --format='%h|%an <%ae>|%cn <%ce>|%s' <TARGET>..HEAD
git log --format='%s%n%b' <TARGET>..HEAD
git log --merges <TARGET>..HEAD
git push --force-with-lease origin <branch>
```
