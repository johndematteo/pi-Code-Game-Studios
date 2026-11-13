# Bevy — Current Best Practices

Last verified: 2026-11-13 (crate source `bevy_app`/`bevy_ecs`/`bevy_asset` 0.20.1; `[features]` in `Cargo.toml`) | Engine: Bevy 0.20.1

Only practices that differ from what a pre-2025 model writes by default are here.

## Project Shape

A Bevy game is one cargo binary crate: `Cargo.toml`, `src/main.rs`, `assets/`,
`tests/`. There is no editor and no project file. `assets/` is the `AssetServer`
root (`AssetPlugin::DEFAULT_UNPROCESSED_FILE_PATH = "assets"`); the processed
cache is `imported_assets/Default` and is build output, not source.

```
Cargo.toml            # pin the crate exactly; commit Cargo.lock
rust-toolchain.toml   # optional, but pin it if you pin anything
src/main.rs           # App::new(), plugin group, systems
assets/               # AssetServer root; the asset processor writes .meta here
tests/                # cargo integration targets: tests/<name>.rs
```

- **Pin the crate exactly** (`bevy = "=0.20.1"`), and commit `Cargo.lock` for a
  binary crate. Bevy publishes breaking changes roughly every release, so a
  caret range silently moves the API under the project.
- **Do not put a test in a folder under `tests/`.** Cargo compiles `tests/*.rs`
  (plus `tests/<dir>/main.rs`); `tests/unit/rules.rs` never runs. Unit tests go in
  `#[cfg(test)]` modules beside the code; integration tests are `tests/<system>.rs`.

## App and Plugins

- Build the app from a plugin, not from `main()`: `app.add_plugins(GamePlugin)`,
  with `GamePlugin` registering schedules, resources and systems. `main()` stays
  three lines so tests can build the same app.
- A plugin group can be edited with `PluginGroupBuilder` (`set`, `disable`,
  `add_before`). Removing `WindowPlugin`/`RenderPlugin` is how a headless app is
  built.
- **Never call `App::update()` while a plugin is building.** It panics
  ("App::update() was called while a plugin was building"). Finish plugin setup
  first, then step.
- `dev` (`bevy_dev_tools`, `file_watcher`) is for development only; upstream says
  it "should not be enabled for published apps!".

## Schedules and Ordering

The schedule names are `PreStartup`, `Startup`, `PostStartup`, `First`,
`PreUpdate`, `FixedPreUpdate`, `FixedUpdate`, `FixedPostUpdate`, `Update`,
`PostUpdate`, `Last`, plus `Main` and `FixedMain`.

- **Declare ordering.** Systems in one schedule have no deterministic order.
  Use `.chain()`, `.before()`, `.after()` or `.in_set()`; an undeclared order is
  a bug that appears on a different machine.
- **`FixedUpdate` for simulation, `Update` for input and presentation.** A fixed
  step carries physics and deterministic gameplay; reading input in `FixedUpdate`
  loses or duplicates input events across ticks.
- **`Res`/`ResMut` conflicts panic at runtime.** Two systems that both take
  `ResMut<T>` in the same schedule cannot run concurrently; Bevy reports a
  documented error code rather than failing to compile. Reach for
  `Local<T>`, `ParamSet`, or split the resource.

## ECS Patterns

- **Change detection is frame-relative.** `Changed<T>` / `Added<T>` describe what
  changed since the last run of *that* system, not since a wall-clock time. A
  system added late sees everything as changed.
- **A component is a type; a resource is a singleton.** Prefer components plus
  queries over a resource that holds a collection of game entities.
- **Observers react to entity events (`On<T>`); messages are buffered
  (`MessageReader`/`MessageWriter`).** These are different mechanisms on 0.20 —
  see `breaking-changes.md`.
- **Relationships are components** (`ChildOf` and the relationship API), not a
  side table.

## Assets

- Load through `AssetServer` with a path relative to `assets/`; keep the handle in
  a component or resource rather than reloading each frame.
- Asset loading is asynchronous. A system that needs the asset takes
  `Res<Assets<T>>` and checks the handle, or uses an asset event.
- `.meta` files are written by the asset processor. Do not hand-edit them, and do
  not count them as assets.

## Compile Time

Bevy is a large crate graph. Two documented levers:

- `dynamic_linking` ("Force dynamic linking, which improves iterative compile
  times") for development builds only.
- A fast linker in `.cargo/config.toml` (lld on Linux/Windows, mold) and
  `[profile.dev.package."*"] opt-level = 3`, as Bevy's "Fast Compiles" setup page
  describes.

Neither changes behaviour, so neither belongs in a correctness argument.

## Testing

See `modules/testing.md`. In short: `App::update()` steps once, `MinimalPlugins`
gives a window-free app, `ScheduleRunnerPlugin::run_once()` runs a schedule with
no loop, and `RunSystemOnce` (`World::run_system_once`) tests one system against a
`World`. Render tests need a real wgpu adapter; the headless feature set is
`default_app`.

## Platform Reality

Native desktop (Windows, macOS, Linux) is Bevy's strongest target. Web/WASM
builds and runs, with caveats: single-threaded, no `dynamic_linking`, a
`wasm-bindgen` toolchain, and large asset payloads. Mobile support exists upstream
(`examples/mobile`) but is not the primary target. The CCGS `Bevy` engine row is
therefore native-desktop only (`cargo run`/`build`/`test`); a WASM build is the
project's own concern.
