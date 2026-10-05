# Fort Knocks — Visual Production Pass 2

**Branch:** `feat/visual-production-batch-2`  
**Primary reference:** `docs/design/visual_reference.md`  
**Previous checkpoint:** visual-production checkpoint merged to `main` in PR #10

## Objective

Scale the proven production-art pipeline across the remaining current platform family and the two meta screens that still read most strongly as menus: Command Board and Workshop.

This pass remains presentation-only. It must not alter campaign sequencing, purchase/equip rules, combat physics, collision or weapon balance.

## Batch 2 scope

### A. Complete current player platform family
Production art for:
- Old Sedan / Estate
- Pickup
- Improvised Technical

Each is reused across:
- Garage showcase,
- Fort Knocks Hub,
- player battle cover.

Enemy cover remains faction-neutral until an enemy visual-direction pass is explicitly approved.

### B. Command Board physicalisation
- recovered physical road-map surface,
- dynamic route path and mission-state pins,
- mission selection remains data-driven and accessible through native buttons,
- no mission names/rewards/state are baked into background art.

### C. Workshop physicalisation
- current weapon hardware visibly presented on the workbench/pegboard,
- current module hardware visibly presented,
- active specialist and module states layered dynamically,
- Twin Field Rack visibly represents both specialist weapons,
- purchase/equip controls remain native Godot UI.

## Explicitly out of scope

Do not add:
- new platforms,
- new weapons,
- new modules,
- new currencies,
- Suburbs environment production art,
- enemy faction art,
- gameplay redesign,
- new progression tiers.

## Acceptance gate

Before merging:
- all four current Fort Knocks platforms are recognisably the same platform between Garage, Hub and Battle,
- module overlays remain visually attached to the correct Pickup/Technical platform,
- Command Board reads first as a physical planning board and second as a menu,
- Workshop reads first as an actual fabrication/loadout space and second as a menu,
- all mission, purchase, equip and back-navigation interactions still work,
- no SVG is directly preloaded as a Resource,
- no production art owns collision or balance,
- portrait touch targets remain usable.

## Completion status

**Accepted by the project owner as the next visual direction and continued on the same branch.** The full player platform family, physical Command Board and physical Workshop presentation are now the baseline for subsequent visual work.

## Next pass after acceptance

The next visual-production branch should focus on the **Suburbs environment kit and region-specific encounter presentation**, reusing the same layering contract established for Outskirts.
