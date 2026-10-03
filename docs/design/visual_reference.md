# Fort Knocks — Locked Primary Visual Reference

**Status: LOCKED**
**Locked on: 2026-10-03**

This document and the companion image are the primary visual target for Fort Knocks.

![Primary visual reference](reference/fort_knocks_primary_visual_reference.svg)

## Authority

When implementation, generated assets, UI, environments, vehicles, props, lighting or later concept work disagree with this reference, the reference wins unless the project owner explicitly changes the direction.

The reference controls **visual language and finish**, not feature scope. Do not copy incidental UI numbers, currencies, weapon names, wave counters, upgrade categories, map nodes, or other invented content from the concept image unless those systems exist in canonical game design.

## Locked theme

**High-quality stylised modern post-collapse salvage warfare.**

The world is recognisably a collapsed modern civilisation:
- roads, overpasses, warehouses, garages, residential streets and low commercial strips,
- civilian cars, pickups, machinery and infrastructure rebuilt for survival,
- corrugated salvage, welded repair plates, concrete, exposed steel, utility poles and improvised fortification,
- a settlement that evolves from vulnerable scrap camp into a disciplined fortified base.

It must not drift toward:
- generic zombie apocalypse,
- nautical / raft combat,
- fantasy wasteland,
- clean sci-fi,
- military-simulator realism,
- flat greybox/procedural-placeholder presentation,
- low-detail cartoon clip-art.

## Finish target

The required finish is materially higher than the current procedural prototype:
- painterly/cel-shaded 2D illustration,
- crisp silhouettes,
- cinematic warm lighting,
- atmospheric depth,
- foreground framing,
- controlled texture and material wear,
- polished dark UI panels with warm hazard accents,
- strong phone-scale readability.

The game remains 2D gameplay. 2.5D comes from layered art, parallax, foreground/midground separation, lighting, selective shadows and composited effects — not from converting combat into 3D.

## Scene application

### Fort Knocks hub
Use the concept's base composition:
- in-world settlement, not a menu background,
- garage/workshop structures physically present,
- warm work lights and camp lighting,
- layered scaffold/corrugated construction,
- active platform visible in the base,
- progression adds organised storage, fabrication, lights, stronger perimeter and heavier infrastructure without replacing the location.

### Command Board
Use a physical campaign-planning surface:
- paper map / recovered road map,
- pinned photographs or route cards,
- drawn route line and unlocked/locked nodes,
- dark surrounding frame,
- retain real campaign regions and mission data rather than concept-only content.

### Garage
Vehicle is the visual hero:
- large side/three-quarter presentation,
- warm overhead work lights,
- real workshop structure behind it,
- clear platform selector and tactical information,
- progression remains Compact → Sedan/Estate → Pickup → Improvised Technical and later approved tiers.

### Workshop
Workbench/pegboard physicality:
- actual weapon/tool silhouettes in the world,
- warm task lighting,
- modules presented as fabricated hardware,
- retain current Scrap Bolt / Heavy Slug / Shock Capsule and existing module rules.

### Battlefields
Use the main reference for atmosphere, colour, silhouettes and background depth.

**Foreground treatment is specifically taken from the second approved concept:** stronger near-camera cover/debris silhouettes, darker foreground value, vegetation/scrap/road-edge framing and a more cinematic depth break.

Foreground must never hide:
- shooter,
- launch gesture,
- trajectory preview,
- interactive object,
- impact result.

## Region language

- **Outskirts:** roadside commercial/industrial fringe, broken overpasses, utilities, scrap yards.
- **Suburbs:** abandoned residential/commercial edge, houses, walls, bus shelters, local roads.
- **Highways:** interchanges, service infrastructure, abandoned transport, concrete.
- **Industrial:** factories, storage yards, tanks, pipes, cranes.
- **Badlands:** stripped roads and sparse infrastructure, not fantasy desert.
- **Military perimeter:** recovered checkpoints, barriers, towers and hardened infrastructure.
- **Inner city / secure zones:** denser urban ruin and increasingly valuable recovered technology.

Only Outskirts and Suburbs should be production-built before current milestone acceptance unless scope changes.

## Colour / lighting hierarchy

Base UI/world anchors:
- near-black blue/green charcoal for UI and deep shadow,
- warm bone/off-white for primary text,
- dirty hazard yellow/gold for selection and player-important emphasis,
- rust/orange for repair and warmth,
- desaturated steel/green-grey for world materials,
- restrained teal/cyan for recovered electronics, precision and unstable technology.

Lighting target:
- warm late-afternoon / sunset bias where appropriate,
- strong readable light direction,
- warm practical lights in Fort Knocks, Garage and Workshop,
- cooler teal reserved for functional contrast rather than bathing the whole scene.

## Non-negotiable readability

Polish cannot damage artillery readability:
1. gameplay silhouettes before decoration,
2. projectile corridor kept comparatively clean,
3. important interactives have distinct silhouette/value,
4. background contrast is lower than active gameplay objects,
5. foreground framing is darkest but kept away from touch/trajectory critical areas,
6. HUD respects portrait safe areas and one-handed play.

## Asset rule

The concept board is a **reference**, not a production texture atlas. Do not crop its objects and ship them as game sprites.

Production assets must be authored/generated as separate clean assets using this visual language and recorded under the project's provenance rules.

## Change control

Any proposal that materially changes the visual theme should explicitly state:
- what differs from this reference,
- why the current reference is insufficient,
- whether the change is local or project-wide.

Do not silently drift the style one screen at a time.
