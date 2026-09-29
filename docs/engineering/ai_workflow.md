# AI-First Development Workflow

## Goal
Codex/Claude should be able to understand, implement, validate, and review work with minimal editor-only intervention.

## Task sequence
1. Start from current `main`.
2. Create a narrowly named branch.
3. Read `AGENTS.md` and relevant canonical docs.
4. Inspect existing implementation before proposing new architecture.
5. Implement the smallest coherent task.
6. Run available headless validation/tests.
7. Review the diff for accidental scope growth.
8. Update documentation when durable rules changed.
9. Open a PR with summary, validation evidence, and known limitations.

## Branch examples
- `feat/battle-prototype`
- `feat/portrait-camera`
- `fix/projectile-collision`
- `chore/headless-validation`
- `design/combat-rules`

## AI-friendly design rules
- Prefer text-based Godot scenes/resources where practical.
- Keep dependencies explicit and discoverable.
- Name systems by responsibility.
- Keep scripts focused.
- Put content values in Resources instead of scattering magic constants through code.
- Build repeatable scripts for checks/import/export rather than instructions such as "click this menu item before Play."
- Prefer changes that can be validated headlessly.
- Do not generate large batches of content before one representative implementation is approved.

## Commit/PR quality
A PR should answer:
- What user/game problem changed?
- What files/systems own the change?
- How was it validated?
- What is intentionally not included?
- Did any design/architecture contract change?

## Local editor use
The desired developer loop is still "open project and press Play." Tools may exist for diagnostics, but ordinary playtesting must not depend on a hidden refresh/import/setup ritual.
