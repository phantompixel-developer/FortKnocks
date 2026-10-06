# 04 Command Board (built)

Vertically scrolling campaign board. **Chapters contain regions, regions contain missions.** Missions are numbered per chapter.
Progress reads top to bottom. The board opens centred on the current mission, with completed content above and locked content below.
Region names, used consistently: **Outskirts, Suburbs, Highway, Industrial, Badlands, The City**. "The Wastes" from the concept board is dropped.

## art/
| File | Notes |
|---|---|
| bg_board_tile_a/b/c.png (1080×2160 each). Stored in `2_Godot_Project/assets/command_board/art/` | Planks + pinned map. **Chained**: a→b→c→a join with no seam, so the pattern only repeats every 3 tiles (about 3.4 screens). Generator: `source_generators/board_bg.py` |
| bg_board_tile_planks.png | Planks only. Fills the sides on screens wider than 1080 |
| region_photo_*.png (760×500) | **PLACEHOLDERS.** Cropped and upscaled from the gameplay mood board. Must be replaced with clean source artwork before release. The Outskirts banner text has been painted out, but that photo is still placeholder quality |

## source_svg/ui + png/ui (vector, text-free)
| File | Use |
|---|---|
| polaroid_frame, polaroid_photo_overlay | Region header (460×420). Photo window 380×250 at (40,34) |
| pushpin_red, tape_strip | Polaroid attachment (chosen per layout) |
| mission_pin_completed / current / locked (108×108) | Mission states. Graphic is 108px; the Godot touch area is 140px |
| mission_pin_current_glow | Pulses behind the current mission |
| mission_pin_available | **Optional, unused by default.** Only for non-linear progression where several missions are selectable at once |
| tag_paper_9s (margins 12) | Small mission-number tag |
| string_red_tile, string_shadow_tile | Route (Line2D, tile mode, width 20) |
| wire_locked_tile | Spare: wire style for gated routes |
| chapter_banner_9s (30) | Chapter divider on the board (native text) |
| hud_chapter_panel_9s (40), hud_chapter_tab_9s (28), progress_track_9s (20), progress_fill_9s (16), deco_string_knot | Bottom chapter HUD |
| frame_rail_9s | Wooden rail for the fixed top bar and the bottom HUD (flipped) |
| scroll_edge_shadow | Soft shadow where the board scrolls under each rail |

## source_svg/decor + png/decor
coffee ring, dirt stain, lined note, torn scrap, marker circle / X / arrow, blue and yellow push pins, loose string. Placed per region layout to give the board its physical density.

Shared additions: `00_shared/ui/btn_close` (+pressed), used by the mission briefing.
