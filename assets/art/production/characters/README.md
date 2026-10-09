# Survivor art

The approved female mechanic and male salvage scout are the character identities for this set. `mechanic_portrait.png` and `scout_portrait.png` are transparent full-body cutouts derived from the approved designs.

`mechanic_battle.png` and `scout_battle.png` are transparent 720×960 combat poses of those same characters, facing right and left respectively. `game/battle/combatant.gd` renders them in a 340×370 world rectangle and keeps the health strip, hit response and collision shape. The explicit projectile launch offset is raised to match the larger launcher art. Portraits are available for future UI but do not create a playable crew system.

Godot imports these PNG textures on project import.

`mechanic_battle.png` was regenerated on 2026-10-08 after the committed PNG was found to be corrupt. It is an original Fort Knocks cutout made with OpenAI built-in image generation, using the repository-owned `mechanic_portrait.png` as the identity reference and `scout_battle.png` only for combat-pose composition. The prompt specified the mechanic's approved clothing and likeness, a braced right-facing launcher pose, painterly/cel-shaded finish, complete boots, a transparent background, and no third-party content. The result was fitted to the existing 720×960 canvas with its muzzle aligned near the established launch origin. It is project-local production art; battle collision and launch geometry remain defined by code.
