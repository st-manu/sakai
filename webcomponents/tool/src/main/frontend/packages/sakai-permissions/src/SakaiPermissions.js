import { SakaiElement } from "@sakai-ui/sakai-element";
import { html, nothing } from "lit";
import { getSiteId } from "@sakai-ui/sakai-portal-utils";
import "@sakai-ui/sakai-group-picker/sakai-group-picker.js";

export class SakaiPermissions extends SakaiElement {

  static properties = {

    tool: { type: String },
    reference: { type: String },
    overrideReference: { attribute: "override-reference", type: String },
    excludedPermissions: {
      attribute: "exclude-permissions",
      converter: {
        fromAttribute: value => value?.split(",").map(v => v.trim()).filter(Boolean) || [],
        toAttribute: value => Array.isArray(value) ? value.join(",") : value,
      },
    },
    disableGroups: { attribute: "disable-groups", type: Boolean },
    bundleKey: { attribute: "bundle-key", type: String },
    onRefresh: { attribute: "on-refresh", type: String },
    fireEvent: { attribute: "fire-event", type: Boolean },

    roles: { state: true },
    groups: { state: true },
    error: { state: true },
    _errorMessage: { state: true },
    _saveErrorMessage: { state: true },
  };

  constructor() {

    super();
    this.excludedPermissions = [];
    this._errorMessage = "";
    this._saveErrorMessage = "";

    this.loadTranslations("permissions-wc").then(async i18n => {

      const bundle = this.bundleKey ? this.bundleKey : this.tool;
      const cachedTool = await this.loadTranslations(bundle);

      // Retry uncached once so a previously cached empty bundle doesn't permanently blank labels.
      const tool = this._hasPermissionLabels(cachedTool)
        ? cachedTool
        : await this.loadTranslations({ bundle, cache: false });

      Object.keys(tool || {}).filter(k => k.startsWith("perm-")).forEach(k => i18n[k.substring(5)] = tool[k]);
      this._i18n = i18n;
    });
  }

  _hasPermissionLabels(tool) {
    return !!tool && Object.keys(tool).some(k => k.startsWith("perm-"));
  }

  connectedCallback() {

    super.connectedCallback();

    this.reference ||= `/site/${getSiteId()}`;

    this._loadPermissions();
  }

  _handleDescriptionClick(e) {

    e.preventDefault();

    const all = this.querySelectorAll(`input[data-perm='${e.target.dataset.perm}']`);
    const checked = this.querySelectorAll(`input[data-perm='${e.target.dataset.perm}']:checked`);

    if (checked.length < all.length || checked.length === 0) {
      all.forEach(i => i.checked = true);
    } else if (checked.length === all.length) {
      all.forEach(i => i.checked = false);
    }
  }

  _handleRoleHover(e, type) {

    const role = (e.currentTarget.dataset.role || e.target.dataset.role || "").replace(".", "\\.");
    if (!role) {
      return;
    }
    this.querySelectorAll(`.${role.replace(" ", "_")}-checkbox-cell`).forEach(cell => {
      cell.classList.toggle("is-role-hover", type === "mouseenter");
    });
  }

  _handleRoleMouseEnter(e) {
    this._handleRoleHover(e, "mouseenter");
  }

  _handleRoleMouseLeave(e) {
    this._handleRoleHover(e, "mouseleave");
  }

  _handleRoleClick(e) {

    e.preventDefault();

    const role = e.target.dataset.role.replace(".", "\\.");

    const anyChecked = this.querySelectorAll(`#permissions-container .${role.replace(" ", "_")}-checkbox-cell input:checked:not(:disabled)`).length > 0;
    this.querySelectorAll(`#permissions-container .${role.replace(" ", "_")}-checkbox-cell input:not(:disabled)`).forEach(i => {
      i.checked = !anyChecked;
    });
  }

  _handlePermissionClick(e) {

    e.preventDefault();

    const checked = this.querySelectorAll("#permissions-container input:checked");

    this.querySelectorAll("#permissions-container input").forEach(input => {
      input.checked = checked.length === 0;
    });
  }

  shouldUpdate() {
    return this._i18n;
  }

