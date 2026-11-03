import { html, nothing } from "lit";
import { styleMap } from "lit/directives/style-map.js";
import { SakaiElement } from "@sakai-ui/sakai-element";
import { pushSetupComplete, registerPushCallback } from "@sakai-ui/sakai-push-utils";
import { markNotificationsViewed } from "@sakai-ui/sakai-notifications";
import "@sakai-ui/sakai-course-card/course-card-settings.js";

export class SakaiCourseCard extends SakaiElement {

  static properties = {
    courseData: { type: Object },
    siteId: { attribute: "site-id", type: String },
    density: { type: String },
    showPin: { attribute: "show-pin", type: Boolean },
    pinned: { type: Boolean },
    _styles: { state: true },
    _accentStyles: { state: true },
  };

  constructor() {

    super();

    this.loadTranslations("coursecard");
    this._onNotificationsCleared = () => {
      if (!this.courseData?.tools) {
        return;
      }
      this.courseData.tools.forEach(t => { t.hasAlerts = false; });
      this.requestUpdate();
    };
  }

  connectedCallback() {

    super.connectedCallback();

    document.body.addEventListener("notifications-cleared", this._onNotificationsCleared);

    if (!this.courseData) {
      if (!this.siteId) {
        console.error("Either courseData or site-id must be specified");
        return;
      }

      const url = `/api/sites/${this.siteId}`;
      fetch(url)
      .then(r => {

        if (r.ok) {
          return r.json();
        }
        throw new Error(`Network error while fetching site data from ${url}`);
      })
      .then(courseData => {

        this.courseData = courseData;
        this._init();
      })
      .catch(error => console.error(error));

    } else {
      this._init();
    }
  }

  disconnectedCallback() {

    super.disconnectedCallback();

    document.body.removeEventListener("notifications-cleared", this._onNotificationsCleared);

    if (this._lastBackgroundImageUrl) {
      URL.revokeObjectURL(this._lastBackgroundImageUrl);
    }
  }

  _hasDecoratedBackground() {

    return Boolean(this.courseData?.image || this.courseData?.courseCardBackgroundColor);
  }

  _applySurfaceStyles() {

    this._styles = {};
    this._accentStyles = {};

    if (this.courseData.image) {
      this._styles.backgroundImage = `linear-gradient(var(--sakai-course-card-gradient-start), var(--sakai-course-card-gradient-end)), url(${this.courseData.image})`;
    } else if (this.courseData.courseCardBackgroundColor) {
      this._styles.backgroundColor = this.courseData.courseCardBackgroundColor;
    }

    if (this._hasDecoratedBackground() && this.courseData.courseCardForegroundColor) {
      this._styles.color = this.courseData.courseCardForegroundColor;
      this._accentStyles = { color: this.courseData.courseCardForegroundColor };
    }
  }

  _init() {

    this._applySurfaceStyles();

    pushSetupComplete.then(() => {

      if (Notification.permission !== "granted") return;

      registerPushCallback("notifications", message => {

        if (this.courseData.siteId !== message.siteId) return;

        this.courseData.tools.forEach(t => {

          if (t.id === message.tool && !message.viewed) t.hasAlerts = true;
          this.requestUpdate();
        });
      });
    })
    .catch(error => console.error(error));
  }

  _toolClicked(e) {
    markNotificationsViewed(this.courseData.siteId, e.currentTarget.dataset.toolId);
  }

  _backgroundColorChanged(e) {

    delete this._styles.backgroundImage;
    this.courseData = { ...this.courseData, courseCardBackgroundColor: e.detail.color, image: undefined };
    this._applySurfaceStyles();
    this.requestUpdate();
  }

  _foregroundColorChanged(e) {

    this.courseData = { ...this.courseData, courseCardForegroundColor: e.detail.color };
    this._applySurfaceStyles();
    this.requestUpdate();
  }

  _imageSelected(e) {

    this.courseData = { ...this.courseData, image: e.detail.url };
    this._applySurfaceStyles();
    this.requestUpdate();
  }

  _openSettingsModal() {

    this.renderRoot.querySelector("course-card-settings")?.showModal();
  }

  _save() {
    this.renderRoot.querySelector(`course-card-settings[course-id='${this.courseData.siteId}']`)?._save();
  }

  shouldUpdate() {
    return this._i18n && this.courseData;
  }

  willUpdate() {

    const compact = this.density === "compact";
    if (compact) {
      this.setAttribute("density", "compact");
    } else {
      this.removeAttribute("density");
    }

    const hasAlerts = Boolean(this.courseData && this._alertTools().length);
    this.classList.toggle("sakai-course-card--has-alerts", hasAlerts);
  }

  _effectiveDensity() {

    return this.density === "compact" ? "compact" : "comfortable";
  }

