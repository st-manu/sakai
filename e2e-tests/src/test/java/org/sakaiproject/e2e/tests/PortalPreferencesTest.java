/*
 * Copyright (c) 2003-2026 The Apereo Foundation
 *
 * Licensed under the Educational Community License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *             http://opensource.org/licenses/ecl2
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.sakaiproject.e2e.tests;

import static com.microsoft.playwright.assertions.PlaywrightAssertions.assertThat;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.microsoft.playwright.APIResponse;
import com.microsoft.playwright.Clock;
import com.microsoft.playwright.Locator;
import com.microsoft.playwright.Page;
import com.microsoft.playwright.Request;
import com.microsoft.playwright.options.ColorScheme;
import com.microsoft.playwright.options.RequestOptions;
import com.microsoft.playwright.options.WaitUntilState;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.EnumSource;
import org.sakaiproject.e2e.support.SakaiUiTestBase;
import org.sakaiproject.e2e.support.SakaiHelper.TestUser;

class PortalPreferencesTest extends SakaiUiTestBase {

    private static final String THEME = "sakai:portal:theme";
    private static final String NAVIGATION = "sakai:portal:sitenav";

    @ParameterizedTest
    @EnumSource(value = ColorScheme.class, names = {"DARK", "LIGHT"})
    void themePreferenceSurvivesReload(ColorScheme osTheme) {
        page.emulateMedia(new Page.EmulateMediaOptions().setColorScheme(osTheme));
        String username = sakai.resolveUsername("student0152");
        sakai.login(username);
        String firstSite = sakai.createProject(username, List.of("sakai.announcements"));
        page.navigate(firstSite);
        Map<?, ?> originalTheme = preferences(THEME);
        List<Request> writes = new ArrayList<>();
        page.onRequest(request -> {
            if (request.url().contains("/direct/userPrefs/") && !"GET".equals(request.method())) {
                writes.add(request);
            }
        });
        try {
            savePreferences(THEME, Map.of("theme", "sakaiUserTheme-notSet"));
            writes.clear();

            page.navigate(firstSite);
            assertThat(page.locator("#current-site-pages")).isVisible();
            assertTrue(writes.isEmpty(), "Page loads must not issue preference mutations");

            page.locator("[data-bs-target='#sakai-account-panel']:visible").first().click();
            Locator themeSwitcher = page.locator("#sakai-dark-theme-switcher");
            assertThat(themeSwitcher).isVisible();
            writes.clear();
            page.waitForResponse(response -> response.url().contains("/" + THEME + "?theme="),
                themeSwitcher::click);
            String chosen = osTheme == ColorScheme.DARK ? "sakaiUserTheme-light" : "sakaiUserTheme-dark";
            assertEquals(chosen, preferences(THEME).get("theme"));
            assertEquals(1, writes.size(), "One explicit theme click must save exactly once");
            Map<String, Map<?, ?>> after = snapshot();
            page.reload(new Page.ReloadOptions().setWaitUntil(WaitUntilState.DOMCONTENTLOADED));
            assertThat(page.locator("html")).hasClass(Pattern.compile(".*" + chosen + ".*"));
            assertEquals(after, snapshot());
            assertEquals(1, writes.size(), "Reload must not save the chosen theme again");
        } finally {
            savePreferences(THEME, Map.of("theme", valueOr(originalTheme, "theme", "sakaiUserTheme-notSet")));
        }
    }

    @Test
    void immediatePinSaveCancelsPendingIndividualSave() {
        try (TestUser user = sakai.createUser("portal-pins")) {
            String username = user.username();
            sakai.login(username);
            String firstSite = sakai.createProject(username, List.of("sakai.announcements"));
            sakai.createProject(username, List.of("sakai.announcements", "sakai.schedule"));
            sakai.createProject(username, List.of("sakai.schedule"));
            sakai.gotoPath(firstSite);
            String siteId = sakai.siteIdFromUrl(firstSite);
            List<Object> expectedIds = new ArrayList<>((List<?>) page.evaluate(
                "async () => (await (await fetch('/portal/favorites/list')).json()).favoriteSiteIds"));
            page.locator("button[data-bs-target='#select-site-sidebar']:visible").first().click();
            Locator individualPin = page.locator("#select-site-sidebar .site-favorite-btn[data-site-id='" + siteId + "']");
            assertThat(individualPin).isVisible();
            assertThat(individualPin).hasAttribute("data-pinned-state", "pinned");
            List<Request> saves = new ArrayList<>();
            page.onRequest(request -> {
                if (request.url().contains("/portal/favorites/update") && "POST".equals(request.method())) {
                    saves.add(request);
                }
            });
            page.clock().install(new Clock.InstallOptions().setTime("2026-01-01T00:00:00Z"));
            page.clock().pauseAt("2026-01-01T00:01:00Z");
            individualPin.click();
            assertTrue(saves.isEmpty());

            expectedIds.remove(siteId);
            page.locator("#allsites-organize-favourites-tab").click();
            Locator last = page.locator("#organize-favorites-list .organize-favorite-item:visible").last();
            if (expectedIds.size() > 1) {
                Collections.swap(expectedIds, expectedIds.size() - 2, expectedIds.size() - 1);
            }
            page.waitForResponse(response -> response.url().contains("/portal/favorites/update"),
                () -> last.press("e"));

            page.clock().runFor(1000);
            assertEquals(1, saves.size(), "The immediate save must cancel the pending 500ms save");
            List<?> actualIds = (List<?>) page.evaluate(
                "async () => (await (await fetch('/portal/favorites/list')).json()).favoriteSiteIds");
            assertFalse(actualIds.contains(siteId), "Reordering must not pin the site just unpinned");
            assertEquals(expectedIds, actualIds, "The final pin order must be persisted");
            page.reload();
            List<?> reloadedIds = (List<?>) page.evaluate(
                "async () => (await (await fetch('/portal/favorites/list')).json()).favoriteSiteIds");
            assertEquals(expectedIds, reloadedIds, "Reload must retain the reordered pins");
        }
    }


    private Map<String, Map<?, ?>> snapshot() {
        return Map.of("theme", preferences(THEME), "navigation", preferences(NAVIGATION));
    }

    private Map<?, ?> preferences(String key) {
        return (Map<?, ?>) page.evaluate("""
            async key => {
              const response = await fetch(`/direct/userPrefs/key/${portal.user.id}/${key}.json`, { cache: 'no-store' });
              if (!response.ok) throw new Error(`Unable to read preferences: ${response.status}`);
              return (await response.json()).data;
            }
            """, key);
    }

    private void savePreferences(String key, Map<String, String> values) {
        page.evaluate("""
            async ({key, values}) => {
              const query = Object.entries(values).map(([name, value]) => `${name}=${encodeURIComponent(value)}`).join('&');
              const response = await fetch(`/direct/userPrefs/updateKey/${portal.user.id}/${key}?${query}`,
                { method: 'PUT' });
              if (!response.ok) throw new Error(`Unable to save preferences: ${response.status}`);
            }
            """, Map.of("key", key, "values", values));
    }

    private String valueOr(Map<?, ?> properties, String key, String fallback) {
        Object value = properties.get(key);
        return value == null ? fallback : value.toString();
    }
}
