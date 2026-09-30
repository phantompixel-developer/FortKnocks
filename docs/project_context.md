# Fort Knocks — Canonical Project Context

Last consolidated: 2026-09-30.

This file is the compact durable context future AI sessions should read before reconstructing the project from chat history.

## Identity

**Fort Knocks** is a portrait-first, single-player, turn-based 2D physics artillery game for Android and iOS.

Pitch:

> Rival survivor crews fight over salvage, equipment, territory, and old-world machinery from improvised roadside fortifications, wrecked civilian vehicles, increasingly capable combat platforms, and eventually restored heavy hardware.

The player starts vulnerable. Their home settlement is jokingly called **Fort Knocks** because it initially looks like a poor collection of scrap, corrugated metal, tarps, and wrecked vehicles. Over the campaign the settlement becomes organised, fortified, and genuinely difficult to break into.

The title also supports the physical combat fantasy of knocking enemies out of cover and breaking defensive positions. It is a working commercial title, not assumed legally cleared.

## Non-negotiable product direction

These are locked unless the user explicitly changes them:

- Portrait-first mobile UX.
- Android and iOS are equal targets.
- Godot 4.7.x, GDScript.
- 2D gameplay physics and collision.
- 2.5D is presentation-only unless a concrete problem proves 3D gameplay necessary.
- Single-player campaign first.
- Turn-based physics artillery.
- Destructible authored cover and environmental interactions.
- Combat-platform progression from poor civilian protection toward restored heavy hardware.
- Stylised post-collapse salvage warfare.
- No water, raft, maritime, or nautical theme.
- No requirement for zombies; human conflict, scarcity, engineering, and old-world machinery are sufficient.
- One primary general progression currency initially: **Salvage**.
- Mobile performance, touch readability, and portrait camera behavior are design requirements.
- Ordinary development/playtest loop should be **open project and press Play**.
- No multiplayer, accounts, clans, backend, live ops, battle pass, ads, IAP, analytics SDKs, or cloud systems without explicit approval.
- Do not add large speculative systems before the current milestone is proven.
- Fort Knocks must be independently identifiable and must not become a clone of Raft Wars or another artillery game.

## Core player loop

```text
select encounter
→ inspect enemy / battlefield
→ choose projectile/tool
→ pull back to set angle + power
→ release
→ follow projectile
→ impact / destruction / displacement
→ survive enemy response
→ win encounter
→ recover Salvage
→ improve Fort Knocks / platform / crew / equipment
→ advance campaign
```

The emotional loop is: **judge → commit → watch → react → improve**.

## Combat pillars

- **Precision** — player judgement of angle, power, range, and later environmental forces.
- **Physics** — readable trajectories, knockback, bounce, displacement, and cause/effect.
- **Destruction** — protection is a tactical object, not background art.
- **Position** — firing lines, elevation, cover, obstructions, and exposed targets matter.
- **Improvisation** — more than one valid way to solve an encounter.
- **Progression** — combat position visibly evolves over the campaign.
- **Spectacle** — projectile flight and impact must remain satisfying across repeated battles.

## Current merged combat baseline

The current prototype on `main` has progressed beyond the original one-projectile vertical slice.

It now includes:

- 720×1280 portrait presentation.
- Wide battlefield with camera travel.
- Player and enemy survivors.
- Destructible wrecked-car cover with staged visual damage.
- Pull-back / slingshot-style aiming.
- Live power percentage and launch angle in degrees.
- Short trajectory preview rather than a complete solved trajectory.
- Previous-shot memory: power, angle, broad result, and world-space impact marker.
- Enemy preview and fast Inspect Enemy flow.
- Approximate enemy direction/distance cue.
- Dedicated portrait camera follow, impact framing, camera impulse, and settle timing.
- Projectile trails, procedural impact feedback, damage readouts, and hit reactions.
- Three data-driven projectile roles:
  - **Scrap Bolt** — balanced; two controlled road rebounds.
  - **Heavy Slug** — strong cover damage / force.
  - **Shock Capsule** — radial pressure / displacement.
