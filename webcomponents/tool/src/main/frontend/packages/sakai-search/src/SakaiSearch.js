import { SakaiElement } from "@sakai-ui/sakai-element";
import { html, nothing } from "lit";
import { unsafeHTML } from "lit/directives/unsafe-html.js";

const SEARCH_MIN_LENGTH = 3;

export class SakaiSearch extends SakaiElement {

  static properties = {

    siteId: { attribute: "site-id", type: String },
    tool: { type: String },

    _results: { state: true },
    _noResults: { state: true },
  };

  constructor() {

    super();

    this._searchTerms = "";

    this.iconMapping = {
      "announcement": "si si-sakai-announcements",
      "assignments": "si si-sakai-assignment-grades",
      "calendar": "si si-sakai-schedule",
      "chat": "si si-sakai-chat",
      "sakai.conversations": "si si-sakai-conversations",
      "forums": "si si-sakai-forums",
      "lessons": "si si-sakai-lessonbuildertool",
      "commons": "si si-sakai-commons",
      "content": "si si-sakai-resources",
      "polls": "si si-sakai-poll",
      "rubrics": "si si-sakai-rubrics",
      "syllabus": "si si-sakai-syllabus",
      "wiki": "si si-sakai-rwiki"
    };

    this.loadTranslations("search").then(t => {

      this._i18n = t;
      this.toolNameMapping = {
        "announcement": this._i18n.toolname_announcement,
        "assignments": this._i18n.toolname_assignment,
        "calendar": this._i18n.toolname_calendar,
        "chat": this._i18n.toolname_chat,
        "sakai.conversations": this._i18n.toolname_conversations,
        "forums": this._i18n.toolname_forum,
        "lessons": this._i18n.toolname_lesson,
        "commons": this._i18n.toolname_commons,
        "content": this._i18n.toolname_resources,
        "polls": this._i18n.toolname_polls,
        "rubrics": this._i18n.toolname_rubrics,
        "syllabus": this._i18n.toolname_syllabus,
        "wiki": this._i18n.toolname_wiki
      };
    });
  }

  handleKeydownOnResult(e, index) {

    if (e.code === "Escape") {
      e.preventDefault();
      this.closeResults();
      return;
    }

    const links = [ ...this.renderRoot.querySelectorAll(".sakai-search__result-link") ];

    if (e.code === "ArrowDown") {
      links[index + 1]?.focus();
      e.preventDefault();
    } else if (e.code === "ArrowUp") {
      links[index - 1]?.focus();
      e.preventDefault();
    }
  }

  closeResults() {

    this._results = [];
    this._noResults = false;
    this.dispatchEvent(new CustomEvent("hiding-search-results"));
    this.renderRoot.querySelector("input")?.focus();
  }

  shouldUpdate() {
    return this._i18n;
  }

  search(e) {

    e.preventDefault();

    const terms = this.renderRoot.querySelector("#sakai-search-input")?.value || "";

    this.closeResults();

    if (terms.length > SEARCH_MIN_LENGTH - 1) {

      const url = `/api/search?terms=${encodeURIComponent(terms)}${this.siteId ? `&site=${encodeURIComponent(this.siteId)}` : ""}${this.tool ? `&tool=${encodeURIComponent(this.tool)}` : ""}`;
      fetch(url, {
        cache: "no-cache",
        credentials: "same-origin"
      })
      .then(r => {

        if (r.ok) {
          return r.json();
        }

        throw new Error(`Failed to get search results from ${url}.`);
      })
      .then(data => {

        this.dispatchEvent(new CustomEvent("showing-search-results"));
        this._results = data;

        this._noResults = this._results.length === 0;
        this._results.forEach(r => { if (r.title.length === 0) r.title = r.tool; });

        this.updateComplete.then(() => {
          if (!this._noResults) {
            this.renderRoot.querySelector(".sakai-search__result-link")?.focus();
          }
        });
      })
      .catch (error => console.error(error));
    }
  }

  render() {

    return html`
      <div class="sakai-search">
        <form class="sakai-search__form" @submit=${this.search}>
          <input type="search"
            class="sakai-search__input sakai-form-control"
            autocomplete="off"
            id="sakai-search-input"
            pattern=".{${SEARCH_MIN_LENGTH},}"
            title="${this._i18n.search_min_length.replace("{}", SEARCH_MIN_LENGTH)}"
            placeholder="${this._i18n.search_placeholder}"
            value=${this._searchTerms}
            aria-label="${this._i18n.search_placeholder}"
          />
          <button class="sakai-search__submit sakai-btn sakai-btn-primary" type="submit" id="sakai-search-button">
            ${this._i18n.search}
          </button>
        </form>
        ${this._noResults ? html`
          <p class="sakai-search__empty">${this._i18n.no_results}</p>
        ` : nothing}
        ${this._results?.length > 0 ? html`
          <div class="sakai-search__results-header">
            <button type="button"
                class="sakai-btn-icon sakai-search__close"
                title="${this._i18n.close_results_tooltip}"
                aria-label="${this._i18n.close_results_tooltip}"
                @click=${this.closeResults}>
              <span class="si si-close" aria-hidden="true"></span>
            </button>
          </div>
          <ul class="sakai-search__results">
            ${this._results.map((r, index) => html`
              <li>
                <a class="sakai-search__result-link" href="${r.url}" @keydown=${e => this.handleKeydownOnResult(e, index)}>
                  <div class="sakai-search__result-meta">
                    <i class="sakai-search__result-icon ${this.iconMapping[r.tool]}" aria-hidden="true"></i>
                    <span class="sakai-search__result-tool">${this.toolNameMapping[r.tool]}</span>
                    <span>${this._i18n.from_site}</span>
                    <span class="sakai-search__result-site">${r.siteTitle}</span>
                  </div>
                  <div class="sakai-search__result-title-row">
                    <span class="sakai-search__result-label">${this._i18n.search_result_title}</span>
                    <span class="sakai-search__result-title">${unsafeHTML(r.title)}</span>
                  </div>
                  <div class="sakai-search__result-text">${unsafeHTML(r.searchResult)}</div>
                </a>
              </li>
            `)}
          </ul>
        ` : nothing}
      </div>
    `;
  }
}
