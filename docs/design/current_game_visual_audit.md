# Fort Knocks — Whole Current Game Visual Audit

**Date:** 2026-10-05  
**Branch:** `audit/current-game-visual-reference`  
**Status:** COMPLETE — remediation plan ready  
**Primary authority:** `docs/design/visual_reference.md`  
**UX authority:** `docs/design/portrait_ux.md`

## Audit purpose

This audit evaluates the **current playable campaign as one visual product**, not as a collection of individually improved scenes.

Scope:

`Hub → Command Board → Garage → Workshop → Outskirts → Suburbs → Battle HUD / Inspect / Mission Brief / Result`

The audit answers four questions:

1. Does the current implementation still match the locked approved visual direction?
2. Which screens now feel coherent and which still expose prototype-era structure?
3. What cross-screen systems are holding the whole game below the reference quality bar?
4. What must be fixed before production expands into Highways or another region?

This is a source/implementation audit against the locked design and current assets. Items involving exact phone-scale appearance must still be confirmed in local Play/device testing, but the findings below are grounded in the current scene hierarchy, coordinates, presentation scripts and production assets.

---

# Executive conclusion

The game has **not drifted away from the approved theme**.

That is the most important positive result.

The current implementation consistently uses:
- ruined modern civilian infrastructure,
- welded salvage construction,
- dark charcoal/steel UI,
- warm hazard/rust accents,
- restrained teal for recovered technology,
- warm sunset/cinematic atmosphere,
- 2D gameplay with layered 2.5D depth,
- distinct Fort Knocks and rival presentation.

The architecture is also now substantially healthier than the original prototype:
- presentation art is separated from gameplay collision,
- the same platform art is reused across Hub/Garage/Battle,
- Outskirts and Suburbs have distinct regional language,
- foreground framing respects the projectile corridor,
- player/rival/objective silhouettes are deliberately separated.

However, **the game is not yet visually at the finish level of the locked concept board**.

The largest remaining gap is no longer “wrong theme.” It is now **production finish and whole-screen composition**.

Three systemic issues currently hold the experience below the reference:

1. **Proof-era campaign presentation is still visible in the live game.**
   Mission Brief and Result are development/evaluation surfaces reused as player-facing campaign screens.

2. **Meta screens still read too strongly as menus placed over world art.**
   Command Board, Garage and Workshop contain the correct content and art, but large rectangular card stacks still dominate their composition.

3. **The authored SVGs establish the correct silhouettes and palette but remain flatter than the approved painterly/cel-shaded finish.**
   They are strong production-direction masters, but not yet the final material/lighting/detail ceiling shown in the reference.

Therefore:

> **Do not begin Highways yet.**

The next work should be a focused current-content polish sequence.

---

# Rating scale

### A — Production aligned
Structure, content hierarchy and visual language are close enough to the locked reference that only normal polish is required.

### B — Strong foundation, visible polish gap
Correct direction and readable implementation, but still noticeably below the reference in composition, material finish or interaction presentation.

### C — Requires a deliberate remediation pass
The correct system may exist, but prototype/menu-era structure remains visibly dominant or conflicts with the approved presentation target.

### D — Blocking mismatch
A direct violation of a locked visual/UX rule or a clearly unfinished player-facing state.

---

# Whole-game scorecard

