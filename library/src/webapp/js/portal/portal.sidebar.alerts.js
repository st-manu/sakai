(function () {
  const toolMenu = document.getElementById("toolMenu");
  if (!toolMenu || !portal?.user?.id) {
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
    const siteLi = [...toolMenu.querySelectorAll("li.site-list-item")]
      .find((li) => li.dataset.site === siteId);
    if (!siteLi) {
      return;
    }
    const alertTools = new Set(
      (tools || []).filter((tool) => tool.hasAlerts).map((tool) => tool.id)
    );
    siteLi.querySelectorAll("a.sakai-sidebar-page__link[data-tool-id]").forEach((link) => {
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
    siteLi.classList.toggle("has-tool-alerts", alertTools.size > 0);
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

  const sitesToLoad = new Set();
  if (portal?.siteId) {
    sitesToLoad.add(portal.siteId);
  }
  toolMenu.querySelectorAll("li.site-list-item.is-current-site, li.site-list-item .site-list-item-collapse.show")
    .forEach((el) => {
      const li = el.classList?.contains("site-list-item") ? el : el.closest("li.site-list-item");
      const siteId = li?.dataset?.site;
      if (siteId) {
        sitesToLoad.add(siteId);
      }
    });

  sitesToLoad.forEach((siteId) => loadSiteAlerts(siteId));

  toolMenu.addEventListener("shown.bs.collapse", (event) => {
    const siteLi = event.target.closest("li.site-list-item");
    const siteId = siteLi?.dataset?.site;
    if (siteId) {
      loadSiteAlerts(siteId);
    }
  });

  document.body.addEventListener("notifications-cleared", () => {
    cache.clear();
    toolMenu.querySelectorAll("a.sakai-sidebar-page__link.has-alerts").forEach((link) => {
      link.classList.remove("has-alerts");
      const indicator = link.querySelector(".portal-notifications-indicator");
      if (indicator) {
        indicator.hidden = true;
        indicator.classList.remove("is-visible");
      }
    });
    toolMenu.querySelectorAll("li.site-list-item.has-tool-alerts").forEach((li) => {
      li.classList.remove("has-tool-alerts");
    });
  });
})();
