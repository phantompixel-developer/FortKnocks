# Fort Knocks — Claude visual asset package

The supplied visual package has been integrated into the **existing Fort Knocks Godot project**.

## Runtime/source asset kit

Use `1_Asset_Kit/` as the retained source and runtime asset package:

- `00_shared/`: shared UI, buttons, panels, stat bars, icons and contact shadow
- `02_garage/`: Garage background and stat icon assets
- `03_workshop/`: Workshop background plus production projectile display/thumbnail art
- `04_command_board/`: scrolling Command Board backgrounds, region photos, pins, route string, decor and HUD

The original standalone reference Godot project was intentionally removed after integration. It contained sample vehicle/ammo/campaign data that conflicted with the live Fort Knocks data model. The useful chained Command Board background tiles were promoted into `1_Asset_Kit/04_command_board/art/` before removal.

## Live integration

The game now consumes these assets through the existing scenes and systems:

- `game/progression/garage_screen.*`
- `game/progression/workshop_screen.*`
- `game/campaign/command_board.*`
- `game/presentation/production_ui.gd`

Canonical Fort Knocks gameplay data remains authoritative. Do not reintroduce sample data from the removed reference project.

## Known placeholder art

Still replace before final release quality:

- Garage scene background
- Command Board region photographs
- Workshop scene background is extracted/upscaled reference art and may need a final authored pass

The existing Fort Knocks four-platform vehicle family remains authoritative; the supplied mood-board vehicle cut-outs were not promoted to gameplay because they do not cover the real progression set cleanly.