| Area | Rating | Summary |
| --- | --- | --- |
| Fort Knocks Hub | **B** | Correct world-first direction and progression logic; dynamic additions are still visibly procedural and UI could integrate more naturally into the settlement. |
| Command Board | **C** | Physical map exists, but campaign geography/copy is stale and the screen is still dominated by a large menu panel/list. |
| Garage | **B-** | Correct authored vehicle family and garage language; vehicle is still presented inside a card instead of truly owning the scene. |
| Workshop | **B-** | Correct hardware and warm workbench direction; large card stacks still make it feel like an equipment menu rather than a physical workshop. |
| Outskirts battle environment | **B** | Strong layering/readability; mission-specific overpass/depot dressing still uses older procedural primitives and finish is flatter than reference. |
| Suburbs battle environment | **B+** | Strongest current regional implementation; coherent shared language and mission-specific landmarks, but material rendering remains vector-flat vs reference. |
| Battle combatants / interactives | **B+** | Good authored silhouette coverage and state separation; final texture/lighting finish still has room to rise. |
| Live aiming HUD | **B** | Good information discipline and hide/show behavior; typography, safe-area handling and panel hierarchy are not final. |
| Inspect Enemy | **B** | Interaction model is correct and readable; presentation polish and safe-area resilience remain. |
| Mission Brief | **D** | Proof-era screen is used in campaign and auto-hides after only 1.15 seconds despite long briefing copy. |
| Battle Result / Debrief | **C-** | Functional but still reports prototype evaluation metrics/takeaways rather than a final campaign debrief/reward presentation. |
| Typography / UI identity | **C** | Palette/panels are coherent, but there is no authored font system and one repeated surface treatment carries too much of the UI. |
| Safe-area / aspect responsiveness | **D** | Explicit project requirement is documented but no safe-area implementation exists; fixed 720×1280 offsets dominate current screens. |
| Screen-to-screen transition polish | **C** | `CurrentScreen` replacement is immediate; no visual transition layer currently joins Hub/meta/battle states. |
| Asset rendering finish | **C+` / B-` foundation** | Correct silhouettes and art direction, but simple SVG fills/gradients do not yet reach the approved painterly/cel-shaded material finish. |

---

# 1. Fort Knocks Hub

## What is working

The Hub is one of the most structurally correct screens in the game.

It follows the locked reference by:
- presenting an actual settlement rather than a menu background,
- keeping the active platform visible in-world,
- showing workshop/perimeter/gate infrastructure,
- changing the same settlement as campaign capability grows,
- using warm work lights and the Fort Knocks knock-mark language,
- keeping only Command Board / Garage / Workshop as the primary navigation.

The progression subtitle also updates appropriately from Outskirts into Suburbs.

## Remaining gaps

### H1 — Progression overlays are still visibly procedural
**Severity: P1**

The static Hub background has authored layers, but much of the actual progression transformation is still drawn from rectangles, lines and circles in `fort_knocks_hub_visual.gd`.

This means the most important emotional promise of the Hub — *the same broken camp becoming a capable fort* — still has a finish mismatch between the authored backdrop and later upgrades.

Examples:
- generator,
- storage,
- fabrication equipment,
- secured storage bay,
- reinforced infrastructure.

### H2 — Active platform is visually important but not compositionally integrated enough
**Severity: P2**

The vehicle is correctly rendered from the shared production source, but the Hub still reads as separate procedural zones rather than one strongly lit cinematic settlement composition.

### H3 — UI remains somewhat detached from the world
**Severity: P2**

The top status cards and bottom buttons are readable, but the screen can move closer to the reference by letting the settlement remain the hero and making navigation feel like an overlay attached to the scene rather than a second visual layer.

## Hub recommendation

Keep the structure. Do **not** redesign the Hub flow.

Later polish should:
- author the major progression-stage overlays as coherent art layers,
- improve local lighting/contact shadows around the active vehicle/workshop,
- reduce visual separation between “scene art” and “UI over scene.”

---

# 2. Command Board

## What is working

The physical-map direction is correct:
- recovered road-map surface,
- route line,
- completion/unlock nodes,
- dark frame,
- real mission data remains native rather than baked into art.

This is aligned with the reference.

## Critical gaps

### C1 — Header copy is factually stale
**Severity: P0**

The screen still displays:

> `OUTSKIRTS RUNS • CLEAR A ROUTE FOR FORT KNOCKS`

The campaign now contains:
- 6 Outskirts missions,
- 4 Suburbs missions.

The Hub already understands this transition, but Command Board does not.

This creates an immediate whole-game coherence error.

### C2 — Route visual has no region identity
**Severity: P0**

`CommandBoardVisual.configure()` receives:
- mission count,
- unlocked count,
- completed count.