- Current Scrap Bolt tuning: first rebound `0.66`, second rebound `0.54`; later ground contact resolves the shot.
- Central concrete roadblock that forces trajectory choices.
- Interactive unstable salvaged power cell.
- Enemy AI that chooses among projectile roles and makes small per-projectile range corrections after misses.
- Win / defeat / restart.
- Touch-first greybox encounter selector for Encounter Proof.
- Three mission-defined layouts using the same combat rules:
  - baseline roadblock trial,
  - enemy high-ground trial,
  - raised-player scrap-gate trial.
- Reusable greybox elevation geometry driven by mission data.
- Second authored environmental interaction: a collapsible scrap gate that becomes a low obstruction when destroyed.
- Compact per-encounter mission brief and post-battle evaluation report for Encounter Proof playtesting.
- Weapon-role explanation moved to a compact upper card that appears/disappears with the weapon-choice tray; the lower deck is now aim data only.

Local playtesting on 2026-09-30 confirmed that the combat loop and the three Encounter Proof layouts feel good and create sufficiently distinct firing problems. **Combat Prototype V1 and Milestone 1B — Encounter Proof are accepted as passed.**

Milestones 1, 1B, 2 and 3 are accepted. The active development milestone is **Milestone 4 — Content Expansion**. New content must create a new tactical or progression decision rather than merely adding larger numbers or cosmetic volume.

Exact combat rules belong in `docs/design/combat_design.md`; exact portrait interaction belongs in `docs/design/portrait_ux.md`.

## Current progression baseline

Milestone 2 is complete and locally accepted.

Current foundation:
- the project boots into a greybox Fort Knocks hub through a root App scene,
- Command Board launches campaign-managed battles,
- Roadblock Trial → High Ground → Scrap Gate currently form the initial sequential Outskirts route,
- first clears award 35 / 50 / 70 Salvage respectively,
- first clear unlocks the next route,
- replayed cleared routes grant no additional Salvage,
- local versioned save state persists progression to `user://fort_knocks_save.json`,
- Garage and Workshop exist as shell screens,
- active platform begins as `run_down_compact`,
- battle remains independently runnable as an Encounter Proof/development scene, but campaign launches bypass its internal development selector.

The first meaningful Salvage/platform progression choice is now implemented:

- Run-down Compact: starting platform, 150 cover durability, 240-wide cover profile.
- Old Sedan / Estate: unlocks after High Ground, costs 80 Salvage, 230 cover durability, 300-wide cover profile.
- The first two mission rewards total 85 Salvage, deliberately funding the first purchase before Scrap Gate.
- Purchased platforms persist in `owned_platform_ids`; owned platforms can be re-equipped without another cost.
- Equipped platform data changes the actual player cover collision/visual profile in battle.
- Battle HUD shows live player cover durability and mission briefing identifies the equipped platform.
- Fort Knocks visibly improves its garage corner and vehicle silhouette when the Sedan is equipped.
- Pickup exists as data/Garage preview only; it is intentionally not purchasable until its first utility/module gameplay is implemented.

The Pickup capability proof and short Outskirts campaign expansion are now implemented:

- Pickup unlocks after **Broken Span** and costs **130 Salvage**.
- Pickup base battle profile is 260 cover durability / 320-wide cover.
- `CombatPlatformDefinition.utility_slot_count` now expresses utility capacity; Pickup has one slot while Compact/Sedan have none.
- Workshop offers two Pickup-compatible modules at 40 Salvage each:
  - **Spotter Rack** — denser visible trajectory sampling plus four highlighted continuation points.
  - **Ballast Crates** — +80 cover durability.
- Only one module is active per platform; module ownership/equipment persists and modules can be swapped after purchase.
- Pickup and its equipped module are visible both in Fort Knocks and during battle.
- The Outskirts campaign now contains six sequential encounters ending in **Outskirts Checkpoint**:
  Roadblock Trial → High Ground → Scrap Gate → Broken Span → Depot Line → Outskirts Checkpoint.
- Existing pre-release saves reconcile completed missions to newly added next-route unlocks, so prior Scrap Gate clears automatically expose Broken Span.

Milestone 2 implementation scope is now structurally complete:

