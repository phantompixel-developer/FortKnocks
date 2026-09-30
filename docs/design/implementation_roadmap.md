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

**Status: ACTIVE**

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

**Milestone 2 implementation scope is now structurally complete.**

**Still required before Milestone 2 passes:**
- local playtest acceptance of the Pickup precision-vs-protection choice,
- local playtest acceptance of Heavy Slug vs Shock Capsule as the specialist-slot decision,
- local playtest acceptance of the six-route campaign/economy pacing,
- confirmation that Fort Knocks' completion-driven visual stages read as meaningful growth,
- persistence validation across restart for campaign, platforms, modules, specialist loadout, and Salvage.

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

### Rule
Do not replace every placeholder at once. Approve one representative production pipeline for each asset class before batching.

---

## Milestone 4 — Content Expansion

### Goal
Scale proven systems without diluting readability.

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