It receives **no mission IDs, region metadata or region boundary information**.

Therefore the physical map cannot visually communicate the key progression event:

> Outskirts → Suburbs

The approved reference calls for a real campaign-planning surface. The current route is still effectively a numbered linear progress visualization.

### C3 — The menu still dominates the physical board
**Severity: P1**

The map is correctly added, but the screen remains dominated by:
- Header card,
- Salvage card,
- large MissionPanel,
- scroll list of rectangular mission buttons.

A rough bounding-box calculation from current scene coordinates shows major panels/buttons occupy roughly **two thirds of the 720×1280 screen area**.

That does not mean the screen is unusable. It means the physical board is still visually subordinate to the menu structure.

### C4 — Proof-era data field remains player-facing
**Severity: P1**

Mission buttons display `mission.test_focus`.

The copy has become more world-readable over time, but this field originated as an encounter-proof evaluation label and should no longer define final campaign card architecture.

## Command Board recommendation

This should be one of the first remediation screens.

Keep:
- native buttons,
- real campaign data,
- the map asset.

Change:
- dynamic region title/subtitle,
- route data aware of mission/region identity,
- obvious visual break between Outskirts and Suburbs,
- mission selection as pinned route cards / compact native overlays attached to the physical board,
- less screen area consumed by one giant rectangular list panel.

---

# 3. Garage

## What is working

The most important system is correct:
- the vehicle is now the visual hero inside the current content hierarchy,
- all four current platforms use authored shared sources,
- modules visibly follow the equipped platform,
- platform progression remains native/data-driven,
- the background has garage structure and warm work-light language.

## Gaps

### G1 — Vehicle is still a hero *inside a card*, not the hero of the room
**Severity: P1**

The reference calls for:
- a large side/three-quarter vehicle,
- warm overhead work lights,
- real garage structure around it.

Current composition places the showcase inside a `CurrentCard` approximately 536×308, while another large progression card occupies the lower middle of the screen.

Major card/button bounding boxes account for roughly **half the viewport**.

The vehicle art is good enough to deserve more visual territory.

### G2 — Platform selector is still text-heavy
**Severity: P1**

Each platform option is a three-line native button:
- name,
- tactical summary,
- action.

That is functional but visually behaves like a progression menu, not a garage selection rail.

### G3 — Current four-platform list is extremely tight
**Severity: P0/P1 — verify in Play**

The PlatformList has approximately 342 px of declared vertical area.

Four current buttons at 82 px plus three 8 px gaps require approximately 352 px.

The following DetailLabel begins at y=408 relative to the card.

This creates a likely small overflow/overlap around the fourth platform row and detail text. It should be checked directly in Godot and corrected even if the present font happens to make it visually survivable.

## Garage recommendation

Do not change platform logic.

Recompose:
- vehicle large in the garage bay,
- platform selector as a compact lower carousel/rail or stacked selector,
- tactical detail as one selected-item panel,
- purchase/equip state attached to selected platform rather than repeating full detail in every row.

---

# 4. Workshop

## What is working

The Workshop direction is correct:
- actual current weapon silhouettes exist,
- module hardware exists,
- selection state is dynamic,
- Twin Field Rack correctly shows both specialists,
- background contains pegboard/workbench language,
- warm task lighting is present.

## Gaps

### W1 — Physical hardware is still trapped inside UI cards
**Severity: P1**

The LoadoutCard and UtilityCard together occupy a large portion of the screen.

Major card/button bounding boxes account for roughly **58% of the viewport**.

The approved reference wants the Workshop to feel like:
> an actual workbench/pegboard first, equipment menu second.

At present the system is closer to:
> a well-skinned equipment menu with hardware illustrations.

### W2 — Too much explanatory copy competes with the hardware
**Severity: P2**

The screen currently shows:
- core round label,
- field-rack label,
- two multi-line specialist buttons,
- rack rule explanation,
- platform label,
- module buttons,
- module note.

All are individually useful, but together they weaken the physical workshop fantasy.

