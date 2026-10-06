# 02 Garage (approved)

Shared UI lives in `../00_shared`. This folder contains only what's unique to the Garage.

## source_svg/icons + png/icons (rebuilt, production quality)
icon_stat_armour (shield), icon_stat_speed (bolt), icon_stat_fuel (jerry can), icon_stat_load (weight). 96px, shown at about 56px.

## art/ (extracted, PLACEHOLDER quality)
| File | Notes |
|---|---|
| bg_garage_scene.png (1080×949) | Truck and back button removed. Reconstructed haze where the truck stood, so a vehicle must always sit there |
| veh_scavenger_pickup_showroom_PLACEHOLDER.png | Showroom cut-out |
| thumb_veh_01_scavenger_pickup_PLACEHOLDER.png | Card thumbnail |
| thumb_veh_02_locked_PLACEHOLDER.png | Lock baked in (it hid the wheels). No unlocked art exists |
| thumb_veh_03_blue_suv_PLACEHOLDER.png | Right edge slightly clipped in the reference |

Live Godot scene: `game/progression/garage_screen.tscn`.