- campaign field rack is live: Scrap Bolt + one Workshop-selected specialist (Heavy Slug or Shock Capsule),
- specialist choice persists and campaign battles expose only those two player weapons,
- standalone Encounter Proof retains all three weapons,
- Fort Knocks now has completion-driven visual stages at 0–1, 2–3, 4–5, and 6 Outskirts clears,
- platform and utility visuals layer on top of those base-growth stages.

Local playtesting on 2026-09-30 accepted the Progression Shell, including the revised Spotter Rack precision-preview readability. **Milestone 2 is passed.**

Do not add another major progression/combat system by default.

Milestone 3 — Identity / Production Presentation is merged and accepted. It establishes:
- a central Fort Knocks palette/UI theme,
- a scavenger-survivor silhouette direction,
- distinct salvage-built Compact/Sedan/Pickup presentation,
- first-region Outskirts environment language,
- stronger Fort Knocks hub identity,
- the provisional two-slash knock-mark visual identifier,
- cohesive aim/projectile/impact VFX,
- procedural ambience and gameplay cue timing,
- lightweight in-world framing for the six Outskirts missions.

Exact visual rules belong in `docs/design/art_direction.md`; audio/music rules belong in `docs/design/audio_direction.md`.

Milestone 4's first development slice now extends the campaign into **Suburbs** with:
- a second-region battlefield presentation,
- a destructible signal-relay mission target,
- an explicit `objective_mode` in mission data,
- balanced / breacher / displacer enemy-tactic data,
- **Dead Air**, where disabling the relay wins even if the defender is still active,
- **Crossroads**, an elevated displacement-focused crew encounter,
- automatic unlock reconciliation from already-completed Outskirts Checkpoint saves.

The next Milestone 4 batch adds the **Improvised Technical** after Suburbs Crossroads:
- 190 Salvage, 300 cover durability, 345-wide profile,
- one active support module,
- **Twin Field Rack**: Bolt + Heavy Slug + Shock Capsule in the same campaign battle,
- **Stabilizer Rig**: 55% less crew displacement while retaining the one-specialist field-rack rule,
- distinct Technical presentation in battle and Fort Knocks,
- a heavier-fabrication Fort Knocks stage after Crossroads.

The next Suburbs batch extends the route to four missions:
- **Loaded Up** protects a destructible Salvage Load while clearing a Raider crew,
- **Hot Cargo** repeats the objective beside a live power cell so the player's own environmental choices can threaten the load,
- **Raider** tactics can redirect enemy fire toward the protected objective,
- Salvage Load destruction is an immediate defeat even when the survivor remains alive,
- the protected load accepts normal direct, Shock-pulse, and power-surge damage,
- completing all four current Suburbs missions adds a secured storage bay to Fort Knocks,
- the hub now reports Suburbs progress as 0–4 clears after Outskirts.

The current test is now broader than encounter variety: local playtesting should confirm that alternate objectives, enemy tactics, protected-objective pressure, and the Technical's versatility-vs-stability choice are all strategically legible before the Suburbs route or platform ladder expands further.

## Portrait UX decisions

Portrait mode is architecture, not a crop of a landscape game.

Locked principles:

- The battlefield may span multiple portrait-screen widths.
- The player and enemy do not need to remain simultaneously visible.
- The camera communicates spatial relationships.
- Manual free camera dragging is not the core combat UX.
- Pull backward opposite the desired shot direction; release to fire.
- Power and angle are always legible while aiming.
- The trajectory preview is partial.
- Inspecting the enemy must not destroy the player's aim context.
- Selection UI must avoid the road, likely projectile path, and the player's pull-back gesture.
- Weapon selection is separated from the bottom aiming information.
- Previous-shot information may help correction but must not solve the next shot.

## Damage / destruction direction

Fort Knocks does **not** pursue fully arbitrary Teardown-style destruction.

Use authored meaningful zones and state changes:

- crew,
- combat platform,
- modules / damage zones,
- selected environment targets.

Prepared pieces may detach, collision may change, modules may be disabled, and cover may open new firing lines. Cosmetic debris should remain cheap and mostly gameplay-neutral.

## Combat-platform direction

`CombatPlatform` is a generalized gameplay concept, not a synonym for vehicle.

It may represent:
- civilian car,
- pickup,
- technical,
- truck,
- APC-class platform,
- tank-class platform,
- barricade,
- bunker,
- wreck,
- building section,
- machinery.

