# Fort Knocks vehicle art

The approved showroom and thumbnail PNGs replace the older active vehicle visuals. Both Garage and the player-side battle cover load the new showroom image for the four current platform IDs; Garage cards load the matching thumbnails. Battle retains the existing cover collision and authored damage overlays.

| Tier | ID | Status |
| --- | --- | --- |
| 1 | run_down_compact | Garage and battle cover |
| 2 | old_sedan | Garage and battle cover |
| 3 | pickup | Garage and battle cover |
| 4 | improvised_technical | Garage and battle cover |
| 5 | armoured_utility_truck | Art ready; no playable definition yet |
| 6 | recovered_apc | Art ready; no playable definition yet |
| 7 | restored_battle_tank | Art ready; no playable definition yet |

Each ID has `<id>_showroom.png` (up to 1024×512) and `<id>_thumbnail.png` (512×256). The first four are live; the final three are staged without inventing progression rules. The opposing cover remains faction-neutral art.

The pickup showroom uses the pre-existing approved pickup cutout. The other six showrooms and all seven thumbnails derive from owner-approved art created on 2026-10-08. Thumbnails were transparency-trimmed and fitted to the Garage card ratio; their vehicle pixels were not repainted.
