class MobileLogin {

  constructor(element, config) {

    this._passConfig = config?.passwordField;
    this._element = element;
    this._element.addEventListener("click", this.showModal.bind(this));
  }

  async showModal() {

    //If modal dialog is not loaded yet, do it now 
    if (!this._loaded) {
      this.createModalElement();
      await this.loadLoginDialog();
      this.adjustLoginDialog();
      const passwordField = this._modalEl.querySelector(".password-field");
      if (passwordField) {
        this.passwordField = new PasswordField(passwordField, this._passConfig);
      }
      this._modal = new bootstrap.Modal(this._modalEl);
      this._loaded = true;
    }
    this._modal.show();
  }

  createModalElement() {

    this._modalEl = document.createElement("div");
    this._modalEl.classList.add("modal");
    this._modalEl.setAttribute("id", "mobileLoginModal");
    this._modalEl.setAttribute("tabindex", -1);
    document.body.appendChild(this._modalEl);
  }

  //Loads html from the xlogin endpoint and inserts the dialog into the modal
  async loadLoginDialog() {

    const xloginQuery = await fetch('/portal/xlogin');
    if (!xloginQuery.ok) return;

    const xloginHtml = await xloginQuery.text();
    const parser = new DOMParser();
    const xloginDocument = parser.parseFromString(xloginHtml, 'text/html');
    const formShell = xloginDocument.querySelector(".sakai-login-page__form-shell");
    if (!formShell) return;

    const dialog = document.createElement("div");
    dialog.className = "modal-dialog modal-dialog-centered";
    const content = document.createElement("div");
    content.className = "modal-content sakai-login-page__modal";
    content.appendChild(formShell);
    dialog.appendChild(content);
    this._modalEl.appendChild(dialog);
  }

  //Makes adjustments, to make the dialog viable to be displayed in a modal
  adjustLoginDialog() {

    // Show the close button, which is hidden on the standalone page
    this._modalEl?.querySelector(".btn-close")?.classList.remove("d-none");

    // The cancel button only makes sense on the full page
    this._modalEl?.querySelector("input[name='cancel']")?.classList.add("d-none");
  }
}
