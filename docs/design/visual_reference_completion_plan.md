# Fort Knocks — Visual Reference Completion Plan

**Branch:** `feat/visual-reference-completion-all`  
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
