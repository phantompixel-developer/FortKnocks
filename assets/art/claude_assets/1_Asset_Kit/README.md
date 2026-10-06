# Fort Knocks: asset kit

Organised by screen. Each screen folder has the same layout:

- `source_svg/`: **editable masters**, one SVG per element (Inkscape, Illustrator, Figma, Affinity). Edit these, then re-export.
- `png/`: runtime exports at 1080×1920 base scale. **These are what Godot uses.**
- `art/`: painted art extracted from the mood board (PNG only, there's no vector source). Files marked `_PLACEHOLDER` need replacing with real art before release. (Workshop ammo is vector and lives in `source_svg/art` + `png/art`.)
- `_preview_*.jpg`: layout guide only. Don't import it.

| Folder | Contents |
|---|---|
| `00_shared/` | Elements reused across screens: back button, arrows, stats panel, stat-bar segments, upgrade button, item cards, coin, lock, lower background, scene fade, contact shadow |
| `02_garage/` | Garage stat icons + extracted vehicle art |
| `04_command_board/` | Scrolling campaign board: 3 chained seamless backgrounds, polaroid/pin/route kit, decor overlays, chapter HUD, placeholder region photos |
| `03_workshop/` | Workshop stat icons + vector ammo illustrations (display + thumbnail) + workshop background |

## Why Godot uses PNG, not SVG
Godot imports SVGs with ThorVG, which ignores SVG filters. The drop shadows, glows and grain in these masters would vanish. So the SVGs are the masters and the PNGs are the build files. After editing an SVG, export it at 1× (same pixel size as the SVG canvas) to the matching `png/` path.

## Nine-patch margins (left/top/right/bottom)
| Asset | Margins |
|---|---|
| panel_stats_9s | 40/40/40/40 |
| statbar_seg_*_9s | 12/12/12/12 |
| btn_upgrade*_9s | 36/30/36/40 |
| card_item_9s | 30/30/30/30 |
| card_item_selected_9s | 50/50/50/50 (has a 20px glow bleed, offset it −20 on every side) |

## Locked items
Each vehicle or ammo type needs only **one** normal thumbnail. The locked look (darkened + lock icon) is applied in Godot by `ItemCard`. The only exception is Garage vehicle 02, whose extracted art has the lock baked in. Real art for it should be drawn normally.

## Brief for real art (when you replace the placeholders)
- Showroom vehicles / ammo: about 1000px wide, transparent background, consistent 3/4 side view, lit warm from upper left.
- Card thumbnails: about 320×220, transparent, same angle as the showroom art.
- Scene backgrounds: paint at **1080×1400 or taller**. 20:9 phones show more height than the mood board covers.
