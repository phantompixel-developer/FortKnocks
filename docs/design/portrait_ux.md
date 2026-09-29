# Portrait UX

## Baseline
Logical game viewport: **720×1280 portrait**.

The battlefield may span multiple screen widths. The camera, rather than a forced split screen, is responsible for presenting spatial information.

## Camera-assisted turn presentation
Player-turn baseline:
1. Frame the enemy position.
2. Briefly communicate enemy health/cover and relevant hazards.
3. Travel across the battlefield.
4. Settle on the player combatant.
5. Enable aiming input.

Do not repeat a long cinematic pan every turn if it becomes tedious. The system must support shorter transitions once the player understands the battlefield.

## During aiming
Visible information should include only what supports the shot:
- active weapon,
- power,
- short trajectory preview,
- environmental force indicator when relevant,
- enemy direction and approximate distance when off screen,
- turn/status information.

Avoid covering the central play space with controls.

## Enemy inspection
Provide a fast player-controlled **Inspect Enemy** action during the player's aiming phase. It pans to the opponent, briefly holds the enemy/cover position, then returns to the shooter. The player's selected power, angle, and trajectory state must remain intact; inspection is information gathering, not an aim reset.

## Projectile flight
After firing:
1. camera transitions from shooter to projectile,
2. follows the projectile without excessive jitter,
3. begins revealing the destination before impact,
4. frames impact and reaction,
5. settles long enough for the player to understand the outcome.

## Safe areas
All permanent HUD controls must respect iOS/Android safe areas and avoid assumptions about notches, rounded corners, navigation bars, or home indicators.

## Touch policy
- Primary controls must be comfortable one-handed where possible.
- Tiny precision targets are prohibited.
- Hover interactions cannot be required.
- Desktop mouse input may emulate touch for development but must not define the UX.
- Essential controls should remain reachable without covering the aiming subject.

## Responsive rule
World framing may expand with aspect ratio. HUD remains anchored to safe regions. Do not scale the entire interface blindly from a single reference phone.
