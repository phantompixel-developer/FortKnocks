# Fort Knocks — Visual Production Pass 3: Suburbs

**Branch:** `feat/visual-production-batch-2` (continued by explicit owner request)  
**Primary authority:** `docs/design/visual_reference.md`  
**Previous production work:** Pass 1 checkpoint + Pass 2 vehicle/meta-screen batch

## Non-negotiable reference lock

This pass does **not** reinterpret the art direction.

The locked target remains:
- high-quality stylised modern post-collapse salvage warfare,
- painterly/cel-shaded 2D presentation,
- cinematic warm late-afternoon lighting,
- restrained steel/green-grey world materials,
- dark near-camera foreground framing,
- modern civilian infrastructure first,
- teal/cyan reserved for genuine recovered electronics or unstable technology,
- strong phone-scale silhouette/readability.

Suburbs must not become:
- generic zombie suburbia,
- fantasy wasteland,
- lush overgrown apocalypse,
- clean sci-fi,
- a recoloured copy of Outskirts,
- a dense decoration layer that obscures artillery play.

## Region identity

Suburbs is the abandoned residential/commercial edge immediately beyond Outskirts.

Recurring language:
- terraced / semi-detached residential rooflines,
- local garages and service lanes,
- broken garden and retaining walls,
- bus/service shelters,
- local-road markings and crossings,
- lighter residential utility clutter,
- sparse dry trees/scrub,
- damaged junction furniture.

The same world language as Outskirts remains visible through utility poles, road wear, welded repairs and warm/rust accents.

## Implemented region layers

Shared across all four Suburbs encounters:
1. `suburbs_sky_far.svg`
2. `suburbs_midground.svg`
3. `suburbs_road.svg`
4. `suburbs_foreground.svg`

Mission-specific low-contrast landmark overlays:
- Dead Air — local service-strip shell,
- Crossroads — damaged junction/corner-shop language,
- Loaded Up — garage/service lane and stripped delivery shell,
- Hot Cargo — denser retaining/service infrastructure without fake power-cell cues.

These overlays are presentation-only and never create gameplay collision.

## Interactive production assets

Suburbs-specific hero interactives now include:
- production Signal Relay,
- production protected Salvage Load,
- region-specific retaining-wall treatment for authored elevated battle platforms.

The existing collision, HP, blast interaction and objective logic remain authoritative.

## Mission readability requirements

### Dead Air
The real Signal Relay must be the strongest relay-like silhouette in the frame. Background infrastructure may suggest local services but must not contain fake active electronics.

### Crossroads
The elevated enemy position and pressure-weapon problem remain readable. Junction furniture stays behind gameplay geometry and must not be mistaken for cover.

### Loaded Up
The protected Salvage Load must read immediately as the mission-critical object. Background delivery/garage shapes remain lower contrast.

### Hot Cargo
The real unstable Power Cell and Salvage Load must remain visually dominant. Background infrastructure must not use teal live-energy cues that compete with the cell.

## Foreground rule

Suburbs foreground follows the second approved concept exactly in principle:
- darkest value in the scene,
- broken garden walls,
- scrub/hedge remnants,
- tyre/fence/sign silhouettes,
- low near-camera framing.

It stays below the projectile corridor and cannot obscure shooter, aim gesture, trajectory, objectives or impact results.

## Acceptance gate

Before this branch is checkpointed:
- all four Suburbs missions clearly belong to the same region,
- Suburbs is recognisably different from Outskirts without changing the global art style,
- Dead Air relay remains unmistakable,
- Crossroads elevated firing problem remains readable,
- Loaded Up Salvage remains obvious at a glance,
- Hot Cargo cell + Salvage relationship remains readable,
- foreground increases depth without obstructing aiming,
- authored platform geometry looks like plausible Suburbs retaining/service infrastructure,
- no mission physics or objective rules change,
- no raw SVG is preloaded as a Resource,
- fallback presentation still allows project boot if production art decode fails.

## Next visual work after acceptance

Do not jump to another global theme.

After Suburbs acceptance, the next visual batch should first review remaining current-screen quality gaps and Milestone 4 acceptance. Only then should a later region (Highways) begin production art.
