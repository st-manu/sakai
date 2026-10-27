# Sakai library (skin & shared front-end assets)

The default skin lives in [`src/skins/default`](src/skins/default). It compiles Bootstrap **5.3** plus Sakai tokens and components into `tool.css`.

## Quick start

```bash
cd library
mvn clean install
```

Skin Sass is built via npm in `src/skins/default` (Node installed by the Maven frontend plugin).

To iterate on CSS only:

```bash
cd library/src/skins/default
npm ci
npm run css-watch
```

## Design system docs

| Doc | Topic |
|-----|--------|
| [docs/sakai-ui-tokens.md](docs/sakai-ui-tokens.md) | Token layers L0–L3 (brand → semantic → components → portal) |
| [docs/sakai-ui-chrome.md](docs/sakai-ui-chrome.md) | Portal chrome contract + `sakai-*` primitives |
| [docs/sakai-ui-icons.md](docs/sakai-ui-icons.md) | Bootstrap Icons standard; FA legacy |
| [`niobe-front-rules/`](../niobe-front-rules/) | Temporary Niobe plan / roadmap / reference notes (safe to delete after renovation) |

## Institutional customization

```bash
mvn clean install -Dsakai.skin.customization.file=/path/to/your.scss
```

Optional skin name:

```bash
mvn clean install -Dsakai.skin.target=my_skin
```

**Quick customization:** override L0 brand tokens (see `src/skins/default/src/sass/tokens/_brand.scss`) — brand HSL via `defineColorHSL`, logo, radii, page/card backgrounds.

**Deep customization:** also override L2/L3 or legacy vars for a specific region.

## Portal templates

Portal Velocity templates are under `portal/portal-render-engine-impl/.../vm/portal/`. Config key:

```
portal.templates=portal
```

(Previously `morpheus`.)

## Icons

Use Bootstrap Icons (`bi`) / tool map (`si`). Do not introduce Font Awesome in new work.
