(() => {

const initialiseList = (reorderer, list, shared) => {

  if (!reorderer || !list) {
    return;
  }

  const items = () => Array.from(list.querySelectorAll(":scope > .reorder-element"));
  const order = () => items().map(item => item.dataset.reorderableId);
  const restore = itemOrder => {
    const itemsById = new Map(items().map(item => [ item.dataset.reorderableId, item ]));
    itemOrder.forEach(id => {
      const item = itemsById.get(id);
      if (item) {
        list.append(item);
      }
    });
    reorderer.refresh();
  };

  const initialOrder = order();
  let previousOrder = [ ...initialOrder ];

  const updateMoveButtons = () => {
    const reorderItems = items();
    reorderItems.forEach((item, index) => {
      const moveUp = item.querySelector(':scope > .sakai-reorder-row-main [data-action="move-up"]');
      const moveDown = item.querySelector(':scope > .sakai-reorder-row-main [data-action="move-down"]');
      if (moveUp) {
        moveUp.disabled = index === 0;
      }
      if (moveDown) {
        moveDown.disabled = index === reorderItems.length - 1;
      }
    });
  };

  const updateOrder = movedItem => {
    updateMoveButtons();
    shared.enableUndo();

    const reorderedItems = items();
    if (shared.lastItemMoved?.dataset.movedMessage && movedItem) {
      shared.lastItemMoved.textContent = shared.lastItemMoved.dataset.movedMessage
        .replace("{0}", reorderedItems.indexOf(movedItem) + 1)
        .replace("{1}", reorderedItems.length);
    }
  };

  const savePreviousOrder = itemOrder => {
    previousOrder = [ ...(itemOrder || order()) ];
    shared.setLastList({ restore: () => restore(previousOrder), updateOrder });
    if (shared.lastMoveArray) {
      shared.lastMoveArray.textContent = previousOrder.join(" ");
    }
  };

  shared.registerInitial(() => restore(initialOrder));
  if (shared.lastMoveArrayInit) {
    const existing = shared.lastMoveArrayInit.textContent.trim();
    shared.lastMoveArrayInit.textContent = existing
      ? `${existing} ${initialOrder.join(" ")}`
      : initialOrder.join(" ");
  }
  if (shared.lastMoveArray) {
    shared.lastMoveArray.textContent = initialOrder.join(" ");
  }

  updateMoveButtons();

  reorderer.addEventListener("reordered", event => {
    savePreviousOrder(event.detail.previousReorderedIds);
    const movedItem = items().find(item => item.dataset.reorderableId === event.detail.data.reorderableId);
    updateOrder(movedItem);
  });

  list.addEventListener("click", event => {
    const button = event.target.closest("button[data-action]");
    if (!button || !list.contains(button) || button.closest(".sakai-reorder-list") !== list) {
      return;
    }

    const row = button.closest(":scope > .reorder-element") || button.closest(".reorder-element");
    if (!row || row.parentElement !== list) {
      return;
    }

    if (button.dataset.action === "move-up") {
      const previous = row.previousElementSibling;
      if (!previous) {
        return;
      }
      savePreviousOrder();
      list.insertBefore(row, previous);
      reorderer.refresh();
      updateOrder(row);
    } else if (button.dataset.action === "move-down") {
      const next = row.nextElementSibling;
      if (!next) {
        return;
      }
      savePreviousOrder();
      list.insertBefore(next, row);
      reorderer.refresh();
      updateOrder(row);
    }
  });
};

const initialise = () => {

  const forumsReorderer = document.getElementById("forums-reorderer");
  const forumsList = document.getElementById("forums-reorder-list");
  if (!forumsReorderer || !forumsList) {
    return;
  }

  const undoLast = document.getElementById("undo-last");
  const undoAll = document.getElementById("undo-all");
  const initialRestores = [];
  let lastList = null;

  const shared = {
    undoLast,
    undoAll,
    lastMoveArray: document.getElementById("lastMoveArray"),
    lastMoveArrayInit: document.getElementById("lastMoveArrayInit"),
    lastItemMoved: document.getElementById("lastItemMoved"),
    enableUndo: () => {
      if (undoLast) {
        undoLast.disabled = false;
      }
      if (undoAll) {
        undoAll.disabled = false;
      }
    },
    setLastList: listApi => {
      lastList = listApi;
    },
    registerInitial: restore => {
      initialRestores.push(restore);
    }
  };

  initialiseList(forumsReorderer, forumsList, shared);

  forumsList.querySelectorAll(".sakai-reorder-nested > sakai-reorderer").forEach(topicsReorderer => {
    const topicsList = topicsReorderer.querySelector(":scope > .sakai-reorder-list");
    initialiseList(topicsReorderer, topicsList, shared);
  });

  undoLast?.addEventListener("click", event => {
    event.preventDefault();
    if (!lastList) {
      return;
    }
    lastList.restore();
    lastList.updateOrder();
  });

  undoAll?.addEventListener("click", event => {
    event.preventDefault();
    initialRestores.forEach(restore => restore());
    forumsList.querySelectorAll("sakai-reorderer").forEach(reorderer => reorderer.refresh?.());
    forumsReorderer.refresh();
  });
};

customElements.whenDefined("sakai-reorderer").then(initialise);

})();
