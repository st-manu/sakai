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

  const sortable = headers
    .map((th, index) => ({ th, index, button: th.querySelector(".sakai-table__sort") }))
    .filter(({ button }) => button);

  if (sortable.length === 0) {
    return;
  }

  const defaultHeader = headers.findIndex((th) => th.dataset.defaultSort);
  let sortColumn = defaultHeader >= 0 ? defaultHeader : sortable[0].index;
  let sortDir = defaultHeader >= 0
    ? (headers[defaultHeader].dataset.defaultSort || "asc")
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

    sortable.forEach(({ th, index, button }) => {
      const active = index === sortColumn;
      th.setAttribute("aria-sort", active ? (sortDir === "asc" ? "ascending" : "descending") : "none");
      button.classList.toggle("is-sorted", active);
      button.classList.toggle("is-sorted-asc", active && sortDir === "asc");
      button.classList.toggle("is-sorted-desc", active && sortDir === "desc");
    });
  };

  sortable.forEach(({ th, index, button }) => {
    button.addEventListener("click", () => {
      if (sortColumn === index) {
        sortDir = sortDir === "asc" ? "desc" : "asc";
      } else {
        sortColumn = index;
        sortDir = th.dataset.defaultSort || "asc";
      }
      applySort();
    });
  });

  applySort();
});
