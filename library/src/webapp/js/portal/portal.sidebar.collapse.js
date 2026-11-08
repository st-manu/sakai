class SidebarCollapseButton {

  get collapsed() {
    return this._element.getAttribute("data-portal-sidebar-collapsed") === "true" ? true : false;
  }

  set collapsed(newValue) {
    const collapsed = Boolean(newValue);
    this._element.setAttribute("data-portal-sidebar-collapsed", String(collapsed));
    this.setCollapsed(collapsed);
  }

  constructor(element, config) {

    this._i18n = config?.i18n;
    this._toggleClass = config?.toggleClass;
    this._portalContainer = config?.portalContainer;
    this._sitesSidebar = config?.sitesSidebar;
    this._sitesSidebarInstance = config?.sitesSidebarInstance;
    this._element = element;
    this._element.addEventListener("click", this.toggle.bind(this));
    this._syncUi(this.collapsed);
  }

  _syncUi(collapsed) {
    this._element.title = collapsed ? this._i18n.titleCollapsed : this._i18n.titleExpanded;
    this._element.setAttribute("aria-label", this._element.title);
    this._element.setAttribute("aria-expanded", collapsed ? "false" : "true");

    const label = this._element.querySelector(".sakai-sidebar__collapse-label");
    if (label) {
      label.textContent = collapsed ? this._i18n.titleCollapsed : this._i18n.titleExpanded;
    }

    if (!collapsed) {
      this._sitesSidebarInstance?.closeRailFlyout?.();
    }

    this.syncToolTooltips(collapsed);
  }

  syncToolTooltips(collapsed = this.collapsed) {
    if (typeof bootstrap === "undefined" || !bootstrap.Tooltip) {
      return;
    }
    const items = this._sitesSidebar?.querySelectorAll(
      "#current-site-pages > .sakai-sidebar-page > a.sakai-sidebar-page__link, "
      + "#current-site-pages > .sakai-sidebar-page > button.sakai-sidebar-page__toggle"
    );
    items?.forEach((item) => {
      if (!item.dataset.sakaiTooltip) {
        const fromTitle = item.getAttribute("title");
        const fromLabel = item.querySelector(".sakai-sidebar-page__label")?.textContent?.trim();
        item.dataset.sakaiTooltip = fromTitle || fromLabel || "";
      }
      const tipText = item.dataset.sakaiTooltip;
      const existing = bootstrap.Tooltip.getInstance(item);
      if (collapsed && tipText) {
        item.setAttribute("title", tipText);
        if (!existing) {
          new bootstrap.Tooltip(item, {
            container: "body",
            placement: "right",
            trigger: "hover focus",
            delay: { show: 150, hide: 0 },
          });
        }
      } else {
        existing?.dispose();
        item.removeAttribute("title");
      }
    });
  }

  toggle() {
    this.collapsed = !this.collapsed;
    this._portalContainer?.classList.toggle(this._toggleClass, this.collapsed);
    this._sitesSidebar?.classList.toggle(this._toggleClass, this.collapsed);
    this._syncUi(this.collapsed);
  }

  async setCollapsed(collapsed) {

    if (!portal?.user?.id) {
      return; // Exit the function early if the user is not logged in.
    }

    collapsed = collapsed ? "true" : "false";
    const putReq = await fetch(`/direct/userPrefs/updateKey/${portal.user.id}/sakai:portal:sitenav?sidebarCollapsed=${collapsed}`, { method: "PUT" });
    if (!putReq.ok) {
      console.error(`Could not set collapsed state "${collapsed}" for sidebar.`);
    }
  }
}
