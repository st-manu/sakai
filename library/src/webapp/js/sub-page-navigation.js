class SubPageNavigation {

  constructor(data) {
    if (!data) {
      console.warn("No data provided for SubPageNavigation");
      return;
    }

    if (!Object.hasOwn(data, "pages")) {
      console.warn("No page data for SubPageNavigation");
      return;
    }

    if (!Object.hasOwn(data, "i18n")) {
      console.warn("No i18n data for SubPageNavigation");
      return;
    }

    this.data = data.pages;
    this.i18n = data.i18n;
    this.siteId = data.siteId;
    this.isInstructor = data.isInstructor;

    this.topLevelPageProps = {};
    data.topLevelPageProps.forEach((p) => { this.topLevelPageProps[p.toolId] = p; });

    this.setup();
  }

  setup() {
    Object.keys(this.data).forEach(pageId => {
      if (Object.hasOwn(this.topLevelPageProps, pageId)) {
        this.renderSubnavForPage(pageId, this.data[pageId], this.topLevelPageProps[pageId]);
      }
    });
    this.setCurrentPage();
  }

  _escapeHtml(value) {
    return String(value ?? "")
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;")
      .replaceAll("'", "&#39;");
  }

  _statusText(disabled, hidden, releaseDate) {
    if (disabled) {
      return (this.i18n.prerequisite_and_disabled || this.i18n.prerequisite || "")
        .replace(/^\[/, "").replace(/\]$/, "");
    }
    if (hidden && releaseDate) {
      return (this.i18n.hidden_with_release_date || "")
        .replace("{releaseDate}", releaseDate)
        .replace(/^\[/, "").replace(/\]$/, "");
    }
    if (hidden) {
      return (this.i18n.hidden || "").replace(/^\[/, "").replace(/\]$/, "");
    }
    return "";
  }

  _statusMarkup(disabled, hidden, releaseDate) {
    const text = this._statusText(disabled, hidden, releaseDate);
    if (!text) {
      return "";
    }
    const icon = disabled ? "bi-slash-circle" : "bi-eye-slash-fill";
    return `<span class="sakai-sidebar-page__status"><span class="sakai-sidebar-page__chip"><span class="bi ${icon}" aria-hidden="true"></span><span>${this._escapeHtml(text)}</span></span></span>`;
  }

  _childrenOf(node) {
    return Array.isArray(node?.children) ? node.children : [];
  }

  _bodyMarkup(label, statusHtml = "") {
    return `<span class="sakai-sidebar-page__body"><span class="sakai-sidebar-page__label">${label}</span>${statusHtml}</span>`;
  }

  _topLevelToolLink(pageId) {
    const escaped = CSS.escape(pageId);
    return document.querySelector(
      `#current-site-pages > .sakai-sidebar-page:not(.sakai-sidebar-page--lessons) > a.sakai-sidebar-page__link[href*="/tool/${escaped}"], `
      + `#current-site-pages > .sakai-sidebar-page:not(.sakai-sidebar-page--lessons) > a.sakai-sidebar-page__link[href*="/tool-reset/${escaped}"]`
    );
  }

  renderSubnavForPage(pageId, subpages, props) {
    const element = this._topLevelToolLink(pageId);
    if (!element) {
      return;
    }

    const siteListItem = element.parentElement;
    if (siteListItem.classList.contains("sakai-sidebar-page--lessons")) {
      return;
    }

    const pageName = element.querySelector(".sakai-sidebar-page__label")?.textContent?.trim()
      || this.topLevelPageProps[pageId].name;
    const mainLink = element.href?.replace(/\/tool\//, "/tool-reset/");
    const iconEl = element.querySelector(".sakai-sidebar-page__icon");
    const iconClass = iconEl?.className || "sakai-sidebar-page__icon si si-sakai-lessonbuildertool";
    const toolStatusHtml = element.querySelector(".sakai-sidebar-page__status")?.outerHTML || "";

    const collapseId = `page-${pageId}-lessons-subpages`;
    const isExpanded = subpages[0]?.toolId === this.getCurrentPlacement()
      || this._treeContainsCurrent(subpages);

    siteListItem.classList.add("sakai-sidebar-page--group", "sakai-sidebar-page--lessons");
    siteListItem.setAttribute("role", "none");
    element.remove();

    const expandLabel = this.i18n.expand || pageName;
    const collapseLabel = this.i18n.collapse || pageName;

    siteListItem.insertAdjacentHTML("afterbegin", `
      <button type="button"
          class="sakai-sidebar-page__link sakai-sidebar-page__toggle${isExpanded ? "" : " collapsed"}"
          data-bs-toggle="collapse"
          data-bs-target="#${collapseId}"
          data-main-href="${this._escapeHtml(mainLink)}"
          role="treeitem"
          tabindex="0"
          aria-expanded="${isExpanded ? "true" : "false"}"
          aria-controls="${collapseId}"
          title="${this._escapeHtml(pageName)}"
          aria-label="${this._escapeHtml(isExpanded ? collapseLabel : expandLabel)}: ${this._escapeHtml(pageName)}">
        <span class="bi bi-chevron-right sakai-sidebar-page__chevron" aria-hidden="true"></span>
        <span class="sakai-sidebar-page__icon-wrap">
          <span class="${iconClass}" aria-hidden="true"></span>
        </span>
        ${this._bodyMarkup(this._escapeHtml(pageName), toolStatusHtml)}
      </button>
      <ul id="${collapseId}"
          class="sakai-sidebar-page__group sakai-sidebar-page-list sakai-sidebar-page-list--nested collapse${isExpanded ? " show" : ""}"
          role="group"
          aria-label="${this._escapeHtml(pageName)}">
        <li class="sakai-sidebar-page" role="none">
          <a class="sakai-sidebar-page__link sakai-sidebar-page__link--main sakai-sidebar-page__link--text"
              href="${this._escapeHtml(mainLink)}"
              role="treeitem"
              tabindex="0"
              title="${this._escapeHtml(this.i18n.main_link_name)}"
              data-lessons-main="true">
            ${this._bodyMarkup(this._escapeHtml(this.i18n.main_link_name))}
          </a>
        </li>
        ${this._renderNodes(subpages, props)}
      </ul>
    `);

    this._bindGroupToggles(siteListItem);
  }

  _treeContainsCurrent(nodes) {
    const placement = this.getCurrentPlacement();
    const pageIdInput = document.getElementById("lessonsSubnavPageId");
    const itemIdInput = document.getElementById("lessonsSubnavItemId");
    const currentPage = pageIdInput?.value;
    const currentItem = itemIdInput?.value;

    const walk = (list) => list.some((node) => {
      if (currentPage && String(node.sendingPage) === String(currentPage)) return true;
      if (currentItem && String(node.itemId) === String(currentItem)) return true;
      if (node.toolId === placement && currentPage) return true;
      return walk(this._childrenOf(node));
    });
    return walk(nodes || []);
  }

  _renderNodes(nodes, ancestorProps) {
    return (nodes || []).map((node) => {
      const children = this._childrenOf(node);
      if (children.length) {
        return this._renderGroupNode(node, ancestorProps, children);
      }
      return this._renderLeafNode(node, ancestorProps);
    }).join("");
  }

  _renderGroupNode(node, ancestorProps, children) {
    const collapseId = `lessons-node-${node.itemId}`;
    const open = this._treeContainsCurrent([node]);
    const disabled = this._isDisabled(node, ancestorProps);
    const hidden = node.hidden === "true" && !disabled && ancestorProps.disabled !== "true";
    const name = this._escapeHtml(node.name);
    const status = this._statusMarkup(disabled, hidden, node.releaseDate);

    return `
      <li class="sakai-sidebar-page sakai-sidebar-page--group sakai-sidebar-page--nested-group" role="none">
        <button type="button"
            class="sakai-sidebar-page__link sakai-sidebar-page__toggle sakai-sidebar-page__toggle--nested${open ? "" : " collapsed"}"
            data-bs-toggle="collapse"
            data-bs-target="#${collapseId}"
            data-main-href="${this._escapeHtml(this.buildSubpageUrlFor(node))}"
            role="treeitem"
            tabindex="0"
            aria-expanded="${open ? "true" : "false"}"
            aria-controls="${collapseId}"
            title="${name}"
            aria-label="${this._escapeHtml(open ? (this.i18n.collapse || "") : (this.i18n.expand || ""))}: ${name}">
          <span class="bi bi-chevron-right sakai-sidebar-page__chevron" aria-hidden="true"></span>
          ${this._bodyMarkup(name, status)}
        </button>
        <ul id="${collapseId}"
            class="sakai-sidebar-page__group sakai-sidebar-page-list sakai-sidebar-page-list--nested collapse${open ? " show" : ""}"
            role="group"
            aria-label="${name}">
          <li class="sakai-sidebar-page" role="none">
            <a class="sakai-sidebar-page__link sakai-sidebar-page__link--main sakai-sidebar-page__link--text${disabled ? " is-disabled" : ""}"
                href="${this._escapeHtml(this.buildSubpageUrlFor(node))}"
                role="treeitem"
                tabindex="0"
                title="${name}"
                ${disabled ? 'aria-disabled="true" tabindex="-1"' : ""}>
              ${this._bodyMarkup(this._escapeHtml(this.i18n.main_link_name))}
            </a>
          </li>
          ${this._renderNodes(children, node)}
        </ul>
      </li>`;
  }

  _renderLeafNode(node, ancestorProps) {
    const disabled = this._isDisabled(node, ancestorProps);
    const hidden = node.hidden === "true" && !disabled && ancestorProps.disabled !== "true";
    const name = this._escapeHtml(node.name);

    return `
      <li class="sakai-sidebar-page" role="none">
        <a class="sakai-sidebar-page__link sakai-sidebar-page__link--child sakai-sidebar-page__link--text${disabled ? " is-disabled" : ""}"
            href="${this._escapeHtml(this.buildSubpageUrlFor(node))}"
            role="treeitem"
            tabindex="0"
            title="${name}"
            ${disabled ? 'aria-disabled="true"' : ""}>
          ${this._bodyMarkup(name, this._statusMarkup(disabled, hidden, node.releaseDate))}
        </a>
      </li>`;
  }

  _isDisabled(node, ancestorProps) {
    return (ancestorProps.disabled === "true" && ancestorProps.disabledDueToPrerequisite === "true")
      || (node.disabled === "true" && node.disabledDueToPrerequisite === "true");
  }

  _bindGroupToggles(root) {
    root.querySelectorAll(".sakai-sidebar-page--group").forEach((groupLi) => {
      const toggle = groupLi.querySelector(":scope > .sakai-sidebar-page__toggle");
      const target = toggle?.getAttribute("data-bs-target");
      const collapseEl = target ? groupLi.querySelector(`:scope > ${target}`) : null;
      if (!toggle || !collapseEl || toggle.dataset.sakaiCollapseBound === "true") {
        return;
      }
      toggle.dataset.sakaiCollapseBound = "true";

      collapseEl.addEventListener("show.bs.collapse", e => {
        e.stopPropagation();
        toggle.setAttribute("aria-expanded", "true");
        toggle.classList.remove("collapsed");
      });
      collapseEl.addEventListener("hide.bs.collapse", e => {
        e.stopPropagation();
        toggle.setAttribute("aria-expanded", "false");
        toggle.classList.add("collapsed");
      });
    });
  }

  buildSubpageUrlFor(subpage) {
    return `/portal/site/${encodeURIComponent(subpage.siteId)}`
        + `/tool/${encodeURIComponent(subpage.toolId)}`
        + `/ShowPage?sendingPage=${encodeURIComponent(subpage.sendingPage)}`
        + `&itemId=${encodeURIComponent(subpage.itemId)}`
        + "&path=clear_and_push"
        + `&title=${encodeURIComponent(subpage.name)}`
        + "&newTopLevel=false";
  }

  getCurrentPlacement() {
    const parts = (new URL(window.location.href)).pathname.split("/");
    return parts.length >= 6 ? parts[5] : "";
  }

  getSubPageElement() {
    const subPageNavToolIdInput = document.getElementById("lessonsSubnavToolId");
    const subPageNavPageIdInput = document.getElementById("lessonsSubnavPageId");
    const subPageNavItemIdInput = document.getElementById("lessonsSubnavItemId");
    let subPageElement = null;

    if (subPageNavToolIdInput && subPageNavPageIdInput && subPageNavItemIdInput) {
      subPageElement = document.querySelector(
        `#toolMenu a[href*="sendingPage=${CSS.escape(subPageNavPageIdInput.value)}"][href*="itemId=${CSS.escape(subPageNavItemIdInput.value)}"]`
      );
    }

    if (!subPageElement && subPageNavToolIdInput) {
      subPageElement = document.querySelector(
        `#toolMenu a[data-lessons-main="true"][href*="/tool-reset/${CSS.escape(subPageNavToolIdInput.value)}"], `
        + `#toolMenu a[data-lessons-main="true"][href*="/tool/${CSS.escape(subPageNavToolIdInput.value)}"]`
      );
    }

    return subPageElement;
  }

  setCurrentPage() {
    let subpageElement = this.getSubPageElement();

    if (!subpageElement) {
      subpageElement = document.querySelector(
        `#toolMenu a[data-lessons-main="true"][href$="/tool-reset/${CSS.escape(this.getCurrentPlacement())}"], `
        + `#toolMenu a[data-lessons-main="true"][href$="/tool/${CSS.escape(this.getCurrentPlacement())}"]`
      );
    }

    if (!subpageElement) {
      return;
    }

    document.querySelectorAll("#toolMenu .sakai-sidebar-page__link[aria-current], #toolMenu .sakai-sidebar-page__link.selected-page").forEach((el) => {
      el.removeAttribute("aria-current");
      el.classList.remove("selected-page");
    });

    subpageElement.classList.add("selected-page");
    subpageElement.setAttribute("aria-current", "page");
  }
}

window.SubPageNavigation = SubPageNavigation;
