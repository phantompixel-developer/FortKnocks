# Fort Knocks — Hub asset kit, review v1

Latest revision: the blue jeep on the left has been removed from the background and assembled preview. The untouched mood-board reference is retained for comparison.

This is the first-screen pilot. Review the Hub before producing assets for the Garage, Workshop, Command Board or gameplay scenes. No game repository or game code was changed.

## Contents

- `backgrounds/`: the Hub scene with HUD and navigation removed. This image is intentionally opaque: the sky and environment are part of the background.
- `ui/buttons/`: blank navigation and small-button faces with transparency outside their outlines. Reuse the faces and overlay the appropriate icon and a live text label.
- `ui/panels/`: a blank resource-counter panel, with transparent outer corners.
- `ui/icons/`: separate transparent PNGs for settings, garage, workshop, missions, map, energy, coin, gem and add/plus.
- `fonts/`: Barlow Condensed Bold and Medium, plus their unmodified SIL Open Font License. These are substitutes, NOT an identified or extracted original font.
- `reference/`: the exact original Hub crop, unchanged.
- `preview/`: visual review sheets; these are not game textures.
- `layout_reference.json`: reference-space component positions and labels for implementation.
- `GENERATION_PROMPTS.json`: prompts used for the reference-based asset reconstruction.
- `asset_manifest.json`: exported dimensions, transparency and source information.

## Fidelity and scope

The source is a single flattened 309 × 501 image. The new assets are reference-based reconstructions, not pixel-exact extractions of original editable layers. The background includes reconstruction where interface elements previously concealed the scene, and generated details can differ from the source. The reference crop is the fixed comparison target; this package is pending visual approval.

The environment remains one flattened background in this pilot. The building, vehicles, tarps, flag and salvage props have NOT yet been separated into movable sprites. There are no weapon sprites on this Hub screen; weapon production belongs to the Workshop pass. This is not the complete game's asset library.

## Implementation

1. Put the opaque background behind the interface.
2. Use the blank navigation face for the four bottom controls. Add the relevant white icon and a separate text label: GARAGE, WORKSHOP, MISSIONS, MAP.
3. Use the resource panel behind live energy, coin and gem values. Keep values editable rather than baking the reference numbers into artwork.
4. Use the settings and plus icons over `ui/buttons/button_square_blank.png` on small button controls.
5. Keep the icon PNG aspect ratios and their transparent padding. Do not bake the preview-sheet background into the UI.
6. Use Bold for navigation labels and Medium for counters. Font size should be adjusted to the final viewport; the JSON coordinates describe the reference, not a tested responsive layout.

Only the normal button appearance is supplied. Pressed, selected and disabled states remain to be agreed; this package does not invent them.

## Font sources

https://github.com/google/fonts/tree/main/ofl/barlowcondensed

The two supplied font binaries are unmodified. Keep `fonts/OFL.txt` with redistributed copies.
