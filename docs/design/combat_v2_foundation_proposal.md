# Fort Knocks — Combat V2 Foundation Proposal

**Status:** Design proposal; no game code or final art changed.  
**Decision 01 (confirmed by project owner):** Prioritise **tactical artillery + environmental destruction**, within a **salvage-and-survival campaign**.  
**Base:** current main, October 2026.  
**Authority:** AGENTS.md, docs/README.md, docs/project_context.md, docs/design/game_design.md, docs/design/combat_design.md, docs/design/portrait_ux.md, docs/design/visual_reference.md, docs/architecture/camera_architecture.md.

## Purpose

This reset is **not** a replacement of the established game identity. The canonical documents already specify the hybrid correctly. This proposal makes the intended experience testable as a single authored encounter, so battle composition, mechanics, art, and physics cannot be designed independently again.

Before implementation, compare this proposal against the canonical files. A durable change to existing rules requires owner acceptance and a matching update to the owning canonical document.

## One-sentence player promise

**Judge a shot → change the battlefield → exploit the opening → secure the objective → bring salvage home.**

The player must enjoy the shot itself and the tactical consequence. A hit that only changes a health number is not the target experience.

## Design hierarchy

1. **Shot judgement** — angle, power, distance, trajectory, bounce, and controlled corrections.
2. **Physical consequence** — the impact visibly changes cover, position, hazard state, or a reachable firing line.
3. **Tactical decision** — choose direct damage, cover removal, displacement, or an environmental interaction.
4. **Campaign consequence** — victory awards Salvage, advances the route and enables meaningful Garage/Workshop choices.
5. **Artistic cohesion** — every gameplay object sits on the same authored spatial ground plane and uses one locked art language. Presentation reinforces mechanics; it does not invent them.

A typical encounter remains approximately 2–4 minutes; this is the existing product target, not a hard guarantee for every mission.

## Firm constraints carried over from the existing design

- Android/iOS; portrait-first logical viewport 720 × 1280 with responsive safe-area handling.
- Godot 4.7.x, GDScript, 2D physics, 2.5D presentation layers only.
- Single-player, turn-based campaign first.
- One player survivor, **outside** their equipped vehicle/cover; enemy generally located to the right, normally off-screen while player aims.
- Touch/mouse **pull-back → angle/power → release fires**. Do not add a separate mandatory FIRE button. The accessibility alternative remains a later explicitly designed mode.
- Existing partial trajectory preview, previous-shot information, enemy direction/distance cue, Inspect Enemy / Return to Shooter, projectile follow and impact/settle camera flow.
- Existing campaign field-rack rule: Scrap Bolt + one selected specialist (Heavy Slug or Shock Capsule), except existing approved platform/module exceptions.
- Existing Hub → Command Board → Battle → Result → Hub loop; Salvage and current save progression are preserved.
- Existing approved assets and the locked visual reference control art. Generated previews are **not** approved replacement assets.
- Do not add multiplayer, accounts, new currencies, vehicle-mounted player shooting, extra weapons, free-roam, or new regions in this pass.
- Original layouts/art/code; borrow principles from other artillery/destruction games, not their distinctive expression.

## The gameplay unit: Roadblock Trial V2

**The first and only production-validation encounter.** Use the existing Roadblock Trial mission entry and core aim/combat systems rather than creating a parallel game.

### Playable layout (world space, left to right)

1. **Shooter pocket, left:** approved survivor standing on traversable road; currently equipped approved civilian vehicle directly beside/behind them as physically grounded cover.
2. **Central obstruction:** low roadblock interrupting shallow firing lines. A higher arc and a banked shot remain potentially viable without modifying the physics rules.
3. **Tactical breakable cover:** authored, visible barrier that shields an enemy angle; its hit state changes both its silhouette and effective collision.
4. **Interactive hazard:** existing unstable power cell placed so targeting it is an intentional trade-off, not an accidental instant win.
5. **Enemy pocket, right:** enemy crew physically grounded beside their own cover, initially off-screen from the player's stable aim camera; access via Inspect Enemy.
6. **One modest elevated feature:** a service deck, berm or failed roadway section that adds a useful height difference, not a large vertical fantasy fortress. The main roadway remains legible.

This is a *topology*, not permission to invent final pixel coordinates. Before art production, author measured geometry and verify every visible tactical surface against its collision shape.

### Three intended viable player strategies

- **Precision:** arc a Scrap Bolt over or around the central obstruction to reach an exposed enemy angle. Controlled ground bounce is an option only where surfaces make it plausible.
- **Breach:** use Heavy Slug to weaken or destroy cover, generating a clearer shot on a later turn.
- **Environment:** use Shock Capsule or a suitable direct impact to discharge the existing power cell, displacing/damaging targets or cover and changing a future shot.

These are target playtest affordances, not guarantees of equivalent success probability. Two specialist choices are not simultaneously available in a normal campaign battle unless an existing approved module allows them.

### Enemy turn

Enemy remains an imperfect artillery opponent. Its offensive decision must be legible (e.g. pressuring crew, cover, or an objective). It cannot use unfair targeting accuracy to compensate for weak level design.

## Destruction contract — authored and controlled, not fully deformable terrain

A breakable gameplay object has:

