# 03 Workshop (built)

Reuses everything in `../00_shared` (panel, bars, upgrade button, cards, arrows, back button, coin, lock). Only the following is unique to the Workshop.

## source_svg/icons + png/icons (vector, production quality)
icon_stat_damage (crosshair), icon_stat_explosion (blast), icon_stat_range (trajectory to target), icon_stat_bounce (bouncing ball). 96px, shown at about 56px.

## source_svg/art + png/art: ammo illustrations (vector, production quality)
| Ammo | Display (large showroom) | Thumbnail (card) |
|---|---|---|
| Standard shell | ammo_standard_display (1100×560) | ammo_standard_thumb |
| Heavy shell | ammo_heavy_display | ammo_heavy_thumb |
| Cluster bomb | ammo_cluster_display | ammo_cluster_thumb |
| EMP charge | ammo_emp_display | ammo_emp_thumb |

- All four were redrawn as vector art in the mood board's painted style. The mood board only had about 45px versions of Heavy, Cluster and EMP, which can't be enlarged to display size without blurring. Standard was redrawn too, so all four match.
- Display and thumbnail of each ammo use the same drawing at different angles (−12° display, −38° thumbnail), so they always match.
- Being vector, they can be re-exported at any resolution (e.g. 2× for tablets) with no quality loss.
- Lighting is warm from the workshop lamp (upper right), with bounce light from the bench below, so they sit naturally on the bench.

## art/
| File | Notes |
|---|---|
| bg_workshop_scene.png (1080×846) | Extracted and upscaled from the mood board, shell and back button removed. The original shell's shadow on the bench is kept, so whichever ammo is shown sits naturally there |
| _reference_extracted/ammo_standard_extracted_from_moodboard.png | The original extracted shell, kept only as a style reference. Not used in the game |

## Layout
- 4 cards, 228×282 each (the shared 9-slice card), with native-text captions.
- Stat bars: 4 segments (one setting, `stat_segments`, in the Godot scene).
- Stat label column is 262px wide to fit "EXPLOSION".
