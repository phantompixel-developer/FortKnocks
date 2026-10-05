# Fort Knocks — Visual Reference Completion Plan

**Branch:** `feat/visual-reference-completion-one-pass`  
**Authority:** `docs/design/visual_reference.md` and the approved Fort Knocks visual board  
**Rule:** presentation may improve; gameplay contracts, collision, progression rules and portrait combat readability must not drift.

## Remaining implementation work

1. **Consolidate the accepted A–D visual-polish stack onto one branch from `main`.**
2. **Author Hub progression overlays** so settlement growth no longer drops from authored art into procedural rectangles/lines.
3. **Propagate the approved reference-finish recipe** beyond the representative pilot to the rest of the current production asset families: vehicles, rival, interactives, campaign board, Workshop hardware, both environment kits and compact/tactical UI.
4. **Break up Suburbs repetition** with more varied residential silhouettes/material wear while preserving lower background contrast.
5. **Add restrained screen transitions** so Hub/meta/battle changes feel like one product without slowing navigation.
6. **Run source-level visual QA**: SVG compatibility, art-path coverage, no direct SVG resource preloads, safe-area API signature, progression overlay coverage, and transition integration.
7. **Local Play/device acceptance remains mandatory** for the final gate because source inspection cannot prove phone-scale composition, touch safety, frame pacing or exact rendered output.

## Quality acceptance

A task is implementation-complete only when:
- it follows the approved modern post-collapse salvage-war visual language;
- it does not add unrelated sci-fi/fantasy/zombie/nautical motifs;
- hero silhouettes remain readable at phone scale;
- environment detail stays subordinate to gameplay objects and projectile path;
- warm key light / cool structural shadow / construction-led wear are visible where appropriate;
- gameplay geometry and progression data remain authoritative;
- procedural fallbacks remain available where production art decoding can fail.

Runtime-dependent acceptance is deliberately not marked complete until normal Godot Play/device review is performed.


## Single-branch consolidation status — 2026-10-05

The complete current-content visual remediation is consolidated on this branch, created from current `main`.

Source-level QA completed after consolidation:
- branch is ahead of `main` and has no behind commits,
- safe-area helper uses Godot 4.7-compatible `DisplayServer.get_display_safe_area()` with no arguments,
- the shared portrait helper is integrated into Battle, Command Board, Garage, Workshop and Hub-facing UI,
- campaign Run Brief is player-controlled; the 1.15-second timer remains only for standalone Encounter Proof,
- all ten current missions have explicit region, location and tactical-warning metadata,
- all six Outskirts and four Suburbs missions have mission-aware production landmark coverage,
- all five current Fort Knocks settlement-growth overlays use authored production layers,
- compact HUD and tactical inspect panel variants are integrated,
- shared screen-reveal transitions are integrated and guarded against overlapping tweens,
- modified runtime GDScript contains no direct `.svg` preload usage.

These checks establish source/architecture completion only. Normal Godot Play and device review remain mandatory before declaring visual acceptance, because repository inspection cannot prove final phone-scale composition, touch comfort, rendered SVG quality, import behavior, frame pacing or device safe-area behavior.


## Screenshot-driven correction pass — 2026-10-05

A second visual correction pass was performed after reviewing real 360×640 Godot Play screenshots against the locked visual reference board. The screenshots exposed a gap that source-only inspection understated: the previous build was structurally aligned but still read as a flat, sparse vector prototype rather than the dense cinematic 2D/2.5D target.

Changes in this pass:
- **Garage:** enlarged the selected platform so the vehicle owns the bay; reduced empty framing; corrected notice placement; preserved Compact unchanged because its silhouette already reads correctly.
- **Old Sedan / Estate:** rebuilt as a longer, rugged estate/wagon with a distinct roofline, roof rack, luggage, four-door/cargo read, larger stance and salvage repairs. It must no longer resemble a stretched Compact.
- **Pickup:** rebuilt as a lifted, heavier utility pickup with a clearer cab/bed split, roll/utility rack, cargo, bull bar and larger tyres.
- **Fort Knocks Hub:** replaced the tall vertical menu stack with a compact bottom navigation dock, reduced the dark screen wash, enlarged the active platform and rebuilt the authored settlement mid-layer with scaffolding, multi-level fabrication space, tarps, command/lookout structure, warm practical lighting and stronger sunset depth.
- **Outskirts:** strengthened the warm sunset atmosphere and rebuilt the roadside midground with more varied modern civilian structures, signage remnants, utility infrastructure, wrecks, vegetation and material breakup while preserving the projectile corridor.
- **Workshop:** moved from three equal weapon thumbnails toward one large selected specialist hero plus the permanent Scrap Bolt; added dedicated projectile hero art and gave hardware more of the screen.
- **Command Board:** increased physical-planning-board detail with pinned location-photo scraps, cord/annotation language and more readable route-order controls.

Reference guardrail remains unchanged:
- modern post-collapse salvage world,
- grounded civilian infrastructure,
- warm cinematic light,
- layered 2.5D depth,
- dark industrial UI,
- strong phone-scale silhouettes,
- no sci-fi/fantasy/zombie/nautical drift.

This pass is source-complete only. It must be reviewed again in Godot Play using the same screenshot set before visual acceptance. If the rendered frames still do not approach the reference, the remaining gap should be treated as art-production quality rather than solved by further UI rearrangement alone.
