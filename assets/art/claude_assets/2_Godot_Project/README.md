# Fort Knocks: Godot UI project

Built and tested in **Godot 4.4.1** (GL Compatibility renderer, so it runs on low-end mobile too). Should open in any Godot 4.3+.
Open `project.godot`. F5 runs the Garage. To run the Workshop, open `screens/workshop/workshop_screen.tscn` and press F6.

## Structure
```
assets/shared/          PNGs from the kit's 00_shared (UI, icons, fx)
assets/garage/          Garage icons + extracted art
assets/workshop/        Workshop icons, ammo display/thumbnail art, background
fonts/                  Stand-in font (DejaVu Sans Condensed Bold, free licence)
ui/theme/               fort_knocks_theme.tres: fonts, colours, text styles, button/panel skins
ui/components/          Reusable scenes: stat_row, item_card, upgrade_button
ui/upgrade_screen/      UpgradeScreen (shared screen logic) + UpgradeItemData (shared data)
screens/garage/         garage_screen.tscn, VehicleData, data/*.tres (sample vehicles)
screens/workshop/       workshop_screen.tscn, AmmoData, data/*.tres (the 4 ammo types)
screens/command_board/  command_board.tscn, region_polaroid, mission_pin, data classes,
                        layouts/ (hand-composed region layouts), data/ (sample chapters)
ui/components/mission_briefing  Shared mission briefing (any screen can use it)
```

## How the screens are built
Garage and Workshop share one script, `UpgradeScreen`. Each `.tscn` is the same layout with its own art, stat labels, icons and settings. A fix or feature added to `UpgradeScreen` applies to both. `garage_screen.gd` and `workshop_screen.gd` are empty subclasses, kept as the place for screen-only extras.

Settings on each screen (Inspector → Layout):
| Setting | Garage | Workshop | Purpose |
|---|---|---|---|
| `stat_segments` | 4 | 4 | Bar segments per stat. Change to 5 at any time, including at runtime: `screen.stat_segments = 5` |
| `stat_label_width` | 230 | 262 | Stat name column width |
| `card_size` | 344×282 | 228×282 | Card size |
| `card_separation` | 18 | 12 | Gap between cards |
| `show_card_captions` | off | on | Text under each card (from `caption`) |
| `display_reference_height` | 0 | 984 | Display art widens with the background on tall screens (0 = fixed size) |

## What is native Godot (nothing baked into images)
- **Text:** every Label uses theme styles.
- **Dynamic values:** name, level, stats, upgrade preview, cost and lock state all come from data resources.
- **Interaction states:** TextureButton normal/pressed/disabled. The upgrade Button uses theme StyleBoxTextures. Cards are Buttons with selected/locked states. The upgrade button disables itself when the player can't afford it.
- **Navigation:** arrows (disabled at either end), tapping a card, **swiping left/right on the large display**, and a touch-scrollable card row. The large display fades and scales in when the selection changes.
- **Responsive layout:** containers + anchors. Base 1080×1920, stretch `canvas_items` / `expand`. Tested at 1080×1920, 1080×2400 (20:9) and 1536×2048 (tablet).

## Hooking it into the game
```gdscript
var ws = preload("res://screens/workshop/workshop_screen.tscn").instantiate()
ws.items = my_ammo_list            # Array of AmmoData (or any UpgradeItemData)
ws.player_coins = save.coins
ws.back_requested.connect(_go_to_hub)
ws.upgrade_requested.connect(func(item): _try_upgrade(item); ws.refresh())
```
Signals (Garage/Workshop): `back_requested`, `upgrade_requested(item)`, `item_selected(item)`.
On a locked item the button reads **UNLOCK** and still emits `upgrade_requested`. Check `item.locked` to tell the two apart.

## Adding a new vehicle or ammo type
Duplicate a `.tres` in `data/`, set its name, stats, costs, `thumbnail` and `showroom_texture`, and add it to the screen's `items` list. You need one thumbnail only, because the locked look is applied automatically.

## Command Board
`screens/command_board/command_board.tscn`. Open it and press F6.

**Data model:** `ChapterData` → `RegionData` (name, photo, layout, mirrored, missions) → `MissionData` (id, title, objective, reward).
Set `chapters` and `current_mission_id`. Missions before the current one show as completed, the current one glows, and later ones are locked. Numbers restart per chapter, and the HUD shows the chapter in view with its done/total.

**Hand-composed regions:** each region uses an authored `RegionLayout` (`layouts/layout_4_missions` … `layout_7_missions`). A layout holds the pin route, polaroid position/tilt/attachment and decor placements, and can be mirrored with `mirrored = true`. Nothing is random. To make a new composition, duplicate a layout and move the points in the Inspector (coordinates are for a 1080-wide section).

**Flow:** tap a mission → `mission_selected(mission, context)` → the shared **MissionBriefing** opens → DEPLOY → `deploy_requested(mission_id, mission, context)`. The board never launches gameplay; your game code does that:
```gdscript
board.deploy_requested.connect(func(id, mission, ctx): Game.start_mission(id))
board.back_requested.connect(_go_to_hub)
# after the player finishes a mission:
board.current_mission_id = next_id
board.build()        # rebuilds and re-centres on the new current mission
```
Locked missions shake when tapped. Completed missions can be replayed (`allow_replay`). Back closes the briefing first. The fixed top rail and bottom HUD reserve their own space; the board scrolls only between them, and the top rail grows on notched phones.

## Swapping in the real font
Put e.g. Teko or Oswald (OFL, from Google Fonts) in `fonts/`, then in `ui/theme/fort_knocks_theme.tres` set **Default Font** to it. Every label updates. Font sizes may need a small adjustment.

## Placeholder content
Vehicle names "IRONCLAD SUV" and "BLUE RAIDER", ammo names other than Standard Shell, and all stats and costs are sample data.

## First open
The first time you open the project, Godot imports every texture. The output panel may show a few "No loader found" theme errors during that one import. They are harmless and stop once importing finishes.
