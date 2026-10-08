# Survivor art

The approved female mechanic and male salvage scout are the character identities for this set. `mechanic_portrait.png` and `scout_portrait.png` are transparent full-body cutouts derived from the approved designs.

`mechanic_battle.png` and `scout_battle.png` are transparent 720×960 combat poses of those same characters, facing right and left respectively. `game/battle/combatant.gd` renders them in its 180×240 world rectangle and keeps the established health strip, hit response, collision and launch origin. The PNG canvases position their muzzles near the existing launch origins. Portraits are available for future UI but do not create a playable crew system.

Godot imports these PNG textures on project import.
