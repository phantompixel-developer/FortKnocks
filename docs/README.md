# Fort Knocks Documentation Index

This directory is the durable source of truth for product, design, architecture, engineering, and originality decisions.

Chat history and model memory are useful context, but exact rules that affect implementation must live here.

## Reading order for AI sessions

1. `AGENTS.md`
2. `docs/project_context.md`
3. The task-relevant design document
4. `docs/architecture/architecture.md`
5. The task-relevant architecture document
6. `docs/design/implementation_roadmap.md`
7. `docs/engineering/definition_of_done.md`
8. `docs/legal/originality_rules.md` when content, naming, assets, or references are involved

## Canonical ownership

- **Project identity / locked decisions / current milestone:** `project_context.md`
- **Overall game design:** `design/game_design.md`
- **Combat rules and current prototype mechanics:** `design/combat_design.md`
- **Portrait interaction and HUD:** `design/portrait_ux.md`
- **Progression / hub / campaign growth:** `design/progression.md`
- **Art direction / visual production pipeline:** `design/art_direction.md`
- **Audio / music direction:** `design/audio_direction.md`
- **Implementation sequence and milestone gates:** `design/implementation_roadmap.md`
- **Application/battle architecture:** `architecture/architecture.md`
- **Camera:** `architecture/camera_architecture.md`
- **Combat platforms:** `architecture/combat_platform.md`
- **Save format / persistence ownership:** `architecture/save_architecture.md`
- **AI development workflow:** `engineering/ai_workflow.md`
- **Task completion requirements:** `engineering/definition_of_done.md`
- **Originality and provenance:** `legal/originality_rules.md`

## Conflict rule

If a chat, old prompt, comment, or historical branch conflicts with the canonical documents on `main`, the canonical documents win unless the user explicitly makes a newer decision.

When a newer durable decision is made:
1. implement it if it belongs to the current task,
2. update the owning canonical document in the same branch,
3. avoid leaving contradictory legacy wording elsewhere.

## Locked vs provisional

Documents should distinguish:
- **Locked / agreed direction** — future work should follow it unless explicitly changed.
- **Current implementation** — what exists in the repository today.
- **Provisional / working** — useful direction that is not yet a permanent content commitment.

Do not silently promote provisional names, balance values, faction concepts, or content counts into permanent canon.

## Locked visual direction

For any presentation, UI, environment, character, combat-platform or art task, read:
- `docs/design/visual_reference.md` — authoritative visual target and change-control rules.
- `docs/design/reference/fort_knocks_primary_visual_reference.svg` — locked concept-board reference.
- `docs/design/visual_production_pass_2.md` — current implementation sequence.

These references control visual direction but do not override canonical gameplay/system scope.
