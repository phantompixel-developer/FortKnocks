# Fort Knocks — Visual Production Asset Manifest

**Applies to:** Visual Production Pass 1  
**Authority:** `docs/design/visual_reference.md`

This manifest converts the locked reference into buildable 2D/2.5D production assets. It intentionally covers only the first complete slice: Hub, Command Board, Garage, Workshop and Outskirts battle.

## Global rules

- Target logical viewport: **720×1280 portrait**.
- Battle world width remains **2160** unless gameplay architecture changes separately.
- Gameplay collision must never be inferred from decorative art.
- Opaque full-scene/background layers may use JPG/WebP; transparent layered art should use PNG/WebP with alpha.
- Prefer a small number of large coherent layers over hundreds of tiny decorative sprites.
- Keep source/master art outside runtime folders where appropriate; runtime exports must be mobile-sized.
- Do not bake HUD text, dynamic currency values, mission names, health, trajectory, targets or progression state into background art.
- Do not crop the concept board into production assets.
- Every generated/licensed/external asset must have provenance recorded.

## Runtime folder target

```text
assets/art/production/
  shared/
    ui/
    props/
    vfx/
  hub/
  campaign/
  garage/
  workshop/
  battle/
    outskirts/
```

Only create folders when the first real asset is ready.

---

## 1. Shared UI production kit

### Required
- dark industrial 9-slice panel
- active/selected warm-hazard border treatment
- disabled/locked treatment
- compact resource/status plate
- large primary action button
- compact secondary button/tab
- icon family for Salvage, platform, module, mission/objective and back/navigation

### Visual requirements
- deep charcoal/navy plates
- subtle worn metal, not noisy grunge
- warm bone text
- dirty gold/orange selection accents
- restrained teal only for precision/recovered-tech states
- generous portrait touch targets

### Integration
Keep Godot Theme as the authority for state/spacing. Text and state remain native UI; image assets provide surfaces/icons, not baked controls.

---

## 2. Fort Knocks Hub

### Background layers
1. `hub_sky_far` — sky, sun, distant ruined skyline
2. `hub_mid_structures` — settlement scaffolding/corrugated buildings
3. `hub_base_structures` — garage/workshop/gate framework
4. `hub_foreground` — low scrap/road-edge framing only

### Stateful overlays
- early perimeter / open workshop
- organised salvage storage
- generator + permanent lighting
- reinforced gate / command mast
- heavier fabrication bay
- secured storage bay

These must be overlays on the same base location, not separate unrelated hub paintings.

### Dynamic content kept separate
- active platform vehicle
- equipped visible module
- progress/resource labels
- navigation buttons
- reward notice

---

## 3. Command Board

### Required art
- physical recovered map/route-board backing
- paper/map texture without baked mission labels
- pin/route-node icons
- completed/available/locked node states
- optional photo-card frame used for mission thumbnails
- surrounding timber/metal/workbench framing

### Integration rule
Mission order, availability, reward and tactical text stay data-driven. Art must support arbitrary current mission definitions rather than hard-code the concept-board routes.

---

## 4. Garage

### Background layers
1. dark garage shell
2. structural beams/tool storage
3. warm overhead practical-light overlay
4. floor/platform shadow/podium
5. low foreground workshop clutter

### Dynamic hero assets
Each current combat platform needs a coherent production family:
- Run-down Compact
- Old Sedan / Estate
- Pickup
- Improvised Technical

For each platform:
- garage showcase sprite
- battle side-view sprite
- hub parked sprite or compatible scaled variant
- authored staged damage overlays/openings where required
- module attachment anchors

The same vehicle must be recognisably the same platform in Hub, Garage and Battle.

---

## 5. Workshop

### Background layers
- workshop shell
- pegboard/tool wall
- warm task-light overlay
- workbench
- restrained foreground clutter

### Dynamic hero assets
- Scrap Bolt
- Heavy Slug
- Shock Capsule
- Spotter Rack
- Ballast Crates
- Twin Field Rack
- Stabilizer Rig

Do not add concept-only ammunition or upgrade categories.

---

## 6. Outskirts Battle

