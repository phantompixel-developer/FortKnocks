# Roadblock Trial — Combat V2 implementation and playtest

**Status:** implemented on feature branch, awaiting real Godot/device acceptance. **Not merged.**  
**Core decision:** tactical artillery + environmental destruction within the existing salvage/survival campaign.

## What this branch changes

The authored centre concrete obstacle in **Roadblock Trial only** now:
- starts intact with 110 durability;
- receives existing weapon cover-damage values (Heavy Slug is especially useful);
- displays surface cracks after a hit;
- changes to a low-rubble silhouette with a new **220 × 32** collision shape centred **60 world pixels** below the original centre when breached;
- allows follow-up shots over the lowered obstruction while retaining a physical low blocker;
- can be influenced by the Shock Capsule pulse when it is in range;
- reports meaningful impact feedback and an environment event;
- surfaces the roadblock/cell state during enemy inspection;
- uses subtle road-contact art aligned to the actual level collision at y=1035.

**Other missions:** roadblock_breakable is false by default. The legacy solid obstruction remains unchanged outside this one mission.

**Deliberately unchanged:** single-player turn rules, the player staying on foot, approved vehicle/character assets, the approved art bible, pull-back/release-to-fire controls, weapon roster, the main mission order, objectives, rewards and save format.

## Layout and actual world coordinates (existing Roadblock Trial)

| Gameplay object | Centre (world pixels) | Tactical meaning |
| --- | --- | --- |
| Player | (300, 1040) | Shooter, beside their cover |
| Player vehicle/cover | (520, 1000) | Physical defensive platform |
| Concrete blocker | (1080, 958) | **Breakable** high obstruction; low rubble after breach |
| Enemy vehicle/cover | (1540, 1000) | Physical cover, can be destroyed |
| Power cell | (1715, 1028) | Existing authored radial hazard |
| Enemy survivor | (1860, 1040) | Standard mission victory target |
| Main ground | y=1035 | Physics ground surface, shared world plane |

This vertical slice intentionally **does not** introduce fake elevated platforms or a bridge collapse. A single physically consequential obstacle is the test before authoring further tactical structures.

## Intended player tactics

1. **Precision:** retain enough height to arc over the intact blocker and enemy cover, or bank Scrap Bolt from suitable road.
2. **Breach:** use Heavy Slug (or repeat hits) to break the blocker into low rubble, then exploit the changed line of fire.
3. **Hazard:** target the existing cell or trigger it with Shock pressure to injure/displace an enemy behind cover.

The specialist weapon must be equipped in the Workshop before the campaign encounter; do not expect Bolt, Slug and Shock all simultaneously unless a previously approved module supports it.

## Testing

### Lightweight Godot headless smoke test

From the repo root, with Godot 4.7.x installed:

```sh
godot --headless --path . --script res://tests/roadblock_v2_smoke.gd
```

The test checks damage transitions, one-time breach signal, debris collider placement, and solid/absent mission reset behavior. The test file is committed, but **has not been run in this connected environment**.

### Local visual / gameplay acceptance (required)

1. Check out `feat/combat-v2-roadblock-vertical-slice`, open the Godot project, press Play.
2. Select or launch **Roadblock Trial**. Confirm approved on-foot survivor and active vehicle, original weapon tray, pull-back angle/power preview, and familiar Inspect Enemy.
3. Use **Heavy Slug** (equip through Workshop for campaign, or choose from three weapons in Encounter Proof). Hit the centre concrete blocker until it breaches. Confirm cracks before breach, visible low rubble afterward and no invisible full-height collision.
4. Fire a follow-up low-to-mid shot through the newly exposed line. If rubble is hit, the collision should correspond to the visible low stones. No projectile should phase through a crew/cover or be blocked by invisible tall concrete.
5. Restart/rematch and confirm full-height blocker resets. Switch to **High Ground** or another mission with a roadblock and confirm it is still invulnerable if configured solid.
6. Inspect the enemy before/after breach and check the environment label; check the power-cell hazard, camera impact hold, enemy turn and results.
7. Confirm campaign victory still grants exactly the pre-existing first-clear Salvage reward, and replay reward logic has not changed.
8. Repeat on a 720×1280 viewport and an unusually tall/narrow phone shape. Examine HUD overlap and camera framing.

### Do not accept this branch if:

- GDScript parser/runtime errors occur;
- the high blocker still collides after being visually breached;
- a non-Roadblock mission unexpectedly gains destructible terrain;
- the game adds a separate mandatory FIRE button or changes the approved weapon set;
- a projectile passes through crew/cover at usual launch speed;
- the new obstacle does not produce a meaningful tactical opportunity when breached;
- the scene still feels visually disjointed during actual Godot play.

## Remaining limitations and next gate

This is a **first functional Combat V2 slice**, not a fully rebuilt battlefield:
- no fully deformable road surface or physics-fractured bridge;
- no new hero assets; uses existing source art and world-space integration;
- no runtime or phone visual acceptance from this connected environment;
- persistent projectile tunnelling concerns require a targeted, instrumented Godot repro if they remain after this pass;
- the surrounding backdrop still needs a separate review against actual screenshot evidence.

Only expand structural interactions or art after this slice is proven in Play mode.
