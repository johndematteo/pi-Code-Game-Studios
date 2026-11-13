# Bevy Testing — Quick Reference

Last verified: 2026-11-13 (against `bevy_app` 0.20.1 source: `App::update`, `ScheduleRunnerPlugin`, `RunSystemOnce`) | Engine: Bevy 0.20.1

Bevy ships no test harness. The supported primitives are the engine's own app
stepping, and they are enough. This page is the recipe `studio/scripts/test-scaffold.sh bevy`
writes into a project's `tests/README.md`.

## What Changed Since ~0.16 (LLM Cutoff)

- `App::update()` exists and is the headless step. It **panics** if called while a
  plugin is building: "App::update() was called while a plugin was building."
- `MinimalPlugins` is the window-free plugin set (task pool, frame count, time,
  schedule runner).
- `ScheduleRunnerPlugin::run_once()` and `::run_loop(Duration)` run a schedule
  with no window.
- `RunSystemOnce` (`World::run_system_once`, `run_system_once_with`) tests one
  system against a `World`.
- `bevy_dev_tools::ci_testing` (feature `bevy_ci_testing`) is upstream's own
  scripted-run and screenshot mechanism.

## The Headless Recipe

A test that needs no GPU builds an app from `MinimalPlugins` and steps it:

```rust
use bevy::prelude::*;

#[test]
fn app_steps_once_headless() {
    let mut app = App::new();
    app.add_plugins(MinimalPlugins);
    app.update();          // one step of every schedule; no window, no renderer
}

#[test]
fn damage_system_applies_once() {
    use bevy::ecs::system::RunSystemOnce;
    let mut world = World::new();
    world.insert_resource(Health { value: 10 });
    world.run_system_once(apply_damage);
    assert_eq!(world.resource::<Health>().value, 9);
}
```

Build the app through the game's own plugin (`GamePlugin`) rather than
re-declaring systems in the test, so the test exercises the shipped
configuration.

## Commands

```bash
cargo test                                                # every target
cargo test --test combat                                  # one integration target
cargo test --no-default-features --features default_app    # headless
```

`default_app` is the documented baseline for apps that need no rendering, so the
headless form needs no GPU. For the headless form to work on a game crate, that
crate must forward the feature:

```toml
[features]
default = ["bevy/2d", "bevy/3d", "bevy/ui", "bevy/audio"]
default_app = ["bevy/default_app"]
```

A bare `--no-default-features` without `default_app` drops the app framework
itself and usually fails to build.

## Reading the Result

| Exit | Meaning |
|------|---------|
| 0 | Every test passed. |
| 101 | A test failed **or** the crate did not compile. `cargo check --tests` first separates them — that is what `studio/scripts/test-run.sh bevy` does. |
| 126 / 127 | `cargo` did not start. |

`cargo test` prints one `test result:` line **per test target** (the crate's
unittests, then each `tests/*.rs`). A run with zero tests prints
`test result: ok. 0 passed; 0 failed; …`, which is **not** a pass.

## Where Tests Live

- Unit tests: `#[cfg(test)] mod tests` in the module they cover, under `src/`.
- Integration tests: `tests/<system>.rs` — one file per target.
- **A folder under `tests/` is not a target.** `tests/unit/rules.rs` is never
  compiled; cargo reads `tests/*.rs`, plus `tests/<dir>/main.rs`.

## Render Tests

A test that builds a real renderer needs a wgpu adapter. On a machine without a
GPU:

- prefer `MinimalPlugins` for logic tests, which never touch the renderer;
- gate render tests behind a feature and exclude it from CI;
- or give CI a software adapter (`mesa-vulkan-drivers` provides lavapipe).

CI for a Bevy crate on Linux also needs `libasound2-dev` and `libudev-dev`, or the
build stops before any test compiles. `test-scaffold.sh bevy` writes that workflow.

## What Not to Do

| Pattern | Problem |
|---------|---------|
| Asserting on an `AssetServer` load immediately | Loading is asynchronous; step the app first |
| Sleeping to wait for a system | Step the schedule instead |
| Testing systems through `DefaultPlugins` | Pulls in the renderer; use `MinimalPlugins` |
| One test file with `#[tokio::test]` | Bevy has its own async executor; `#[test]` + `app.update()` is the supported form |
