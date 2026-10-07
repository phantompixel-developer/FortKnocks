# Fort Knocks — Game-Wide Visual Signature

**Status:** LOCKED FOR CURRENT PRODUCTION  
**Established:** 2026-10-07  
**Primary authority:** `docs/design/visual_reference.md`

## Why this exists

Fort Knocks had reached a point where individual screens could be visually strong while still appearing to belong to different games.

The problem was not palette drift alone. The project had multiple rendering pipelines:

- Hub uses authored raster scene tiles and physical UI art.
- Garage / Workshop use the shared high-fidelity raster asset kit.
- Command Board uses a physical paper / wood / pin / photograph kit.
- Battle used the same broad palette but retained more of the earlier clean vector/SVG rendering and a parallel SVG UI-surface family.

From this point forward, region identity may change **content**, but not the game's rendering signature.

## Canonical signature

The target is the visual treatment already strongest across Hub, Garage, Workshop and Command Board:

- stylised painterly / cel-shaded 2D illustration,
- strong dark silhouette control,
- broad warm directional key light,
- cool blue-charcoal deep shadow,
- visible contact shadow / ambient occlusion,
- worn civilian materials rather than clean military/sci-fi surfaces,
- restrained surface texture and edge wear,
- warm dust / atmospheric separation,
- physical object staging rather than flat icon-like placement,
- dark navy/charcoal UI surfaces with layered borders,
- warm bone/off-white typography,
- dirty yellow/gold active emphasis,
- Barlow Condensed typography family,
- teal/cyan only for functional recovered technology.

The Garage / Workshop scene treatment is a particularly useful quality reference:
objects should feel lit, weighted and physically present before decorative detail is added.

## What must NOT happen

Do not:
- flatten Hub/Garage/Workshop/Command Board to match the older battlefield SVG look,
- introduce a separate battle-only UI skin,
- create region-specific rendering styles,
- use clean vector gradients as the final quality ceiling for hero art,
- add grain/noise everywhere as a substitute for real material rendering,
- use glow as the primary method of making gameplay objects readable,
- crop concept-board art into production battlefield textures.

## Screen rules

### Hub

The Hub is an in-world settlement first.
Its authored raster environment and warm practical-light treatment are part of the canonical signature.

### Command Board

The board may use paper, timber, tape and photographs because it is a physical object in the same world.
Its material language can differ from combat steel/concrete while retaining:
- warm lighting,
- texture,
- depth,
- physical contact/shadow,
- the shared typography hierarchy.

Region photographs are visual/compositional references; placeholder photographs are not automatically production battlefield textures.

### Garage / Workshop

These currently provide the clearest rendering-quality benchmark:
- strong upper-side warm light,
- deep cool shadow,
- weighted hero object,
- contact shadow,
- controlled grime/wear,
- dark lower UI field,
- layered raster UI surfaces.

### Battle

Battle must now converge toward the same finish:
- environment layers may remain separate for parallax/readability,
- collision and gameplay stay 2D,
- the visual result must no longer read as a cleaner/flatter vector game,
- hero vehicles, survivors and interactives require the same light/material discipline as Garage/Workshop,
- background contrast remains lower than gameplay objects,
- projectile corridor remains cleaner than either foreground or background,
- dark foreground framing remains cinematic but never blocks aiming.

## Shared UI rule

There is one live-game UI surface family.

Canonical shared runtime surfaces are under:

`assets/art/claude_assets/1_Asset_Kit/00_shared/png/ui/`

Battle should use the same family for panels/cards/buttons rather than maintaining an independent SVG panel language.

The older production SVG panel/button assets may remain as fallback/reference assets, but they are not the preferred visible production signature.

## Battle art pipeline direction

The current battlefield SVG layer architecture remains useful because it separates:
- sky/far,
- midground,
- mission landmark,
- road,
- foreground,
- interactive/gameplay objects.

That architecture stays.

However, **SVG is not the locked final rendering format**.

Where the current vector masters cannot reach the painterly/cel-shaded finish of Hub/Garage/Workshop, replace the visible production layer with an authored raster PNG/WebP layer while retaining:
- the same dimensions,
- the same layer role,
- the same collision-independent contract,
- the SVG or procedural source as fallback/blockout where useful.

This allows visual quality to rise without rewriting battle mechanics.

## Acceptance test

A screenshot sequence of:

Hub → Command Board → Garage → Workshop → Outskirts battle → Suburbs battle

must feel like one game's camera moving between different physical places.

Failure signs include:
- battle suddenly becoming flatter or cleaner,
- different outline/shadow philosophy,
- different typography weight,
- UI plates looking from a different product,
- objects losing contact with the ground,
- lighting direction changing without scene justification,
- region changes appearing to be engine/style changes rather than location changes.

Highways must not start until this cross-screen comparison passes locally.
