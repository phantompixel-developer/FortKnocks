# Roadblock Trial — Battlefield V2 pilot

**Status:** Experimental, awaiting local Godot Play/device approval.
**Base:** `visual/battlefield-diorama-pilot`
**Working branch:** `visual/roadblock-trial-battlefield-v2`
**Scope:** `roadblock_trial` only. No other encounter, mission resource or campaign unlock changes.

## The problem

A handsome skyline behind transparent combat sprites is not a convincing encounter.
V1 separated world-space road from far panorama and added contact shading, which
improved composition but still left floating individual actors/vehicles and abrupt
portrait-camera travel. V2 treats two roadside fighting positions, one central
collidable checkpoint blocker, the exposed road and the same physical contact
surfaces as a single scene.

## V2 spatial contract

- Base road `Ground` collision top remains **y=1035**; its existing long road
  rebound surface is retained between/behind the positions.
- Two *actual* `ArenaPlatform` collision rectangles represent cracked raised
  road shoulders: **(342,1010,575,70)** and **(1203,1010,575,70)**.
  They use existing Outskirts material, not new invisible terrain. Projectiles
  encounter their top faces at y=1010.
- Pilot player vehicle center **(752,970)**, rival cover **(1368,970)**,
  central collidable blocker **(1060,958)**.
- Player and rival stand at **y=1010**, adjacent to the rendered outer edge of
  their respective vehicles. Their x coordinate is derived from
  `get_battle_art_half_width()`, including when the player equips a wider
  Sedan/Pickup/Technical. No launch-origin/weapon calculation is changed.
- The unstable power cell remains a live gameplay target at its authored mission
  position. Objective, HP, weapon behaviour, shot memory, bounce limits, enemy
  tactics, and progression rewards remain unchanged.
- The world-space road treatment paints irregular foundations, wheel tracks,
  broken road edges and a checkpoint apron at those *same world coordinates*.
  A near pass overlaps actual boots and wheels with gravel, cover-stage scrap
  and short-lived impact dust. Painted detail does not claim extra collision.
- The opening camera view follows the road continuously from the player
  fighting position via the central blocker to the rival fighting position.
  It uses modest **0.94x** zoom during travel and **1.08x** for Roadblock
  player/enemy close views; no squashing or misleading all-arena thumbnail.
  The transition occurs once at deployment; ordinary later turns use the
  existing shorter focused travel. Other missions retain the original **1.35x**
  zoom and camera behaviour.
- On a cover impact the adjacent survivor braces; this is visual only and does
  **not** damage or move them. Existing projectile, health and cover damage
  pathways remain authoritative.

The existing exported `Battle.enable_roadblock_diorama_pilot` toggle is the
A/B gate: **on** enables V2 presentation/layout for Roadblock Trial;
**off** restores its baseline mission positions and artwork. The parent
branch is an independent untouched V1 checkpoint.

## What this does NOT claim

This is not a full terrain-destructibility system and should not be sold as one.
The two shoulders are currently authored solid collision, while cover and
central obstruction already have their own behaviour. No physically simulated
vehicle attachment, suspension rig or brand-new character pose assets have
been authored. Those are potential *future art/animation* decisions only if
this geometry/camera pilot proves better in normal Play.

## Required local acceptance (before merge or wider rollout)

1. Press Play, select Roadblock Trial (or start it from the Command Board).
   The opening reveal should show one continuous location; no pop/snap,
   empty vertical bands, or loss of road-scale perspective.
2. Player/rival boots must be seated on the visible shoulders, wheels must not
   float or sink into the platform fronts, and the central barrier must share
   the same road surface. Check all currently equipped vehicle tiers.
3. Launch Bolt at the shoulder, base road, blocker and enemy cover. Confirm the
   bounce count/energy and hit classification follow the **visible geometry**.
   A low shot must not get trapped inside overlapping static collision shapes.
4. Hit the player's/rival's cover and defeat it. Confirm crew-brace,
   accumulating nearby scrap, remaining cover HP, eventual rubble and
   no phantom collision after destruction.
5. Confirm camera at briefing, player aim, Inspect Enemy, return, flight,
   ricochet, impact and turn handoff. Test a high-arc shot and a miss offscreen.
6. Test portrait 720x1280 and one tall mobile aspect ratio. Aim UI, enemy
   indicator, muzzle and trajectory must remain readable without the art
   occluding the drag region.
7. Disable pilot in Battle inspector and confirm baseline Roadblock plays.
   Launch High Ground, Scrap Gate and one Suburbs mission to verify other
   encounter positions, camera and interaction rules were not changed.
8. Check Godot debugger/import output, and repeat via a normal fresh open →
   Play flow without editor regeneration steps.

**Merge gate:** No Godot runtime or device execution was available to the
repository-editing assistant. This branch is an implemented, source-reviewed
pilot, **not** locally Play-approved. Record visual before/after captures and
resolve any geometry/camera defects before extending the new composition to
High Ground, Suburbs or further vehicles.
