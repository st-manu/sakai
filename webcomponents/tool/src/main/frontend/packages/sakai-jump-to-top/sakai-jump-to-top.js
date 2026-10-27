import { loadProperties } from "@sakai-ui/sakai-i18n";

async function init() {

  const portalMainContainer = document.querySelector(".portal-main-container");
  if (!portalMainContainer) {
    return;
  }

  let jumptotopLabel = "Jump to top";
  try {
    const i18n = await loadProperties("jumptotop");
    if (i18n?.jumptotop_title) {
      jumptotopLabel = i18n.jumptotop_title;
    }
  } catch (error) {
    console.warn("jumptotop i18n unavailable, using fallback label", error);
  }

  let jumpToTopButton = document.querySelector(".jump-to-top");
  if (!jumpToTopButton) {
    jumpToTopButton = document.createElement("button");
    jumpToTopButton.type = "button";
    jumpToTopButton.classList.add("jump-to-top", "sakai-portal-fab", "sakai-portal-fab--jump");
    jumpToTopButton.insertAdjacentHTML("beforeend", "<span class=\"bi bi-arrow-up sakai-portal-fab__icon\" aria-hidden=\"true\"></span>");
  }

  jumpToTopButton.type = "button";
  jumpToTopButton.title = jumptotopLabel;
  jumpToTopButton.ariaLabel = jumptotopLabel;

  if (!jumpToTopButton.dataset.jumpBound) {
    jumpToTopButton.dataset.jumpBound = "true";
    jumpToTopButton.addEventListener("click", () => {
      portalMainContainer.scrollTo({ top: 0, behavior: "smooth" });
    });
  }

  const fabs = document.getElementById("sakai-portal-fabs");
  if (fabs) {
    const presence = document.getElementById("footerAppPresence");
    if (presence) {
      fabs.insertBefore(jumpToTopButton, presence);
    } else if (jumpToTopButton.parentElement !== fabs) {
      fabs.appendChild(jumpToTopButton);
    }
  } else if (jumpToTopButton.parentElement !== portalMainContainer) {
    portalMainContainer.appendChild(jumpToTopButton);
  }

  const sync = () => {
    jumpToTopButton.classList.toggle("show", portalMainContainer.scrollTop > 500);
  };
  portalMainContainer.addEventListener("scroll", sync, { passive: true });
  sync();
}

export { init };
