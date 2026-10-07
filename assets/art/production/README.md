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

- **Shared regional assets:**
  - `battle/outskirts/outskirts_sky_far.svg`
  - `battle/outskirts/outskirts_midground.svg`
  - `battle/outskirts/outskirts_road.svg`
  - `battle/outskirts/outskirts_foreground.svg`
- **Mission landmark assets:**
  - `battle/outskirts/roadblock_trial_landmark.svg`
  - `battle/outskirts/high_ground_trial_landmark.svg`
  - `battle/outskirts/scrap_gate_trial_landmark.svg`
  - `battle/outskirts/broken_span_landmark.svg`
  - `battle/outskirts/depot_line_landmark.svg`
  - `battle/outskirts/outskirts_checkpoint_landmark.svg`
- **Purpose:** layered 2D/2.5D production environment for every current Outskirts campaign mission, using the same shared-base + authored-landmark pipeline as Suburbs.
- **Created:** 2026-10-05; mission landmark parity completed 2026-10-07.
- **Origin:** original repository-authored vector artwork created specifically for Fort Knocks.
- **External source art:** none.
- **Licence dependency:** none.
- **Gameplay authority:** none; authored encounter collision remains separate.
- **Composition rule:** foreground is intentionally concentrated low in frame to protect pull-back aiming, trajectory visibility and interactives. Landmark overlays remain decorative and must never encode gameplay geometry.

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


## Vehicle — Old Sedan / Estate
- **Asset:** `vehicles/old_sedan.svg`
- **Purpose:** second platform-tier production master reused in Garage, Hub and player Battle.
- **Created:** 2026-10-05
- **Origin:** original repository-authored vector artwork created specifically for Fort Knocks.
- **External source art:** none.
- **Licence dependency:** none.
- **Gameplay authority:** none.

## Vehicle — Pickup
- **Asset:** `vehicles/pickup.svg`
- **Purpose:** utility-platform production master reused in Garage, Hub and player Battle.
- **Created:** 2026-10-05
- **Origin:** original repository-authored vector artwork created specifically for Fort Knocks.
- **External source art:** none.
- **Licence dependency:** none.
- **Gameplay authority:** none; module attachment overlays are presentation-only.

## Vehicle — Improvised Technical
- **Asset:** `vehicles/improvised_technical.svg`
- **Purpose:** reinforced current top-tier platform production master reused in Garage, Hub and player Battle.
- **Created:** 2026-10-05
- **Origin:** original repository-authored vector artwork created specifically for Fort Knocks.
- **External source art:** none.
- **Licence dependency:** none.
- **Gameplay authority:** none; support-module attachment overlays are presentation-only.

## Command Board
- **Asset:** `campaign/command_board_surface.svg`
- **Purpose:** recovered physical route-map surface beneath dynamic mission-state route pins.
- **Created:** 2026-10-05
- **Origin:** original repository-authored vector artwork.
- **Dynamic data:** mission names, availability, completion and rewards remain native/data-driven.

## Workshop hardware
- **Assets:**
  - `workshop/workshop_weapons.svg`
  - `workshop/workshop_modules.svg`
- **Purpose:** physical presentation of the already-approved weapon and platform-module inventory.
- **Created:** 2026-10-05
- **Origin:** original repository-authored vector artwork.
- **Scope guardrail:** these assets depict only Scrap Bolt, Heavy Slug, Shock Capsule, Spotter Rack, Ballast Crates, Twin Field Rack and Stabilizer Rig.


## Suburbs environment kit

- **Assets:**
  - `battle/suburbs/suburbs_sky_far.svg`
  - `battle/suburbs/suburbs_midground.svg`
  - `battle/suburbs/suburbs_road.svg`
  - `battle/suburbs/suburbs_foreground.svg`
  - `battle/suburbs/suburbs_dead_air_landmark.svg`
  - `battle/suburbs/suburbs_crossroads_landmark.svg`
  - `battle/suburbs/suburbs_loaded_up_landmark.svg`
  - `battle/suburbs/suburbs_hot_cargo_landmark.svg`
