# Roadblock Trial — World-Anchored Diorama Pilot

**Branch:** `visual/battlefield-diorama-pilot`  
**Parent:** `visual/battlefield-completion-batch-4` at `ed9a492faa9fd9257e650f87007da1761c2d5077`  
**Status:** implemented in code; **not visually accepted until local Godot Play review**.

## Decision / scope

The current mission-specific raster panorama plus separate live cutouts does not provide enough world-space contact or coherent depth. Test an authored **2.5D scene composition** before changing the art style, engine, camera mechanics, combat rules, or any other mission.

This is an isolated experiment for **Roadblock Trial only**. All other Outskirts and Suburbs missions retain the exact Batch 4 rendering path. Keep this branch separate until the pilot is approved; do not merge it directly into `main`.

## Implementation

- `game/battle/roadblock_diorama_back.gd` — a new world-anchored background renderer under collision and live actors. Reuses the original painting only for far-upper scenery, then draws distinct midground and authored checkpoint landmark planes. The actual road and its contact line are world anchored, with flyover cast-shadows, curb/shoulder transitions, wear and material seams.
- `game/battle/roadblock_diorama_near.gd` — localized near-ground occlusion in front of the actors, with foot/wheel contact strips following actual character/vehicle positions instead of replaying a wide semi-transparent panorama.
- `game/battle/battle.tscn` — both pilot layers are new, initially hidden World children. They sandwich the pre-existing interactive nodes. This does **not** add a collider or alter child ownership for gameplay.
- `game/battle/battle_controller.gd` — enables both pilot layers only for `roadblock_trial`, hides the legacy panorama/near pass for that mission, and restores the legacy path automatically for every other mission.

The switch is exposed on the root Battle node as `enable_roadblock_diorama_pilot` (default `true`). Uncheck it in the Battle scene Inspector and press Play to see the previous Batch 4 composition with **exactly the same** mission positions and gameplay. Recheck it for the pilot. No in-game debug menus are required.

## Visual production intent

The production test should validate the *construction principle* first:

1. Far scenery has gentle parallax while fixed structures remain tied to the road and tactical obstacles.
2. Ground and body contact are registered in a shared coordinate system; the background no longer contains the full playable road as a separate moving painting.
3. Foreground physically passes in front of the low boot/wheel surfaces, but never blocks an aiming gesture, projectile, target, or impact read.
4. Player and vehicle art remains the **approved** current artwork for the A/B comparison, not a replacement design.
5. Light/shadow direction and material finish must feel coherent across scenery, combatants and interactives.

**Art limitation:** this pass reuses existing raster sky/panorama and SVG checkpoint/road artwork. Those may still differ in rendering finish from the Garage showroom PNGs. If the architecture solves positional depth but the image style still feels like a green-screen composite, the next action is to author properly split painterly road/midground/foreground and combat-specific vehicle cutouts using the approved visual signature—not revert to a full flat backdrop. Do not interpret this code pilot as final production artwork.

## Strict non-changes

- No modifications to `.tres` mission definitions, `platform_rects`, mission progression, camera director or shot-follow behavior.
- No changes to ground, player, enemy, cover or interactives' physics positions, collision shapes, health, damage, bounce logic, projectile trajectory or weapon tuning.
- No changes to the approved Garage, Workshop, Hub, Command Board, HUD or approved player/rival PNG artwork.
- No modifications to other mission backdrops.
- Everything new here is non-colliding drawing code.

## Local Godot acceptance

Godot is not available via the repository connector; no Play-mode claim is made.

1. Pull/checkout `visual/battlefield-diorama-pilot` and run the **main project** normally in Godot.
2. Deploy **Roadblock Trial**. Observe scene on a 720×1280 portrait viewport or an actual phone. Check feet and wheels vs ground line, and verify roadblock/power cell are not visually swallowed by scenery.
3. Aim low and high, fire at cover, direct enemy, roadblock and power cell. Inspect the enemy; verify world-space alignment persists during pan, projectile-follow, impact and knockback.
4. Test the top/bottom of camera framing and extreme phone aspect ratios. Verify no exposed blank strips, source-rect artifacts, z-order pops, contact strips across sprite torsos, or excessive background smear.
5. Without changing game logic, uncheck `enable_roadblock_diorama_pilot` on the root Battle scene node. Re-run Roadblock Trial and compare screenshot/video pairs at **the same aim/camera state**. Re-enable the flag after comparing.
6. Deploy **High Ground** and **Suburbs Dead Air** to prove their Batch 4 presentation and mechanics remain unchanged.
7. Check for missing assets, GDScript parse/type errors, rendering warnings and mobile frame-time regressions.

### Pass/fail

- **Pass:** combatants, cover and interactive objects look physically planted and spatially related to the road and checkpoint, without sacrificing portrait aiming clarity. Only then authorize an art-quality pass and replication of the composed-scene system to remaining missions.
- **Fail:** no material improvement in in-world placement, clashes between SVG and painterly art dominate, contact masks hide gameplay, or camera motion exposes seams. Retain Batch 4 as fallback; iterate the Roadblock-only pilot or revisit the art direction **before** building Highways.

Do not merge this experimental branch or start Highways merely because the files import cleanly.
