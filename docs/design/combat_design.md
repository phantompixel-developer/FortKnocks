# Combat Design

## Combat goal
The battle should be understandable in seconds but reward repeated judgement. The fun comes from predicting a shot, watching the projectile travel, and seeing a consequential physical result.

## Turn loop
1. **Reveal/inspect** — show the relevant enemy position.
2. **Return to shooter** — camera presents the active combatant.
3. **Decision** — select weapon/tool if more than one is available.
4. **Aim** — set angle and power.
5. **Commit** — fire.
6. **Projectile flight** — projectile simulation, visible trail, optional authored bounce, and camera follow.
7. **Impact resolution** — classify direct hit, cover hit, environment hit, hazard hit, or miss; apply damage/force and immediate feedback.
8. **Settle** — hold the result long enough for hit reactions, destruction, chained hazards, and feedback to read.
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

## Previous-shot memory
The player's next aiming turn may show the previous shot as a compact learning aid:
- previous power percentage,
- previous launch angle,
- coarse result label such as DIRECT, COVER, ROADBLOCK, GROUND, or WIDE,
- a small world-space marker at the previous final impact point when that point exists in the arena.

The marker is hidden during projectile flight and enemy turns, then restored for the next player aiming phase. This supports deliberate correction without providing a solved trajectory or exact automatic targeting.

## Initial tactical weapon set
The prototype proves three distinct shot roles. These are not a final inventory.

### Scrap Bolt
- baseline direct damage and knockback,
- standard trajectory,
- **two controlled road bounces** before later ground contact resolves the shot,
- forgiving option for banked shots under or around cover.

The first rebound is strongest. The second retains enough energy to create a meaningful follow-up bank rather than a cosmetic hop, but is weaker than the first. Scrap Bolt bounces from authored ground surfaces only; it does not bounce from characters, cover, or arbitrary props.

### Heavy Slug
- slightly faster travel,
- lower direct crew damage than Scrap Bolt,
- much higher cover damage,
- stronger knockback,
- no bounce.

Its purpose is to make destroying protection a conscious tactical choice.

### Shock Capsule
- low direct damage,
- slower travel,
- radial pressure damage and force around impact,
- can trigger nearby interactive hazards through its pulse,
- no bounce.

Its purpose is displacement, clustered damage, and environment interaction rather than precision damage.

Weapon values live in `WeaponDefinition` resources so future projectiles can be added without branching the controller for every type.

## Information
The opponent does not need to remain visible while the player aims. Portrait UX instead uses:
- an initial enemy preview,
- an off-screen enemy direction/distance indicator,
- a fast Inspect Enemy action,
- a temporary target card during inspection showing enemy health, cover state, and interactive hazard state.

The target card is informational only; it does not pause or alter combat rules, reveal a solved trajectory, or remain on screen during aiming.

## Impact feedback contract
Every resolved shot must communicate what happened without relying on the player inferring it from HP values:
- projectile flight has a readable streak/trail,
- direct crew hits produce a distinct impact burst, hit reaction, damage popup, and strong camera impulse,
- cover hits produce a material impact burst, visible staged damage, cover damage popup, and medium camera impulse,
- environment impacts produce dust and explicit miss feedback,
- off-world shots report a miss without manufacturing a fake radial effect,
- each Scrap Bolt road rebound receives a numbered ricochet cue without ending the turn,
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

## Arena geometry
The greybox encounter now includes a tall central concrete roadblock. It exists to make trajectory choice matter:
- very low shots can collide with the obstruction,
- high arcs can clear it,
- Scrap Bolt can use the road before/after the obstruction for bank-shot experiments,
- Heavy Slug remains useful when the opponent's immediate cover is the real problem,
- Shock Capsule can reward landing near clustered targets rather than threading a direct line.

This is intentionally authored geometry, not procedural terrain.

## Environmental interaction
The current greybox arena contains one unstable salvaged power cell near the enemy position. Direct impact or a nearby Shock Capsule pulse can discharge it.

The discharge:
- creates a larger radial visual/camera response,
- applies radial damage and impulse to nearby crew and cover,
- can change the firing problem without requiring a dedicated shot,
- remains an authored gameplay interaction rather than a general-purpose destruction simulation.

This is the first proof that a Fort Knocks arena can contain tactical targets beyond the opposing survivor.

## Encounter-proof authoring

The combat prototype now supports multiple greybox encounters through `MissionDefinition` resources. Encounter data may change:
- player and enemy positions,
- cover positions,
- reusable raised-platform rectangles,
- central roadblock presence/position,
- unstable power-cell presence/position,
- collapsible scrap-gate presence/position,
- greybox backdrop variant,
- objective label,
- authored tactical-feature preview position/text used before the enemy reveal.

At the start of a proof encounter, the camera may briefly frame the mission-defined tactical feature before the enemy preview. This is presentation metadata, not a mission-specific combat rule.

The current proof set is:
- **Roadblock Trial** — baseline obstruction, cover, road bounces, and unstable power cell.
- **High Ground** — enemy and cover on a raised service deck, forcing elevation-aware shots.
- **Scrap Gate** — raised player firing position plus a destructible vertical gate that can be knocked down to change the firing line.

These are greybox test encounters, not final campaign missions or world canon.

### Collapsible scrap gate
The scrap gate is an authored environment target rather than general destruction simulation.
- It blocks trajectories while standing.
- It has a small explicit durability pool.
- Weapons use their existing cover-damage values against it, so Heavy Slug gains another tactical use without adding a new projectile.
- When depleted, it falls into a low horizontal obstruction instead of disappearing, changing rather than deleting the geometry.
- Shock Capsule pressure can also contribute damage if the gate lies inside the pulse radius.

The encounter-proof rule is to reuse the same combat system across different geometry. Do not solve each mission by adding mission-specific weapons or controller exceptions.

## Enemy AI
Enemy AI remains intentionally lightweight but is no longer a stateless calculator.

It now:
- chooses Heavy Slug frequently while player cover survives,
- may use Shock Capsule once the player is exposed,
- otherwise uses Scrap Bolt,
- stores a small launch-speed correction per weapon after genuine short/long ground misses,
- nudges the next shot in the opposite direction of the previous error,
- retains small random variance so it does not become deterministic.

This is an aiming opponent, not a strategic campaign AI.

## Projectile outcomes
A projectile definition can combine:
- direct damage,
- cover damage,
- impulse/knockback,
- authored ground bounces,
- radial pulse radius,
- radial damage/force,
- later: penetration, status effects, and special impact behavior.

New weapons should change decisions, not only increase damage numbers.

## Victory
Initial slice: incapacitate the enemy combatant.

Later missions may introduce objective variants such as destroying a specified module, surviving a turn count, protecting cargo, or defeating a boss. These are extensions, not slice requirements.

## Physics policy
Use deterministic-enough, controlled 2D physics and clamp extreme outcomes. Spectacle must not compromise readability. Only objects designed to react should participate in costly dynamic simulation.

## Prototype scope
The current three projectile types and one interactive hazard exist to prove tactical variety. Do not expand into a large inventory until these options produce meaningfully different player choices.
