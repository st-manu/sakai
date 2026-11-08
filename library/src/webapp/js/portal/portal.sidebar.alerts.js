(function () {
  const toolMenu = document.getElementById("toolMenu");
  const pagesList = document.getElementById("current-site-pages");
  if (!toolMenu || !pagesList || !portal?.user?.id) {
    return;
  }

  const cache = new Map();

  const ensureIndicator = (link) => {
    const wrap = link.querySelector(".sakai-sidebar-page__icon-wrap");
    if (!wrap) {
      return;
    }
    let indicator = wrap.querySelector(".portal-notifications-indicator");
    if (!indicator) {
      indicator = document.createElement("span");
      indicator.className = "portal-notifications-indicator";
      indicator.setAttribute("aria-hidden", "true");
      wrap.appendChild(indicator);
    }
    return indicator;
  };

  const applyAlerts = (siteId, tools) => {
    if (pagesList.dataset.siteId !== siteId) {
      return;
    }
    const alertTools = new Set(
      (tools || []).filter((tool) => tool.hasAlerts).map((tool) => tool.id)
    );
    pagesList.querySelectorAll("a.sakai-sidebar-page__link[data-tool-id]").forEach((link) => {
      const toolId = link.getAttribute("data-tool-id");
      const hasAlert = toolId && alertTools.has(toolId);
      link.classList.toggle("has-alerts", hasAlert);
      const indicator = ensureIndicator(link);
      if (!indicator) {
        return;
      }
      indicator.hidden = !hasAlert;
      indicator.classList.toggle("is-visible", hasAlert);
    });
    pagesList.classList.toggle("has-tool-alerts", alertTools.size > 0);
  };

  const loadSiteAlerts = (siteId) => {
    if (!siteId || cache.has(siteId)) {
      if (cache.has(siteId)) {
        applyAlerts(siteId, cache.get(siteId));
      }
      return Promise.resolve();
    }
    return fetch(`/api/sites/${encodeURIComponent(siteId)}`, {
      credentials: "same-origin",
      headers: { Accept: "application/json" },
    })
      .then((response) => {
        if (!response.ok) {
          throw new Error(`Failed alerts for ${siteId}`);
        }
        return response.json();
      })
      .then((data) => {
        cache.set(siteId, data.tools || []);
        applyAlerts(siteId, data.tools || []);
      })
      .catch((error) => console.warn(error));
  };

  const siteId = pagesList.dataset.siteId || portal?.siteId;
  if (siteId) {
    loadSiteAlerts(siteId);
  }

  document.body.addEventListener("notifications-cleared", () => {
    cache.clear();
    pagesList.querySelectorAll("a.sakai-sidebar-page__link.has-alerts").forEach((link) => {
      link.classList.remove("has-alerts");
      const indicator = link.querySelector(".portal-notifications-indicator");
      if (indicator) {
        indicator.hidden = true;
        indicator.classList.remove("is-visible");
      }
    });
    pagesList.classList.remove("has-tool-alerts");
  });
})();
