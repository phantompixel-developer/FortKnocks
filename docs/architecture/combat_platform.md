# Combat Platform Architecture

## Definition
A **CombatPlatform** is the physical fighting position associated with a crew. It may be a vehicle, barricade, bunker, wreck, building section, or machinery. Vehicle progression is a major campaign expression, but battle architecture must not assume every platform has wheels.

## Composition
Conceptual structure:
```text
CombatPlatform
├── Body
├── Collision
├── CrewSlots
├── ModuleSlots
├── DamageZones
└── Visuals
```

## Definition resource
`CombatPlatformDefinition` now exists and currently owns only data needed by the first progression proof:
- ID/display name,
- tactical summary,
- purchase cost,
- campaign unlock requirement,
- whether the platform is currently purchasable,
- cover durability,
- cover collision/visual size,
- cover colour/profile.

The first live definitions are:
- `run_down_compact` — 150 cover / 240-wide profile,
- `old_sedan` — 230 cover / 300-wide profile / 80 Salvage,
- `pickup` — data/preview only until its module gameplay is implemented.

Do not add mass classes, crew slots, module slots, or damage-zone schemas until the next platform actually needs them.

## Current battle integration

For the current greybox progression proof, the equipped platform configures the player's existing `DestructibleCover` rather than replacing the entire battle scene with vehicle-specific subclasses.

Important implementation rule:
- the player cover duplicates its shared `RectangleShape2D` before resizing,
- therefore changing the player's platform profile must not resize enemy cover that originated from the same scene sub-resource.

This is intentionally a thin adapter. When Pickup introduces the first real utility/module position, platform composition can grow from this definition instead of hardcoding a second special-case cover object.

## Damage zones
Avoid arbitrary mesh/sprite destruction simulation. Platforms expose authored zones such as:
- front body,
- cabin,
- rear body,
- wheel/support,
- armour plate,
- mounted equipment.

Zones can transition between authored states, detach prepared pieces, alter collision, disable modules, or pass damage to crew according to defined rules.

## Modules
Modules are compositional upgrades. A module can provide a capability, protection, resource bonus, or trade-off. The platform should not hardcode every module type.

## Crew slots
Crew position affects exposure and available actions. A slot should define its anchor/cover relationship; character logic should not contain vehicle-specific coordinates.

## Physics
Do not simulate every cosmetic component. Keep one controlled platform body unless a designed encounter requires separated physics pieces. Destruction debris should be cheap, short-lived, and gameplay-neutral unless explicitly authored otherwise.