### W3 — Hardware art still has flat-vector finish
**Severity: P1/P2**

The silhouettes are correct, but the final reference expects more material wear, directional light and painterly depth.

## Workshop recommendation

Keep all mechanics.

Recompose around:
- one large workbench/pegboard hero area,
- actual highlighted equipped hardware,
- concise native action controls,
- contextual detail only for the currently selected item.

---

# 5. Outskirts battle

## What is working

Outskirts now has:
- authored shared sky/far layer,
- authored midground,
- authored road,
- authored dark foreground,
- production combatants/vehicles/interactives,
- clear projectile corridor,
- correct warm/cool hierarchy.

The battle architecture is aligned with the reference.

## Gaps

### O1 — Mission-specific environment overlays are behind Suburbs quality
**Severity: P1**

After the authored Outskirts base is drawn, `BattlefieldVisual` still draws some mission identity using older procedural methods:
- `_draw_overpass_backdrop()`,
- `_draw_salvage_backdrop()`.

These rely heavily on `draw_rect`, `draw_line`, circles and simple polygons.

Suburbs now uses dedicated authored landmark SVGs per mission.

Therefore the newer region has a more coherent asset pipeline than the first region.

### O2 — Base environment rendering remains flatter than reference
**Severity: P2**

The SVGs establish the correct composition and silhouette language but still rely on simple fills/gradients and repeated shapes.

The reference target calls for:
- controlled texture,
- material wear,
- painterly/cel-shaded surfaces,
- more integrated directional lighting.

## Outskirts recommendation

Bring Outskirts mission landmarks up to the Suburbs asset architecture before creating Highways.

Do not redesign encounter geometry.

---

# 6. Suburbs battle

## What is working

Suburbs is currently the strongest environment implementation.

It has:
- a distinct but related regional identity,
- shared production layers,
- four mission-specific authored landmark overlays,
- region-specific retaining-wall platform treatment,
- authored relay/salvage objectives,
- intact/destroyed objective states,
- deliberate avoidance of fake live-tech cues around Hot Cargo,
- correct dark foreground hierarchy.

## Remaining gaps

### S1 — Material rendering still below reference ceiling
**Severity: P2**

Residential rows, walls, garages and props are structurally correct but still use simplified vector construction.

### S2 — Repetition is visible in the residential layer
**Severity: P2**

The long 2160 px scene repeats similar house/window/garage forms.

This is acceptable for current readability but will eventually need more authored variation and surface breakup to reach the concept-board richness.

## Suburbs recommendation

No architectural rewrite.

Suburbs should be the **template for region implementation**, with later material-detail refinement.

---

# 7. Battle HUD and aiming presentation

## What is working

The HUD architecture is substantially correct.

The game already follows several difficult portrait rules:
- weapon selection is top-left rather than on the shooter,
- weapon info is separate from aim data,
- weapon tray/info hide during pull-back,
- lower deck only carries power/angle/last shot,
- Inspect replaces the normal aiming presentation,
- enemy direction/distance restores spatial context,
- central projectile corridor is mostly unobstructed.

These should not be thrown away.

## Critical gaps

### B1 — No safe-area implementation
**Severity: P0**

Both `portrait_ux.md` and `visual_reference.md` explicitly require safe-area handling.

Repository search finds no runtime safe-area implementation.

Current HUD uses fixed coordinates such as:
- top controls around y=42–230,
- bottom control deck y=1090–1168,
- HintLabel down to y=1244.

On a 1280 logical-height screen the HintLabel is only 36 px from the bottom edge.

The project uses:
- 720×1280 viewport,
- `canvas_items` stretch,
- `expand` aspect.

Without dynamic safe-area insets, notches/home indicators/aspect expansion can invalidate otherwise good layouts.

### B2 — Typography is still default-system presentation
**Severity: P1**

No TTF/OTF or theme font override exists in the repository.

The UI has a strong palette but not yet a strong typographic identity.

### B3 — Health/turn information lacks a mature hierarchy
**Severity: P2**