Architecture must therefore avoid assuming every platform has wheels.

## Progression direction

Primary general resource: **Salvage**.

Working platform escalation:

```text
run-down compact
→ old sedan / estate
→ pickup
→ improvised technical
→ armoured utility truck
→ recovered APC-class platform
→ restored tank-class platform
```

Progression should add capability, choices, identity, crew/module opportunities, and visual presence rather than only inflating HP/damage.

Fort Knocks itself should visibly transform from makeshift camp to fortified settlement.

Detailed progression belongs in `docs/design/progression.md`.

## Campaign direction

Working escalation:

1. Outskirts
2. Suburbs
3. Highways
4. Industrial zone
5. Badlands
6. Military perimeter
7. Inner city / secure zones

The order and names are useful design scaffolding, not final world canon.

The collapse cause remains deliberately vague during early development.

## Crew direction

Crew should stay readable and ability-led rather than becoming a spreadsheet-heavy RPG.

Working role concepts include:
- Mechanic — limited repair action.
- Spotter — improves trajectory information.
- Scavenger — increases salvage return.
- Heavy — more resistant to displacement.
- Medic — recovery/revive utility.

These role names/effects are **provisional** until implemented and playtested.

## Fort Knocks hub direction

The hub should be an in-world expression of progression, not a generic menu dressed as a base.

Working functions:
- Garage — combat platforms.
- Workshop — weapons/tools.
- Crew Quarters — survivors.
- Command Board — campaign.
- Scrapyard — salvage/progression.
- Radio Tower — reserved for later only if needed.

Do not implement the full hub before the combat milestone gate is passed.

## Architecture principles

- Typed GDScript where practical.
- Composition over deep inheritance.
- Resources for configurable content.
- Signals for cross-subsystem events.
- Explicit scene dependencies.
- Few autoloads.
- No giant global manager.
- No editor-only ritual required before Play.
- Avoid unnecessary plugins/SDKs and LFS.
- One representative content implementation before batch generation.

The architectural target is described in `docs/architecture/architecture.md`.

## Implementation roadmap

Milestone order is deliberate:

1. **Combat Prototype V1 — PASSED** — aiming, camera, impact, destruction, projectile roles, enemy response, and portrait readability accepted through local playtesting.
2. **Encounter Proof — PASSED** — multiple greybox layouts and environmental interactions accepted as creating repeatable tactical decisions.
3. **Progression Shell — PASSED** — Fort Knocks hub, six-route Outskirts campaign, Salvage, platform/module/loadout progression, save data and visible hub growth accepted through local playtesting.
4. **Identity / Production Presentation — PASSED** — representative survivor, platform, environment, UI, audio, VFX and world-identity pipelines are merged and accepted as the content baseline.
5. **Content Expansion — ACTIVE** — four-mission Suburbs slice now proves relay destruction, protected-objective defense, readable enemy tactics, and the Improvised Technical trade-off before broader content scaling.
6. **Mobile Shipping — FUTURE** — balance, performance, device validation, Android/iOS release work.

Do not skip a milestone because later systems are more exciting. See `docs/design/implementation_roadmap.md`.

## Intentionally deferred

Do not build these without an explicit change in scope:

- multiplayer,
- accounts,
- cloud saves/services,
- clans,
- leaderboards,
- ads,
- IAP,
- battle pass,
- live events,
- procedural campaign generation,
- large weapon catalogs,
- elaborate narrative systems,
- production art pipelines before gameplay needs them.

## Provisional concepts — do not treat as canon

The following may be useful but are not locked final content:

- faction names such as Scavengers, Road Crews, Breakers, Wardens, or Remnants,
- exact campaign-region names/order,
- exact crew role names,
- exact weapon balance values,
- exact mission counts,
- exact vehicle models,
- final story/collapse explanation.

Future sessions should preserve the underlying design function while allowing these names/content details to change.

## Memory rule

Model memory may help recover context, but it is not precise enough to be the only record for:
- exact combat rules,
- exact current implementation status,
- balance values,
- milestone gates,
- architecture contracts,
- progression ladders,
- UI placement rules,
- legal/originality constraints.

For those topics, read the canonical repository documents before implementing.
