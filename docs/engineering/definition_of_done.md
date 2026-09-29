# Definition of Done

A task is not done merely because code was written.

## Required
- Requested behavior is implemented and scoped to the task.
- Godot project files/resources have no broken references introduced by the change.
- GDScript parses without new errors.
- Existing tests/checks pass; new logic has focused tests where practical.
- Mobile/portrait behavior was considered for gameplay/UI work.
- No avoidable manual editor configuration is required after pulling the branch.
- No unrelated refactor or speculative feature was bundled in.
- Documentation matches any new durable architecture or gameplay rule.

## For visual/gameplay changes
Also provide a reproducible way to observe the change and verify:
- portrait framing,
- touch interaction where relevant,
- readable feedback,
- stable camera behavior,
- acceptable performance.

## For data/content additions
- IDs/names are consistent.
- Files live in the canonical area.
- Source/provenance is recorded when production assets are introduced.
- Placeholder content is clearly identified.

## Before PR
Review `git diff`/changed files and actively remove accidental generated files, editor caches, dead code, and duplicate assets.
