# Hub Asset Kit v1

This directory contains runtime-ready derivatives of the user-supplied **Fort Knocks Hub Asset Kit v1**.

## Scope

- Hub background with interface removed.
- Reusable Hub navigation/button faces.
- Transparent Hub UI icons.
- Resource panel face.
- Barlow Condensed Bold/Medium and the supplied SIL Open Font License.
- The original kit's layout is treated as a visual composition reference, not as authority to invent new currencies or gameplay systems.

## Runtime policy

The raster source PNGs are stored here as high-quality WebP runtime derivatives to reduce repository/export weight while preserving the supplied visual direction. Text and live values stay native Godot controls.

The current Fort Knocks build has Salvage and campaign progress, but it does not have canonical Energy/Gem currencies, a dedicated Settings screen, or a separate Map screen. Those supplied visual assets are retained in the kit for later use but must not create fake gameplay state.

## Gameplay authority

These assets are presentation-only. Navigation signals, save data, campaign progression, platform ownership, mission state and economy remain script/data driven.