Turn, player health and enemy health are mostly floating labels while other HUD elements use industrial panels.

This may work against simple sky values, but it does not yet feel as deliberately composed as the reference UI.

### B4 — One shared panel/button treatment is doing too much
**Severity: P2**

`panel_industrial.svg` and `button_industrial.svg` are reused broadly.

Consistency is good, but final polish needs hierarchy:
- HUD micro-panel,
- standard card,
- emphasized mission/result card,
- primary action,
- compact tactical chip.

Not every surface should look like the same scaled plate.

---

# 8. Mission Brief

## Rating: D — highest-priority player-facing visual/UX problem

The campaign currently uses the same MissionBriefCard architecture that originated in Encounter Proof.

### MB1 — It auto-hides after 1.15 seconds
**Severity: P0**

`_begin_mission()` currently:

1. shows the mission brief,
2. waits one frame,
3. waits **1.15 seconds**,
4. hides the brief.

Current briefing paragraphs are far too long to read in 1.15 seconds.

This is a direct usability failure regardless of art quality.

### MB2 — It exposes proof-era structure
**Severity: P0/P1**

The card includes:
- mission title,
- `test_focus`,
- full briefing,
- objective.

The current UX documentation explicitly says the Encounter Proof brief is a development-facing surface and **not the final campaign mission screen**.

### MB3 — It interrupts rather than builds anticipation
**Severity: P1**

The approved visual direction supports an in-world route/run presentation.

The current brief behaves like a temporary modal test card rather than a deliberate campaign start.

## Mission Brief recommendation

Replace campaign use with a final **Run Brief**:
- mission name,
- region/location line,
- concise objective,
- one short tactical warning,
- equipped platform/loadout summary where useful,
- explicit **BEGIN RUN** action or tap-to-continue.

Do not put a long paragraph on a 1-second timer.

Standalone Encounter Proof can retain the old diagnostic brief if that development mode is still useful.

---

# 9. Inspect Enemy

## What is working

This interaction should be retained.

It now:
- stays until explicit return,
- hides normal weapon/aim UI,
- shows enemy/cover/hazard state,
- preserves aim state,
- pans deliberately to enemy.

This directly addresses the earlier usability problem and matches the portrait UX plan.

## Remaining gaps

### I1 — Same safe-area/Typography issues as wider HUD
**Severity: P1/P2**

### I2 — Target card is informational rather than visually tactical
**Severity: P2**

The card could eventually use compact icons/silhouette-state indicators, but this is not a priority over Mission Brief/Result/safe area.

---

# 10. Battle Result / Debrief

## Rating: C-

The ResultCard is functional but visibly inherited from encounter evaluation.

### R1 — Player-facing campaign result still reports proof metrics
**Severity: P0/P1**

The card emphasizes:
- shots,
- direct hits,
- cover hits,
- environment events,
- weapon usage.

These are useful for development analysis, but they are not the strongest final campaign reward hierarchy.

### R2 — “Takeaway” text is analytical/developer-like
**Severity: P1**

Examples generated by `_encounter_takeaway()` include ideas such as:
- the run leaned on cover breaking,
- the run leaned on a weapon type,
- compare with another encounter.

This is useful telemetry feedback disguised as UI.

### R3 — Reward/progression information is secondary
**Severity: P0/P1**

The campaign result should prioritize:
1. victory/defeat,
2. mission objective outcome,
3. Salvage recovered,
4. newly unlocked route/platform/module progression,
5. optional performance summary.

Current reward text is folded into the takeaway label.

## Result recommendation

Create a final campaign debrief while preserving a development report only in Encounter Proof/debug mode.

---

# 11. Typography and UI identity

## Finding

The project has:
- a coherent palette,
- coherent industrial panel/button assets,
- text shadow,
- consistent uppercase language.

It does **not** yet have:
- a project typography system,
- a branded title/display face,
- defined body/utility typography roles,
- font assets or global font overrides.

## Severity: P1

This is a relatively small implementation change with game-wide visual impact.

