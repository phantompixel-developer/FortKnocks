# Fort Knocks — Game Design Foundation

## High concept
Fort Knocks is a portrait-first, single-player, turn-based physics battler set after the collapse of modern civilisation. Rival survivor crews fight over salvage, fuel, equipment, and territory from improvised cover, civilian vehicles, fortified trucks, and eventually restored military hardware.

The player begins with almost nothing. The home settlement, jokingly called **Fort Knocks**, visibly grows as salvage returns from the campaign until the name stops being a joke.

## Player fantasy
Start as a vulnerable scavenger with improvised cover and become the leader of a hardened settlement equipped with increasingly formidable combat platforms.

## Core loop
1. Select a campaign encounter.
2. Inspect the enemy position.
3. Enter battle.
4. Choose a weapon/tool.
5. Aim and set power.
6. Fire.
7. Follow the projectile and resolve impact/physics/destruction.
8. Survive the enemy turn.
9. Win the encounter and recover salvage.
10. Spend salvage at Fort Knocks to unlock meaningful new options.
11. Push further into contested territory.

## Core pillars
- **Precision** — shots reward judgement of angle, power, distance, and environmental forces.
- **Physics** — impacts create knockback, debris, displacement, and readable cause/effect.
- **Destruction** — cover is part of the problem, not scenery.
- **Position** — height, exposed angles, hard cover, and vulnerable modules matter.
- **Improvisation** — weapons and environmental interactions provide multiple solutions.
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

## Campaign escalation
A working progression arc:
1. **Outskirts** — improvised weapons, wrecked cars, basic aiming.
2. **Suburbs** — destructible cover and vertical obstacles.
3. **Highways** — stronger vehicles, moving/vehicle-themed battlefields.
4. **Industrial zone** — machinery and hazardous environmental targets.
5. **Badlands** — wind, distance, elevation, exposed positions.
6. **Military perimeter** — disciplined enemies and heavy armour.
7. **Inner city / secure zones** — complex encounters and restored high-end hardware.

Names are placeholders until the world bible is created.

## First vertical slice
The first playable slice contains only:
- 720×1280 portrait presentation.
- One wide ruined-road battlefield.
- One survivor per side.
- A rusty civilian car as player cover.
- A wreck/vehicle as enemy cover.
- Enemy-position preview.
- Camera travel back to the player.
- Touch-friendly angle/power aiming.
- One projectile.
- Projectile-follow camera.
- Destructible cover.
- Alternating player/enemy turns.
- Primitive enemy AI.
- Win, lose, restart.

No campaign map, workshop, economy, unlock tree, production art, multiplayer, or backend belongs in this slice.