  _alertTools() {
    return (this.courseData?.tools || []).filter(tool => tool.hasAlerts);
  }

  _togglePin(e) {

    e.preventDefault();
    e.stopPropagation();

    this.pinned = !this.pinned;
    if (this.courseData) {
      this.courseData = { ...this.courseData, pinned: this.pinned };
    }

    this.dispatchEvent(new CustomEvent("site-pin-changed", {
      detail: {
        siteId: this.courseData.siteId,
        siteTitle: this.courseData.title,
        pinned: this.pinned,
        source: "sites-launcher",
      },
      bubbles: true,
      composed: true,
    }));
  }

  _renderSettingsModal() {

    return html`
      <course-card-settings id="card-settings-dialog-${this.courseData.siteId}" course-id="${this.courseData.siteId}"
          course-title="${this.courseData.title}"
          background-color="${this.courseData.courseCardBackgroundColor}"
          foreground-color="${this.courseData.courseCardForegroundColor}"
          image-url="${this.courseData.image}"
          @image-selected=${this._imageSelected}
          @background-color-changed=${this._backgroundColorChanged}
          @foreground-color-changed=${this._foregroundColorChanged}>
      </course-card-settings>
    `;
  }

  render() {

    const density = this._effectiveDensity();
    const description = this.courseData.shortDescription?.trim();
    const alertTools = this._alertTools();
    const decorated = this._hasDecoratedBackground();
    const hasActions = this.showPin || this.courseData.canEdit;
    const surfaceClasses = [
      "sakai-course-card__surface",
      `sakai-course-card__surface--${density}`,
      decorated ? "sakai-course-card__surface--decorated" : "sakai-course-card__surface--plain",
    ].join(" ");
    const titleClasses = [
      "sakai-course-card__title",
      decorated ? "" : "sakai-course-card__title--link",
    ].filter(Boolean).join(" ");

    return html`
      ${this._renderSettingsModal()}
      <div class="sakai-course-card__shell">
        <div class="${surfaceClasses}" style=${styleMap(this._styles)}>
          ${hasActions ? html`
            <div class="sakai-course-card__actions">
              ${this.showPin ? html`
                <button type="button"
                    class="sakai-btn-icon sakai-course-card__pin ${this.pinned ? "sakai-course-card__pin--on" : ""}"
                    data-pinned="${this.pinned ? "true" : "false"}"
                    title="${(this.pinned ? this._i18n.unpin_tooltip : this._i18n.pin_tooltip)} ${this.courseData.title}"
                    aria-pressed="${this.pinned ? "true" : "false"}"
                    aria-label="${(this.pinned ? this._i18n.unpin_tooltip : this._i18n.pin_tooltip)} ${this.courseData.title}"
                    @click=${this._togglePin}>
                  <i class="si si-pin sakai-pin-icon__outline" style=${styleMap(this._accentStyles)} aria-hidden="true"></i>
                  <i class="si si-pin-fill sakai-pin-icon__fill" style=${styleMap(this._accentStyles)} aria-hidden="true"></i>
                </button>
              ` : nothing}
              ${this.courseData.canEdit ? html`
                <button type="button"
                    class="sakai-btn-icon sakai-course-card__settings"
                    title="${this._i18n.settings_tooltip}"
                    @click=${this._openSettingsModal}>
                  <i class="bi bi-three-dots-vertical" style=${styleMap(this._accentStyles)} aria-hidden="true"></i>
                </button>
              ` : nothing}
            </div>
          ` : nothing}
          <div class="sakai-course-card__content ${hasActions ? "sakai-course-card__content--has-actions" : ""}">
            <a class="${titleClasses}"
                href="${this.courseData.url}"
                title="${this._i18n.visit} ${this.courseData.title}"
                style=${styleMap(this._accentStyles)}>
              ${this.courseData.title}
            </a>
            ${description ? html`
              <a class="sakai-course-card__description-link ${decorated ? "" : "sakai-course-card__description-link--plain"}"
                  href="${this.courseData.url}"
                  title="${this._i18n.visit} ${this.courseData.title}">
                <div class="sakai-course-card__description" title="${description}" style=${styleMap(this._accentStyles)}>
                  ${description}
                </div>
              </a>
            ` : nothing}
          </div>
        </div>

        ${alertTools.length ? html`
        <div class="sakai-course-card__alerts">
          ${alertTools.map(tool => html`
            <a class="sakai-course-card__alert"
                href="${tool.url}"
                @click=${this._toolClicked}
                data-tool-id="${tool.id}"
                title="${tool.title}">
              <i class="si ${tool.iconClass}" aria-hidden="true"></i>
              <span class="portal-notifications-indicator"><span class="visually-hidden">${tool.title}</span></span>
            </a>
          `)}
        </div>
        ` : nothing}
      </div>
    `;
  }
}
