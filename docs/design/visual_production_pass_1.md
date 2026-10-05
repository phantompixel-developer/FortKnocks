# Fort Knocks — Visual Production Pass 1

**Branch:** `feat/locked-visual-direction-production-pass`
**Primary reference:** `docs/design/visual_reference.md`  
**Production asset manifest:** `docs/design/visual_asset_manifest.md`

## Objective

Move the existing playable game toward the locked visual reference without changing proven combat/progression rules.

This is a presentation production pass, not a feature-expansion pass.

## First complete slice

Production Pass 1 covers:
1. shared UI/theme foundation,
2. Fort Knocks Hub,
3. Command Board,
4. Garage,
5. Workshop,
6. Outskirts battle presentation.

Suburbs follows after the first slice proves readability and performance.

## What stays unchanged

Do not redesign:
- pull-back aiming,
- turn structure,
- camera-state rules,
- mission objectives,
- save/progression contracts,
- current platform/module balance,
- weapon rules,
- portrait information hierarchy.

Visual work must fit around those systems.

## Workstreams

### A. Presentation tokens
- central colours and text hierarchy,
- dark plated panels with controlled warm borders,
- selected/locked/disabled states,
- common card/button spacing,
- safe-area-aware top resource/header treatment,
- typography scale.

### B. Art layering contract
Every production battlefield should support:
1. atmosphere/sky,
2. far silhouette,
3. midground landmark layer,
4. gameplay terrain,
5. gameplay actors/interactives,
6. near foreground framing,
7. VFX,
8. HUD.

Only layers 4–5 determine gameplay collision unless explicitly authored otherwise.

### C. Hub
- replace flat/procedural feel with layered base composition,
- preserve visible progression stages,
- warm practical lights,
- physical garage/workshop/gate identity,
- active platform presented clearly.

### D. Command Board
- retain data-driven mission generation,
- replace generic vertical buttons with route/map presentation where feasible,
- mission cards/nodes must still expose name, tactical focus, reward and state accessibly.

### E. Garage
- large active vehicle showcase,
- stronger environmental framing,
- platform choices remain data driven,
- ensure four current platform tiers fit portrait without overlap.

### F. Workshop
- physical workbench/pegboard presentation,
- field rack and module choice remain obvious,
- no extra weapons/modules invented to match concept art.

### G. Outskirts battle
- warmer, richer atmosphere,
- improved far/mid silhouettes,
- authored roadside material language,
- second-reference foreground framing layer,
- keep trajectory corridor and interactive targets clean.

## Asset production approach

Use one representative asset/category before batching:
- one production vehicle/platform visual,
- one survivor direction,
- one environment prop kit,
- one background/midground kit,
- one foreground framing kit,
- one UI skin.

Approve in-engine before producing variants.

Prefer sprite sheets/atlases and layered transparent assets for world art. Use procedural Godot drawing only where it remains visually competitive or is useful for dynamic state/VFX.

## Representative production gate status

**Implementation status: accepted in local Play and merged to `main` as the visual-production checkpoint (PR #10).**

Implemented in this gate:
- layered production Fort Knocks backdrop,
- reusable production Run-down Compact,
- layered production Outskirts environment,
- scalable shared industrial UI surfaces,
- production player survivor aligned to existing gameplay geometry.

The user confirmed the lighting, depth, palette, foreground framing and readability direction in normal Play. The pipeline is approved to scale through subsequent visual-production passes.

## Acceptance gate

Do not expand to the rest of the game until local Play confirms:
- Hub, Board, Garage, Workshop and Outskirts visibly belong to the locked reference,
- game no longer reads as a greybox/procedural prototype at normal phone size,
- foreground increases depth without obstructing aim,
- current gameplay information remains at least as readable as before,
- no touch overlap is introduced,
- no progression or save behavior regresses,
- mobile rendering cost remains reasonable.

## Review checklist for every visual PR

- Does it match the locked reference at a glance?
- Is it still recognisably Fort Knocks rather than generic apocalypse art?
- Does it preserve 2D gameplay?
- Does it improve finish, not just add detail?
- Does it preserve projectile/touch readability?
- Does it reuse central palette/material language?
- Is the asset provenance recorded?
- Does it avoid adding unapproved gameplay content?

If any answer is no, the visual is not production-ready.
