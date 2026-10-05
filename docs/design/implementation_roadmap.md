# Fort Knocks — Implementation Roadmap

This roadmap defines sequencing and gates. It exists to stop the project from expanding into progression/content before the combat foundation is proven.

## Milestone 1 — Combat Prototype V1

### Goal
Prove that one battle is enjoyable repeatedly in portrait orientation.

### Required capabilities
- pull-back aiming,
- power percentage and angle readout,
- partial trajectory assistance,
- enemy inspection and spatial context,
- projectile-follow camera,
- readable impact/settle flow,
- character damage,
- authored destructible cover,
- meaningful knockback/displacement,
- at least three projectile roles with different tactical purposes,
- at least one authored environmental interaction,
- enemy turn and non-perfect aiming behavior,
- win / lose / restart.

### Status — PASSED
Accepted through local playtesting on 2026-09-30. The player confirmed the combat and encounter experience feels good enough to move forward.

Validated foundation:
- aiming is usable and understandable,
- portrait HUD no longer obstructs the shooter,
- projectile outcomes and feedback are readable,
- cover/environment interactions create tactical choices,
- enemy turns are functional enough for the current milestone,
- repeated battles support continued play.

### Gate
**Passed.** Combat no longer blocks Progression Shell work. Continue to fix regressions when found, but do not keep expanding the prototype merely to avoid moving on.

---

## Milestone 1B — Encounter Proof

### Goal
Prove the combat system supports multiple interesting battle problems, not just one tuned arena.

### Build
- 2–3 additional greybox encounter layouts,
- meaningful height/obstruction differences,
- another authored environmental interaction,
- reuse the same combat rules rather than introducing a large weapon set,
- basic mission-definition data to load layouts/objectives,
- test short/long/high-arc/bank-shot situations.

### Current implementation status
The first Encounter Proof implementation now provides:
- three selectable greybox encounter definitions,
- baseline, enemy-high-ground, and raised-player layouts,
- reusable authored elevation geometry,
- optional roadblock and power-cell placement from mission data,
- a second environmental interaction: a collapsible scrap gate,
- touch-first encounter selection from the normal Play flow,
- compact mission brief before each proof encounter,
- mission-defined camera preview of the encounter's defining tactical feature,
- end-of-battle encounter report with shot/direct/cover counts, meaningful environment-event count, and weapon-use counts for comparison,
- restart-current-encounter and choose-another-encounter paths,
- weapon-selection explanation moved out of the lower combat area and synchronized with the weapon tray.

### Status — PASSED
Accepted through local playtesting on 2026-09-30.

The proof set demonstrated:
- different layouts change angle, power, and useful projectile choices,
- destruction can open or alter firing lines,
- the camera remains usable across the tested range/elevation variation,
- new encounters can be authored primarily through `MissionDefinition` content and reusable encounter pieces rather than rewriting battle rules.

### Gate
**Passed.** Encounter authoring is repeatable enough to begin the Progression Shell. Keep the current three proof encounters as development references; do not expand the greybox catalog without a progression/content need.

---

## Milestone 2 — Progression Shell

**Status: PASSED**

### Goal
Connect proven battles into the smallest complete game loop.

### Build
- simple Fort Knocks home screen/hub,
- Command Board / short campaign path,
- battle results,
- Salvage rewards,
- Garage,
- Workshop,
- minimal Crew screen only if a crew choice is ready to matter,
- first three platform families:
  - run-down compact,
  - old sedan/estate,
  - pickup,
- existing projectile roles integrated into progression/loadout,
- explicit versioned save format.

### Current implementation status

The first Progression Shell foundation now includes:
- root App / CurrentScreen game flow,
- greybox Fort Knocks hub,
- Command Board,
- campaign-managed battle launch/return,
- first-clear Salvage rewards,
- sequential mission unlocks,
- battle result → progression update contract,
- Garage and Workshop shell screens,
- explicit local `save_version = 1` persistence,
- first live Salvage purchase/equip flow,
- Old Sedan / Estate unlock after High Ground for 80 Salvage,
- equipped-platform cover durability/geometry applied in battle,
- visible Fort Knocks garage/platform change after equipping the Sedan,
- Pickup unlock/purchase/equip flow,
- one Pickup utility slot with Spotter Rack vs Ballast Crates,
- utility effects applied in battle,
- six connected Outskirts encounters ending in a checkpoint-style combined-tactics mission,
- campaign reconciliation for older pre-release saves when the route expands,
- Pickup and equipped utility shown in Fort Knocks,
- campaign field rack: Scrap Bolt + one selected specialist (Heavy Slug or Shock Capsule),
- specialist choice persisted and applied only to campaign battles,
- four Fort Knocks visual stages driven by Outskirts completion in addition to platform/utility visuals.

