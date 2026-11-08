import { SakaiElement } from "@sakai-ui/sakai-element";
import { html, nothing } from "lit";
import { unsafeHTML } from "lit/directives/unsafe-html.js";
import "@sakai-ui/sakai-user-photo/sakai-user-photo.js";
import { callSubscribeIfPermitted, NOT_PUSH_CAPABLE, pushSetupComplete, registerPushCallback, PUSH_PERMISSION_STATES } from "@sakai-ui/sakai-push-utils";
import { getServiceName, getSiteId } from "@sakai-ui/sakai-portal-utils";
import { NOTIFICATIONS, PUSH_DENIED_INFO, PUSH_INTRO, PUSH_SETUP_INFO, PWA_INSTALL_INFO } from "./states.js";
import { markNotificationsViewed } from "./utils.js";

export class SakaiNotifications extends SakaiElement {

  static properties = {

    url: { type: String },
    notifications: { type: Array },
    chromeInfoUrl: { attribute: "chrome-info-url", type: String },
    firefoxInfoUrl: { attribute: "firefox-info-url", type: String },
    safariInfoUrl: { attribute: "safari-info-url", type: String },
    edgeInfoUrl: { attribute: "edge-info-url", type: String },
    _state: { state: true },
    _highlightTestButton: { state: true },
    _browserInfoUrl: { state: true },
    _pushEnabled: { state: true },
  };

  constructor() {

    super();

    /*
      Polyfill for Notification in unsupported environments.
      The Notification object can be undefined when browsing inside an iOS or Android webview.
      See: https://developer.mozilla.org/en-US/docs/Web/API/Notifications_API
    */
    if (typeof window.Notification === "undefined") {
      window.Notification = function() {};
      window.Notification.permission = "denied";
      window.Notification.requestPermission = function(cb) {
        if (cb) cb("denied");
        return Promise.resolve("denied");
      };
    }

    /*
      Polyfill for navigator.setAppBadge in unsupported environments.
      This API may be undefined in several environments
      See: https://developer.mozilla.org/en-US/docs/Web/API/Navigator/setAppBadge
    */
    if (typeof navigator.setAppBadge === "undefined") {
      navigator.setAppBadge = function() {
        return Promise.resolve();
      };
      navigator.clearAppBadge = function() {
        return Promise.resolve();
      };
    }

    window.addEventListener("online", () => this._online = true );

    this.notifications = [];
    this._filteredNotifications = new Map();
    this._i18nLoaded = this.loadTranslations("sakai-notifications");
    this._pushRegistered = false;
    this._pushEnabled = false; // Default to false, will be set in _registerForNotifications
  }

  connectedCallback() {

    super.connectedCallback();

    this._state = NOTIFICATIONS;

    if (this.chromeInfoUrl && navigator.userAgent.includes("Chrome") && !navigator.userAgent.includes("Edg")) {
      this._browserInfoUrl = this.chromeInfoUrl;
    } else if (this.firefoxInfoUrl && navigator.userAgent.includes("Firefox")) {
      this._browserInfoUrl = this.firefoxInfoUrl;
    } else if (this.safariInfoUrl && navigator.userAgent.includes("Safari") && !navigator.userAgent.includes("Edg")) {
      this._browserInfoUrl = this.safariInfoUrl;
    } else if (this.safariInfoUrl && navigator.userAgent.includes("Edg")) {
      this._browserInfoUrl = this.edgeInfoUrl;
    }
  }

  loadNotifications() {
    return this._i18nLoaded.then(() => this._loadInitialNotifications());
  }

  _loadInitialNotifications(register = true) {

    console.debug("_loadInitialNotifications");

    return fetch(this.url, {
      cache: "no-cache",
      headers: { "Content-Type": "application/json" },
    })
    .then(r => {

      if (r.ok) {
        return r.json();
      }

      throw new Error(`Network error while retrieving notifications from ${this.url}`);
    })
    .then(notifications => {

      this.notifications = notifications;
      this._filterIntoToolNotifications();
      this._fireLoadedEvent();
      register && this._registerForNotifications();
    })
    .catch(error => console.error(error));
  }

