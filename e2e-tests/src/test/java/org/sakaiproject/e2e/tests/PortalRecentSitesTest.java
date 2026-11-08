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
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.microsoft.playwright.APIResponse;
import com.microsoft.playwright.Locator;
import com.microsoft.playwright.options.FormData;
import com.microsoft.playwright.options.RequestOptions;

import java.util.List;
import java.util.UUID;

import org.junit.jupiter.api.Test;
import org.sakaiproject.e2e.support.SakaiUiTestBase;

class PortalRecentSitesTest extends SakaiUiTestBase {

    @Test
    void recentSitesLiveInTheSitesLauncherInsteadOfTheSidebar() {
        String username = "portal-recent-" + UUID.randomUUID();

        sakai.login("admin");
        APIResponse created = page.request().post("/direct/user/new", RequestOptions.create().setForm(FormData.create()
            .set("eid", username).set("firstName", "Portal").set("lastName", "Recent")
            .set("email", username + "@example.com").set("type", "registered")
            .set("password", sakai.passwordFor(username))));
        try {
            assertTrue(created.ok(), "Unable to create isolated recent-test account: HTTP " + created.status());
        } finally {
            created.dispose();
        }

        try {
            sakai.login(username);
            String recentSite = sakai.createProject(username, List.of("sakai.announcements"));
            String currentSite = sakai.createProject(username, List.of("sakai.schedule"));
            String recentSiteId = sakai.siteIdFromUrl(recentSite);

            // createProject pins every site, so unpin it to keep it in the recent list.
            page.request().post("/portal/favorites/update", RequestOptions.create().setForm(FormData.create()
                .set("siteId", recentSiteId).set("pinned", "false")));

            page.navigate(recentSite);
            page.navigate(currentSite);

            assertThat(page.locator("#recent-site-list")).hasCount(0);

            page.locator("button[data-bs-target='#select-site-sidebar']:visible").first().click();

            Locator recentBadge = page.locator("#moresites-content [data-badge-group='recent'] .sakai-sites-launcher__badge")
                .filter(new Locator.FilterOptions().setHasText("Playwright Java Testing " + recentSiteId));
            assertThat(recentBadge).isVisible();

            Locator pin = recentBadge.locator(".sakai-sites-launcher__badge-pin");
            assertThat(pin).hasAttribute("data-pinned", "false");
        } finally {
            sakai.login("admin");
            page.request().delete("/direct/user/" + username);
        }
    }
}
