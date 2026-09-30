# Save Architecture

## Scope

Persistence begins in **Milestone 2 — Progression Shell**.

The current save layer is intentionally local, single-player, and small. It does not require accounts, cloud services, backend infrastructure, or an autoload/global singleton.

`SaveService` is owned by the root `App` scene and writes to:

`user://fort_knocks_save.json`

## Schema version

Current schema:

`save_version = 1`

Version ownership belongs entirely to `SaveService`. Gameplay and UI code consume normalized snapshots and must not reinterpret old save formats themselves.

Current v1 shape:

```json
{
  "save_version": 1,
  "campaign": {
    "completed_missions": [],
    "unlocked_missions": ["roadblock_trial"]
  },
  "inventory": {
    "salvage": 0,
    "platform_id": "run_down_compact"
  },
  "crew": {},
  "settings": {}
}
```

`crew` and `settings` are reserved top-level sections so future additions do not require unrelated gameplay systems to rewrite the root shape. They should remain empty until real features need them.

## Campaign rules

- `roadblock_trial` is the default unlocked route.
- A mission awards its configured Salvage only on its **first successful clear**.
- First clear records the mission ID in `completed_missions`.
- First clear also adds the mission's `next_mission_id` to `unlocked_missions` when one exists.
- Cleared missions remain replayable.
- Replays award no additional Salvage in the foundation implementation.
- Defeat awards no Salvage and does not unlock progression.

These rules exist to prove campaign progression without introducing a grind/farming economy before upgrade costs are designed.

## Inventory foundation

The only live progression inventory values are:

- `salvage` — the single general progression resource.
- `platform_id` — currently `run_down_compact`.

Garage purchase/equip behavior is not implemented yet. The field exists because the first three combat-platform families are the next meaningful progression step.

## App ownership

`App` owns high-level flow:

```text
Fort Knocks Hub
→ Command Board
→ Battle
→ Battle result
→ SaveService progression update
→ Fort Knocks Hub
```

Battle reports a structured outcome. It does **not** write save files or directly mutate campaign progression.

`SaveService` does **not** decide combat outcomes or screen navigation.

## Migration policy

Future save versions must migrate inside `SaveService`.

Rules:
- increment `save_version` when the persisted meaning/shape changes,
- add explicit migration code before shipping a new schema,
- normalize missing/invalid optional fields defensively,
- do not silently let gameplay systems reinterpret stale data,
- unsupported/corrupt prototype saves may fall back to a fresh save while the product is pre-release, but this policy must be revisited before public release.