  _registerForNotifications() {

    console.debug("registerForNotifications");

    pushSetupComplete.then(() => {

      this._pushEnabled = true;

      if (Notification.permission !== "granted" || this._pushRegistered) return;

      this._pushRegistered = true;

      registerPushCallback("notifications", message => {

        this.notifications.unshift(message);
        this._fireLoadedEvent();
        this._filterIntoToolNotifications();
      });
    })
    .catch(error => {

      this._pushEnabled = false;

      if (error === NOT_PUSH_CAPABLE) {
        this._state = PUSH_SETUP_INFO;
      } else if (error === PUSH_PERMISSION_STATES.PWA_REQUIRED) {
        this._state = PWA_INSTALL_INFO;
      }
    });
  }

  _filterIntoToolNotifications() {

    this._filteredNotifications.clear();

    this.notifications.forEach(noti => {

      const decorated = this._decorateNotification(noti);
      const dot = decorated.event.indexOf(".");
      const toolEventPrefix = dot === -1 ? decorated.event : decorated.event.slice(0, dot);

      !this._filteredNotifications.has(toolEventPrefix) && this._filteredNotifications.set(toolEventPrefix, []);

      this._filteredNotifications.get(toolEventPrefix).push(decorated);
    });

    // Sort alphabetically by title, with motd always at the top
    const entries = Array.from(this._filteredNotifications.entries());
    entries.sort((a, b) => {
      if (a[0] === "motd") return -1;
      if (b[0] === "motd") return 1;
      const titleA = this._i18n[a[0]] || a[0];
      const titleB = this._i18n[b[0]] || b[0];
      return titleA.localeCompare(titleB);
    });
    this._filteredNotifications = new Map(entries);

    this._state = NOTIFICATIONS;
    this.requestUpdate();
  }

  _decorateNotification(noti) {

    const decorated = { ...noti };
    const dot = decorated.event.indexOf(".");
    const toolEventPrefix = dot === -1 ? decorated.event : decorated.event.slice(0, dot);

    if (toolEventPrefix === "asn") {
      this._decorateAssignmentNotification(decorated);
    } else if (toolEventPrefix === "annc") {
      this._decorateAnnouncementNotification(decorated);
    } else if (toolEventPrefix === "commons") {
      this._decorateCommonsNotification(decorated);
    } else if (toolEventPrefix === "sam") {
      this._decorateSamigoNotification(decorated);
    } else if (toolEventPrefix === "messages") {
      this._decorateMessageNotification(decorated);
    } else if (toolEventPrefix === "lessonbuilder") {
      this._decorateLessonsCommentNotification(decorated);
    } else if (toolEventPrefix === "site") {
      this._decorateSiteImportNotification(decorated);
    } else if (toolEventPrefix === "test") {
      this._decorateTestNotification(decorated);
    }

    return decorated;
  }

  _decorateAssignmentNotification(noti) {

    if (noti.event === "asn.new.assignment" || noti.event === "asn.revise.access") {
      noti.title = this._i18n.assignment_created.replace("{0}", noti.title).replace("{1}", noti.siteTitle);
    } else if (noti.event === "asn.grade.submission") {
      noti.title = this._i18n.assignment_submission_graded.replace("{0}", noti.title).replace("{1}", noti.siteTitle);
    }
  }

  _decorateAnnouncementNotification(noti) {

    if (noti.event === "annc.new" || noti.event === "annc.available.announcement") {
      noti.title = this._i18n.announcement.replace("{0}", noti.title).replace("{1}", noti.siteTitle);
    }
  }

  _decorateCommonsNotification(noti) {

    noti.title = this._i18n.academic_comment_graded.replace("{0}", noti.siteTitle);
  }

  _decorateSamigoNotification(noti) {

    if (noti.event === "sam.assessment.available" || noti.event === "sam.assessment.update.available") {
      noti.title = this._i18n.samigoCreated.replace("{0}", noti.title).replace("{1}", noti.siteTitle);
    }
  }

  _decorateMessageNotification(noti) {

    if (noti.event === "messages.new" || noti.event === "messages.reply") {
      noti.title = this._i18n.message_received.replace("{0}", noti.fromDisplayName).replace("{1}", noti.siteTitle);
    } else if (noti.event === "messages.read.receipt") {
      noti.title = this._i18n.message_read.replace("{0}", noti.fromDisplayName).replace("{1}", noti.siteTitle);
    }
  }

