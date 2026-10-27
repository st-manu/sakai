# Sakai UI design tokens

Sakai’s default skin uses **layered CSS custom properties**. Prefer the shallowest layer that meets your need.

| Layer | File | Audience |
|-------|------|----------|
| **L0 Brand** | [`tokens/_brand.scss`](../src/skins/default/src/sass/tokens/_brand.scss) | Institutions — logo, brand HSL, radii, page vs card background, spacing scale |
| **L1 Semantic** | [`tokens/_semantic.scss`](../src/skins/default/src/sass/tokens/_semantic.scss) | Product UI — primary, text, background, border, link, elevation |
| **L2 Components** | [`tokens/_components.scss`](../src/skins/default/src/sass/tokens/_components.scss) | Buttons, banners, cards, modals/offcanvas |
| **L3 Portal** | [`tokens/_portal.scss`](../src/skins/default/src/sass/tokens/_portal.scss) | Portal chrome only (sidebar, header, page content) |
| **Legacy / deep** | [`tokens/_legacy-light.scss`](../src/skins/default/src/sass/tokens/_legacy-light.scss) | Fine-grained tool/nav overrides still used by unmigrated tools |

Dark theme overrides live in [`themes/_dark.scss`](../src/skins/default/src/sass/themes/_dark.scss) and should target **L1** (and L0 where needed), not duplicate every legacy var.

Tool-specific L3 tokens belong under [`tokens/tools/`](../src/skins/default/src/sass/tokens/tools/) when a tool is migrated (future).

## Typography scale (portal / chrome)

Prefer these over ad-hoc `rem` sizes in new portal SCSS:

| Token | Default | Use |
|-------|---------|-----|
| `--sakai-font-size` | 14px (`$default-font-size`) | Body / primary UI text |
| `--sakai-font-size-sm` | 12px (`$default-font-size-small`) | Meta, breadcrumbs, secondary labels |
| `--sakai-font-size-xs` | 11px (`$default-font-size-x-small`) | Eyebrows, badges, dense captions |

`--default-font-size` remains as a legacy alias of the base size.

## Institutional customization

Maven still supports:

```bash
mvn clean install -Dsakai.skin.customization.file=/path/to/custom.scss
```

**Quick mode:** override only L0 (and optionally logo/font vars in `_defaults.scss`).

**Deep mode:** also override L2/L3 or legacy vars for a specific region.

Compiled entry point: [`tool.scss`](../src/skins/default/src/sass/tool.scss) → `tool.css`.