- **Purpose:** layered production environment for the four current Suburbs encounters, using one shared regional identity plus mission-specific low-contrast landmark composition.
- **Created:** 2026-10-05
- **Origin:** original repository-authored vector artwork created specifically for Fort Knocks from the locked visual reference.
- **External source art:** none.
- **Licence dependency:** none.
- **Gameplay authority:** none; collision and mission geometry remain authored in mission resources / battle nodes.

## Suburbs Signal Relay

- **Asset:** `battle/suburbs/signal_relay.svg`
- **Purpose:** production hero visual for the Dead Air objective.
- **Created:** 2026-10-05
- **Origin:** original repository-authored vector artwork.
- **Gameplay authority:** none; existing health/collision/objective state remains authoritative.

## Suburbs protected Salvage Load

- **Asset:** `battle/suburbs/salvage_load.svg`
- **Purpose:** production hero visual for Loaded Up / Hot Cargo protected-objective play.
- **Created:** 2026-10-05
- **Origin:** original repository-authored vector artwork.
- **Gameplay authority:** none; existing health/collision/objective state remains authoritative.


## Rival survivor

- **Asset:** `characters/rival_survivor.svg`
- **Purpose:** production opponent survivor used across current battles.
- **Created:** 2026-10-05
- **Origin:** original repository-authored vector artwork.
- **External source art:** none.
- **Licence dependency:** none.
- **Gameplay authority:** none; collision, knockback and launch origin remain script-owned.
- **Identity rule:** distinct from Fort Knocks through olive/rust materials without introducing a new faction genre or competing emblem.

## Rival cover vehicle

- **Asset:** `vehicles/rival_cover_vehicle.svg`
- **Purpose:** faction-neutral opponent civilian cover vehicle.
- **Created:** 2026-10-05
- **Origin:** original repository-authored vector artwork.
- **External source art:** none.
- **Licence dependency:** none.
- **Gameplay authority:** none; enemy cover HP/collision remain unchanged.

## Shared battle hero interactives

- **Assets:**
  - `battle/shared/roadblock.svg`
  - `battle/shared/scrap_gate.svg`
  - `battle/shared/unstable_power_cell.svg`
  - `battle/shared/unstable_power_cell_spent.svg`
  - `battle/suburbs/signal_relay_destroyed.svg`
  - `battle/suburbs/salvage_load_destroyed.svg`
- **Purpose:** production presentation for the current tactical objects and their critical spent/destroyed states.
- **Created:** 2026-10-05
- **Origin:** original repository-authored vector artwork.
- **Gameplay authority:** none; existing collision, HP, collapse and discharge logic remains authoritative.


## Hub reference-finish pilot v1

- **Assets:** `hub/reference_v1/`
- **Purpose:** user-supplied first-screen Hub production pilot, integrated as the active Hub presentation.
- **Integrated:** 2026-10-05
- **Origin:** supplied directly by the project owner as `Fort_Knocks_Hub_Asset_Kit_v1.zip`, reconstructed from the approved Hub mood-board screen.
- **Runtime format:** raster art is stored as compact WebP derivatives; the Hub background is split into ten lossless-layout horizontal tiles so the repository connection can carry the authored composition without changing it.
- **Typography:** Barlow Condensed Bold/Medium supplied with the kit; runtime files are character-subset derivatives used for the current uppercase Hub UI. The SIL Open Font License is stored beside the fonts.
- **Gameplay authority:** none. Salvage, campaign progress, active platform and navigation continue to come from current save/game state.
- **Scope guardrail:** Energy, Gem, Settings, Map and Plus artwork is preserved in the asset library but is not wired to invented systems. The current build exposes only the real Garage, Workshop and Missions/Command Board actions.
