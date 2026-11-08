const labelStackedTables = () => {
  document.querySelectorAll(".sakai-table--stack").forEach(table => {
    const headerRow = table.querySelector("thead tr");
    if (!headerRow) {
      return;
    }

    const headers = Array.from(headerRow.children);
    const labels = headers.map(header => {
      const clone = header.cloneNode(true);
      clone.querySelectorAll(".visually-hidden, .sakai-table__print-label").forEach(node => node.remove());
      return clone.textContent.trim();
    });

    table.querySelectorAll("tbody tr").forEach(row => {
      Array.from(row.children).forEach((cell, index) => {
        if (cell.hasAttribute("data-label") || cell.hasAttribute("colspan")) {
          return;
        }
        if (cell.classList.contains("sakai-table__select") || cell.classList.contains("sakai-table__actions")) {
          return;
        }
        if (headers[index]?.classList.contains("sakai-table__primary")) {
          cell.classList.add("sakai-table__primary");
        }
        const label = labels[index];
        if (label) {
          cell.setAttribute("data-label", label);
        } else if (!cell.textContent.trim() && !cell.querySelector("input, a, button, img, .si")) {
          cell.classList.add("sakai-table__empty");
        }
      });
    });
  });
};

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", labelStackedTables, { once: true });
} else {
  labelStackedTables();
}
