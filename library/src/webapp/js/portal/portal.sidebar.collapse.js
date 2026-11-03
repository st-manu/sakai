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
    this._element = element;
    this._element.addEventListener("click", this.toggle.bind(this));
    this._syncUi(this.collapsed);
  }

  _syncUi(collapsed) {
    this._element.title = collapsed ? this._i18n.titleCollapsed : this._i18n.titleExpanded;
    this._element.setAttribute("aria-label", this._element.title);

    const label = this._element.querySelector(".sakai-sidebar__collapse-label");
    if (label) {
      label.textContent = collapsed ? this._i18n.titleCollapsed : this._i18n.titleExpanded;
    }

    this._syncToolTooltips(collapsed);
  }

  _syncToolTooltips(collapsed) {
    if (typeof bootstrap === "undefined" || !bootstrap.Tooltip) {
      return;
    }
    const links = this._sitesSidebar?.querySelectorAll(".is-current-site .sakai-sidebar-page__link[title], .sakai-sidebar-site--current .sakai-sidebar-page__link[title]");
    links?.forEach((link) => {
      const existing = bootstrap.Tooltip.getInstance(link);
      if (collapsed) {
        if (!existing) {
          new bootstrap.Tooltip(link, {
            container: "body",
            placement: "right",
            trigger: "hover focus",
            delay: { show: 150, hide: 0 },
          });
        }
      } else {
        existing?.dispose();
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
