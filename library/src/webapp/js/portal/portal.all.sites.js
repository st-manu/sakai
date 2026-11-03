const allsites = { pinnedQueue: { favoriteSiteIds: [] }, sites: [], terms: [], sortable: undefined };

allsites.isWorkspaceSite = site => typeof site?.siteId === "string" && site.siteId.startsWith("~");

allsites.isAdminSite = site => site?.siteId === "!admin";

allsites.readLabels = function () {

  const el = document.getElementById("sites-launcher-i18n");
  return {
    projects: el?.dataset.projects || "PROJECTS",
    other: el?.dataset.other || "OTHER",
    administration: el?.dataset.administration || "ADMINISTRATION",
    unknownTerm: el?.dataset.unknownTerm || "(unknown academic term)",
  };
};

allsites.groupKeyForSite = function (site, labels) {

  if (allsites.isAdminSite(site)) {
    return { key: "administration", label: labels.administration, kind: "administration" };
  }
  if (site.course) {
    const termLabel = (site.term || "").trim() || labels.unknownTerm;
    return { key: `term:${termLabel}`, label: termLabel, kind: "term" };
  }
  if (site.project) {
    return { key: "projects", label: labels.projects, kind: "projects" };
  }
  return { key: "other", label: labels.other, kind: "other" };
};

allsites.buildGroups = function (sites) {

  const labels = allsites.readLabels();
  const groups = new Map();

  sites.forEach(site => {
    const meta = allsites.groupKeyForSite(site, labels);
    if (!groups.has(meta.key)) {
      groups.set(meta.key, { ...meta, sites: [] });
    }
    groups.get(meta.key).sites.push(site);
  });

  groups.forEach(group => {
    group.sites.sort((a, b) => (a.title || "").localeCompare(b.title || "", undefined, { sensitivity: "base" }));
  });

  const termOrder = new Map(
    (allsites.terms || []).map((term, index) => [term.name, index])
  );

  const kindRank = { term: 0, projects: 1, administration: 2, other: 3 };

  return Array.from(groups.values()).sort((a, b) => {
    const kindDiff = (kindRank[a.kind] ?? 9) - (kindRank[b.kind] ?? 9);
    if (kindDiff !== 0) return kindDiff;
    if (a.kind === "term") {
      const aIdx = termOrder.has(a.label) ? termOrder.get(a.label) : Number.MAX_SAFE_INTEGER;
      const bIdx = termOrder.has(b.label) ? termOrder.get(b.label) : Number.MAX_SAFE_INTEGER;
      if (aIdx !== bIdx) return aIdx - bIdx;
      return a.label.localeCompare(b.label, undefined, { sensitivity: "base" });
    }
    return a.label.localeCompare(b.label, undefined, { sensitivity: "base" });
  });
};

allsites.createCard = function (site) {

  const card = document.createElement("sakai-course-card");
  card.courseData = site;
  card.density = "compact";
  card.pinned = !!site.pinned;
  if (!allsites.isWorkspaceSite(site)) {
    card.showPin = true;
  }
  return card;
};

allsites.organizeLabels = function () {

  const pane = document.getElementById("organize-favorites-pane");
  return {
    moveUp: pane?.dataset.labelMoveUp || "Move up",
    moveDown: pane?.dataset.labelMoveDown || "Move down",
    drag: pane?.dataset.labelDrag || "Drag to reorder",
  };
};

allsites.rebuildOrganizeFromSites = function (sites) {

  const list = document.getElementById("organize-favorites-list");
  if (!list) {
    return;
  }

  list.replaceChildren();

  const pinned = (sites || []).filter(site => site.pinned && !allsites.isWorkspaceSite(site));
  // Preserve server/API pin order when present via pinnedQueue; otherwise keep API order.
  const order = allsites.pinnedQueue?.favoriteSiteIds?.length
    ? allsites.pinnedQueue.favoriteSiteIds
    : pinned.map(site => site.siteId);
  const byId = new Map(pinned.map(site => [site.siteId, site]));

  order.forEach(siteId => {
    const site = byId.get(siteId);
    if (site) {
      allsites.addOrganizeItem(site.siteId, site.title);
      byId.delete(siteId);
    }
  });
  byId.forEach(site => allsites.addOrganizeItem(site.siteId, site.title));

  allsites.refreshOrganizeMoveButtons();
  allsites.updateOrganizeEmptyState();
};