  _decorateLessonsCommentNotification(noti) {

    noti.title = this._i18n.lessons_comment_posted.replace("{0}", noti.siteTitle);
  }

  _decorateSiteImportNotification(noti) {

    if (noti.event === "site.import.end") {
      noti.title = this._i18n.site_import_completed.replace("{0}", () => noti.siteTitle);
    }
  }

  _decorateTestNotification(noti) {

    noti.body = this._i18n.test_notification_body.replace("{0}", getServiceName());
    noti.bodyShowing = true;
  }

  _fireLoadedEvent() {

    const unviewed = this.notifications.filter(n => !n.viewed).length;
    this.dispatchEvent(new CustomEvent("notifications-loaded", { detail: { count: unviewed }, bubbles: true }));
    navigator.setAppBadge(unviewed);
  }

  _clearNotification(e) {

    const notificationId = e.currentTarget.dataset.notificationId;

    const url = `/api/users/me/notifications/${notificationId}/clear`;
    fetch(url, { method: "POST", credentials: "include" })
      .then(r => {

        if (r.ok) {
          const index = this.notifications.findIndex(a => a.id == notificationId);
          this.notifications.splice(index, 1);
          this._fireLoadedEvent();
          this._filterIntoToolNotifications();
        } else {
          throw new Error(`Network error while clearing notification at ${url}`);
        }
      })
      .catch(error => console.error(error));
  }

  _clearAllNotifications() {

    const url = "/api/users/me/notifications/clear";
    fetch(url, { method: "POST", credentials: "include" })
      .then(r => {

        if (r.ok) {
          this.notifications = [];
          this._fireLoadedEvent();
          this._filterIntoToolNotifications();
          this.dispatchEvent(new CustomEvent("notifications-cleared", { bubbles: true }));
        } else {
          throw new Error(`Network error while clearing all notifications at ${url}`);
        }
      })
      .catch(error => console.error(error));
  }

  clearTestNotifications() {

    this.notifications = [ ...this.notifications.filter(n => !n.event.startsWith("test")) ];
    this._filterIntoToolNotifications();
  }

  _markAllNotificationsViewed() {

    markNotificationsViewed()
      .then(r => {

        if (r.ok) {
          this.notifications?.forEach(a => a.viewed = true);
          this.requestUpdate();
          this._fireLoadedEvent();
        } else {
          throw new Error("Network error while marking all notifications viewed");
        }
      })
      .catch(error => console.error(error));
  }

  _viewMotd(e) {

    const trigger = e.currentTarget;
    const noti = this._filteredNotifications.get(trigger.dataset.prefix).find(n => n.ref === trigger.dataset.ref);

    if (!noti?.body) {
      const url = `/direct${trigger.dataset.ref}.json`;
      fetch(url)
      .then(r => {

        if (r.ok) {
          return r.json();
        }

        throw new Error(`Network error while retrieving MOTD from ${url}`);
      })
      .then(motd => {

        noti.body = motd.body;
        noti.bodyShowing = true;
        this.requestUpdate();
      })
      .catch(error => console.error(error));
    } else {
      noti.bodyShowing = !noti.bodyShowing;
      this.requestUpdate();
    }
  }

  _triggerPushSubscription() {

    callSubscribeIfPermitted().then(permission => {

      switch (permission) {
        case "denied":
          this._state = PUSH_DENIED_INFO;
          break;
        case "granted":
          this.loadNotifications();
          this._highlightTestButton = true;
          break;
      }
    });
  }

  _showNotifications() { this._state = NOTIFICATIONS; }

  _getNotificationUserId(noti) {
    return noti.fromUser?.trim() || noti.from?.trim() || "blank";
  }

  _enablePush() {

    if (Notification.permission === "denied") {
      this._state = PUSH_DENIED_INFO;
    } else {
      this._state = PUSH_INTRO;
    }
  }

