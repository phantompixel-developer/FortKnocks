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
A `CombatPlatformDefinition` should eventually describe stable content data such as:
- ID/display name,
- platform family,
- base mass class,
- crew slot definitions,
- module slot definitions,
- damage-zone definitions,
- visual scene/reference,
- supported integrated equipment.

Do not add fields until gameplay needs them.

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
