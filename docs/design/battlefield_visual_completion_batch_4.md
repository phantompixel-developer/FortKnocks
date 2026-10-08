# Fort Knocks — Batch 4: Battlefield Visual Completion

**Branch:** `visual/battlefield-completion-batch-4`  
**Date:** 2026-10-07  
**Authority:** `docs/design/visual_reference.md` and `docs/design/current_game_visual_audit.md`

## Acceptance target

Outskirts and Suburbs must read as two regions of the same finished game. Suburbs must no longer expose a visibly newer environment pipeline than Outskirts.

This is a presentation pass. It does not intentionally change collision, mission geometry, HP, projectile behaviour, objective rules, AI, platform balance or encounter progression.

## Implemented

### Outskirts

- Replaced production-path procedural overpass/salvage landmark drawing with per-mission authored SVG overlays.
- Added dedicated composition for:
  - Roadblock Trial,
  - High Ground,
  - Scrap Gate,
  - Broken Span,
  - Depot Line,
  - Outskirts Checkpoint.
- High Ground and Broken Span no longer share the same visual identity merely because both use visual variant 1.
- Scrap Gate and Depot Line no longer share the same visual identity merely because both use visual variant 2.
- Increased atmospheric layering, material wear, road repair history and low foreground framing.
- Kept legacy procedural environment code only as a missing-production-art fallback.

### Suburbs

- Broke the repeated house/garage rhythm in the shared midground.
- Added more varied rooflines, setbacks, repairs, boarded surfaces, road wear and foreground silhouettes.
- Rebalanced all four landmark overlays around real gameplay targets:
  - Dead Air keeps background antenna-like clutter away from the Signal Relay.
  - Crossroads moves junction furniture away from the elevated enemy silhouette.
  - Loaded Up preserves a quieter read zone around protected Salvage.
  - Hot Cargo keeps neutral backdrop behind Salvage, the live cell and roadblock without introducing fake live-tech cues.

### Combat interactives and contact

- Added render-only contact treatment for player/rival cover vehicles.
- Added contact treatment for the central roadblock and collapsible scrap gate.
- Added neutral contact plus restrained live-tech spill for the unstable power cell.
- Added objective-specific ground treatment for Signal Relay and protected Salvage.
- Upgraded raised Outskirts/Suburbs platform rendering with region-specific wear, face breakup and bottom contact shadow while keeping the collision rectangle unchanged.

## Explicit non-changes

No mission `.tres` geometry or rule data is part of this batch. In particular:
- `platform_rects` are unchanged,
- roadblock/power-cell/gate/relay/salvage positions are unchanged,
- objective modes are unchanged,
- collision shape dimensions are unchanged,
- projectile/aim/camera rules are unchanged.

## Required local Play acceptance

Repository review can verify the asset/code architecture, but these items require Godot Play:

1. Run all six Outskirts missions and confirm each reads as a distinct place without hiding the player, enemy, trajectory corridor or tactical interactive.
2. Compare High Ground directly with Broken Span, and Scrap Gate directly with Depot Line.
3. Run Dead Air, Crossroads, Loaded Up and Hot Cargo and confirm the real objective/threat is the first tactical read.
4. Check intact/destroyed/spent/collapsed states for Relay, Salvage, power cell and scrap gate.
5. Check compact/sedan/pickup/technical cover contact at road level and on any raised platform used by current missions.
6. Confirm the new foreground remains below useful pull-back trajectory space in portrait.
7. Confirm no SVG decode warnings appear in the Godot console.

Do not begin Highways until this Play gate passes.


## Visual-signature unification extension

Batch 4 is now also the current-content **visual-signature convergence gate**.

The reason is structural: current meta screens already use a richer authored raster/physical treatment while Battle retained a parallel cleaner SVG/UI treatment. Shipping another region on top of that split would multiply the inconsistency.

Authority:
- `docs/design/visual_signature.md`

Implemented in this extension:
- Battle's shared theme now uses the same raster panel/card surface family already used by Garage, Workshop and Command Board.
- Battle remains on the shared Barlow Condensed typography family.
- The old battle-only SVG panel/button family is no longer the preferred live surface language.
- Battlefield region/hero art remains on the existing layered architecture but is explicitly treated as requiring continued convergence toward the painterly/cel-shaded signature where local Play still exposes flat-vector mismatch.

### Expanded acceptance gate

Before this batch closes, local review must compare:
1. Hub,
2. Command Board,
3. Garage,
4. Workshop,
5. at least two representative Outskirts battles,
6. at least two representative Suburbs battles.