The chosen type system should remain:
- highly readable at phone size,
- industrial/condensed only where appropriate,
- not faux-military,
- not distressed to the point of harming legibility.

---

# 12. Safe areas and responsive composition

## Rating: D

This is a documented requirement with no implementation.

### Current evidence

`project.godot`:
- viewport 720×1280,
- portrait orientation,
- canvas-items stretch,
- expand aspect.

Most UI scenes:
- use fixed pixel offsets,
- assume the baseline viewport,
- do not query or apply safe-area insets.

No code reference to a safe-area API is currently present.

## Required outcome

Create one shared portrait layout/safe-area system before more screens multiply the problem.

It should provide:
- top safe inset,
- bottom safe inset,
- left/right safe inset,
- baseline 720×1280 composition area,
- responsive centering/anchoring when aspect expands.

This should be applied first to:
- Hub actions/top bar,
- meta-screen back buttons,
- Battle top HUD,
- Battle hint/control deck.

---

# 13. Screen transitions

## Rating: C

`FortKnocksApp._replace_screen()` immediately removes the current screen and inserts the next.

There is no shared transition presentation between:
- Hub → Command Board,
- Hub → Garage,
- Hub → Workshop,
- Command Board → Battle,
- Battle → Hub.

This makes individually polished screens feel less like one finished product.

## Recommendation

After the higher-priority UI remediation:
- add a very short shared transition layer,
- use restrained fade/welded shutter/light dip rather than flashy motion,
- preserve fast iteration and do not slow navigation.

---

# 14. Asset finish versus approved reference

## Finding

The current authored assets are **directionally correct** but should not be mistaken for the final reference-quality ceiling.

Examples reviewed:
- industrial panel/button,
- Improvised Technical,
- Suburbs midground,
- Hub mid-structures.

They use:
- clean vector paths,
- flat fills,
- simple linear gradients,
- crisp silhouette construction.

This successfully solved:
- theme consistency,
- reuse,
- silhouette recognition,
- layering architecture.

But the locked reference asks for:
- painterly/cel-shaded surface treatment,
- controlled texture,
- richer wear,
- more directional light,
- more atmospheric/material depth.

## Severity: P1 as a cross-cutting quality program

Do **not** repaint every asset immediately.

First fix whole-screen composition and final campaign UI.

Then take one representative set:
- one vehicle,
- one survivor,
- one Hub structure,
- one Outskirts/Suburbs environment slice,
- one UI panel family,

and raise those to the actual reference rendering finish.

Once approved, propagate that finish systematically.

---

# 15. Rough menu-dominance check

This is not a pixel-perfect visibility metric; it is a simple bounding-box check using the current scene rectangles to explain why some screens still feel menu-led.

Approximate major UI rectangle/button area relative to the baseline 720×1280 viewport:

- Hub: ~20%
- Garage: ~53%
- Workshop: ~58%
- Command Board: ~67%

The number itself is not a design target.

The useful conclusion is:

> Hub already behaves much more like a world with UI layered over it. Garage, Workshop and especially Command Board still behave like large UI compositions with world art behind them.

That matches the visual-reference comparison.

---

# Ranked remediation backlog

## P0 — Fix before any new region

### 1. Replace campaign Mission Brief
- final player-facing Run Brief,
- no 1.15-second reading timer,
- explicit continue/begin action,
- remove proof-era presentation from campaign mode.

### 2. Replace campaign Result/Debrief
- objective outcome first,
- Salvage reward prominent,
- unlock/progression reveal,
- optional performance data secondary,
- keep proof metrics only for Encounter Proof/debug.

### 3. Implement shared safe-area/responsive layout foundation
Apply to all current screens before expanding the UI surface area.

### 4. Correct Command Board campaign geography
- remove stale Outskirts-only header,
- make map region-aware,
- visually distinguish Outskirts → Suburbs,
- stop treating all ten missions as one anonymous route.

### 5. Verify/fix Garage four-row vertical fit
The source layout indicates likely 10 px overflow / detail overlap.