### World-space layers

#### Atmosphere
- sky/sunset gradient or painted sky
- distant haze/sun

#### Far layer
- distant low city/industrial silhouettes
- should be lowest contrast

#### Midground kit
- roadside commercial shell
- broken flyover pieces
- utility poles/cables
- salvage-yard stacks
- stripped vehicle silhouettes
- depot/crane silhouettes

#### Gameplay terrain skin
- cracked asphalt
- faded maintenance lines
- kerb/concrete edge treatments

Collision remains the existing authored gameplay geometry.

#### Foreground — locked secondary-reference treatment
- dark close concrete fragments
- blurred/dark scrap silhouettes
- scrub/vegetation clumps
- partial wreck/bodywork silhouettes
- occasional warm rust highlights

Foreground must stay mostly below the projectile/aiming corridor and behind gameplay actors in draw order.

### Interactive objects stay separate
- roadblock
- collapsible scrap gate
- unstable power cell
- combat platforms / survivors
- later objective targets

They require stronger value/silhouette than the environment.

---

## 7. First representative asset gate

Do **not** generate all assets at once.

First approval set — **IMPLEMENTED, awaiting local Play acceptance**:
1. **Hub layered background set** — authored sky/far, mid-structure and low foreground layers integrated behind dynamic settlement progression.
2. **Run-down Compact production vehicle family** — one authored source reused across Hub / Garage / player Battle.
3. **Outskirts environment set** — authored sky/far, midground, road and approved dark foreground layers integrated for Outskirts variants.
4. **Shared UI panel/button kit** — authored scalable industrial panel/button surfaces integrated through the central Theme and existing `style_card()` calls.
5. **Player survivor production silhouette** — authored source integrated for the player only, aligned to existing feet/muzzle gameplay contracts; enemy remains visually distinct on the current fallback.

Integrate these in the real project and evaluate at normal phone scale.

Only after that set matches the locked reference should the remaining variants be produced.

## Mobile budget principles

Until measured on device:
- prefer 2K-or-smaller individual runtime textures where practical,
- atlas small props/UI icons,
- avoid large transparent empty texture areas,
- avoid full-resolution duplicate backgrounds,
- keep parallax layers static/non-colliding,
- use particles/procedural VFX rather than frame-heavy cinematic sprite sheets unless justified,
- profile before increasing resolution.

Final budgets should be set from Android/iOS device profiling, not guessed.

## Review standard

An asset is rejected when it:
- looks like greybox art with extra texture,
- is generic apocalypse art that could belong to any game,
- changes the game into sci-fi/fantasy/zombie/nautical imagery,
- makes the projectile corridor harder to read,
- uses a different lighting/rendering style from the locked reference,
- cannot be mapped cleanly to the existing scene/gameplay architecture,
- introduces an unapproved gameplay feature simply because the concept image showed it.


## Implementation note — 2026-10-05

The first representative asset-pipeline proof is now live:
- `assets/art/production/vehicles/run_down_compact.svg` is the single authored source for the starting platform,
- Hub reuses the source directly,
- Garage now has a dynamic platform showcase and reuses the source when Compact is active,
- player Battle cover reuses the source while existing collision/damage rules stay authoritative,
- enemy cover deliberately remains on its existing procedural/faction-neutral presentation so Fort Knocks markings are not leaked to opponents,
- later platforms remain temporary fallbacks until their individual production assets are approved.

This proves the intended separation between production art and gameplay geometry before the rest of the vehicle ladder is authored.


## Representative gate implementation — 2026-10-05

The representative production set is now complete in code/assets and should be judged in local Play before expanding the art batch.

Key separation rules are proven:
- Hub environment art is static layered presentation while settlement progression remains dynamic.
- Outskirts decorative layers do not own collision.
- Player survivor art does not own collision or launch origin.
- Shared UI art scales through nine-patch surfaces while native controls keep text/input/state.
- Fort Knocks player markings are not applied to enemy cover or enemy survivor presentation.

If this gate passes visually and functionally, the next production batch can safely scale the established pipeline to Command Board/Workshop hero details and the remaining platform family without changing the art architecture.