The test is not whether every location has identical colours or materials. The test is whether they share:
- rendering finish,
- light/shadow philosophy,
- physical weight/contact,
- typography,
- UI surface family,
- wear/detail density,
- cinematic depth.

If Battle still reads as a different game after the structural/UI convergence in this branch, the remaining work is an **art replacement pass**, not another code/layout rewrite. Current battle layer contracts should be retained and their visible SVG layers replaced with higher-fidelity authored raster layers one category at a time.


## Visual-signature implementation completed in this branch

The convergence pass now applies the design-board signature materially, not only through documentation:

- **Battle UI:** live Battle panels/cards now use the same authored raster surface family as Garage/Workshop/Command Board, with the same Barlow Condensed typography hierarchy.
- **Outskirts atmosphere:** brighter blue-to-golden-hour sky, broad illustrated clouds, stronger warm sun, layered city/industrial haze and clearer warm/cool light separation.
- **Suburbs atmosphere:** brighter blue sky, cream cloud masses, warm late-afternoon sun, greener mature tree silhouettes and warmer residential roof planes.
- **Outskirts midground:** rebuilt commercial/salvage fringe with directional light planes, dark physical bays, glass, worn signs, utility depth, wrecks and grounded contact bands.
- **Suburbs midground:** rebuilt neighbourhood rhythm with varied house types, warm roof planes, tree/hedge massing, different garages, real material breakup and less repetition.
- **Roads:** both regions now use warmer shoulder light, layered asphalt value, repair history, cracks, stains, tyre/oil contact and region-appropriate markings.
- **Foreground framing:** both regions have stronger near-camera silhouettes, warm rim/reflection, deeper contact mass and region-specific debris while preserving the projectile corridor.
- **Mission landmarks:** every current Outskirts landmark and every current Suburbs landmark was relit/reworked into the same warm-key/cool-shadow material language while preserving tactical read zones.
- **Combat hero props:** roadblock, scrap gate, unstable power cell, Signal Relay and protected Salvage received the same material/light treatment, including destroyed/spent states where applicable.
- **Combatants / vehicles:** player/rival survivor art and compact/sedan/pickup/technical/rival cover art now share the same golden-hour rim/contact philosophy.
- **Presentation copy:** visible Battle prototype wording such as "greybox battle problem" / "ENCOUNTER PROOF" was removed from the live presentation.

### Final review sequence for the project owner

Review in this order so style drift is easy to spot:

1. **Hub** — establish the canonical settlement lighting/material baseline.
2. **Garage** — confirm hero-object weight, warm key light, dark UI field and vehicle contact.
3. **Workshop** — confirm the same signature works on a different hero object/material.
4. **Command Board** — confirm physical paper/wood presentation still feels like the same world/product.
5. **Roadblock Trial** — first Outskirts signature check.
6. **Broken Span** — verify large concrete landmark still uses the same rendering language.
7. **Depot Line** — verify salvage/warehouse materials and interactives feel consistent.
8. **Dead Air** — first Suburbs signature check and Relay readability.
9. **Loaded Up** — protected Salvage readability.
10. **Hot Cargo** — simultaneous Salvage / live cell / roadblock readability.
11. **Crossroads** — enemy/background separation on the elevated composition.

Acceptance is specifically:
- changing from Garage/Workshop to Battle no longer feels like changing games,
- Outskirts and Suburbs are distinct **locations**, not distinct renderers,
- Battle UI belongs to the same product family,
- player/rival vehicles feel grounded and lit by the same world,
- objectives remain more readable than scenery,
- no gameplay/collision geometry changed.

The remaining gate is local Godot Play at phone scale. Highways remains blocked until that review passes.


## Approved vehicle and character asset integration (2026-10-08)

- Garage now uses owner-approved transparent showroom and thumbnail raster art for the four current platform IDs. Existing purchase, active-platform, lock, level and module rules remain unchanged.
- Those same new showroom images replace the older active player vehicle SVG art in battle cover. Existing cover collision, damage overlays and module rules remain unchanged.
- The future utility truck, APC and battle tank pairs are stored as production art but are not added to the playable catalog before their rules and progression are authored.
- The approved mechanic and scout static cutouts are staged for character UI. Battle continues to use 180×240 SVGs, updated to the approved identities while preserving firing alignment and collision.
- Local Godot Play still must verify import, 720×1280 Garage fit/card legibility, selected module overlay position, and battle cover/character silhouette and launch alignment.
