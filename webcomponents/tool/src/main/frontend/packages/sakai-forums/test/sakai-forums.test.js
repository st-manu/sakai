import "../sakai-forums.js";
import { html } from "lit";
import * as data from "./data.js";
import * as sitePickerData from "../../sakai-site-picker/test/data.js";
import { expect, fixture, waitUntil, aTimeout } from "@open-wc/testing";
import fetchMock from "fetch-mock/esm/client";

describe("sakai-forums tests", () => {

  window.top.portal = { locale: "en_GB" };

  fetchMock
    .get(data.i18nUrl, data.i18n, { overwriteRoutes: true })
    .get(sitePickerData.i18nUrl, sitePickerData.i18n, { overwriteRoutes: true })
    .get(data.userForumsUrl, data.userForums, { overwriteRoutes: true })
    .get("*", 500, { overwriteRoutes: true });

  it ("renders in user mode correctly", async () => {

    // In user mode, we'd expect to get announcements from multiple sites.
    let el = await fixture(html`
      <sakai-forums user-id="${data.userId}"></sakai-forums>
    `);

    await waitUntil(() => el.dataPage);

    expect(el.shadowRoot.querySelectorAll(".messages > div").length).to.equal(9);

    const sortByMessagesLink = el.shadowRoot.querySelector(`a[title="${el._i18n.sort_by_messages_tooltip}"]`);
    expect(sortByMessagesLink).to.exist;
    sortByMessagesLink.click();

    await el.updateComplete;

    expect(el.shadowRoot.querySelectorAll(".messages > div.cell > a").item(0).innerHTML).to.contain("3");

    sortByMessagesLink.click();
    await el.updateComplete;

    expect(el.shadowRoot.querySelectorAll(".messages > div.cell > a").item(0).innerHTML).to.contain("5");

    const sortByForumsLink = el.shadowRoot.querySelector(`a[title="${el._i18n.sort_by_forums_tooltip}"]`);
    expect(sortByForumsLink).to.exist;
    sortByForumsLink.click();

    await el.updateComplete;

    expect(el.shadowRoot.querySelectorAll(".messages > div.cell > a").item(1).innerHTML).to.contain("8");
    sortByForumsLink.click();

    await el.updateComplete;
    expect(el.shadowRoot.querySelectorAll(".messages > div.cell > a").item(1).innerHTML).to.contain("2");
  });

  it ("is accessible", async () => {

    let el = await fixture(html`
      <sakai-forums user-id="${data.userId}"></sakai-forums>
    `);

    await waitUntil(() => el.dataPage);

    expect(el.shadowRoot).to.be.accessible();
  });
});
