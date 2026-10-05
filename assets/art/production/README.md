# Production Art Provenance

All assets listed here are presentation-only unless an owning gameplay document says otherwise. Collision, balance, firing geometry and progression data remain authoritative in game resources/scripts.

## Vehicle — Run-down Compact

- **Asset:** `vehicles/run_down_compact.svg`
- **Purpose:** first representative production combat-platform asset; one source reused across Hub, Garage and player Battle.
- **Created:** 2026-10-05
- **Origin:** original repository-authored vector artwork created specifically for Fort Knocks from the locked visual specification.
- **External source art:** none.
- **Licence dependency:** none.
- **Reference authority:** `docs/design/visual_reference.md`.

## Character — Fort Knocks Survivor

- **Asset:** `characters/fort_knocks_survivor.svg`
- **Purpose:** player-side production survivor visual aligned to the existing foot position and projectile launch origin.
- **Created:** 2026-10-05
- **Origin:** original repository-authored vector artwork created specifically for Fort Knocks.
- **External source art:** none.
- **Licence dependency:** none.
- **Gameplay authority:** none; the existing Combatant collision and launch-origin contract remains unchanged.

## Outskirts environment kit

- **Assets:**
  - `battle/outskirts/outskirts_sky_far.svg`
  - `battle/outskirts/outskirts_midground.svg`
  - `battle/outskirts/outskirts_road.svg`
  - `battle/outskirts/outskirts_foreground.svg`
- **Purpose:** layered 2D/2.5D production environment for the Outskirts campaign region.
- **Created:** 2026-10-05
- **Origin:** original repository-authored vector artwork created specifically for Fort Knocks.
- **External source art:** none.
- **Licence dependency:** none.
- **Gameplay authority:** none; authored encounter collision remains separate.
- **Composition rule:** foreground is intentionally concentrated low in frame to protect pull-back aiming, trajectory visibility and interactives.

## Fort Knocks Hub environment kit

- **Assets:**
  - `hub/hub_sky_far.svg`
  - `hub/hub_mid_structures.svg`
  - `hub/hub_foreground.svg`
- **Purpose:** production-quality static world layers behind the existing dynamic Fort Knocks progression overlays.
- **Created:** 2026-10-05
- **Origin:** original repository-authored vector artwork created specifically for Fort Knocks.
- **External source art:** none.
- **Licence dependency:** none.
- **Progression authority:** none; settlement growth remains dynamically drawn/data-driven and is deliberately not baked into these assets.

## Shared UI surfaces

- **Assets:**
  - `shared/ui/panel_industrial.svg`
  - `shared/ui/button_industrial.svg`
- **Purpose:** scalable industrial nine-patch surfaces shared by Hub, Command Board, Garage, Workshop and Battle HUD.
- **Created:** 2026-10-05
- **Origin:** original repository-authored vector artwork created specifically for Fort Knocks.
- **External source art:** none.
- **Licence dependency:** none.
- **State authority:** native Godot controls/theme remain responsible for text, input, selected/disabled state and accessibility.

Future production assets should record equivalent provenance here or in a per-asset manifest.


## Runtime loading note

The `.svg` files in this directory are editable production master art.

Do **not** directly `preload()` these SVG paths from gameplay/presentation scripts. Some Godot editor/build configurations can expose the SVG image decoder without registering the source extension as a parse-time ResourceLoader, which caused the visual-production branch to fail script parsing.

Runtime code must go through:
- `game/presentation/production_art.gd`

That helper:
- reads the SVG source as text,
- decodes it through `Image.load_svg_from_string()`,
- creates an `ImageTexture`,
- caches the resulting texture,
- returns `null` on failure so the owning presentation code can use its procedural fallback.

This keeps art-loader failures non-fatal and separates editable source art from gameplay boot requirements.

Before mobile release/export, the preferred final packaging step remains rasterizing approved masters to PNG/WebP runtime derivatives and retaining SVG only as source/master art.
