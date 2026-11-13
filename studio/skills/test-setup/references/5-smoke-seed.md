# /test-setup — Phase 5: Create Smoke Test Seed

> Part of `/test-setup`. `SKILL.md` names when to read this file; the settings it
> resolved and the rules under its later headings still apply here.

## Phase 5: Create Smoke Test Seed

Create `tests/smoke/critical-paths.md`:

```markdown
# Smoke Test: Critical Paths

**Purpose**: Run these 10-15 checks in under 15 minutes before any QA hand-off.
**Run via**: `/smoke-check` (which reads this file)
**Update**: Add new entries when new core systems are implemented.

## Core Stability (always run)

1. Game launches to main menu without crash
2. New game / session can be started from the main menu
3. Main menu responds to all inputs without freezing

## Core Mechanic (update per sprint)

<!-- Add the primary mechanic for each sprint here as it is implemented -->
<!-- Example: "Player can move, jump, and the camera follows correctly" -->
4. [Primary mechanic — update when first core system is implemented]

## Data Integrity

5. Save game completes without error (once save system is implemented)
6. Load game restores correct state (once load system is implemented)

## Performance

7. No visible frame rate drops on target hardware (60fps target)
8. No memory growth over 5 minutes of play (once core loop is implemented)
```

---

The list is engine-agnostic — it is prose `/smoke-check` reads, and no command in
it changes per engine. Two engine notes:

- **Bevy** has no equivalent of Godot's `--quit-after`, so there is no default
  `commands.smoke` to point at. Check 1 ("game launches to main menu without
  crash") is the `cargo run` check on Bevy: say so in the list, and if the project
  wired `bevy_dev_tools`' `ci_testing`, name the command it exposes here.
- **Bevy's `commands.test`** is `cargo test`; `/smoke-check` runs it through
  `studio/scripts/test-run.sh bevy`, which compiles the crate first. Nothing in
  this file changes for that — it is `/smoke-check` Phase 2's business.

---
