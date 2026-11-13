# Bevy — Deprecated APIs

Last verified: 2026-11-13 (against `bevy` 0.20.1 crate source) | Engine: Bevy 0.20.1

If an agent suggests any API in the "Deprecated" column, it MUST be replaced with
the "Use Instead" column. Bevy removes APIs rather than warning on them for long,
so a row here is usually a **compile error**, not a deprecation warning.

## Events and Observers

| Deprecated | Use Instead | Since | Notes |
|------------|-------------|-------|-------|
| `Event` as a buffered event | `Message` | 0.20 | `Event` now means an entity event (observer payload). Deriving `Event` for a buffered event compiles but is not readable by a reader. |
| `EventWriter<T>` | `MessageWriter<T>` | 0.20 | Renamed with the buffered-event change. |
| `EventReader<T>` | `MessageReader<T>` | 0.20 | Renamed. |
| `Events<T>` | `Messages<T>` | 0.20 | Renamed. |
| `EventMutator<T>` | `MessageMutator<T>` | 0.20 | Renamed. |
| `Trigger<T>` | `On<T>` | 0.20 | The observer's system parameter. |
| `Parent` | `ChildOf` | 0.20 | Relationship component; `Parent` is no longer a component. |

## Assets

| Deprecated | Use Instead | Since | Notes |
|------------|-------------|-------|-------|
| Writing a path as an absolute or `res://`-style path | A path relative to the `AssetServer` root (`assets/`) | — | `AssetPlugin::DEFAULT_UNPROCESSED_FILE_PATH` is `assets`; the processed root is `imported_assets/Default`. A load path is relative to the first. |
| Hand-editing a `.meta` file | Let the asset processor write it | — | Bevy writes one `.meta` beside each asset. It is not an asset; an asset scan excludes it. |
| Loading in a test and asserting immediately | Step the app, then assert | — | Asset loading is asynchronous: a test needs `app.update()` (or a run loop) before the handle resolves. |

## Features

| Deprecated | Use Instead | Since | Notes |
|------------|-------------|-------|-------|
| A bare `--no-default-features` | `--no-default-features --features default_app` | 0.20 | Bare `--no-default-features` drops the app framework. `default_app` is the documented headless baseline. |
| Naming a removed bare flag (e.g. a renderer flag from an older `Cargo.toml`) | The collection that covers it (`2d`, `3d`, `ui`, `common_api`) | 0.20 | Flags were reorganised into collections. |
| Enabling `dev` in a release build | `dev` only in development | — | Upstream: "should not be enabled for published apps!" |

## App and Schedule

| Deprecated | Use Instead | Since | Notes |
|------------|-------------|-------|-------|
| Calling `App::update()` while plugins are still being built | `update()` after `finish()`/`run()` setup | 0.20 | It panics: "App::update() was called while a plugin was building." |
| Relying on system order without saying it | `.chain()`, `.before()`, `.after()`, `.in_set()` | — | Ordering is not deterministic unless declared. |
| `Update` for physics or fixed-step work | `FixedUpdate` | — | A variable-step schedule cannot carry fixed-step simulation. |

## Documentation Habits That Are Also Deprecated

| Habit | Do Instead | Why |
|-------|-----------|-----|
| Citing Bevy API from memory | Read `modules/` here, then `docs.rs/bevy/<version>` | Bevy is 0.x with breaking changes every release. |
| Copying an example from a blog post | Copy from the `bevyengine/bevy` examples tree at the project's version | Blog examples are usually one or more releases stale. |
| Assuming `bevy_rapier` for physics | Check `PLUGINS.md`; Avian is the ECS-native choice | Both are viable; naming one without checking the project's `Cargo.toml` is the error. |
