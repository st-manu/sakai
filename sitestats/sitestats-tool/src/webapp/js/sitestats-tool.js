import(`./sitestats-report-editor.js${new URL(import.meta.url).search}`);

document.querySelector("#print-report")?.addEventListener("click", () => window.print());

const activityUser = document.getElementById("activity-user");
if (activityUser) {
  const submit = activityUser.form.querySelector("button[type=submit]");
  const updateSubmit = () => { submit.disabled = !activityUser.value; };
  activityUser.addEventListener("change", updateSubmit);
  updateSubmit();

  customElements.whenDefined("sakai-user-picker").then(() => {
    const picker = document.createElement("sakai-user-picker");
    picker.placeholder = activityUser.options[0].text;
    picker.bindSelect(activityUser);
  });
}