allsites.organizeRowHtml = siteTitle => {

  const labels = allsites.organizeLabels();
  const safeTitle = String(siteTitle || "").replace(/"/g, "&quot;");
  return `
  <div class="sakai-reorder-row-main">
    <div class="sakai-reorder-move-controls">
      <span class="btn btn-icon sakai-reorder-drag-handle pinned-drag-handle"
          tabindex="0"
          role="button"
          title="${labels.drag}"
          aria-label="${labels.drag}">
        <span class="si si-drag-handle" aria-hidden="true"></span>
      </span>
      <button type="button" class="btn btn-icon" data-action="move-up" title="${labels.moveUp}" aria-label="${labels.moveUp}">
        <span class="bi bi-chevron-up" aria-hidden="true"></span>
      </button>
      <button type="button" class="btn btn-icon" data-action="move-down" title="${labels.moveDown}" aria-label="${labels.moveDown}">
        <span class="bi bi-chevron-down" aria-hidden="true"></span>
      </button>
    </div>
    <div class="sakai-reorder-row-content">
      <div class="sakai-reorder-title-block">
        <div class="sakai-reorder-display">
          <span class="sakai-reorder-title" title="${safeTitle}">${safeTitle}</span>
        </div>
      </div>
    </div>
  </div>
`;
};

allsites.updatePinned = function (reorder) {

  clearTimeout(allsites.updateTimeoutId);
  allsites.updateTimeoutId = undefined;

  const data = new URLSearchParams();
  data.append("userFavorites", JSON.stringify(allsites.pinnedQueue));
  if (reorder) data.append("reorder", "true");

  const url = "/portal/favorites/update";
  fetch(url, {
    credentials: "include",
    headers: { "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8" },
    method: "POST",
    body: data,
  })
  .then(r => {

    if (!r.ok) {
      throw new Error(`Network error while updating pinned sites at url ${url}`);
    } else {
      const notification = document.getElementById("allsites-refresh-notification");
      if (notification) notification.style.display = "block";
    }
  })
  .catch(error => console.error(error));
};

allsites.scheduleUpdatePinned = function (reorder) {

  clearTimeout(allsites.updateTimeoutId);
  allsites.updateTimeoutId = setTimeout(() => allsites.updatePinned(reorder), 500);
};

allsites.syncPinnedFromCards = function () {

  const root = document.getElementById("moresites-content");
  if (!root) return;

  allsites.pinnedQueue.favoriteSiteIds = Array.from(root.querySelectorAll("sakai-course-card"))
    .filter(card => card.pinned)
    .map(card => card.courseData?.siteId)
    .filter(Boolean);
};

allsites.updateOrganizeEmptyState = function () {

  const list = document.getElementById("organize-favorites-list");
  const hasItems = !!list?.querySelector(".organize-favorite-item");
  document.getElementById("pinned-to-show")?.classList.toggle("sakai-is-hidden", !hasItems);
  document.getElementById("no-pinned-to-show")?.classList.toggle("sakai-is-hidden", hasItems);
};

allsites.addOrganizeItem = function (siteId, siteTitle) {

  const list = document.getElementById("organize-favorites-list");
  if (!list || list.querySelector(`.organize-favorite-item[data-site-id="${CSS.escape(siteId)}"]`)) {
    return;
  }

  const li = document.createElement("li");
  li.classList.add("list-group-item", "organize-favorite-item", "sakai-reorder-row");
  li.dataset.siteId = siteId;
  li.dataset.sortableId = siteId;
  li.innerHTML = allsites.organizeRowHtml(siteTitle);
  list.append(li);
  allsites.refreshOrganizeMoveButtons();
  allsites.updateOrganizeEmptyState();
};

allsites.removeOrganizeItem = function (siteId) {

  document.querySelector(`#organize-favorites-list .organize-favorite-item[data-site-id="${CSS.escape(siteId)}"]`)?.remove();
  allsites.refreshOrganizeMoveButtons();
  allsites.updateOrganizeEmptyState();
};

allsites.handleCardPinChanged = function (e) {

  if (e.detail?.source !== "sites-launcher") return;

  allsites.syncPinnedFromCards();
  allsites.scheduleUpdatePinned();

  if (e.detail.pinned) {
    allsites.addOrganizeItem(e.detail.siteId, e.detail.siteTitle);
  } else {
    allsites.removeOrganizeItem(e.detail.siteId);
  }
};

allsites.renderSiteCards = function (sites, query = "") {

  const content = document.getElementById("moresites-content");
  const noResults = document.getElementById("all-sites-no-search-results");
  if (!content) return;

  const needle = query.trim().toLowerCase();
  const filtered = needle
    ? sites.filter(site => {
        const title = (site.title || "").toLowerCase();
        const desc = (site.shortDescription || "").toLowerCase();
        const term = (site.term || "").toLowerCase();
        return title.includes(needle) || desc.includes(needle) || term.includes(needle);
      })
    : sites;

  content.replaceChildren();
  content.className = "sakai-sites-launcher__sections";
  content.setAttribute("aria-busy", "false");

  if (!filtered.length) {
    noResults?.classList.remove("is-hidden", "sakai-is-hidden");
    return;
  }

  noResults?.classList.add("is-hidden");

  allsites.buildGroups(filtered).forEach(group => {
    const section = document.createElement("section");
    section.className = "sakai-sites-launcher__section";
    section.dataset.groupKey = group.key;

    const heading = document.createElement("h3");
    heading.className = "sakai-sites-launcher__section-title";
    heading.textContent = group.label;
    section.append(heading);

    const grid = document.createElement("div");
    grid.className = "sakai-sites-launcher__grid";
    group.sites.forEach(site => grid.append(allsites.createCard(site)));
    section.append(grid);
    content.append(section);
  });
};

allsites.resetSearch = function () {

  const searchInput = document.getElementById("search-all-sites");
  if (searchInput) searchInput.value = "";
  searchInput?.focus();
  allsites.renderSiteCards(allsites.sites);
};

allsites.refreshOrganizeMoveButtons = function () {

  const list = document.getElementById("organize-favorites-list");
  if (!list) return;

  const items = [...list.querySelectorAll(".organize-favorite-item")];
  items.forEach((li, index) => {
    li.querySelector("[data-action='move-up']")?.toggleAttribute("disabled", index === 0);
    li.querySelector("[data-action='move-down']")?.toggleAttribute("disabled", index === items.length - 1);
  });
};

allsites.moveOrganizeItem = function (li, direction) {

  const list = document.getElementById("organize-favorites-list");
  const sortable = allsites.sortable;
  if (!list || !sortable || !li) return;

  const order = sortable.toArray();
  const sortableId = li.dataset.sortableId;
  const index = order.indexOf(sortableId);
  if (index < 0) return;

  const nextIndex = direction === "up" ? index - 1 : index + 1;
  if (nextIndex < 0 || nextIndex >= order.length) return;

  order.splice(index, 1);
  order.splice(nextIndex, 0, sortableId);
  sortable.sort(order, true);
  allsites.refreshOrganizeMoveButtons();
  allsites.commitOrganizeOrder();
};

allsites.commitOrganizeOrder = function () {

  const list = document.getElementById("organize-favorites-list");
  if (!list) return;

  const orderedIds = Array.from(list.querySelectorAll(".organize-favorite-item"))
    .map(el => el.dataset.siteId)
    .filter(Boolean);
  const remaining = (allsites.pinnedQueue.favoriteSiteIds || []).filter(id => !orderedIds.includes(id));
  allsites.pinnedQueue.favoriteSiteIds = [...orderedIds, ...remaining];
  allsites.updatePinned(true);
};

allsites.setupOrganize = function () {

  const list = document.getElementById("organize-favorites-list");
  if (!list || typeof Sortable === "undefined") return;

  allsites.updateOrganizeEmptyState();
  allsites.refreshOrganizeMoveButtons();

  if (allsites.sortable) {
    allsites.sortable.destroy();
  }

  allsites.sortable = Sortable.create(list, {
    dataIdAttr: "data-sortable-id",
    handle: ".sakai-reorder-drag-handle, .pinned-drag-handle",
    onUpdate: () => {
      allsites.refreshOrganizeMoveButtons();
      allsites.commitOrganizeOrder();
    },
  });

  if (!list.dataset.moveBound) {
    list.dataset.moveBound = "true";
    list.addEventListener("click", e => {
      const button = e.target.closest("[data-action='move-up'], [data-action='move-down']");
      if (!button || button.disabled) return;
      const li = button.closest(".organize-favorite-item");
      allsites.moveOrganizeItem(li, button.dataset.action === "move-up" ? "up" : "down");
    });
  }
};

allsites.setupSearch = function () {

  const searchInput = document.getElementById("search-all-sites");
  searchInput?.addEventListener("input", () => {
    allsites.renderSiteCards(allsites.sites, searchInput.value);
  });
  searchInput?.addEventListener("keydown", event => {
    if (event.key === "Escape") {
      allsites.resetSearch();
    }
  });
};

allsites.setup = function () {

  const sidebar = document.getElementById("select-site-sidebar");
  sidebar?.querySelector("button, a, input")?.focus();

  sidebar?.addEventListener("site-pin-changed", allsites.handleCardPinChanged);
  allsites.setupOrganize();
  allsites.setupSearch();
};

document.addEventListener("DOMContentLoaded", () => {

  document.body.addEventListener("site-pin-changed", e => {

    if (e.detail.source === "all-sites" || e.detail.source === "sites-launcher") return;

    if (!e.detail.pinned) {
      allsites.removeOrganizeItem(e.detail.siteId);
    } else {
      allsites.addOrganizeItem(e.detail.siteId, e.detail.siteTitle);
    }
  });

  const sidebar = document.getElementById("select-site-sidebar");

  if (sidebar) {

    let drawerLoaded = false;

    sidebar.addEventListener("show.bs.modal", async () => {

      // Mobile: sites launcher can open from the bar while the nav offcanvas is open.
      const navSidebar = document.getElementById("portal-nav-sidebar");
      if (navSidebar && globalThis.bootstrap?.Offcanvas) {
        bootstrap.Offcanvas.getInstance(navSidebar)?.hide();
      }

      if (drawerLoaded) {
        document.getElementById("search-all-sites")?.focus();
        return;
      }

      const content = document.getElementById("moresites-content");
      const loading = document.getElementById("moresites-loading");
      const errorBanner = document.getElementById("moresites-error");
      const userId = globalThis.portal?.user?.id;

      loading?.style.removeProperty("display");
      errorBanner?.style.setProperty("display", "none");
      content?.setAttribute("aria-busy", "true");

      if (!userId) {
        console.error("No portal user id available for sites launcher");
        loading?.style.setProperty("display", "none");
        errorBanner?.style.setProperty("display", "block");
        return;
      }

      try {
        const [sitesResponse, favoritesResponse] = await Promise.all([
          fetch(`/api/users/${encodeURIComponent(userId)}/sites`, { credentials: "include" }),
          fetch("/portal/favorites/list", { credentials: "include" }),
        ]);

        if (!sitesResponse.ok) {
          throw new Error(`Network error while loading sites from ${sitesResponse.url}`);
        }

        const payload = await sitesResponse.json();
        allsites.sites = Array.isArray(payload.sites) ? payload.sites : [];
        allsites.terms = Array.isArray(payload.terms) ? payload.terms : [];

        let favoriteSiteIds = [];
        if (favoritesResponse.ok) {
          const favorites = await favoritesResponse.json();
          favoriteSiteIds = Array.isArray(favorites.favoriteSiteIds) ? favorites.favoriteSiteIds : [];
        }
        if (!favoriteSiteIds.length) {
          favoriteSiteIds = allsites.sites
            .filter(site => site.pinned && !allsites.isWorkspaceSite(site))
            .map(site => site.siteId);
        }
        allsites.pinnedQueue.favoriteSiteIds = favoriteSiteIds.filter(id => !String(id).startsWith("~"));

        allsites.renderSiteCards(allsites.sites);
        allsites.rebuildOrganizeFromSites(allsites.sites);
        drawerLoaded = true;
        allsites.setup();
        document.getElementById("search-all-sites")?.focus();
      } catch (error) {
        console.error(error);
        loading?.style.setProperty("display", "none");
        errorBanner?.style.setProperty("display", "block");
        content?.setAttribute("aria-busy", "false");
      }
    });
  }

  const organizeTab = document.getElementById("allsites-organize-favourites-tab");
  const refreshNotification = document.getElementById("allsites-refresh-notification");

  if (organizeTab && refreshNotification) {
    organizeTab.addEventListener("click", () => {
      if (refreshNotification.offsetParent !== null) {
        location.reload();
      }
    });
  }

});
