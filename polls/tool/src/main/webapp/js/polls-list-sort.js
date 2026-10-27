document.addEventListener("DOMContentLoaded", () => {
  const table = document.getElementById("sortableTable");
  if (!table) {
    return;
  }

  const tbody = table.tBodies[0];
  const headers = Array.from(table.querySelectorAll("thead th"));
  if (!tbody || headers.length === 0) {
    return;
  }

  const defaultSortIndex = headers.findIndex((th) => th.dataset.defaultSort);
  let sortColumn = defaultSortIndex >= 0 ? defaultSortIndex : 0;
  let sortDir = defaultSortIndex >= 0
    ? (headers[defaultSortIndex].dataset.defaultSort || "asc")
    : "asc";

  const cellSortValue = (row, columnIndex) => {
    const cell = row.children[columnIndex];
    if (!cell) {
      return "";
    }
    const order = cell.getAttribute("data-order");
    if (order != null && order !== "") {
      return order;
    }
    return (cell.textContent || "").trim().toLocaleLowerCase();
  };

  const applySort = () => {
    const rows = Array.from(tbody.rows);
    rows.sort((a, b) => {
      const av = cellSortValue(a, sortColumn);
      const bv = cellSortValue(b, sortColumn);
      if (av < bv) {
        return sortDir === "asc" ? -1 : 1;
      }
      if (av > bv) {
        return sortDir === "asc" ? 1 : -1;
      }
      return 0;
    });
    rows.forEach((row) => tbody.appendChild(row));

    headers.forEach((th, index) => {
      const btn = th.querySelector(".sakai-table__sort");
      if (!btn) {
        return;
      }
      const active = index === sortColumn;
      btn.setAttribute("aria-sort", active ? (sortDir === "asc" ? "ascending" : "descending") : "none");
      btn.classList.toggle("is-sorted", active);
      btn.classList.toggle("is-sorted-asc", active && sortDir === "asc");
      btn.classList.toggle("is-sorted-desc", active && sortDir === "desc");
    });
  };

  headers.forEach((th, index) => {
    if (th.classList.contains("no-sort")) {
      return;
    }
    const label = (th.textContent || "").trim();
    const title = th.getAttribute("title") || label;
    th.textContent = "";
    const btn = document.createElement("button");
    btn.type = "button";
    btn.className = "sakai-table__sort";
    btn.textContent = label;
    btn.title = title;
    btn.setAttribute("aria-sort", "none");
    btn.addEventListener("click", () => {
      if (sortColumn === index) {
        sortDir = sortDir === "asc" ? "desc" : "asc";
      } else {
        sortColumn = index;
        sortDir = th.dataset.defaultSort || "asc";
      }
      applySort();
    });
    th.appendChild(btn);
  });

  applySort();
});
