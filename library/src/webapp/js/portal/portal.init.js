var portal = portal || {};
portal.search = portal.search || {};

portal.search.setup = options => {

  const search = document.querySelector("#sakai-search-panel sakai-search");
  if (!search) return;

  options.tool ? search.setAttribute("tool", options.tool) : search.removeAttribute("tool");
  options.site ? search.setAttribute("site-id", options.site) : search.removeAttribute("site-id");
  const label = document.getElementById("sakai-search-panel-label");
  // toolId names the tool for the title when its search results use a different tool name, e.g. wiki for sakai.rwiki.
  // Tool titles are site content, so the label is set as text.
  if (label) {
    label.textContent = options.tool ? `${portal.search.searchTranslation} ${portal.toolTitles[options.toolId || options.tool]}` : portal.search.defaultTitle;
  }
};

document.addEventListener("DOMContentLoaded", () => {

  portal.search.searchTranslation = document.getElementById("sakai-search-translation")?.textContent;
  portal.search.defaultTitle = document.getElementById("sakai-search-default-title")?.textContent;

  document.getElementById("sakai-search-panel")?.addEventListener("shown.bs.offcanvas", e => {
    e.target.querySelector("sakai-search input")?.focus();
  });

  document.querySelectorAll(".portal-search-button").forEach(b => {
    b.addEventListener("click", () => portal.search.setup({}));
  });

  document.getElementById("sakai-calendar-panel")?.addEventListener("show.bs.offcanvas", e => {
    e.target.querySelector("sakai-calendar")?.loadData();
  });

  const notificationsPanel = document.getElementById("sakai-notifications-panel");
  notificationsPanel?.addEventListener("show.bs.offcanvas", e => {
    e.target.querySelector("sakai-notifications")?.loadNotifications();
  });

  notificationsPanel?.addEventListener("hidden.bs.offcanvas", e => {
    e.target.querySelector("sakai-notifications")?._clearTestNotifications();
  });

  document.getElementById("sakai-directlink-panel")?.addEventListener("change", async e => {

    const toggle = e.target.closest("[data-direct-link-toggle]");
    if (!toggle) return;

    const textarea = document.getElementById(toggle.dataset.target);
    if (!textarea) return;

    const fullUrl = toggle.dataset.directUrl;

    if (!toggle.checked) {
      textarea.value = fullUrl;
      return;
    }

    try {
      const response = await fetch(`/direct/url/shorten?path=${encodeURI(fullUrl)}`, { credentials: "include" });
      textarea.value = response.ok ? await response.text() : fullUrl;
    } catch (error) {
      console.error(error);
      textarea.value = fullUrl;
    }
  });
});

portal.displayProfile = e => {

  e.preventDefault();
  const trigger = e.currentTarget;
  document.querySelector("sakai-account").setAttribute("user-id", trigger.dataset.userId);
  bootstrap.Modal.getOrCreateInstance(document.getElementById("account-details-modal")).show();
};