- explicit gameplay identity (cover, obstacle, support, hazard, or mission objective);
- collision footprint and visible art grounded in the same coordinates;
- at least intact / damaged / broken (or existing object's equivalent) presentation states where meaningful;
- authored consequences on break: remove or lower a blocker, expose a firing line, discharge a hazard, alter local cover, or trigger a **small, predetermined** collapse;
- readable feedback: hit location, material response, sound/VFX, settle time and an unambiguous changed state.

**The primary road/soil is not freely deformable in V2.** Full terrain erosion, arbitrarily simulated structural physics and mass debris are out of scope. Decorative debris may be cosmetic; anything that blocks shots must have explicit collision. Destruction cannot cause invisible lingering colliders or untracked gameplay obstacles.

An authored small support-collapse interaction may be investigated *after* barrier and hazard transitions are proven reliable. Do not make a whole bridge collapse a prerequisite for the first vertical slice.

## Camera and portrait interaction contract

1. **Opening reveal:** show enemy, cover and key hazards once.
2. **Aim:** stable camera on survivor, partial trajectory in a clean projectile corridor, compact weapon tray above; hide tray during pull-back.
3. **Inspect:** user-triggered, persists until Return to Shooter, shows target information and preserves any prior aim parameters.
4. **Projectile follow:** tracked, readable trajectory with modest lead/lookahead.
5. **Impact:** frame actual hit and change in collision/cover/health. Hold long enough that the player recognises the tactical consequence.
6. **Return:** move to the appropriate next actor without excessively long repeated pans.

Safe areas and alternative tall/narrow phone aspects must work. Do not attempt to show both opposing survivors permanently at gameplay scale in a single portrait aim view.

## Production art integration contract

- Gameplay geometry is authored first, then visual surfaces and asset anchors are composed against it.
- One consistent world scale for survivors, vehicles, road height, barriers and enemy cover; one coherent light direction and value hierarchy.
- Foreground treatment may add depth but must not occlude shooter, launch gesture, projected arc or meaningful hit targets.
- Distant scenery is noninteractive and lower contrast. Interactives are identifiable by silhouette, depth, damage state and environmental context rather than intrusive floating highlights.
- Asset presentation uses the locked visual reference; do not reuse proposal images as runtime atlases or accept generated substitutions without approval.
- The player vehicle is a gameplay cover/platform, **not** a gun mount.

## Source-of-truth boundary

| Domain | Authority |
| --- | --- |
| Mission objective/progression | Existing mission definitions and campaign systems |
| Physics/collision/destructible states | Godot world nodes and typed gameplay scripts |
| Camera | CameraDirector |
| Combat orchestration | Current BattleController until extraction becomes justified |
| UI and gestures | Portrait UX rules and existing live battle HUD |
| Visual identity | Locked visual reference and approved assets |
| New encounter-specific details | This proposal, only after acceptance and translation into canonical docs |

Never design a decorative object as tactical unless it is backed by actual world collision and interaction logic.

## Acceptance gate — pass/fail in local Godot Play

### Functional
- Existing pull-back-and-release aiming works; no invented mandatory FIRE control.
- Scrap Bolt bounce, Heavy Slug cover damage, and Shock Capsule/hazard pulse remain consistent with the installed loadout.
- Projectile collisions do not tunnel through crew/cover at tested launch speeds; direct and environmental impacts register exactly once.
- Destroyed cover/hazards transition art **and** collision in the same outcome; no ghost blocker.
- Mission briefing, turn change, result and Salvage flow continue to work unchanged.

### Tactical
- At least **two materially different winning plans** are demonstrated in play, with a third environmental option where loadout permits.
- Destroying or weakening the designed central/defensive objects visibly changes a subsequent aiming decision.
- Players can identify the likely useful targets by looking at the environment, without reading a tutorial paragraph.

### Visual/UX
- On-foot survivor, approved vehicle and road appear in one spatially coherent world, not as independent cutouts.
- One screenshot of player aim, one of Inspect Enemy and one of post-impact reliably show the correct tactical state.
- Logical 720 × 1280 viewport, a taller/narrower phone aspect, and safe-area insets are checked for HUD overlap.
- Camera never hides the key result during the required settle phase.
- Production assets are correctly attributed and aligned to their collision locations.

### Validation evidence
- Short Play-mode capture of one battle with aim, inspect, direct impact, cover break, hazard reaction and turn handoff.
- Screenshots for aim / inspect / changed battlefield.
- A concise checklist recording actual results, not self-awarded green check marks from a concept image.
- Any unavailable runtime/device checks must be explicitly reported as unverified.

## Work sequencing / stop rules

**A. Geometry specification:** construct a labelled level layout with measured player, cover, obstruction, enemy and hazard positions. Evaluate game camera against it.

**B. Greybox gameplay:** implement only missing interactions/collision fixes needed for this layout, preserving core mechanics and existing content.

**C. Proof and tuning:** repeat the intended shot plans, test projectile reliability and observe camera state transitions. Reject an encounter with no meaningful tactical differences.

**D. Production art application:** fit existing approved art to validated world geometry, then author only demonstrably missing assets in the locked style.

**E. Visual/combat acceptance:** compare three actual Godot frames and a gameplay recording to the signed specification. No expansion until this slice passes.

**Stop:** no new weapons, vehicles, regions, UI redesigns, physics sandbox, major campaign rework or background-art-only polish pass while this gate remains open.

## Open for further owner review

1. Whether later battlefields should allow limited **pre-authored surface collapse** beyond cover and barriers. Proposed V2 default: no freely deformable ground.
2. Degree of vehicle mobility in combat. Proposed V2 default: stationary cover/utility during a battle; progression alters the position's capabilities.
3. How much complex structural destruction is desired after the small Roadblock Trial slice works. Proposed default: expand authored modules only when each produces a new tactical decision.

These are provisional implementation limits, not newly locked long-term game rules.
