# Fort Knocks: UI assets + Godot project (Garage, Workshop, Command Board)

## 1_Asset_Kit/
Source and export files, organised by screen:
- `00_shared/`: UI used across screens (buttons, panels, stat bars, cards, coin, lock, close button)
- `02_garage/`: Garage icons + extracted vehicle art (placeholders)
- `03_workshop/`: Workshop icons, vector ammo illustrations (display + thumbnail), workshop background
- `04_command_board/`: chained seamless map backgrounds, polaroid/pin/route kit, decor, chapter HUD, placeholder region photos

Each screen folder has `source_svg/` (editable masters), `png/` (game exports) and `art/` (painted/extracted art). Read `1_Asset_Kit/README.md` first.

## 2_Godot_Project/
Godot 4.4 project with all three screens built and tested (open `project.godot`).
- F5 runs the Garage.
- Open `screens/workshop/workshop_screen.tscn` or `screens/command_board/command_board.tscn` and press F6 to run the others.
Read `2_Godot_Project/README.md` for how to connect the screens to your game.

## Still placeholder (replace before release)
- Garage vehicle art and both scene backgrounds (extracted from the mood board)
- Command Board region photos
- The stand-in font (swap in Teko or Oswald via the theme)
- Sample names, stats, costs and missions in the `data/` folders
