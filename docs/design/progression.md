# Progression Foundation

## Principle
Progression should increase capability, options, identity, and visual presence. Avoid turning the game into linear stat inflation.

The player should feel the transition from surviving behind scrap to commanding a serious fortified settlement and increasingly capable combat platforms.

## Primary resource
**Salvage** is the only general progression currency in the foundation design.

Specific campaign rewards may later unlock unique blueprints/components, but do not introduce multiple generic currencies without a proven need.

## Combat-platform progression
Working visual/mechanical ladder:

1. **Run-down compact car**
   - One crew position.
   - Low durability and mass.
   - No module slot.
   - Makeshift survival rather than a war machine.

2. **Old sedan / estate**
   - Wider cover profile.
   - Better structural durability.
   - Still civilian and vulnerable.

3. **Pickup truck**
   - Introduces a utility/module position in the bed.
   - Strong visual transition from hiding to preparing for combat.

4. **Improvised technical**
   - Reinforced pickup/utility vehicle.
   - Adds a weapon or support mount and second meaningful position.
   - Welded scrap armour and field repairs define the look.

5. **Armoured utility truck**
   - Multiple armour zones and module choices.
   - Strong resistance but larger target and higher repair cost.

6. **Recovered APC-class platform**
   - Heavy mass and protection.
   - Multiple crew/module positions.
   - Less vulnerable to simple knockback strategies.

7. **Restored tank-class platform**
   - Late-game aspiration.
   - Integrated heavy hardware.
   - Must still have weaknesses: size, vulnerable subsystems, limited firing geometry, or expensive maintenance.

These are progression families, not licensed or exact real-world vehicle models.

## Meaningful modules
Working module categories:
- armour plate,
- repair equipment,
- ammo storage,
- spotter position,
- protective screen,
- support mount,
- weapon mount,
- salvage rack,
- reinforced suspension/ballast.

Each module must create a decision or trade-off rather than only add a larger number.

## Crew direction
Crew should remain ability-led and readable rather than becoming a spreadsheet-heavy RPG.

Working role concepts:
- **Mechanic** — limited repair capability.
- **Spotter** — improved trajectory information.
- **Scavenger** — increased Salvage return.
- **Heavy** — greater resistance to displacement/knockback.
- **Medic** — recovery/revive utility.

These role names and exact effects are provisional until implemented and playtested. The durable rule is that crew composition should create a small number of understandable tactical/progression choices.

## Fort Knocks hub progression
The home hub should change visibly rather than communicate growth only with levels.

Working hub functions:
- **Garage** — combat platforms.
- **Workshop** — projectiles/weapons/tools.
- **Crew Quarters** — survivors.
- **Command Board** — campaign selection.
- **Scrapyard** — Salvage/progression.
- **Radio Tower** — reserved for later systems if a real need emerges.

Visual progression:
- early: tarp, wrecked car, campfire, corrugated metal;
- mid: workshop, generators, gates, organised storage, pickups, watchtower;
- late: reinforced perimeter, communications, heavy garage capability, restored military hardware.

Avoid making a generic numeric “Base Level” the primary expression of hub growth.

## Campaign progression
Working region escalation:
1. Outskirts.
2. Suburbs.
3. Highways.
4. Industrial zone.
5. Badlands.
6. Military perimeter.
7. Inner city / secure zones.

These names/order are provisional. The durable design goal is escalation from desperate scavenging and civilian cover toward organised factions, heavy protection, complex environments, and recovered old-world technology.

## Current Progression Shell foundation

The first implementation batch now establishes the application loop around the proven combat.

Implemented foundation:
- Press Play opens an early greybox **Fort Knocks hub**, not the battle scene.
- The hub presents current Salvage, Outskirts completion, active platform, Command Board, Garage, and Workshop.
- **Command Board** reads campaign state and launches mission definitions.
- The three accepted Encounter Proof missions currently seed the first campaign path:
  1. Roadblock Trial — first-clear reward: **35 Salvage**.
  2. High Ground — first-clear reward: **50 Salvage**.
  3. Scrap Gate — first-clear reward: **70 Salvage**.
- Clearing a route once unlocks the next route.
- Cleared routes remain replayable but do not grant repeat Salvage in this foundation.
- Defeat grants no Salvage and no unlock.
- Battle reports a structured result to `App`; battle does not mutate progression directly.
- Garage currently exposes the active **run-down compact** and previews the sedan/estate and pickup path.
- Workshop currently exposes the three proven projectile roles without an upgrade economy.
- Versioned local save state persists campaign completion/unlocks, Salvage, and current platform ID.

This is deliberately a **foundation**, not the completed Milestone 2 economy. The next progression batch should make Salvage purchase a meaningful platform capability/choice rather than adding more menus.

## Small progression-shell target
When the combat and encounter gates are passed, the first progression implementation should remain small:
- Fort Knocks home/hub shell,
- Command Board,
- roughly 4–6 connected missions plus a checkpoint/boss-style encounter,
- Salvage rewards,
- Garage,
- Workshop,
- first three platform families:
  - run-down compact,
  - old sedan/estate,
  - pickup,
- explicit versioned save data.

Do not author a large campaign or seven complete platform tiers before this loop is proven.

## Progression gate
Do not build full progression systems until the combat prototype proves aiming, impact, destruction, camera flow, projectile roles, and encounter variety are fun.

See `implementation_roadmap.md` for sequencing.
