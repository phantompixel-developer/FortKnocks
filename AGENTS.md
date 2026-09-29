# Fort Knocks — AI Agent Instructions

This repository is an AI-first Godot 4.7.x mobile game project.

## Required reading before implementation
1. `docs/design/game_design.md`
2. The design document relevant to the task.
3. `docs/architecture/architecture.md`
4. The architecture document relevant to the task.
5. `docs/engineering/definition_of_done.md`

## Product constraints
- Portrait-first Android/iOS game.
- 2D gameplay. 2.5D is allowed only where it improves presentation without introducing unnecessary 3D gameplay complexity.
- GDScript is the default implementation language.
- Single-player campaign first.
- Core interaction: turn-based physics artillery, destructible cover, combat-platform progression.
- Theme: stylised post-collapse salvage warfare. No water/raft theme.
- The project must remain independently identifiable as Fort Knocks, not a recreation of another commercial game.

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

## Validation
Before declaring a task complete:
- Confirm the project parses/imports without errors.
- Run relevant headless checks/tests when available.
- Check for missing resources and broken scene references.
- For visual work, provide reproducible run steps and capture evidence where practical.
- Update documentation if architecture or game rules changed.

## Source/IP guardrail
Never copy source code, art, dialogue, characters, level layouts, UI, music, sound, names, or other expressive assets from Raft Wars or another game. Genre mechanics may inspire discussion, but implementation and presentation must be original. See `docs/legal/originality_rules.md`.
