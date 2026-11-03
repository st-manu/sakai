import(`./sitestats-report-editor.js${new URL(import.meta.url).search}`);

document.querySelector("#print-report")?.addEventListener("click", () => window.print());
