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

import com.microsoft.playwright.Locator;
import com.microsoft.playwright.Page;
import com.microsoft.playwright.options.AriaRole;

import java.util.List;

import org.junit.jupiter.api.MethodOrderer;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;
import org.sakaiproject.e2e.support.SakaiUiTestBase;

@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class ChatTest extends SakaiUiTestBase {

    private static String sakaiUrl;
    private static final String MESSAGE = "Playwright chat message " + System.currentTimeMillis();

    @Test
    @Order(1)
    void createsSiteWithChat() {
        sakai.login("instructor1");
        sakaiUrl = sakai.createCourse("instructor1", List.of("sakai\\.chat"));
    }

    @Test
    @Order(2)
    void postsAndDeletesMessageFromRoom() {
        openChatRoom();

        page.locator("#topForm\\:controlPanel\\:message").fill(MESSAGE);
        page.locator("#topForm\\:controlPanel\\:submit").click();

        Locator message = page.locator(".chatList .chatText", new Page.LocatorOptions().setHasText(MESSAGE));
        assertThat(message).isVisible();

        page.locator(".chatList li[data-message-id]").filter(new Locator.FilterOptions().setHasText(MESSAGE))
            .locator(".chatRemove").click();

        Locator removeModal = page.locator("#removemodal");
        assertThat(removeModal).isVisible();
        assertThat(removeModal.locator("#message")).containsText(MESSAGE);

        removeModal.locator("#deleteButton").click();

        assertThat(removeModal).isHidden();
        assertThat(page.locator(".chatList .chatText", new Page.LocatorOptions().setHasText(MESSAGE))).hasCount(0);
    }

    @Test
    @Order(3)
    void switchesBetweenMessagesAndUsersOnNarrowScreens() {
        openChatRoom();
        page.setViewportSize(600, 900);

        Locator messagesPanel = page.locator("#chatListWrapperCont");
        Locator usersPanel = page.locator("#chatPresenceWrapper");

        assertThat(page.locator("#chatTabPresence")).isVisible();
        assertThat(messagesPanel).isVisible();
        assertThat(usersPanel).isHidden();

        page.getByRole(AriaRole.TAB, new Page.GetByRoleOptions().setName("Users in Chat")).click();

        assertThat(page.getByRole(AriaRole.TAB, new Page.GetByRoleOptions().setName("Users in Chat"))).hasAttribute("aria-selected", "true");
        assertThat(usersPanel).isVisible();
        assertThat(messagesPanel).isHidden();
    }

    private void openChatRoom() {
        sakai.login("instructor1");
        page.navigate(sakaiUrl);
        sakai.toolClick("Chat Room");
        assertThat(page.locator("#topForm\\:controlPanel\\:message")).isVisible();
    }
}
