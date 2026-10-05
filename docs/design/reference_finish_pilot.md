# Fort Knocks — Reference Finish Pilot

**Status:** IMPLEMENTED  
**Branch:** `feat/visual-polish-d-reference-finish-pilot`  
**Authority:** `docs/design/visual_reference.md`

## Purpose

This pilot closes the gap between the correct Fort Knocks visual language and the richer rendering finish shown in the approved primary reference.

It does not change silhouettes, gameplay geometry, progression or the approved theme.

The goal is to prove a repeatable finishing treatment before applying it across every production asset.

## Representative pilot set

The following reused production masters received the finish pass:

- `assets/art/production/vehicles/run_down_compact.svg`
- `assets/art/production/characters/fort_knocks_survivor.svg`
- `assets/art/production/hub/hub_mid_structures.svg`
- `assets/art/production/battle/outskirts/outskirts_midground.svg`
- `assets/art/production/shared/ui/panel_industrial.svg`
- `assets/art/production/shared/ui/button_industrial.svg`

Because these are existing shared masters, the pilot propagates naturally to their current usages rather than creating screenshot-specific duplicates.

## Locked finishing recipe

### 1. Preserve silhouette first
Do not add surface detail that weakens the phone-scale outline.

Vehicle family, survivor posture, structures and interactives must remain identifiable before texture/detail.

### 2. Use a three-value material structure
Each important material should read through:
- warm or neutral key-light plane,
- base material plane,
- cooler/deeper occlusion plane.

Avoid one flat fill plus random scratches.

### 3. Warm key light, cool structural shadow
The approved reference uses a cinematic warm directional bias.

Use:
- warm amber/rust edge light on upper/exposed planes,
- cool green-grey/blue-grey in recesses and lower occlusion,
- near-black only for deepest contact/separation.

Do not orange-wash the whole asset.

### 4. Wear follows construction
Chips, scratches and rust belong primarily on:
- exposed edges,
- repair plates,
- seams,
- fasteners,
- lower grime zones,
- frequently handled UI edges.

Avoid uniform noise.

### 5. Contact and attachment need weight
Vehicles, structures and UI plates should show:
- stronger contact shadow,
- darker overlap where parts meet,
- believable attachment points,
- brighter edge only where light can actually catch it.

### 6. Recovered technology remains restrained
Teal/cyan is reserved for:
- electronics,
- targeting/precision,
- unstable/recovered old-world technology.

It is not a general cool-light wash.

### 7. Depth decreases detail
Backgrounds:
- lower local contrast,
- fewer hard material accents,
- less wear detail.

Hero gameplay objects:
- strongest silhouette,
- strongest controlled material separation,
- readable state changes.

### 8. SVG runtime compatibility
Current editable masters remain SVG.

Use only the SVG feature set already proven by `ProductionArt.texture_from_svg()`:
- paths,
- basic shapes,
- linear/radial gradients,
- stroke,
- opacity.

Do not depend on unsupported filter stacks or runtime SVG resource preloads.

Before mobile shipping, approved masters should still be rasterized to PNG/WebP runtime derivatives as already documented.

## Pilot-specific improvements

### Run-down Compact
- warmer top-edge/rim light,
- cooler lower-body occlusion,
- additional chipped paint and repair-surface breakup,
- stronger window reflection separation,
- darker wheel/contact integration.

### Fort Knocks survivor
- directional coat/scarf rim light,
- deeper cloth/material separation,
- restrained fabric wear,
- launcher/metal highlight breakup,
- stronger silhouette-preserving shadow planes.

### Hub mid structures
- roof-edge warm light,
- corrugated plane variation,
- cooler lower-wall shadow,
- controlled rust/chip marks,
- localized workshop glow.

### Outskirts midground
- stronger atmospheric material hierarchy,
- warm roof/wall key-light edges,
- cool lower-building occlusion,
- restrained roadside wear,
- lower contrast than hero battle objects.

### Industrial UI family
- clearer bevel depth,
- subtle handling wear,
- restrained warm edge,
- deeper lower contact edge,
- preserved high-contrast text area.

## Propagation rule

Do not blindly add more scratches.

When this finish is propagated to another asset, apply the material/light recipe according to that asset's construction and gameplay importance.

The approved reference remains the visual ceiling and authority.
