(function () {
  const main = document.querySelector(".portal-main-container");

  let fabs = null;
  let presenceWrap = null;
  let presenceToggle = null;
  let presenceArea = null;
  let presenceClose = null;
  let presenceBound = false;
  let adoptingJump = false;

  const resolvePresenceEls = () => {
    fabs = document.getElementById("sakai-portal-fabs");
    presenceWrap = document.getElementById("footerAppPresence");
    presenceToggle = document.getElementById("presenceToggle");
    presenceArea = document.getElementById("presenceArea");
    presenceClose = document.getElementById("presenceClose");
  };

  const isPresenceHidden = () =>
    !presenceArea
    || presenceArea.classList.contains("is-hidden")
    || presenceArea.hasAttribute("hidden");

  const setPresenceOpen = (open) => {
    if (!presenceArea || !presenceToggle) {
      return;
    }
    presenceArea.classList.toggle("is-hidden", !open);
    if (open) {
      presenceArea.removeAttribute("hidden");
      if (typeof window.updatePresence === "function") {
        window.updatePresence();
      } else if (typeof window.delayedUpdatePresence === "function") {
        window.delayedUpdatePresence();
      }
    } else {
      presenceArea.setAttribute("hidden", "");
    }
    presenceToggle.setAttribute("aria-expanded", open ? "true" : "false");
    presenceToggle.classList.toggle("is-active", open);
  };

  const togglePresence = () => {
    setPresenceOpen(isPresenceHidden());
  };

  const bindPresence = () => {
    resolvePresenceEls();
    if (presenceBound || !presenceWrap) {
      return;
    }
    presenceBound = true;

    presenceWrap.addEventListener("click", (event) => {
      event.preventDefault();
      event.stopImmediatePropagation();
      togglePresence();
    }, true);

    presenceClose?.addEventListener("click", (event) => {
      event.preventDefault();
      event.stopImmediatePropagation();
      setPresenceOpen(false);
    }, true);

    document.addEventListener("keydown", (event) => {
      if (event.key === "Escape" && !isPresenceHidden()) {
        setPresenceOpen(false);
        presenceToggle?.focus();
      }
    });
  };

  const syncJumpVisibility = (jump) => {
    if (!main || !jump) {
      return;
    }
    jump.classList.toggle("show", main.scrollTop > 500);
  };

  const adoptJump = (jump) => {
    if (!jump || adoptingJump) {
      return;
    }
    resolvePresenceEls();
    jump.classList.add("sakai-portal-fab", "sakai-portal-fab--jump");
    jump.type = "button";
    const icon = jump.querySelector("i, .bi, .si, span.sakai-portal-fab__icon, span");
    if (icon) {
      icon.className = "bi bi-arrow-up sakai-portal-fab__icon";
      icon.setAttribute("aria-hidden", "true");
    }

    adoptingJump = true;
    try {
      if (fabs) {
        if (presenceWrap) {
          if (jump.parentElement !== fabs || jump.nextElementSibling !== presenceWrap) {
            fabs.insertBefore(jump, presenceWrap);
          }
        } else if (jump.parentElement !== fabs) {
          fabs.appendChild(jump);
        }
      } else if (main && jump.parentElement !== main) {
        main.appendChild(jump);
      }
    } finally {
      adoptingJump = false;
    }
    syncJumpVisibility(jump);
  };

  const ensureJump = () => {
    let jump = document.querySelector(".jump-to-top");
    if (jump) {
      adoptJump(jump);
      return jump;
    }
    if (!main) {
      return null;
    }
    const label = document.documentElement.lang?.startsWith("es")
      ? "Volver arriba"
      : "Jump to top";
    jump = document.createElement("button");
    jump.type = "button";
    jump.title = label;
    jump.setAttribute("aria-label", label);
    jump.className = "jump-to-top sakai-portal-fab sakai-portal-fab--jump";
    jump.innerHTML = "<span class=\"bi bi-arrow-up sakai-portal-fab__icon\" aria-hidden=\"true\"></span>";
    jump.addEventListener("click", () => {
      main.scrollTo({ top: 0, behavior: "smooth" });
    });
    adoptJump(jump);
    return jump;
  };

  if (main) {
    main.addEventListener("scroll", () => {
      syncJumpVisibility(document.querySelector(".jump-to-top"));
    }, { passive: true });
  }

  const observer = new MutationObserver(() => {
    if (adoptingJump) {
      return;
    }
    bindPresence();
    const found = document.querySelector(".jump-to-top");
    if (found) {
      adoptJump(found);
    }
  });

  const startObserving = () => {
    resolvePresenceEls();
    const root = fabs || main || document.body;
    if (!root) {
      return false;
    }
    observer.observe(root, { childList: true });
    return true;
  };

  const boot = () => {
    bindPresence();
    startObserving();
    ensureJump();
    setTimeout(ensureJump, 0);
    setTimeout(ensureJump, 500);
    setTimeout(ensureJump, 2000);
  };

  if (document.body) {
    boot();
  } else {
    document.addEventListener("DOMContentLoaded", boot);
  }
})();