  _sendTestNotification() {

    this._highlightTestButton = false;

    console.debug("Sending test notification...");

    const url = "/api/users/me/notifications/test";
    fetch(url, { method: "POST" })
    .then(r => {

      if (!r.ok) {
        console.error(`Test notification request failed with status ${r.status}: ${r.statusText}`);
        throw Error(`Network error while sending test notification at ${url}`);
      }

      console.debug("Test notification request sent successfully");
    })
    .catch(error => {
      console.error("Test notification error:", error);
    });
  }

  shouldUpdate() {
    return this._i18n;
  }

  _renderGroup(prefix, notifications) {

    const groupId = `${prefix}-group`;

    return html`
      <div class="accordion-item sakai-notifications__group">
        <h2 class="accordion-header sakai-notifications__group-header">
          <button type="button"
              class="accordion-button sakai-notifications__group-toggle"
              data-bs-toggle="collapse"
              data-bs-target="#${groupId}"
              aria-expanded="true"
              aria-controls="${groupId}">
            <span class="sakai-notifications__count">${notifications.length}</span>
            <span class="sakai-notifications__group-title">${this._i18n[prefix]}</span>
          </button>
        </h2>
        <div id="${groupId}" class="accordion-collapse collapse show sakai-notifications__group-panel">
          <div class="accordion-body sakai-notifications__group-body">
            <ul class="sakai-notifications__list">
              ${notifications.map(noti => html`
                <li class="sakai-notifications__item">
                  <div class="sakai-notifications__item-header">
                    <sakai-user-photo class="sakai-notifications__photo"
                        user-id="${this._getNotificationUserId(noti)}"
                        classes="sakai-notifications__photo-img"
                        profile-popup="on"
                        site-id="${getSiteId()}"></sakai-user-photo>
                    <div class="sakai-notifications__details">
                      <strong class="sakai-notifications__from">${noti.fromDisplayName}</strong>
                      <time class="sakai-notifications__when">${noti.formattedEventDate}</time>
                    </div>
                    ${prefix !== "motd" && prefix !== "test" ? html`
                      <button type="button"
                          class="sakai-btn-icon sakai-notifications__clear"
                          aria-label="${this._i18n.clear_this_notification}"
                          data-notification-id="${noti.id}"
                          @click=${this._clearNotification}>
                        <span class="si si-close" aria-hidden="true"></span>
                      </button>` : nothing}
                  </div>
                  <div class="sakai-notifications__item-body">
                    ${prefix === "motd" ? html`
                      <button type="button"
                          class="sakai-notifications__message"
                          data-ref="${noti.ref}"
                          data-prefix="${prefix}"
                          aria-expanded="${noti.bodyShowing ? "true" : "false"}"
                          @click=${this._viewMotd}>
                        ${noti.title}
                      </button>` : prefix === "test" ? html`
                      <div class="sakai-notifications__message">${noti.title}</div>` : html`
                      <a class="sakai-notifications__message" href="${noti.url}">${noti.title}</a>`}
                    ${noti.bodyShowing ? html`
                      <div class="sakai-notifications__body">${unsafeHTML(noti.body)}</div>` : nothing}
                  </div>
                </li>
              `)}
            </ul>
            ${prefix === "test" ? html`
              <div class="sakai-notifications__group-footer">
                <button type="button"
                    class="sakai-btn sakai-btn-ghost"
                    @click=${this.clearTestNotifications}>
                  ${this._i18n.clear}
                </button>
              </div>` : nothing}
          </div>
        </div>
      </div>`;
  }

