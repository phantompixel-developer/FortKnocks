# Fort Knocks — AI Agent Instructions

This repository is an AI-first Godot 4.7.x mobile game project.

## Required reading before implementation
1. `docs/README.md`
2. `docs/project_context.md`
3. `docs/design/game_design.md`
4. `docs/design/visual_reference.md` for any visual, UI, environment, character, platform or presentation work.
5. `docs/design/visual_production_pass_1.md` when implementing the current production-art migration.
6. The design document relevant to the task.
7. `docs/architecture/architecture.md`
8. The architecture document relevant to the task.
9. `docs/design/implementation_roadmap.md` when scope/sequencing is relevant.
10. `docs/engineering/definition_of_done.md`

For exact implementation rules, canonical repository documentation is more reliable than chat/model memory. If a durable decision changes, update the owning canonical document in the same branch.

## Product constraints
- Portrait-first Android/iOS game.
- 2D gameplay. 2.5D is allowed only where it improves presentation without introducing unnecessary 3D gameplay complexity.
- GDScript is the default implementation language.
- Single-player campaign first.
- Core interaction: turn-based physics artillery, destructible authored cover/environment, and combat-platform progression.
- Theme: stylised post-collapse salvage warfare. No water/raft theme.
- The project must remain independently identifiable as Fort Knocks, not a recreation of another commercial game.
- One primary general progression currency initially: Salvage.
- Ordinary developer loop should remain open project → Play.

## Engineering rules
- Never implement directly on `main`.
- Prefer small, reviewable branches and PRs.
- Read existing systems before adding new ones. Do not duplicate responsibilities.
- Prefer typed GDScript, composition, Resources, signals, and explicit dependencies.
- Do not create giant manager scripts or deep inheritance trees.
- Keep editor-only/manual setup to a minimum. Configuration should live in project files, scenes, resources, or scripts.
- Mobile performance and touch UX are requirements, not later polish.
- Do not add plugins, SDKs, backends, analytics, accounts, multiplayer, monetisation, or cloud services without explicit approval.
- Do not add speculative systems outside the requested milestone.
- Keep placeholder art clearly separated from production art.
- The locked primary visual reference is `docs/design/visual_reference.md`. Do not silently introduce a conflicting art style. Concept-board details are visual guidance only and must not create unapproved gameplay systems.
- Do not skip milestone gates in `docs/design/implementation_roadmap.md`.

## Validation
Before declaring a task complete:
- Confirm the project parses/imports without errors.
- Run relevant headless checks/tests when available.
- Check for missing resources and broken scene references.
- For visual work, provide reproducible run steps and capture evidence where practical.
- Update documentation if architecture or game rules changed.
- Review the final diff for accidental scope growth.

## Source/IP guardrail
Never copy source code, art, dialogue, characters, level layouts, UI, music, sound, names, or other expressive assets from Raft Wars or another game. Genre mechanics may inspire discussion, but implementation and presentation must be original. See `docs/legal/originality_rules.md`.