---

## P1 — Current-content production polish

### 6. Recompose Garage around the vehicle
Vehicle should own the bay rather than sit inside a large card.

### 7. Recompose Workshop around physical hardware
Workbench/pegboard first; buttons/details second.

### 8. Reduce Command Board menu dominance
Use compact native route cards/pins attached to the physical planning surface.

### 9. Establish final typography hierarchy
One readable branded display face + highly legible body/utility treatment.

### 10. Bring Outskirts mission landmarks to Suburbs asset parity
Replace procedural flyover/depot mission dressing with authored landmark layers.

### 11. Add UI surface hierarchy
Create compact HUD, standard panel, emphasized card and primary-action variants rather than one plate everywhere.

---

## P2 — Finish and cohesion

### 12. Upgrade Hub progression overlays
Turn key generator/storage/fabrication/fortification stages into more authored visual layers.

### 13. Material/rendering finish pilot
Raise a representative art set from clean vector to approved painterly/cel-shaded finish.

### 14. Add restrained screen transitions
Make the current flow feel continuous rather than instantly replaced.

### 15. Suburbs repetition/material breakup
More variation only after the higher-impact presentation work is accepted.

---

# Recommended implementation batches

## Batch A — Campaign presentation foundation
**IMPLEMENTED on `feat/visual-polish-a-campaign-foundation`.**

Implemented together:
1. shared safe-area/responsive portrait layout helper using the platform display safe area,
2. player-controlled final campaign Run Brief,
3. campaign Result/Debrief with objective/reward/progression hierarchy,
4. explicit development Encounter Proof vs campaign presentation split,
5. player-facing mission region/location/tactical metadata for all ten current missions.

Why first:
- affects every mission,
- fixes a direct documented UX violation,
- establishes responsive rules before more UI is changed.

## Batch B — Physical meta-screen composition
**IMPLEMENTED on `feat/visual-polish-b-meta-screens`.**

Implemented:
1. region-aware physical Command Board with explicit Outskirts → Suburbs route language,
2. vehicle-first Garage bay with a compact 2×2 platform selector and corrected four-platform fit,
3. workbench/pegboard-first Workshop with exposed weapon/module hardware,
4. shared display / section / metadata typography hierarchy,
5. primary/secondary action hierarchy using the existing production UI assets,
6. removal of duplicate fake route art behind the functional Command Board.

Why second:
- these three screens are the largest remaining source of “menu over art” presentation.

## Batch C — Battle presentation parity
**IMPLEMENTED on `feat/visual-polish-c-battle-parity`.**

Implemented:
1. six authored Outskirts mission landmark overlays, giving all ten current missions mission-aware production composition,
2. compact HUD surface family for status/weapon/aim data plus a distinct tactical inspect surface,
3. player/enemy status plates and stronger battle typography/action hierarchy,
4. safe-area layout integration for the new HUD surfaces,
5. campaign/proof result-action hierarchy and victory/defeat emphasis,
6. static ten-mission landmark/objective coverage validation (local phone-scale Play validation still required).

## Batch D — Reference-level rendering finish
Run one representative high-fidelity art pilot before batch-upgrading the asset library.

Only after Batch D is approved should the production pipeline scale that rendering finish broadly.

---

# What should NOT happen next

Do not:
- start Highways,
- create another platform tier,
- add another weapon catalog,
- add speculative currencies,
- redesign the locked theme,
- replace the current battle-control architecture,
- re-open portrait orientation,
- bake UI text into art,
- trade gameplay readability for foreground density.

The current game already has enough content to expose its visual-system weaknesses.

Fix the current product first.

---

# Definition of audit closure

This audit is complete when:

- findings are accepted as the next visual-production priorities,
- the implementation roadmap records the current-content polish gate,
- AI workflow docs point future sessions to this audit,
- implementation begins on a fresh remediation batch from this branch or a follow-up branch as directed by the project owner.

The next recommended implementation target is **Batch A — Campaign presentation foundation**.