  render() {

    return html`
      <div class="sakai-notifications">
        ${this._state === PUSH_SETUP_INFO ? html`
          <div class="sakai-banner sakai-banner--warn">
            <div class="sakai-notifications__banner-heading">${this._i18n.push_setup_failure_info}</div>
            <ol class="sakai-notifications__banner-list">
              <li>${this._i18n.push_setup_failure_info_1.replace("{0}", getServiceName())}</li>
              <li>${this._i18n.push_setup_failure_info_2}</li>
              <li>${this._i18n.push_setup_failure_info_3}</li>
            </ol>
            <div class="sakai-notifications__banner-heading">${this._i18n.push_setup_failure_info_4.replaceAll("{}", getServiceName())}</div>
          </div>
        ` : nothing}

        ${this._state === PUSH_DENIED_INFO ? html`
          <div class="sakai-banner sakai-banner--error">
            <p class="sakai-notifications__banner-text">${this._i18n.notifications_denied.replace("{0}", getServiceName())}</p>
            <p class="sakai-notifications__banner-text">${this._i18n.notifications_not_allowed2.replace("{0}", getServiceName())}</p>
            ${this._browserInfoUrl ? html`
              <a href="${this._browserInfoUrl}" class="sakai-notifications__banner-link" target="_blank" rel="noopener">${this._i18n.browser_info_link_text}</a>
            ` : nothing}
          </div>
          <div class="sakai-notifications__state-actions">
            <button type="button" class="sakai-btn sakai-btn-primary" @click=${this._showNotifications}>${this._i18n.show_notifications}</button>
          </div>
        ` : nothing}

        ${this._state === PWA_INSTALL_INFO ? html`
          <div class="sakai-banner sakai-banner--info">
            <div class="sakai-notifications__banner-heading">${this._i18n.pwa_install_title}</div>
            <p class="sakai-notifications__banner-text">${this._i18n.pwa_install_instructions}</p>
          </div>
        ` : nothing}

        ${this._state === PUSH_INTRO ? html`
          <div class="sakai-banner sakai-banner--info">
            <p class="sakai-notifications__banner-text">${this._i18n.notifications_not_allowed.replace("{0}", getServiceName())}</p>
            <p class="sakai-notifications__banner-text sakai-notifications__banner-heading">${this._i18n.notifications_not_allowed2.replace("{0}", getServiceName())}</p>
          </div>
          <div class="sakai-notifications__state-actions">
            <button type="button" class="sakai-btn sakai-btn-primary" @click=${this._triggerPushSubscription}>${this._i18n.accept_notifications}</button>
          </div>
        ` : nothing}

        ${this._state === NOTIFICATIONS || this._state === PWA_INSTALL_INFO ? html`
          ${Notification.permission !== "granted" && this._online && this._pushEnabled ? html`
            <div class="sakai-banner sakai-banner--warn sakai-notifications__push-banner">
              <span>${this._i18n.push_not_enabled}</span>
              <button type="button"
                  class="sakai-btn sakai-btn-secondary"
                  aria-label="${this._i18n.enable_push_label}"
                  @click=${this._enablePush}>
                ${this._i18n.enable_push}
              </button>
            </div>
          ` : nothing}

          <div class="accordion sakai-notifications__groups">
            ${Array.from(this._filteredNotifications, e => e[0]).map(prefix => html`
              ${this._renderGroup(prefix, this._filteredNotifications.get(prefix))}
            `)}
          </div>

          ${!this.notifications?.length ? html`
            <p class="sakai-notifications__empty">${this._i18n.no_notifications}</p>
          ` : nothing}

          <div class="sakai-notifications__actions">
            ${this._online && this._pushEnabled && Notification.permission === "granted" ? html`
              <div class="sakai-notifications__actions-start">
                <button type="button"
                    class="sakai-btn ${this._highlightTestButton ? "sakai-btn-primary sakai-notifications__test--highlight" : "sakai-btn-secondary"} sakai-notifications__test"
                    @click=${this._sendTestNotification}>
                  ${this._i18n.test}
                </button>
              </div>
            ` : nothing}

            <div class="sakai-notifications__actions-end sakai-actions">
              ${Notification.permission !== "granted" && this._online ? html`
                <button type="button" class="sakai-btn sakai-btn-secondary" @click=${this.loadNotifications}>
                  ${this._i18n.update}
                </button>
              ` : nothing}

              ${this._online && this.notifications?.filter(a => !a.viewed).length > 0 ? html`
                <button type="button" class="sakai-btn sakai-btn-secondary" @click=${this._markAllNotificationsViewed}>
                  ${this._i18n.mark_all_viewed}
                </button>
              ` : nothing}

              ${this._online && this.notifications?.length ? html`
                <button type="button"
                    id="sakai-notifications-clear-all-button"
                    class="sakai-btn sakai-btn-secondary"
                    @click=${this._clearAllNotifications}>
                  ${this._i18n.clear_all}
                </button>
              ` : nothing}
            </div>
          </div>
        ` : nothing}
      </div>
    `;
  }
}
