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

The second Progression Shell batch now makes Salvage meaningful through the first real combat-platform choice:

- **Run-down Compact** remains the starting platform: 150 cover durability and a 240-wide cover profile.
- **Old Sedan / Estate** unlocks after clearing High Ground and costs **80 Salvage**.
- Buying a platform permanently adds it to owned platform IDs; owned platforms can be re-equipped without cost.
- The Sedan changes battle geometry to **230 cover durability / 300-wide cover**, providing stronger protection while occupying more of the player's shallow firing line.
- The equipped platform is shown in the mission brief and its live cover durability is visible in the battle HUD.
- Fort Knocks visibly changes when the Sedan is equipped: the vehicle silhouette and garage/workshop corner become more organised.
- **Pickup** is represented in data and the Garage as the next progression proof, but remains non-purchasable until its utility/module gameplay actually exists.

The 80-Salvage price is intentionally aligned with the first two Outskirts rewards: Roadblock Trial (35) + High Ground (50) = 85. This creates a natural first purchase decision before Scrap Gate without requiring replay farming.

The third Progression Shell batch now proves the Pickup as the first capability-changing platform:

- **Pickup** unlocks after clearing **Broken Span** and costs **130 Salvage**.
- Pickup base battle profile: **260 cover durability / 320-wide cover**.
- The Pickup has exactly **one utility-bed slot** in this proof.
- Two mutually exclusive utility modules are available in Workshop once the Pickup is owned and equipped:
  - **Spotter Rack** — 40 Salvage; turns the normal sparse arc into a visibly denser precision preview across the same on-screen curve, plus four highlighted continuation points beyond the normal horizon.
  - **Ballast Crates** — 40 Salvage; adds 80 cover durability.
- Owned modules can be swapped freely; only the equipped module affects battle.
- Pickup/module state is visible in Fort Knocks and in the battle mission brief.

The economy is intentionally staged:
- after buying the 80-Salvage Sedan, clearing Scrap Gate leaves 75 Salvage,
- Broken Span awards 65, bringing the player to 140,
- Pickup costs 130, leaving 10,
- Depot Line awards 75, bringing the player to 85,
- either first module costs 40 before the Outskirts Checkpoint.

This means the new choices are funded by campaign progress rather than replay farming.

The Outskirts campaign now contains six connected encounters:
1. Roadblock Trial — 35 Salvage.
2. High Ground — 50 Salvage.
3. Scrap Gate — 70 Salvage.
4. Broken Span — 65 Salvage.
5. Depot Line — 75 Salvage.
6. Outskirts Checkpoint — 100 Salvage.

The last three deliberately reuse proven combat pieces in new combinations rather than introducing another weapon or combat subsystem. Existing saves that already cleared Scrap Gate reconcile forward and unlock Broken Span automatically.

The fourth Progression Shell batch closes the remaining structural gaps without adding another combat system:

### Campaign field rack
All three proven projectiles remain owned, but campaign battles now carry:
- **Scrap Bolt** — permanent core round,
- **one specialist slot** — choose either Heavy Slug or Shock Capsule in Workshop.

This creates a deliberate pre-mission choice:
- Heavy Slug specialist = cover-breaking / force,
- Shock Capsule specialist = radial displacement / environment pressure.

There is no purchase cost for switching specialists. The constraint is field capacity, not another currency sink. Standalone Encounter Proof continues to expose all three weapons for development testing.

### Visible Fort Knocks campaign growth
Fort Knocks now changes from campaign completion as well as equipped platform:
- **0–1 cleared** — survival camp / holding together,
- **2–3 cleared** — organised storage begins; camp is taking shape,
- **4–5 cleared** — generator, permanent lighting, improved watch/gate; powered and organised,
- **6 cleared** — reinforced perimeter and command mast; Outskirts secured.

Platform/utility visuals layer on top of this campaign-state growth, so base progression is no longer represented only by vehicle selection.

The Progression Shell now contains every structural element required by the Milestone 2 build list. It should not be expanded further by default. The remaining gate is local playtest acceptance of the full six-route campaign, platform/module decisions, field-rack decision, persistence, and visible Fort Knocks growth.

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
