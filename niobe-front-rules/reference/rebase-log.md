# Niobe rebase log

## 2026-11-06 — master @ 5dc84ab5588662e202509cea3a6f5d3360a9da2d

- **Previous HEAD / backup branch:** `ae7be22bf8dc58b12023a6ea666881e3e5ba3f99` /
  `niobe-backup-20261106-0923` (older safety branch: `niobe-backup-9commits`)
- **Rebase result HEAD:** `ef5ff9374aea1e22a8e505fde88af8122b1e3185`
- **Branch tip after test hooks and this log:** `a130be8e4e3` + docs commit (same branch)
- **Target commits replayed:** 31 (`3e38edd6..5dc84ab5`)
- **Niobe commits:** 52 preserved, byte-identical except the portal and polls commits below,
  plus one follow-up commit for test hooks (`a130be8e4e3`).

### Conflicts resolved

1. `e2e-tests/src/test/java/org/sakaiproject/e2e/support/SakaiHelper.java` (`b20ff8ed399`,
   portal navigation rebuild).
   - Target (master) waited for `LoadState.LOAD` and expanded a saved collapsed sidebar
     (`#sidebar-collapse-button[data-portal-sidebar-collapsed='true']`, PUT
     `sidebarCollapsed=false`); it also expanded the legacy
     `li.site-list-item.is-current-site` group.
   - Niobe replaced the Morpheus sidebar with `#current-site-pages .sakai-sidebar-page__link`
     and dropped the legacy group expander.
   - Resolution: kept the target's load wait and saved-sidebar expansion (Niobe's
     `SidebarCollapseButton` implements the same `data-portal-sidebar-collapsed` + PUT
     contract), dropped the legacy `li.site-list-item` expander, kept Niobe's sidebar
     selectors and all-sites launcher fallback. Required by the target's new
     `LoginTest.toolNavigationExpandsASavedCollapsedSidebar`.
2. `e2e-tests/src/test/java/org/sakaiproject/e2e/tests/PollTest.java` (`b77a816f2c9`, polls
   migration).
   - Target added `assertThat(page.locator("#poll-text")).hasValue(POLL_TITLE)` and replaced
     forced clicks with `sakai.submitForm(...)`.
   - Resolution: kept Niobe's `sakai-tool-header__actions` / `sakai-banner--success` /
     `.sakai-table-wrap` selectors and ported the target's `#poll-text` assertions; the
     `submitForm` changes merged automatically. `polls/.../edit.html` still binds
     `th:field="*{text}"` on `#poll-text`, so the target's
     `PollEditorController.unEscapeHtml` fix reaches the edit form.

### Silent conflicts found and fixed

1. **Notifications reply test used removed markup.** The target's new
   `webcomponents/.../sakai-notifications/test/sakai-notifications.test.js` case asserted
   legacy `.toast-body`. Updated to Niobe's `.sakai-notifications__item-body`; the case now
   passes.
2. **New Messages e2e test used removed menu/accordion markup.**
   `MessagesReplyNotificationTest` referenced `#messagesComposeMenuLink`, `#messages-accordion`,
   `li.toast` and `#pvtMsgDetail .breadCrumb`, and clicked a notification group toggle that is
   expanded by default in Niobe. Updated to `.sakai-messages__compose-link`, `#messages-group`,
   `li.sakai-notifications__item`, `.sakai-notifications__message` and a `#pvtMsgDetail`
   visibility check. Added a stable `sakai-messages__compose-link` class to the shared
   `pvtToolHeader.jsp` compose action (the `pvtMenu.jsp` span id no longer exists).
3. **Pre-existing e2e compile break.** `PortalPreferencesTest` used `@Test` without importing
   `org.junit.jupiter.api.Test` on the branch before the rebase; added the import so the
   target's new tests and the existing portal tests compile.
4. **Target behaviour preserved in merged files.** Verified every target-added line in the 14
   files both sides touched survives verbatim except the two selectors changed above. Confirmed
   the target's Messages reply event (`rrepMsg`, `EVENT_MESSAGES_RESPONSE`), Gradebook keyboard
   navigation, Lessons recursive subnav + `decrementQRCount`, Calendar midnight (`>=`) fixes,
   `LinkMigrationHelper` bracket default, MariaDB TLS notes and webapi 404 handler are all
   present.

### Legacy ledger changes (target-side additions)

