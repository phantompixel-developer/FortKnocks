# Combat Design

## Combat goal
The battle should be understandable in seconds but reward repeated judgement. The fun comes from predicting a shot, watching the projectile travel, and seeing a consequential physical result.

## Turn loop
1. **Reveal/inspect** — show the relevant enemy position.
2. **Return to shooter** — camera presents the active combatant.
3. **Decision** — select weapon/tool if more than one is available.
4. **Aim** — set angle and power.
5. **Commit** — fire.
6. **Flight** — projectile simulation and camera follow.
7. **Impact** — collision, damage, force, cover/module reaction, effects.
8. **Settle** — allow essential physics and destruction to resolve.
9. **Status resolution** — deaths/incapacitation, fire/status effects, victory check.
10. **Turn handoff**.

## Aiming
Primary mobile input:
- Touch/press in the aiming region.
- Drag direction controls launch angle.
- Drag distance controls power.
- Release commits the shot.

The implementation must support an accessibility alternative later: aim, lock, then explicit fire.

Trajectory assistance must not reveal the complete solution. The initial target is a short dotted preview near the shooter, sufficient to communicate direction without removing judgement.

## Information
The opponent does not need to remain visible while the player aims. Portrait UX instead uses:
- an initial enemy preview,
- a subtle relative-position strip,
- an off-screen enemy direction/distance indicator,
- an optional tap/hold inspect action.

## Damage model
Combat objects are separated conceptually into:
- **Crew** — vulnerable characters whose incapacitation can end the fight.
- **Combat platform** — vehicle/fortification providing structure, cover, and modules.
- **Modules / destructible zones** — predefined meaningful targets.
- **Environment** — selected props/supports/hazards that can react to impacts.

Do not implement fully arbitrary destruction. Use authored destructible zones and state changes.

## Projectile outcomes
A projectile definition can combine:
- direct damage,
- blast damage,
- impulse/knockback,
- penetration,
- bounce count,
- status effect,
- special impact behavior.

New weapons should change decisions, not only increase damage numbers.

## Victory
Initial slice: incapacitate the enemy combatant.

Later missions may introduce objective variants such as destroying a specified module, surviving a turn count, protecting cargo, or defeating a boss. These are extensions, not slice requirements.

## Physics policy
Use deterministic-enough, controlled 2D physics and clamp extreme outcomes. Spectacle must not compromise readability. Only objects designed to react should participate in costly dynamic simulation.

## Initial weapon
The prototype uses one neutral, original test projectile. Its purpose is to tune trajectory, force, impact feedback, and timing before a weapon roster exists.
