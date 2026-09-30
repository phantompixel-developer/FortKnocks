# Architecture Foundation

## Technical baseline
- Godot 4.7.x.
- GDScript.
- 2D gameplay.
- Portrait-first Android/iOS.
- Compatibility renderer unless a measured requirement justifies changing it.
- Data-driven content through custom Resources where appropriate.

## Intended repository structure
```text
game/
  core/
  battle/
  characters/
  platforms/
  weapons/
  campaign/
  progression/
  ui/
assets/
  art/
  audio/
  fonts/
  shaders/
source_assets/
tests/
tools/
docs/
```

Do not create empty directories only to satisfy this diagram. Add them when the first real file belongs there.

## Scene-level composition
Long-term application flow:

```text
App
├── GameFlow
├── CurrentScreen
└── OverlayLayer
```

Candidate screens:
- home / Fort Knocks hub,
- campaign map / Command Board,
- loadout,
- battle,
- results,
- workshop / garage.

## Battle target architecture

```text
Battle
├── BattleController
├── TurnController
├── Battlefield
│   ├── Terrain
│   ├── Environment
│   ├── PlayerPlatform
│   └── EnemyPlatform
├── ProjectileLayer
├── DestructionLayer
├── EffectsLayer
├── CameraDirector
└── BattleHUD
```

This is an architectural target, not permission to create every node/script before it has behavior.

## Current prototype architecture
The current combat prototype intentionally keeps some orchestration inside `BattleController` while rules are still being proven.

Current explicit combat phases are conceptually:
- INTRO / preview,
- PLAYER_AIM,
- PROJECTILE_FLIGHT,
- IMPACT_RESOLUTION,
- SETTLE,
- ENEMY_THINKING,
- GAME_OVER.

Do **not** refactor these into separate managers solely to match the target diagram. Extract `TurnController`, `ImpactResolver`, or other subsystems when feature pressure makes the responsibility boundary valuable.

Current weapons already use a data-driven `WeaponDefinition` Resource. Preserve that direction rather than adding projectile-specific controller branches where configuration can own the difference.

## Responsibilities
- **BattleController** — battle lifecycle, victory/defeat, orchestration.
- **TurnController** — whose turn and allowed phase transitions once extracted.
- **AimController** — local aiming input/state once extraction is justified.
- **Projectile** — flight/collision behavior driven by data.
- **ImpactResolver** — translates impact data into approved gameplay effects once extraction is justified.
- **DamageSystem** — applies damage to valid targets/zones when a shared system becomes necessary.
- **CombatPlatform** — platform composition and damageable zones/modules.
- **EnemyBrain** — chooses AI action without owning battle rules.
- **CameraDirector** — camera state machine and transitions.
- **BattleHUD** — presentation/input surface, not combat authority.

## Communication
Prefer:
- direct typed references for clear parent-child ownership,
- signals for events crossing subsystem boundaries,
- Resources for immutable/configurable content definitions.

Avoid:
- long `get_parent().get_parent()` chains,
- global lookups for ordinary scene dependencies,
- circular dependencies,
- systems that both decide rules and render UI,
- speculative abstractions with only one caller.

## Autoload policy
Keep globals rare. Initial candidates only:
- App / app-level flow,
- SaveService,
- AudioService,
- ContentService.

Do not create a global manager for every subsystem.

## Data model
Existing / expected Resources:
- `WeaponDefinition` — current projectile-role configuration.
- `MissionDefinition` — current encounter layout/objective configuration.
- ProjectileDefinition — add only if projectile data outgrows WeaponDefinition.
- CrewDefinition.
- CombatPlatformDefinition.
- ModuleDefinition.
- RegionDefinition.

Implementation should favor composition over deep inheritance.

## Encounter authoring

`MissionDefinition` owns stable encounter data; it does not own battle rules. The current definition supplies combatant/cover positions, optional authored obstacles/interactions, reusable greybox platform rectangles, a backdrop variant, objective/test-focus text, and an optional tactical-feature preview position/text.

`BattleController` currently applies the selected definition because encounter loading is still small and has one caller. Do not create a separate global mission manager merely to move these assignments elsewhere.

Reusable runtime arena pieces such as `ArenaPlatform` and `CollapsibleBarrier` must remain generic. Encounter resources are registered through the small campaign-side `EncounterCatalog`; the battle selector builds itself from that catalog. Adding a new encounter may update content registration, but should not require mission-ID conditionals in battle, projectile, or damage rules.

## Save compatibility
Save data must carry an explicit version once persistence is introduced. Migration belongs in the save layer; gameplay systems should not silently reinterpret old saves.

Persistence is a Progression Shell milestone task, not a combat-prototype prerequisite.

## Development-loop constraint
A fresh checkout/pull should not require a hidden editor menu action, asset refresh button, or undocumented setup step before ordinary Play. Build import/configuration automation where needed.