| Symbol / file | Type | Consumer | Removable now? | Follow-up |
|---|---|---|---|---|
| `e2e-tests/.../AssignmentKeepDropCategoryTest.java` (`navIntraTool`) | class | Assignments (unmigrated) | no | Update with the Assignments refactor |
| `e2e-tests/.../LessonsQuestionPrerequisitesTest.java` (`.sak-banner-warn`) | class | Lessons (unmigrated) | no | Update with the Lessons refactor |
| `samigo/.../beginTakingAssessment.jsp` (`style="display: none;"` on `.sak-banner-error`) | inline style | Samigo (unmigrated) | no | Replace with a hidden class when Samigo migrates |
| `.sak-banner-*` in `library/.../base/_extendables.scss` | shared CSS | several unmigrated tools | no | Remove when the last consumer moves to `.sakai-banner--*` |

No new `navIntraTool`/Morpheus/Trinity/Font Awesome/direct `bi bi-*` was added in a migrated
tool, the shared skin, the portal or `library/docs`.

### Tests run

- `mvn -o compile` — `msgcntr/messageforums-app`, `msgcntr/messageforums-component-impl`,
  `polls/tool`, `lessonbuilder/api|hbm|components|tool`, `gradebookng/api|impl|tool`, `webapi`,
  `samigo/samigo-services`: **OK**
- `mvn -o test`:
  - `MessageForumsForumManagerTests` — 2/2
  - `GradingServiceTests` — 45/45
  - `StatisticsServiceTest` + `StatisticsServiceMatchingTest` — 30/30
  - `GlobalExceptionHandlerTest` — 2/2
  - `LinkMigrationHelperImplTest` — 7/7
  - `AssignmentServiceTest` — 76/76
- `mvn -o test-compile` in `e2e-tests`: **OK**
- Web components (`npx wtr`): calendar, notifications and rubrics — **22 passed, 1 failed**.
  The failure is the pre-existing axe failure in `sakai-notifications.test.js` “renders
  correctly” (`sakai-user-photo` has no accessible name); the same failure was recorded before
  the rebase.
- `npm run lint` (webcomponents): **OK**
- `git diff --check`, conflict-marker scan, `node --check` on the merged Gradebook and
  Video training scripts: **OK**

### Blocked

- Playwright: no Sakai server on `http://localhost:8080` (HTTP 000). Flows to run when a server
  is available:
  - Login collapsed-sidebar navigation (`LoginTest`)
  - Messages reply notification + reply/reply-all (`MessagesReplyNotificationTest`, `MessagesTest`)
  - Polls create/bulk/limits (`PollTest`)
  - Gradebook keyboard editing (`GradebookFirstKeystrokeTest`, `GradebookTest`)
  - Lessons question prerequisites/responses (`LessonsQuestionPrerequisitesTest`,
    `LessonsQuestionResponseTest`)
  - Calendar recurrence widget (`CalendarRecurrenceWidgetTest`)
  - Video training publish AJAX (`VideoTrainingTest`)
  - Samigo evaluation search/cancellation (`SamigoEvaluationSearchTest`,
    `SamigoCancellationCategoryTest`)
  - PaSystem banner icons (`PaSystemTest`)

### Follow-ups

- Run the Playwright flows above before merging.
- Keep the backup branch until the rebase is confirmed on a running server.

## 2026-11-11 — master @ af576e8b4d3

- **Previous HEAD / backup branch:** `d4ac330e944` / `niobe-backup-20261111-1909`
  (aborted partial attempt kept as `niobe-rebase-wip-partial`; delete once the rebase is accepted)
- **Rebase result HEAD:** `0230d6769ae` (branch `niobe-rebase`, not pushed)
- **Target commits replayed:** 32 (`5dc84ab5..af576e8b4d3`)
- **Niobe commits:** 20 replayed; `git diff --check` reports the same 32 whitespace findings as the
  backup on Niobe-authored lines (pre-existing, not fixed here).
- **Push:** not done; pending approval and browser verification.

### Conflicts resolved

1. `help/.../TutorialMessages_es.properties` (`Niobe: sakai icons`): kept master's text, applied
   Niobe's `si si-chevron-right` icon.
2. `webcomponents/.../sakai-calendar/src/calendar-styles.js` (`Niobe: calendar widget`): kept
   master's SAK-53095 outline for selected days, which is target-owned behaviour and asserted by
   `sakai-calendar.test.js`. Niobe's `--sakai-calendar-selected-*` tokens are now unused.
3. `webcomponents/bundle/.../coursecard_es.properties` (`Niobe: dashboard`): union of keys.
4. `polls/api/.../polls_es.properties` (`Niobe: polls`): master's translations kept, Niobe's new keys
   added.
