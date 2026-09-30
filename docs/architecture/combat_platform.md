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
- utility-slot capacity,
- cover durability,
- cover collision/visual size,
- cover colour/profile.

The first live definitions are:
- `run_down_compact` — 150 cover / 240-wide profile,
- `old_sedan` — 230 cover / 300-wide profile / 80 Salvage,
- `pickup` — 260 cover / 320-wide profile / 130 Salvage / `utility_slot_count = 1`,
- `improvised_technical` — 300 cover / 345-wide profile / 190 Salvage / one support-module slot.

Do not add mass classes, crew-slot schemas, or damage-zone schemas until a platform actually needs them. The Technical proves that the existing generic module slot is sufficient for another tier without introducing separate vehicle subclasses.

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
`PlatformModuleDefinition` now exists for the first utility-slot proof.

Current Pickup modules:
- `spotter_rack` — denser midpoint trajectory sampling across the normal visible arc + 4 highlighted continuation points,
- `ballast_crates` — +80 cover durability.

Current Improvised Technical modules:
- `twin_field_rack` — allows the campaign battle to carry both specialist projectiles at once,
- `stabilizer_rig` — sets crew displacement response to 45% of normal.

Pickup modules cost 40 Salvage; Technical modules cost 55 Salvage. Each platform currently has one active module slot, so benefits remain mutually exclusive.

`PlatformModuleDefinition` now carries only the battle effects required by these proven modules:
- cover-health bonus,
- trajectory-preview bonus,
- carry-both-specialists flag,
- crew-knockback multiplier.

Module ownership/equipment is persisted separately from platform ownership. Battle receives the equipped module from `App`; modules do not read save data themselves.

This remains a small compositional module seam. Do not generalize it into inventory grids, rarity, attachment trees, or slot taxonomies without a gameplay need.

## Crew slots
Crew position affects exposure and available actions. A slot should define its anchor/cover relationship; character logic should not contain vehicle-specific coordinates.

## Physics
Do not simulate every cosmetic component. Keep one controlled platform body unless a designed encounter requires separated physics pieces. Destruction debris should be cheap, short-lived, and gameplay-neutral unless explicitly authored otherwise.
