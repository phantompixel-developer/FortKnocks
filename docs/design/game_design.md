# Fort Knocks — Game Design Foundation

## High concept
Fort Knocks is a portrait-first, single-player, turn-based physics battler set after the collapse of modern civilisation. Rival survivor crews fight over salvage, equipment, territory, and old-world machinery from improvised cover, civilian vehicles, fortified trucks, and eventually restored heavy hardware.

The player begins with almost nothing. The home settlement, jokingly called **Fort Knocks**, visibly grows as salvage returns from the campaign until the name stops being a joke.

## Name and identity
Early Fort Knocks is deliberately unimpressive: tarp, corrugated metal, scrap, old cars, and improvised barricades. The name starts as survivor humour and becomes increasingly literal as the settlement grows into a defended stronghold.

The name also supports the physical combat fantasy of knocking opponents out of cover and breaking defensive positions.

The commercial name is a working title until appropriate legal/storefront clearance is complete.

## Player fantasy
Start as a vulnerable scavenger with improvised protection and become the leader of a hardened settlement equipped with increasingly formidable combat platforms, experienced crew, and recovered old-world technology.

## Core loop
1. Select a campaign encounter.
2. Inspect the enemy position and meaningful battlefield features.
3. Enter battle.
4. Choose a projectile/tool.
5. Pull back to set angle and power.
6. Release to fire.
7. Follow the projectile and resolve impact/physics/destruction.
8. Survive the enemy turn.
9. Win the encounter and recover Salvage.
10. Spend Salvage at Fort Knocks to unlock meaningful new options.
11. Push further into contested territory.

## Core pillars
- **Precision** — shots reward judgement of angle, power, distance, and later environmental forces.
- **Physics** — impacts create readable trajectories, knockback, bounce, debris, and displacement.
- **Destruction** — cover is part of the problem, not scenery.
- **Position** — height, exposed angles, obstructions, hard cover, and vulnerable modules matter.
- **Improvisation** — projectiles and environmental interactions provide multiple solutions.
- **Progression** — the player's fighting position evolves visibly from scrap to serious hardware.
- **Spectacle** — projectile flight and impacts should be satisfying enough to carry repeated play.

## Product constraints
- Portrait orientation is primary.
- Android and iOS are equal targets.
- 2D gameplay; layered 2D/2.5D presentation where useful.
- Single-player campaign first.
- Match target: roughly 2–4 minutes for normal encounters.
- One primary progression currency initially: **Salvage**.
- No multiplayer, accounts, clans, battle pass, backend, or live-ops systems in the initial product.

## World direction
The setting is a dry post-collapse world of abandoned suburbs, highways, industrial districts, badlands, checkpoints, ruined cities, and former military sites. The cause of the collapse is intentionally undefined during early development.

Zombies are not a foundation requirement. Human factions, scarcity, improvised engineering, and old-world machinery are enough to sustain the game.

The tone is stylised and gritty rather than photorealistic grimdark.

## Campaign escalation
A working progression arc:
1. **Outskirts** — improvised equipment, wrecked cars, basic aiming.
2. **Suburbs** — destructible cover and vertical obstacles.
3. **Highways** — stronger vehicles and vehicle-themed battlefields.
4. **Industrial zone** — machinery and hazardous environmental targets.
5. **Badlands** — wind, distance, elevation, exposed positions.
6. **Military perimeter** — disciplined enemies and heavy armour.
7. **Inner city / secure zones** — complex encounters and restored high-end hardware.

These names/order are working scaffolding, not final world canon.

## Current combat-prototype baseline
The original one-projectile vertical slice has been surpassed. Current `main` now proves a broader combat baseline:

- 720×1280 portrait battle presentation.
- Wide authored battlefield and camera travel.
- One survivor per side.
- Destructible vehicle cover with staged damage.
- Pull-back aiming.
- Power percentage and angle in degrees.
- Partial trajectory preview.
- Previous-shot power/angle/result memory and impact marker.
- Enemy preview / Inspect Enemy.
- Approximate off-screen enemy direction and distance.
- Three tactical projectile roles:
  - Scrap Bolt — balanced, two road rebounds.
  - Heavy Slug — cover breaker.
  - Shock Capsule — radial pressure/displacement.
- Central roadblock.
- Interactive unstable power cell.
- Projectile-follow camera and impact/settle presentation.
- Enemy projectile choice and imperfect correction behavior.
- Win, lose, restart.

Exact rules live in `combat_design.md` and `portrait_ux.md`.

## Current milestone
The project remains in **Combat Prototype V1 / encounter-proof development**. Campaign, economy, save progression, and production art should follow the milestone gates in `implementation_roadmap.md`, not be added simply because they are part of the eventual product.
