# AI-First Development Workflow

## Goal
Codex/Claude should be able to understand, implement, validate, and review work with minimal editor-only intervention.

## Task sequence
1. Start from current `main`.
2. Create a narrowly named branch.
3. Read `AGENTS.md`, `docs/README.md`, and `docs/project_context.md`.
4. Read the task-relevant canonical design/architecture documents.
5. For any visual/UI/environment/platform/presentation task, read `docs/design/visual_reference.md` and the active visual production plan before changing presentation.
6. Check `docs/design/implementation_roadmap.md` before expanding scope.
7. Inspect existing implementation before proposing new architecture.
8. Implement the smallest coherent milestone-sized task.
8. Run available headless validation/tests.
9. Review the diff for accidental scope growth.
10. Update canonical documentation when durable rules changed.
11. Open a PR with summary, validation evidence, and known limitations.

## Branch examples
- `feat/battle-prototype`
- `feat/portrait-camera`
- `fix/projectile-collision`
- `chore/headless-validation`
- `design/combat-rules`
- `docs/canonical-project-context`

## AI-friendly design rules
- Prefer text-based Godot scenes/resources where practical.
- Keep dependencies explicit and discoverable.
- Name systems by responsibility.
- Keep scripts focused.
- Put content values in Resources instead of scattering magic constants through code.
- Build repeatable scripts for checks/import/export rather than instructions such as "click this menu item before Play."
- Prefer changes that can be validated headlessly.
- Do not generate large batches of content before one representative implementation is approved.
- Do not reconstruct exact rules from memory when canonical docs already define them.

## Documentation discipline
When chat discussion produces a durable decision:
- identify the canonical owning document,
- update that document in the implementation branch,
- remove or revise contradictory old wording,
- mark concepts as provisional when they are not actually locked.

Use `docs/project_context.md` for cross-cutting project decisions, not as a dumping ground for every implementation detail.

## Commit/PR quality
A PR should answer:
- What user/game problem changed?
- What files/systems own the change?
- How was it validated?
- What is intentionally not included?
- Did any design/architecture contract change?
- Did the milestone status change?

## Local editor use
The desired developer loop is still **open project and press Play**. Tools may exist for diagnostics, but ordinary playtesting must not depend on a hidden refresh/import/setup ritual.
