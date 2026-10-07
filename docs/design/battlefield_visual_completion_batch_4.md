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
