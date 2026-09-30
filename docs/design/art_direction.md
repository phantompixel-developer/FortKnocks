# Fort Knocks — Art Direction

## Target

**Stylised gritty 2D salvage-war illustration**: readable and characterful at phone size rather than photorealistic, grimdark, military-simulator, or generic zombie imagery.

The first production-presentation pass establishes an independent Fort Knocks visual language built from:
- welded civilian machinery,
- mismatched repair plates,
- faded road-maintenance markings,
- corrugated salvage,
- exposed concrete and rebar,
- warm hazard paint against muted oxidised greens,
- cold blue/teal reserved for unstable recovered technology.

## Core palette and visual grammar

Representative palette:
- **Coal / deep outline:** near-black green-grey.
- **Iron / plate:** dark desaturated industrial greens.
- **Bone:** warm off-white for readable text and highlights.
- **Hazard:** dirty yellow/gold for player-readable emphasis.
- **Rust:** oxidised orange-brown for repairs, wear, and secondary marks.
- **Oxide:** desaturated teal for equipment and precision information.
- **Cold energy:** pale cyan/teal for unstable old-world electrical technology.

The palette is implemented centrally in game/presentation/fort_knocks_theme.gd. New UI and authored procedural visuals should reuse it rather than inventing screen-specific colours.

### Knock-mark motif

Two offset diagonal painted slashes are the first simple Fort Knocks identifier.

They appear on:
- the hub perimeter/gate,
- improvised combat-platform repair plates,
- selected salvage/roadside props.

This is a visual identifier, not a final faction logo. It can evolve later, but new work should not introduce a conflicting player emblem casually.

## Visual principles

- Strong silhouettes at phone size.
- Exaggerated but believable vehicle/platform shapes.
- Player-relevant objects read before scenery.
- Damage states change silhouette and surface treatment immediately.
- Dust, sparks, smoke, debris, recoil and impact animation carry much of the perceived polish.
- Avoid visual noise inside the projectile corridor.
- The same gameplay object should remain recognisable across damage states.
- Background depth is achieved with layered non-colliding 2D shapes before considering 3D.
- Presentation must not silently alter collision, balance or firing geometry.

## Layering

Typical battlefield presentation:
1. sky / atmosphere,
2. distant Outskirts silhouette,
3. midground structures and utility infrastructure,
4. gameplay terrain,
5. combatants and combat platforms,
6. interactive foreground props,
7. VFX,
8. portrait HUD.

The first Outskirts implementation uses multiple non-colliding layers in battlefield_visual.gd; gameplay remains fully 2D.

## Survivor direction

The representative survivor silhouette now uses:
- layered scavenged coat/clothing,
- backpack,
- shoulder/utility hardware,
- scarf/headwear,
- improvised launcher,
- small warm/cold accent differences rather than highly detailed facial art.

The target is a survivor who reads as a resourceful roadside fighter, not a soldier in pristine military kit.

Crew variants should be created through readable silhouette/equipment differences before adding cosmetic detail.

## Combat-platform direction

The first four platform families should remain readable by silhouette before detail:
- **Run-down Compact** — small civilian shell, patched and vulnerable.
- **Old Sedan / Estate** — longer civilian mass and wider protection.
- **Pickup** — open rear utility bed and obvious module space.
- **Improvised Technical** — pickup-derived but visibly reinforced, with a support cage/mount and heavier fabrication. The active Technical module should be visible: paired rack hardware for Twin Field Rack, ground-brace/jack language for Stabilizer Rig.


Early platforms are still recognisably civilian:
- **Run-down Compact** — small, vulnerable, patched.
- **Old Sedan / Estate** — longer protection profile and more substantial cabin.
- **Pickup** — wider utility silhouette with an exposed rear bed.

Shared visual rules:
- dark chassis,
- mismatched salvage panels,
- visible welding/repair plates,
- exaggerated readable wheels,
- chipped/rusted surfaces,
- authored damage openings,
- optional module silhouette mounted where its function is visually understandable.

Later platforms may become more disciplined and armoured, but should retain evidence of repair and reuse.

## Interactive prop direction

The first representative props establish three material families:
- **Roadblock:** poured concrete, chips, exposed rebar, faded maintenance striping.
- **Scrap gate:** welded frame, mismatched corrugated panels, bolted braces, painted hazard marks.
- **Power cell:** recovered industrial electrical hardware, welded carrier, cold-energy readout.

Interactive props must be visibly more deliberate than background clutter.

## Outskirts identity

The first region is a contiguous abandoned roadside/industrial fringe rather than six unrelated arenas.

Recurring motifs:
- low commercial/industrial silhouettes,
- broken flyover concrete,
- utility poles and cables,
- salvage yards and stripped vehicle stacks,
- cracked road surfaces,
- faded maintenance markings,
- improvised roadside barriers.

Mission-specific geometry remains authored for gameplay; environmental art should reinforce the firing problem without obscuring it.

## Fort Knocks

The hub is a progression visualisation, not a menu background.

Early:
- mismatched corrugated perimeter,
- open workshop,
- scrap,
- camp fire,
- vulnerable civilian platform.

Mid:
- organised salvage storage,
- generator,
- permanent lights,
- improved garage structure,
- utility-equipped Pickup.

Outskirts-secured:
- reinforced perimeter,
- cross-braced gate,
- command/radio mast,
- more deliberate defensive organisation.

Progression should look like the same settlement becoming more capable, not a sequence of unrelated hub skins.

## UI direction

The UI uses the same physical language as the world:
- coal/iron plates,
- bone text,
- warm hazard emphasis,
- oxide/cold accents for precision or recovered technology,
- restrained borders,
- compact rectangular cards.

Rules:
- do not cover the road, likely projectile path, shooter, or pull-back gesture,
- use colour to reinforce state, not replace text,
- selected/active states must remain readable in greyscale/value,
- keep all touch targets large enough for portrait mobile use.

## VFX direction

Impacts use a staged sequence:
1. fast contact flash,
2. material-specific ring/sparks,
3. slower dust/debris/pulse tail.

Material language:
- road/ground → dust,
- cover/gate → warm metal sparks and fragments,
- crew → compact warm impact arc,
- shock/power → cold expanding rings.

Projectile roles should also read in flight through silhouette and trail, not only colour.

## 2.5D rule

2.5D may be used for parallax, layered vehicle parts, lighting tricks or presentational depth. Core collision, trajectory, damage and gameplay remain 2D unless a concrete design problem proves otherwise.

## Representative production pipeline

The Milestone 3 representative pipeline is deliberately lightweight and repository-native:

1. Establish silhouette and value hierarchy with Godot 2D drawing primitives.
2. Validate phone-size readability in the real battle/hub.
3. Keep collision and visual code independent.
4. Reuse the central palette/theme.
5. Approve the representative object/category before adding more variants.
6. Only replace procedural shapes with external authored sprites/atlases when that replacement clearly improves quality without harming readability/performance.
7. Record source/provenance for every external production asset.

This prevents expensive art batching before the visual language is proven.

## Provenance for the current production-presentation pass

The current Milestone 3 visuals are original, repository-authored procedural/vector-style drawings implemented in GDScript. No third-party artwork, generated image asset, licensed sprite pack, copied logo, or external texture was introduced by this pass.

The presentation therefore has no external art-asset attribution dependency at this stage.

## Originality

Do not use another game's artwork as an image-to-image source for production assets. References may describe broad genre qualities, but final characters, silhouettes, UI, environments, props and composition must have an independent design language.
