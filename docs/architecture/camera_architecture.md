# Camera Architecture

Portrait mode makes the camera part of gameplay architecture.

## Owner
A dedicated `CameraDirector` owns battle-camera state and transitions. Aim, projectile, AI, and HUD systems request camera behavior; they do not directly fight over `Camera2D`.

## Initial states
- **ENEMY_PREVIEW** — frames opponent and important nearby cover.
- **TRAVEL_TO_ACTIVE** — moves to the active combatant.
- **AIM** — stable framing that preserves touch/trajectory readability.
- **INSPECT_ENEMY** — player-requested enemy view that persists until explicit return.
- **PROJECTILE_FOLLOW** — follows the fired projectile with bounded smoothing.
- **IMPACT** — frames impact, target reaction, and limited camera impulse.
- **SETTLE** — holds enough context to understand destruction/status changes.

An overview state may be added only if encounters require it.

## State rules
- Camera state is explicit; avoid scattered tweens from unrelated scripts.
- Transitions must be interruptible where UX requires it.
- Returning from inspect is player-triggered and restores the previous aim context.
- Repetitive preview/travel durations should shorten after the first reveal of an encounter.
- Camera shake/impulse is presentation only and must never obscure essential targeting information.
- Projectile follow should look ahead enough to reveal impact rather than centering blindly on the projectile.
- Impact impulse is short, directional, and scaled by result: strongest for crew/destruction, lighter for cover, subtle for environment misses.
- After impact, the camera holds through an explicit settle phase before the next turn begins.

## World bounds
The camera must respect authored battlefield bounds but may use controlled overscan/lead framing for projectiles.

The current battle presentation uses `Camera2D.zoom = (1.35, 1.35)` and a road-level vertical center of 850 world units. Subject focus moves the vertical center upward for raised encounters and projectile travel while keeping the scene within its vertical framing range. Horizontal clamping derives from the live viewport width and zoom so portrait safe framing still reaches both world edges. Shooter and enemy focus points lean toward their nearby cover to keep the enlarged combat objects readable together.

## Testing
Camera tests should include:
- short and very long shots,
- high arc shots,
- targets above/below the player,
- screen-edge impacts,
- fast projectiles,
- direct crew hits,
- cover destruction,
- environment misses,
- interrupted inspection,
- unusual phone aspect ratios.


## Roadblock Trial V2 camera pilot (October 2026)

The Roadblock Trial V2 branch introduces `CameraDirector.set_zoom_level()` as
an interruptible presentation tween owned by the camera, with a common x/y
zoom to preserve 2D art proportions. The first mission reveal now sweeps the
continuous world-space roadside positions through the central choke to the
rival instead of pretending both fighters can be made legible at once in a
portrait wide shot. Subsequent aim/inspect/enemy turns retain conventional
close framing; projectiles still own follow and impact movement.

This is an opt-in Roadblock-only composition pilot, not a global camera
retune. All nonpilot encounters stay at the existing 1.35 reference zoom.
See `docs/design/roadblock_battlefield_v2.md` for local Play criteria.
