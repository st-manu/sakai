const initOverflowMenus = () => {
  const overflowMenus = () => Array.from(document.querySelectorAll(
    ".sakai-table details.sakai-overflow-menu, .sakai-tool-header__actions details.sakai-overflow-menu",
  ));

  const reset = (menu) => {
    const panel = menu.querySelector(":scope > .sakai-overflow-menu__panel");
    if (!panel) {
      return;
    }
    panel.classList.remove("is-positioned");
    panel.style.removeProperty("--sakai-overflow-panel-top");
    panel.style.removeProperty("--sakai-overflow-panel-left");
  };

  const position = (menu) => {
    const summary = menu.querySelector(":scope > summary");
    const panel = menu.querySelector(":scope > .sakai-overflow-menu__panel");
    if (!summary || !panel) {
      return;
    }

    const summaryRect = summary.getBoundingClientRect();
    const panelWidth = panel.offsetWidth;
    const panelHeight = panel.offsetHeight;
    const margin = 8;
    const gap = 4;

    let left = Math.min(summaryRect.right - panelWidth, window.innerWidth - panelWidth - margin);
    left = Math.max(margin, left);

    let top = summaryRect.bottom + gap;
    if (top + panelHeight > window.innerHeight - margin) {
      top = summaryRect.top - panelHeight - gap;
    }
    top = Math.max(margin, top);

    panel.style.setProperty("--sakai-overflow-panel-left", `${left}px`);
    panel.style.setProperty("--sakai-overflow-panel-top", `${top}px`);
    panel.classList.add("is-positioned");
  };

  const repositionOpenMenus = () => {
    overflowMenus().forEach((menu) => {
      if (menu.open) {
        position(menu);
      }
    });
  };

  overflowMenus().forEach((menu) => {
    menu.addEventListener("toggle", () => {
      if (menu.open) {
        position(menu);
      } else {
        reset(menu);
      }
    });
  });

  document.addEventListener("click", (event) => {
    overflowMenus().forEach((menu) => {
      if (menu.open && !menu.contains(event.target)) {
        menu.open = false;
      }
    });
  });

  document.addEventListener("scroll", repositionOpenMenus, true);
  window.addEventListener("resize", repositionOpenMenus);
};

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", initOverflowMenus, { once: true });
} else {
  initOverflowMenus();
}
