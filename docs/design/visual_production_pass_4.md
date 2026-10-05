# Fort Knocks — Visual Production Pass 4: Combat Hero Completion

**Branch:** `feat/visual-production-batch-2`  
**Primary authority:** `docs/design/visual_reference.md`  
**Scope:** current combat hero objects only

## Objective

Remove the remaining obvious prototype-quality visual mismatch from battle after the Outskirts/Suburbs environment passes.

Every object the player actively aims at, protects, breaks, inspects or uses tactically should now share the same authored stylised salvage-war finish.

This pass is presentation-only. It must not change:
- collision,
- HP,
- projectile launch origins,
- objective rules,
- blast radius/force,
- barrier collapse physics,
- platform balance,
- enemy AI.

## Reference lock

The approved style remains:
- believable ruined modern civilian world,
- improvised salvage construction,
- strong readable silhouettes,
- warm cinematic light,
- muted steel/green-grey materials,
- rust/hazard accents,
- teal only for actual recovered/live technology,
- dark foreground depth without obscuring gameplay.

The rival side must feel like another survivor crew from the same world, not a new genre/faction aesthetic.

## Implemented combat hero assets

### Rival survivor
- authored rival survivor production master,
- distinct olive/oxidised/rust identity rather than Fort Knocks hazard-yellow identity,
- launcher authored around the existing enemy launch origin,
- same collision and knockback rules,
- health strip uses rival rust accent,
- no new faction lore introduced.

### Rival cover
- authored neutral rival civilian cover vehicle,
- no Fort Knocks knock-mark motif,
- player-facing orientation mirrored in presentation,
- existing enemy cover collision/HP retained,
- authored damage overlays remain state-driven.

### Shared tactical interactives
- production concrete roadblock,
- production collapsible scrap gate,
- production unstable power cell,
- authored spent power-cell state,
- production Signal Relay + destroyed state,
- production protected Salvage Load + destroyed state.

### Damage/state rule
Where authored intact/destroyed states exist, state changes are presentation-only and follow existing gameplay state.
Dynamic procedural damage overlays remain acceptable where they communicate state clearly and do not change collision.

## Acceptance checks

- player and rival survivors remain visually distinct at phone scale,
- both launcher muzzles visually agree with existing projectile origins,
- rival cover does not show Fort Knocks markings,
- roadblock remains visually readable as inert hard cover,
- scrap gate remains readable before and after collapse,
- power cell is the strongest cold-tech object in relevant encounters,
- Signal Relay remains distinct from ordinary background infrastructure,
- protected Salvage remains obvious in Loaded Up / Hot Cargo,
- destroyed/spent states remain visually coherent,
- no raw SVG is directly preloaded as a Resource,
- no gameplay tuning changed.

## Next step after local acceptance

Perform a whole-current-game visual audit against the locked reference before expanding to Highways.

That audit should rank remaining visible gaps by impact and fix only current-content weaknesses before building another region.
