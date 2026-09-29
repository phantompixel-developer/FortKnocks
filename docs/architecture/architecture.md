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
- campaign map,
- loadout,
- battle,
- results,
- workshop/garage.

## Battle composition
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

## Responsibilities
- **BattleController** — battle lifecycle, victory/defeat, orchestration.
- **TurnController** — whose turn, allowed phase transitions.
- **AimController** — local aiming input/state only.
- **Projectile** — flight/collision behavior driven by data.
- **ImpactResolver** — translates impact data into approved gameplay effects.
- **DamageSystem** — applies damage to valid targets/zones.
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
- systems that both decide rules and render UI.

## Autoload policy
Keep globals rare. Initial candidates only:
- App / app-level flow,
- SaveService,
- AudioService,
- ContentService.

Do not create a global manager for every subsystem.

## Data model
Candidate Resources:
- ProjectileDefinition,
- WeaponDefinition,
- CrewDefinition,
- CombatPlatformDefinition,
- ModuleDefinition,
- MissionDefinition,
- RegionDefinition.

Implementation should favor composition over deep inheritance.

## Save compatibility
Save data must carry an explicit version once persistence is introduced. Migration belongs in the save layer; gameplay systems should not silently reinterpret old saves.
