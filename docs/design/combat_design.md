# Combat Design

## Combat goal
The battle should be understandable in seconds but reward repeated judgement. The fun comes from predicting a shot, watching the projectile travel, and seeing a consequential physical result.

## Turn loop
1. **Reveal/inspect** — show the relevant enemy position.
2. **Return to shooter** — camera presents the active combatant.
3. **Decision** — select weapon/tool if more than one is available.
4. **Aim** — set angle and power.
5. **Commit** — fire.
6. **Projectile flight** — projectile simulation, visible trail, and camera follow.
7. **Impact resolution** — classify direct hit, cover hit, environment hit, or miss; apply damage/force and immediate feedback.
8. **Settle** — hold the result long enough for hit reactions, destruction, and feedback to read.
9. **Status resolution** — deaths/incapacitation, later status effects, and victory check.
10. **Turn handoff**.

## Aiming
Primary mobile input:
- Touch/press in the aiming region.
- Pull **backward**, opposite the desired firing direction, like drawing a slingshot/catapult.
- Pull direction controls the launch angle.
- Pull distance controls power.
- Release commits the shot.
- While aiming, show both **power percentage** and **launch angle in degrees**.
- A virtual tension line behind the shooter and the short trajectory preview in front should make the inverse relationship visually obvious.

The implementation must support an accessibility alternative later: aim, lock, then explicit fire.

Trajectory assistance must not reveal the complete solution. The initial target is a short dotted preview near the shooter, sufficient to communicate direction without removing judgement.

## Information
The opponent does not need to remain visible while the player aims. Portrait UX instead uses:
- an initial enemy preview,
- a subtle relative-position strip,
- an off-screen enemy direction/distance indicator,
- an optional tap/hold inspect action.

## Impact feedback contract
Every resolved shot must communicate what happened without relying on the player inferring it from HP values:
- projectile flight has a readable streak/trail,
- direct crew hits produce a distinct impact burst, hit reaction, damage popup, and strong camera impulse,
- cover hits produce a material impact burst, visible staged damage, cover damage popup, and medium camera impulse,
- environment impacts produce dust and explicit miss feedback,
- off-world shots report a miss without manufacturing a fake impact,
- the camera briefly settles on the result before turn handoff.

Feedback is intentionally procedural during greybox development. Production VFX/audio come later.

## Damage model
Combat objects are separated conceptually into:
- **Crew** — vulnerable characters whose incapacitation can end the fight.
- **Combat platform** — vehicle/fortification providing structure, cover, and modules.
- **Modules / destructible zones** — predefined meaningful targets.
- **Environment** — selected props/supports/hazards that can react to impacts.

Do not implement fully arbitrary destruction. Use authored destructible zones and state changes.

The greybox wrecked-car cover uses three authored damage stages before becoming rubble. The purpose is to prove that repeated cover hits visibly change the firing problem before modular platform damage is introduced.

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
