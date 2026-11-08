class SitesSidebar {

  constructor(element, config) {

    this._i18n = config?.i18n;
    this._element = element;

    element.querySelectorAll(".site-opt-pin").forEach(buttonEl => new PinButton(buttonEl, { i18n: this._i18n?.pinButtons }));

    document.addEventListener("site-pin-change", this.handlePinChange.bind(this));
    document.body.addEventListener("site-pin-changed", this.syncPinButtons.bind(this));

    element.querySelectorAll(".sakai-sidebar-page--group").forEach(groupLi => {
      this._bindGroupToggle(groupLi);
    });

    this._railFlyout = null;
    this._bindRailFlyout();
    this._bindTreeKeyboard();
  }

  _bindGroupToggle(groupLi) {
    const btn = groupLi.querySelector(":scope > .sakai-sidebar-page__toggle[data-bs-toggle='collapse']");
    const target = btn?.getAttribute("data-bs-target");
    const panel = target ? groupLi.querySelector(`:scope > ${target}`) : null;
    if (!btn || !panel || btn.dataset.sakaiCollapseBound === "true") {
      return;
    }
    btn.dataset.sakaiCollapseBound = "true";

    panel.addEventListener("show.bs.collapse", e => {
      e.stopPropagation();
      btn.setAttribute("aria-expanded", "true");
      btn.classList.remove("collapsed");
    });
    panel.addEventListener("hide.bs.collapse", e => {
      e.stopPropagation();
      btn.setAttribute("aria-expanded", "false");
      btn.classList.add("collapsed");
    });
  }

  _isRailCollapsed() {
    const portalContainer = document.querySelector(".portal-container");
    return portalContainer?.classList.contains("sidebar-collapsed")
      || this._element.classList.contains("sidebar-collapsed");
  }

  _bindRailFlyout() {
    this._element.addEventListener("click", (e) => {
      if (!this._isRailCollapsed()) return;

      const toggle = e.target.closest(
        ".sakai-sidebar-page--lessons > .sakai-sidebar-page__toggle, "
        + ".sakai-sidebar-page--subsites > .sakai-sidebar-page__toggle"
      );
      if (!toggle || !this._element.contains(toggle)) return;

      e.preventDefault();
      e.stopPropagation();
      e.stopImmediatePropagation();

      const groupLi = toggle.closest(".sakai-sidebar-page--group");
      if (!groupLi) return;

      if (groupLi.classList.contains("sakai-sidebar-page--flyout-open")) {
        this._closeRailFlyout();
      } else {
        this._openRailFlyout(groupLi, toggle);
      }
    }, true);

    document.addEventListener("click", (e) => {
      if (!this._railFlyout) return;
      if (this._railFlyout.contains(e.target)) return;
      this._closeRailFlyout();
    });

    document.addEventListener("keydown", (e) => {
      if (e.key === "Escape") {
        this._closeRailFlyout();
      }
    });

    window.addEventListener("resize", () => {
      if (this._railFlyout) {
        this._positionRailFlyout(this._railFlyout);
      }
    });
  }

  closeRailFlyout() {
    this._closeRailFlyout();
  }

  _openRailFlyout(groupLi, toggle) {
    this._closeRailFlyout();

    const panel = groupLi.querySelector(":scope > .sakai-sidebar-page__group");
    if (!panel) return;

    this._flyoutPrevExpanded = panel.classList.contains("show");
    this._flyoutHadCollapse = panel.classList.contains("collapse") || panel.classList.contains("collapsing");
    bootstrap.Collapse.getInstance(panel)?.dispose();
    panel.classList.remove("collapse", "collapsing", "show");
    panel.removeAttribute("style");
    groupLi.classList.add("sakai-sidebar-page--flyout-open");
    toggle.setAttribute("aria-expanded", "true");
    this._railFlyout = groupLi;
    this._positionRailFlyout(groupLi);

    const tip = bootstrap.Tooltip.getInstance(toggle);
    tip?.hide();
    tip?.disable();
  }

  _positionRailFlyout(groupLi) {
    const toggle = groupLi.querySelector(":scope > .sakai-sidebar-page__toggle");
    if (!toggle) return;

    const toggleRect = toggle.getBoundingClientRect();
    const sidebarRect = this._element.getBoundingClientRect();
    const rtl = document.documentElement.dir === "rtl";
    const gap = 4;
    const edge = 8;
    const spaceBelow = window.innerHeight - toggleRect.top - edge;
    const spaceAbove = toggleRect.bottom - edge;
    const openUpward = spaceBelow < 160 && spaceAbove > spaceBelow;
    const maxHeight = Math.min(
      window.innerHeight * 0.7,
      Math.max(120, openUpward ? spaceAbove : spaceBelow)
    );

    if (openUpward) {
      groupLi.style.setProperty("--sakai-rail-flyout-top", "auto");
      groupLi.style.setProperty(
        "--sakai-rail-flyout-bottom",
        `${Math.round(window.innerHeight - toggleRect.bottom)}px`
      );
    } else {
      groupLi.style.setProperty("--sakai-rail-flyout-top", `${Math.round(toggleRect.top)}px`);
      groupLi.style.setProperty("--sakai-rail-flyout-bottom", "auto");
    }
    groupLi.style.setProperty("--sakai-rail-flyout-max-height", `${Math.round(maxHeight)}px`);
    if (rtl) {
      groupLi.style.setProperty("--sakai-rail-flyout-left", "auto");
      groupLi.style.setProperty(
        "--sakai-rail-flyout-right",
        `${Math.round(window.innerWidth - sidebarRect.left + gap)}px`
      );
    } else {
      groupLi.style.setProperty(
        "--sakai-rail-flyout-left",
        `${Math.round(sidebarRect.right + gap)}px`
      );
      groupLi.style.setProperty("--sakai-rail-flyout-right", "auto");
    }
  }

  _closeRailFlyout() {
    if (!this._railFlyout) return;

    const groupLi = this._railFlyout;
    const toggle = groupLi.querySelector(":scope > .sakai-sidebar-page__toggle");
    const panel = groupLi.querySelector(":scope > .sakai-sidebar-page__group");

    groupLi.classList.remove("sakai-sidebar-page--flyout-open");
    if (this._flyoutHadCollapse && panel) {
      panel.classList.add("collapse");
      panel.classList.toggle("show", this._flyoutPrevExpanded);
    }
    if (toggle) {
      toggle.setAttribute("aria-expanded", this._flyoutPrevExpanded ? "true" : "false");
      toggle.classList.toggle("collapsed", !this._flyoutPrevExpanded);
      bootstrap.Tooltip.getInstance(toggle)?.enable();
    }
    groupLi.style.removeProperty("--sakai-rail-flyout-top");
    groupLi.style.removeProperty("--sakai-rail-flyout-bottom");
    groupLi.style.removeProperty("--sakai-rail-flyout-left");
    groupLi.style.removeProperty("--sakai-rail-flyout-right");
    groupLi.style.removeProperty("--sakai-rail-flyout-max-height");
    this._railFlyout = null;
    this._flyoutPrevExpanded = false;
    this._flyoutHadCollapse = false;
  }

  _treeItems() {
    const tree = document.getElementById("current-site-pages");
    if (!tree) return [];
    return [...tree.querySelectorAll('[role="treeitem"]')].filter((el) => {
      if (el.closest("[hidden], .collapse:not(.show)")) {
        const collapse = el.closest(".collapse");
        if (collapse && !collapse.classList.contains("show") && !collapse.contains(el.closest(".sakai-sidebar-page--group")?.querySelector(":scope > .sakai-sidebar-page__toggle"))) {
          // Item inside a closed panel (not the toggle itself)
          if (collapse.querySelector(":scope > *") && !el.matches(".sakai-sidebar-page__toggle")) {
            const group = el.closest(".sakai-sidebar-page--group");
            const toggle = group?.querySelector(":scope > .sakai-sidebar-page__toggle");
            if (toggle !== el && collapse.contains(el)) {
              return collapse.classList.contains("show");
            }
          }
        }
      }
      const panel = el.closest(".sakai-sidebar-page__group.collapse");
      if (panel && !panel.classList.contains("show")) {
        return false;
      }
      return true;
    });
  }

  _bindTreeKeyboard() {
    const tree = document.getElementById("current-site-pages");
    if (!tree) return;

    tree.addEventListener("keydown", (e) => {
      const item = e.target.closest('[role="treeitem"]');
      if (!item || !tree.contains(item)) return;

      const items = this._visibleTreeItems();
      const index = items.indexOf(item);
      if (index < 0) return;

      const expandKey = document.documentElement.dir === "rtl" ? "ArrowLeft" : "ArrowRight";
      const collapseKey = document.documentElement.dir === "rtl" ? "ArrowRight" : "ArrowLeft";

      switch (e.key) {
        case "ArrowDown":
          e.preventDefault();
          items[Math.min(index + 1, items.length - 1)]?.focus();
          break;
        case "ArrowUp":
          e.preventDefault();
          items[Math.max(index - 1, 0)]?.focus();
          break;
        case "Home":
          e.preventDefault();
          items[0]?.focus();
          break;
        case "End":
          e.preventDefault();
          items[items.length - 1]?.focus();
          break;
        case expandKey:
          if (item.getAttribute("aria-expanded") === "false") {
            e.preventDefault();
            item.click();
          }
          break;
        case collapseKey:
          if (item.getAttribute("aria-expanded") === "true") {
            e.preventDefault();
            item.click();
          }
          break;
        default:
          break;
      }
    });
  }

  _visibleTreeItems() {
    const tree = document.getElementById("current-site-pages");
    if (!tree) return [];
    return [...tree.querySelectorAll('[role="treeitem"]')].filter((el) => {
      const panel = el.closest(".sakai-sidebar-page__group");
      if (!panel) return true;
      const isToggleForPanel = el.matches(".sakai-sidebar-page__toggle")
        && el.getAttribute("aria-controls") === panel.id;
      if (isToggleForPanel) return true;
      return panel.classList.contains("show");
    });
  }

  setView(mobile) {

    const mobileClasses = ["portal-nav-sidebar-mobile", "offcanvas", "offcanvas-start"];
    const desktopClasses = ["portal-nav-sidebar-desktop"];

    this._element.style.removeProperty("visibility");
    if (mobile) {
      this._element.classList.add(...mobileClasses);
      this._element.classList.remove(...desktopClasses);
    } else {
      bootstrap.Offcanvas.getInstance(this._element)?.dispose();
      this._element.classList.remove(...mobileClasses);
      this._element.classList.add(...desktopClasses);
    }
    this._element.classList.remove("d-none", "sakai-is-hidden");
  }

  syncPinButtons(event) {

    const siteId = event.detail?.siteId;
    if (!siteId) {
      return;
    }
    const pinned = !!event.detail.pinned;
    this._element.querySelectorAll(`.site-opt-pin[data-pin-site="${CSS.escape(siteId)}"]`).forEach(button => {
      button.dataset.pinned = pinned ? "true" : "false";
      button.setAttribute("aria-pressed", pinned ? "true" : "false");
      const title = pinned ? this._i18n?.pinButtons?.titleUnpin : this._i18n?.pinButtons?.titlePin;
      if (title) {
        button.setAttribute("aria-label", title);
      }
    });
  }

  async handlePinChange(event) {

    const pinButton = event.target;
    const pinned = event.detail.pinned;
    const siteId = event.detail.siteId;
    const siteTitle = pinButton.dataset.siteTitle;
    const timeStamp = new Date().valueOf();

    pinButton.setAttribute("disabled", "disabled");

    try {
      const favoritesReq = await fetch(`/portal/favorites/list?_${timeStamp}`);
      if (!favoritesReq.ok) {
        throw new Error("Failed to request favorites");
      }

      const favoritesValues = await favoritesReq.json();
      const alreadyPinned = favoritesValues.favoriteSiteIds.includes(siteId);

      if (pinned !== alreadyPinned) {
        const payload = structuredClone(favoritesValues);
        if (pinned) {
          payload.favoriteSiteIds.push(siteId);
        } else {
          payload.favoriteSiteIds.splice(payload.favoriteSiteIds.indexOf(siteId), 1);
        }

        const data = new URLSearchParams();
        data.append("userFavorites", JSON.stringify(payload));

        const url = "/portal/favorites/update";
        const response = await fetch(url, {
          credentials: "include",
          headers: { "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8" },
          method: "POST",
          body: data,
        });

        if (!response.ok) {
          throw new Error(`Network error while updating pinned sites at url ${url}`);
        }

        document.body.dispatchEvent(new CustomEvent("site-pin-changed", {
          detail: { siteId, pinned, siteTitle },
          bubbles: true,
        }));
      }
    } catch (error) {
      console.error(error);
      const reverted = !pinned;
      pinButton.dataset.pinned = reverted ? "true" : "false";
      pinButton.setAttribute("aria-pressed", reverted ? "true" : "false");
      const title = reverted ? this._i18n?.pinButtons?.titleUnpin : this._i18n?.pinButtons?.titlePin;
      if (title) {
        pinButton.setAttribute("aria-label", title);
      }
    }

    pinButton.removeAttribute("disabled");
  }
}

class PinButton {

  get title() {
    return this._element.getAttribute("aria-label");
  }

  set title(newValue) {
    this._element.setAttribute("aria-label", newValue);
  }

  get pinned() {
    return this._element.dataset.pinned === "true";
  }

  set pinned(newPinned) {
    this._element.dataset.pinned = newPinned;
    this._element.setAttribute("aria-pressed", newPinned ? "true" : "false");
  }

  constructor(element, config) {

    this._element = element;
    this._i18n = config?.i18n;
    this._site = element.dataset.pinSite;
    element.addEventListener("click", this.toggle.bind(this));
    this.pinned = element.dataset.pinned === "true";
    this.title = this.pinned ? this._i18n.titleUnpin : this._i18n.titlePin;
  }

  toggle() {

    this.pinned = !this.pinned;
    this.title = this.pinned ? this._i18n.titleUnpin : this._i18n.titlePin;
    this.emitPinChange();
  }

  emitPinChange() {

    this._element.dispatchEvent(new CustomEvent("site-pin-change", {
      detail: { pinned: this.pinned, siteId: this._site },
      bubbles: true,
    }));
  }
}
