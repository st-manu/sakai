# Niobe front rules (working docs)

Temporary notes for the Niobe design system, portal chrome, and tool migration.

**Current state:** the navigation model is settled (R/A1/A2/A3/P0/P1–P4/D/M + zones), and the
design foundation is implemented (primitives, semantic roles, type/spacing/motion/focus, central icon
map). The four reference refactors (Polls, Announcements, Messages, Statistics) are navigation-good
drafts; they need a surface parity pass before the pattern is considered final.

**Workflow:**

1. Refactor a tool with `tool-navigation-refactor-prompt.md`.
2. Audit the result with `niobe-refactor-audit-prompt.md`.
3. Rebase onto the target with `niobe-rebase-prompt.md` when needed.
4. Squash the Niobe commits with `niobe-commit-organizer-prompt.md`.

**Keep in the product repo (permanent):**
- `library/docs/sakai-ui-foundations.md`
- `library/docs/sakai-ui-tokens.md`
- `library/docs/sakai-ui-chrome.md`
- `library/docs/sakai-ui-icons.md`
- Agent / AI guidance: `AGENTS.md`, `.cursor/rules/frontend.mdc`

**Delete this folder** when the renovation is done (or when the roadmap below is no longer useful).
Before deleting it, promote the final navigation contract to `library/docs/sakai-ui-chrome.md` and
remove links to these temporary docs.

| File | Purpose |
|------|---------|
| [plan.md](plan.md) | Niobe vision, architecture principles, and delivery plan |
| [navigation-model.md](navigation-model.md) | Navigation audit: R/A1/A2/A3/P0/P1–P4/D/M roles, zones, failure patterns, responsive tiers, decision tree |
| [tool-navigation-refactor-prompt.md](tool-navigation-refactor-prompt.md) | Reusable full-tool prompt: discovery → target design + phase plan → phased execution → Playwright + docs. Only input: `TOOL_NAME`; everything else is discovered |
| [niobe-refactor-audit-prompt.md](niobe-refactor-audit-prompt.md) | Exhaustive post-refactor audit: Niobe compliance, legacy/dead-code sweep, legacy ledger, behaviour and docs |
| [niobe-rebase-prompt.md](niobe-rebase-prompt.md) | Rebase Niobe onto master/27.x: conflict rules, silent semantic conflicts, verification, rebase log |
| [niobe-commit-organizer-prompt.md](niobe-commit-organizer-prompt.md) | Squash Niobe commits by tool/function: `Niobe: <summary>`, single author, docs last |
| [sakai-ui-tool-migration.md](sakai-ui-tool-migration.md) | Tool-by-tool migration roadmap |
| [polls-reference.md](polls-reference.md) | First migrated tool (Thymeleaf) — A1/P0/P2/P3 + primitives checklist |
| [announcements-reference.md](announcements-reference.md) | Velocity reference — server menu → `sakai-*` actions |
| [sitestats-reference.md](sitestats-reference.md) | Multi-view Thymeleaf + shared Lit widgets |
| [messages-reference.md](messages-reference.md) | JSF private messages — header, list, detail and flow views |
| [screenshots/](screenshots/) | Playwright smoke captures (safe to delete anytime) |