  render() {

    if (this.roles) {
      return html`
        <div class="sakai-permissions">
          ${this.groups?.length ? html`
            <div class="sakai-permissions__groups">
              <label class="sakai-form-label" for="permissions-group-picker">${this._i18n["per.lis.selectgrp"]}</label>
              <sakai-group-picker id="permissions-group-picker"
                  .groups=${this.groups}
                  @groups-selected=${this._groupsSelected}>
              </sakai-group-picker>
            </div>
          ` : nothing}

          <div class="sakai-actions">
            <button type="button"
                class="sakai-btn sakai-btn-secondary"
                aria-label="${this._i18n["per.lis.restoredef"]}"
                @click=${this._resetPermissions}>
              ${this._i18n["per.lis.restoredef"]}
            </button>
          </div>

          <div class="sakai-table-wrap">
            <table id="permissions-container" class="sakai-table sakai-permissions__table">
              <thead>
                <tr id="permission-header">
                  <th scope="col" class="sakai-permissions__perm-col">
                    <button type="button"
                        class="sakai-permissions__toggle"
                        title="${this._i18n["per.lis.head.title"]}"
                        @click=${this._handlePermissionClick}>
                      ${this._i18n["per.lis.head"]}
                    </button>
                  </th>
                  ${this.roles.map(role => html`
                    <th scope="col"
                        class="sakai-permissions__role-col"
                        data-role="${role}"
                        @mouseenter=${this._handleRoleMouseEnter}
                        @mouseleave=${this._handleRoleMouseLeave}>
                      <button type="button"
                          class="sakai-permissions__toggle"
                          title="${this._i18n["per.lis.role.title"]}"
                          data-role="${role}"
                          @click=${this._handleRoleClick}>
                        ${this.roleNameMappings[role]}
                      </button>
                    </th>
                  `)}
                </tr>
              </thead>
              <tbody>
                ${this.available.map(perm => html`
                  <tr class="permission-row">
                    <th scope="row" class="sakai-permissions__perm-col">
                      <button type="button"
                          class="sakai-permissions__toggle"
                          title="${this._i18n["per.lis.perm.title"]}"
                          data-perm="${perm}"
                          @click=${this._handleDescriptionClick}>
                        ${this._i18n[perm]}
                      </button>
                    </th>
                    ${this.roles.map(role => html`
                      <td class="permission-cell ${role.replace(" ", "_")}-checkbox-cell"
                          data-label="${this.roleNameMappings[role]}">
                        <label class="visually-hidden" for="${role}:${perm}">
                          ${this._i18n["gen.enable"]} ${this.roleNameMappings[role]}
                        </label>
                        <input type="checkbox"
                            class="sakai-permission-checkbox"
                            aria-label="${this._i18n["gen.enable"]} ${this.roleNameMappings[role]}"
                            .checked=${this.on[role].includes(perm)}
                            .disabled=${this.locked?.[role]?.includes(perm)}
                            data-role="${role}"
                            data-perm="${perm}"
                            id="${role}:${perm}" />
                      </td>
                    `)}
                  </tr>
                `)}
              </tbody>
            </table>
          </div>

          ${this._saveErrorMessage ? html`
            <div class="sak-banner-error" role="alert" aria-live="polite">
              ${this._saveErrorMessage}
            </div>
          ` : nothing}

          <div class="sakai-actions">
            <button type="button"
                class="sakai-btn sakai-btn-primary"
                aria-label="${this._i18n["gen.sav"]}"
                @click=${this._savePermissions}>
              ${this._i18n["gen.sav"]}
            </button>
            <button type="button"
                class="sakai-btn sakai-btn-secondary"
                aria-label="${this._i18n["gen.can"]}"
                @click=${this._completePermissions}>
              ${this._i18n["gen.can"]}
            </button>
          </div>
        </div>
      `;
    } else if (this.error) {
      return html`<div class="sak-banner-error" role="alert" aria-live="polite">
        ${this._errorMessage || this._i18n.alert_permission}
      </div>`;
    }

    return html`<div class="sak-banner-info">${this._i18n.waiting_for_permissions}</div>`;
  }

  _loadPermissions() {

    const url = `/api/sites/${portal.siteId}/permissions/${this.tool}?ref=${encodeURIComponent(this.reference)}${this.overrideReference ? `&overrideRef=${encodeURIComponent(this.overrideReference)}` : ""}`;
    fetch(url, { cache: "no-cache" })
      .then(async res => {

        if (!res.ok) {
          const message = (await res.text())?.trim();
          const fallbackMessage = this._i18n?.alert_permission || "";
          this._errorMessage = message || fallbackMessage;
          this.error = true;
          throw new Error(`Permissions fetch failed with status ${res.status}${message ? `: ${message}` : ""}`);
        } else {
          this.error = false;
          return res.json();
        }
      })
      .then(data => {

        this.on = data.on;
        this.locked = data.locked;
        const excluded = new Set(this.excludedPermissions);
        this.available = data.available.filter(perm => !excluded.has(perm));
        this.disabled = data.disabled;
        !this.disableGroups && (this.groups = data.groups);
        this.roleNameMappings = data.roleNameMappings;
        this.roles = Object.keys(this.on);
      })
      .catch (error => console.error(`Failed to load permissions for tool ${this.tool} from ${url}`, error));
  }

  _savePermissions() {

    document.body.style.cursor = "wait";
    this._saveErrorMessage = "";

    const boxes = this.querySelectorAll("#permissions-container input[type=\"checkbox\"]");
    const params = new URLSearchParams();
    params.append("ref", this.reference);

    Array.from(boxes).forEach(b => {
      params.append(b.id, b.checked ? "true" : "false");
    });

    fetch(`/api/sites/${portal.siteId}/permissions`, {
      method: "POST",
      body: params,
      timeout: 30000
    })
    .then(async res => {

      if (res.ok) {
        this._completePermissions();
      } else {
        const message = (await res.text())?.trim();
        const fallbackMessage = this._i18n?.["per.error.save"] || "";
        this._saveErrorMessage = message || fallbackMessage;
        throw new Error(`Permissions save failed with status ${res.status}${message ? `: ${message}` : ""}`);
      }
    })
    .catch(error => {

      if (!this._saveErrorMessage) {
        this._saveErrorMessage = this._i18n?.["per.error.save"] || "";
      }
      console.error(`Failed to save permissions for tool ${this.tool}`, error);
    })
    .finally(() => document.body.style.cursor = "default");
  }

  _resetPermissions() {

    this.updateComplete.then(() => {

      const inputs = this.renderRoot.querySelectorAll("input[type='checkbox']");
      inputs.forEach(elem => {

        const role = elem.getAttribute("data-role");
        const perm = elem.getAttribute("data-perm");
        if (role && perm) {
          const elemChanged = (elem.checked != this.on[role].includes(perm));
          elem.checked = this.on[role].includes(perm);
          elemChanged && elem.dispatchEvent(new Event("change"));
        }
      });
    });
  }

  _completePermissions() {

    if (this.fireEvent) {
      this.dispatchEvent(new CustomEvent("permissions-complete"));
    } else if (this.onRefresh) {
      window.location.href = this.onRefresh;
    } else {
      window.location.reload();
    }
  }

  _groupsSelected(e) {

    this.reference = e.detail.value;
    this._loadPermissions();
  }
}