5. **Recipient pickers** in `compose.jsp`, `pvtMsgForward.jsp`, `pvtMsgReply.jsp`,
   `pvtMsgReplyAll.jsp`, `messages.js` (`Niobe: messages`). Decision: master's `sakai-user-picker`
   (SAK-53097) wins. Niobe's markup and bcc toggle are kept; the select2/`changeSelect`/
   `addTagSelector`/`handleSelectionChange`/`updateClearButtons` logic and the per-list clear links
   are removed; `bindRecipientPicker` binds each list; `clearSelection` dispatches `change`; the Bcc
   listbox title is `pvt_bcc`.
6. `msgcntr/.../css/messages.css` (`Niobe: messages`/`NEW! Forums`): master's select2 rule and
   Niobe's `.composeFormTable` rule are both dead; the file is deleted as in Niobe's final tree.
   The `messages.css` links were already removed in the Niobe forums commit.
7. `e2e-tests/.../MessagesTest.java`: Niobe's `.sakai-messages__compose-link` hook plus master's
   `waitForPortalFocus()`.
8. `sitestats/.../Messages_es.properties` (`Niobe: statistics`): Niobe removed the trailing colons
   from these labels in English and Spanish, so Spanish follows Niobe. Master's translation
   `Todo` is kept for the item-type "All" option.

### Silent conflicts found and fixed

1. **Target E2E selectors for removed markup.** `MessagesTest`, `MessagesSearchTest`, `TagsTest`
   used `#messagesComposeMenuLink` (removed by Niobe). Changed to `.sakai-messages__compose-link`.
2. **Target Polls E2E used `.navIntraTool`** (`PollsSearchTest.createItem`). Changed to the Niobe
   header action container `.sakai-tool-header__actions`.
3. **Lessons `advanced-content-items` (SAK-46792).** Master's `rsf:id` on Niobe's panel was
   auto-merged. The `UIOutput.make` call in `ShowPageProducer` only renders for non-student
   pages, so the panel stays hidden for students. Verified present in the rebased template.
4. **Target-added lines from the overlap list.** A line-presence check of every target-added
   and Niobe-added line in the 32 overlap files found no unexplained loss. The only misses are the
   select2/clear-link/`addTagSelector` removals above, the calendar selected-day colours, and the
   sitestats/TutorialMessages wording changes listed above.

### Follow-ups (not blocking the rebase)

- **Playwright not run.** No Sakai server on `localhost:8080`. Flows to run before the push:
  - Messages: compose (To/Bcc add, remove, clear all), reply, reply-all and forward recipient
    pickers, draft save/restore (`MessagesTest`).
  - Polls: create from the header Add action (`PollsSearchTest`).
  - Calendar: selected and has-events day styles.
  - Lessons: student page advanced panel hidden; search results.
  - Statistics overview filter labels (Spanish).
- **Pre-existing failures** (same result on the backup): `sakai-notifications` renders
  correctly (axe `aria-command-name` on `.sakai-notifications__photo-img`, `role="button"` with no
  name) and `sakai-permissions` renders correctly (axe `button-name` on empty `aria-label`). Both
  are Niobe code. Frontend suite: 394 passed, 2 failed.
- **Dead tokens:** `--sakai-calendar-selected-bg-color` / `--sakai-calendar-selected-color` in
  `_legacy-light.scss` and `_dark.scss` have no consumers now.
- **Legacy kept in Lessons** (already in the backup, not introduced here): `d-flex`,
  `align-items-stretch`, `w-100` on the panels in `ShowPage.html` (around lines 268, 309, 377).
- **Unmigrated tools, target legacy:** Assignments `w-100` in the student submission view; Samigo
  `style=` on tag containers; Gradebook `mb-*`/`d-flex` in shortcut captions. Recorded, not fixed.
- **`messages.css`** deletion is staged as part of the rebase; the file is gone from the tree.

### Verification

- `mvn -o -Pe2e -pl e2e-tests test-compile`: passed (includes the Checkstyle `var` rule).
- `mvn -o -pl lessonbuilder/components compile`: passed.
- `mvn -o -pl msgcntr/messageforums-app compile`: passed.
- Frontend `npx wtr` (88 files): 394 passed, 2 failed (the pre-existing failures above).
  `sakai-calendar.test.js` 4/4, including the SAK-53095 outline assertion.
- Playwright: blocked (no server).
