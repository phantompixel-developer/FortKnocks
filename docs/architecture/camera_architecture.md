# Camera Architecture

Portrait mode makes the camera part of gameplay architecture.

## Owner
A dedicated `CameraDirector` owns battle-camera state and transitions. Aim, projectile, AI, and HUD systems request camera behavior; they do not directly fight over `Camera2D`.

## Initial states
- **ENEMY_PREVIEW** — frames opponent and important nearby cover.
- **TRAVEL_TO_ACTIVE** — moves to the active combatant.
- **AIM** — stable framing that preserves touch/trajectory readability.
- **INSPECT_ENEMY** — temporary player-requested enemy view.
- **PROJECTILE_FOLLOW** — follows the fired projectile with bounded smoothing.
- **IMPACT** — frames impact, target reaction, and limited camera impulse.
- **SETTLE** — holds enough context to understand destruction/status changes.

An overview state may be added only if encounters require it.

## State rules
- Camera state is explicit; avoid scattered tweens from unrelated scripts.
- Transitions must be interruptible where UX requires it.
- Returning from inspect restores the previous aim context.
- Repetitive preview/travel durations should shorten after the first reveal of an encounter.
- Camera shake/impulse is presentation only and must never obscure essential targeting information.
- Projectile follow should look ahead enough to reveal impact rather than centering blindly on the projectile.

## World bounds
The camera must respect authored battlefield bounds but may use controlled overscan/lead framing for projectiles.

## Testing
Camera tests should include:
- short and very long shots,
- high arc shots,
- targets above/below the player,
- screen-edge impacts,
- fast projectiles,
- interrupted inspection,
- unusual phone aspect ratios.
