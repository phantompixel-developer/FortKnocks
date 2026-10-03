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

First approval set:
1. one Hub layered background set,
2. one Run-down Compact production vehicle family,
3. one Outskirts background/midground/foreground layer set,
4. one shared UI panel/button kit,
5. one survivor production silhouette.

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