The current Outskirts route now meets the intended 4–6 mission plus checkpoint scale without adding speculative combat systems. Existing projectile roles are now integrated into a real loadout choice rather than only listed in Workshop.

**Milestone 2 implementation scope is complete and accepted.**

### Local acceptance — 2026-09-30

Local playtesting confirmed the Progression Shell is ready to advance:
- hub → Command Board → battle → reward → hub flow works,
- campaign progress and Salvage persist,
- Sedan and Pickup ownership/equip progression works,
- Pickup utility modules persist and materially alter battle,
- Spotter Rack now has a clearly perceptible precision-preview advantage over the normal trajectory guide,
- Ballast Crates provide the intended protection alternative,
- specialist field-rack selection works,
- six-route Outskirts progression is usable,
- Fort Knocks visibly changes as campaign/platform progression advances.

### Gate
**Passed.** Do not continue expanding the Progression Shell by default. New work should move to Milestone 3 and improve identity/presentation around the now-proven systems.

### Campaign scope
Start small: approximately 4–6 connected missions plus a checkpoint/boss-style encounter is enough to prove progression. Do not author dozens of missions yet.

### Save foundation
When persistence begins, use an explicit schema version, e.g.:

```json
{
  "save_version": 1,
  "campaign": {},
  "inventory": {},
  "crew": {},
  "settings": {}
}
```

Migration belongs in the save layer.

### Gate
Progression should cause meaningful decisions and visible Fort Knocks transformation, not merely add menus.

---

## Milestone 3 — Identity / Production Presentation

**Status: PASSED**

### Goal
Turn the proven game into recognisably **Fort Knocks**.

### Build
- production survivor direction,
- production civilian/combat-platform art,
- environment art for the first campaign region,
- Fort Knocks hub visual progression,
- cohesive UI skin,
- sound design,
- music direction,
- polished projectile/impact/destruction VFX,
- faction/world presentation,
- lightweight story/context.

### Current implementation

The representative production-presentation pipelines are now implemented:
- shared Fort Knocks palette/theme and reusable screen skin,
- stronger scavenger-survivor silhouette,
- distinct compact/sedan/pickup silhouettes with salvage repair language and authored damage presentation,
- layered non-colliding Outskirts environment treatment across road, flyover and salvage-depot variants,
- Fort Knocks perimeter/workshop/garage/gate identity plus visible campaign-growth stages,
- recurring two-slash knock-mark/hazard motif as a provisional player identifier,
- distinct visual treatment for roadblock, scrap gate and unstable power cell,
- cohesive projectile silhouettes, trails, aim-guide treatment and staged impact VFX,
- procedural audio director with hub/menu/battle ambience and event cues,
- lightweight in-world context across all six Outskirts missions,
- canonical visual/audio pipeline and provenance documentation.

No new progression system, weapon catalog or campaign region was added as part of this milestone.

### Acceptance — 2026-09-30

Milestone 3 is accepted for progression. The presentation branch was merged after local testing exposed and the branch fixed GDScript parser/type-inference regressions; the user then explicitly directed development to continue from merged `main`.

The representative visual/audio language is now the baseline for additional content. New regions should extend this language rather than replacing it with unrelated presentation.

### Rule

Scale the proven visual/audio language deliberately. New content still needs a gameplay reason to exist; do not batch a large asset catalog merely because the presentation gate has passed.
---

## Milestone 4 — Content Expansion

**Status: ACTIVE — FOUR-MISSION SUBURBS SLICE IMPLEMENTED, LOCAL ACCEPTANCE PENDING**

### Goal
Scale proven systems without diluting readability.

### Current implementation slice

The first expansion batch deliberately proves three new content axes without adding a broad catalog:
- **Suburbs** begins as a second campaign-region presentation with its own low residential/commercial silhouette language.
- **Dead Air** introduces a mission objective that can be won by disabling a destructible signal relay; incapacitating the enemy is no longer the only valid victory condition.
- **Crossroads** returns to crew defeat but introduces an elevated displacement-focused enemy problem.
- Mission data now carries an explicit objective mode and enemy tactic.
- Enemy tactics currently include balanced, breacher and displacer behavior; non-balanced tactics are surfaced in battle messaging so the distinction is readable.
- The signal relay reuses the existing projectile/damage/VFX pipeline and can be damaged directly or by Shock pressure.
- Existing completed Outskirts saves reconcile into the new route through the established next-mission unlock pass.

The second Content Expansion batch adds the first post-Pickup platform tier:
- **Improvised Technical** unlocks after Crossroads for 190 Salvage,
- one support-module slot,
- **Twin Field Rack** carries Bolt + Slug + Shock together,
- **Stabilizer Rig** cuts crew displacement by 55% while retaining the normal one-specialist rack,
- Workshop, battle briefing, Fort Knocks and platform visuals expose the trade-off,
- Garage presentation has been tightened to fit four platform tiers without portrait overlap,
- Fort Knocks gains a heavier-fabrication stage after Crossroads.

The third Content Expansion batch extends Suburbs to four missions with a second objective family:
- **Loaded Up** introduces a protected Salvage Load; victory requires clearing the raiders while the load survives,
- **Hot Cargo** repeats the protected-objective rule beside a live power cell so the player's own Shock/hazard choices can cause collateral damage,
- `MissionDefinition` now supports `protect_salvage` plus Salvage Load placement/durability,
- **Raider** enemy tactics deliberately redirect fire toward the protected objective,
- direct shots, Shock pressure and power-cell surges all use the same damage pipeline against the Salvage Load,
- destroying the load is an immediate mission defeat even when the player survivor remains alive,
- inspection shows Salvage durability and live-cell state together,
- clearing the current four-mission Suburbs slice adds a secured storage bay to Fort Knocks.

This remains a representative Content Expansion slice, not the full Milestone 4 catalog.

### Current acceptance gate

Before scaling Milestone 4 further, local Play-mode review should confirm:
- **Dead Air** ends when the relay is disabled even if the defender is still alive,
- killing the Dead Air defender first does not prematurely end the relay objective,
- **Breacher** behavior creates noticeably more cover pressure,
- **Displacer** behavior creates noticeably more Shock/position pressure,
- the Suburbs battlefield reads differently from Outskirts without obscuring gameplay,
- Improvised Technical unlocks after Crossroads and can be bought with the intended campaign economy,
- **Twin Field Rack** visibly enables Bolt + Slug + Shock in one campaign battle,
- **Stabilizer Rig** produces a clearly perceptible reduction in player displacement,
- switching Technical modules restores the correct mutually exclusive trade-off,
- **Loaded Up** fails when the protected Salvage Load is destroyed and wins only when the raiders are cleared with the load intact,
- Raider behavior visibly redirects meaningful fire toward the protected objective,
- player direct fire and Shock pressure can also damage the protected load,
- **Hot Cargo** makes the nearby live cell a genuine collateral-risk decision rather than decorative hazard placement,
- Garage/Workshop remain readable with no portrait overlap,
- Fort Knocks visibly reflects both the Technical foothold and the later secured-storage progression stage.

Do not expand beyond the current four Suburbs missions or add another platform tier until these distinctions survive local playtesting.

### Whole-current-game visual audit — 2026-10-05

The second visual-production checkpoint was merged to `main` in PR #11. A subsequent whole-current-game audit against the locked visual reference is recorded in:

- `docs/design/current_game_visual_audit.md`

The audit confirms the overall theme has remained aligned, but identifies current-content polish work that should happen **before Highways or further content expansion**.

Highest-priority remediation:
1. replace the proof-era campaign Mission Brief with a readable final Run Brief,
2. replace the proof-era campaign Result/Takeaway surface with a final debrief/reward hierarchy,
3. implement shared safe-area/responsive portrait layout handling,
4. make Command Board region-aware for Outskirts → Suburbs,
5. verify/fix the four-platform Garage row fit,
6. then recompose Garage/Workshop/Command Board toward the approved physical-world-first reference.

Milestone 4 therefore remains active, but **visual/current-content acceptance is now a gate before further region expansion**.

All four audit remediation batches (A–D) are now implemented across the stacked visual-polish branches. The remaining gate is **combined local Play/device validation**, not additional speculative implementation.

Do not begin Highways until the combined stack has been reviewed in normal Play against `docs/design/visual_reference.md`.



Possible expansion:
- additional campaign regions,
- more platform families,
- modules,
- crew roles,
- mission-objective variants,
- additional environmental interactions,
- selected new projectile roles,
- more sophisticated enemy archetypes.

New content must create new decisions, not only larger numbers.

---

## Milestone 5 — Mobile Shipping

### Goal
Deliver a stable Android/iOS product.

Required work includes:
- broad phone/aspect-ratio testing,
- touch/safe-area validation,
- performance profiling,
- memory/texture/audio budgets,
- pause/resume/background behavior,
- save robustness,
- accessibility pass,
- export/signing/store requirements,
- legal/name/asset-provenance review.

iOS build/signing remains a Mac/Xcode step.

## Cross-milestone rules

- Branch from current `main`.
- Keep ordinary playtesting to **open project → Play**.
- Do not introduce hidden refresh/import/setup rituals.
- Prefer one representative implementation before batch content.
- Update canonical docs when a durable rule changes.
- Avoid speculative managers, backends, or services.
- Keep placeholder and production assets clearly distinguished.
