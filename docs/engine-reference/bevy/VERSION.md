# Bevy — Version Reference

Last verified: 2026-11-13 (crate source for `bevy` 0.20.1 and crates.io release dates) | Engine: Bevy 0.20.1

`engine.name: Bevy` is a Rust game engine: one cargo crate, one binary, ECS
first. This file records the version these pages were written against. The
project's own version is read from its `Cargo.toml` / `Cargo.lock`, never from a
setting — see "Installed-Version Gap Warning".

| Field | Value |
|-------|-------|
| **Engine Version** | Bevy 0.20.1 |
| **Rust (MSRV)** | 1.97.1 — `rust-version` in `bevy` 0.20.1's own `Cargo.toml`. Bevy's README says the MSRV "is generally close to the latest stable release of Rust", so it moves every release. |
| **Edition** | 2024 |
| **Installed at pin time** | NOT DETERMINED — `/setup-engine` §3 reads the `bevy` version from the project's `Cargo.toml` and `Cargo.lock` and records it here. |
| **Release Date** | 0.20.0 on 2026-10-08; 0.20.1 on 2026-10-28 |
| **Project Pinned** | 2026-11-13 |
| **Last Docs Verified** | 2026-11-13 — crate source for `bevy` 0.20.1 (`bevy_app`, `bevy_ecs`, `bevy_asset`) and crates.io release dates |
| **LLM Knowledge Cutoff** | May 2025 |

## Knowledge Gap Warning

May 2025 is a floor for every model the studio runs on: a newer model may know more, but check this folder first.

**HIGH RISK.** A model whose training data ends in May 2025 saw Bevy at about
0.16 (released 2025-04-24). Everything from 0.17 onward is post-cutoff, and Bevy
is not a 1.0 engine: it ships breaking API changes roughly every release, with a
per-release migration guide and no semver stability promise. Bevy's own README
says it plainly: *"Bevy is still in the early stages of development… Documentation
is sparse. A new version of Bevy containing breaking changes to the API is
released approximately once every 3 months. We provide migration guides, but we
can't guarantee migrations will always be easy."*

## Mandatory Source-Read Policy

Treat any Bevy API an agent remembers as **untrusted**. Before writing Bevy code:

1. Read the page for the subsystem in `modules/` here.
2. Check `deprecated-apis.md` for the rename or removal that applies.
3. Check `breaking-changes.md` for the release the project is on.
4. When the answer is not in these files, read the primary source: `docs.rs/bevy`
   for the project's exact version, the `bevyengine/bevy` examples tree, and the
   release's migration guide at `https://bevy.org/learn/migration-guides/`.

An agent that cites Bevy API from memory without step 1 is the single largest
source of wrong code on a Bevy project.

## Installed-Version Gap Warning

This folder is a pin, not the project's version. `/setup-engine bevy` is
instruct-only: it does not pin a toolchain and does not rewrite `Cargo.toml`. The
project's `Cargo.toml` / `Cargo.lock` is the truth. **Read it before trusting a
version-qualified claim here** — `NOT DETERMINED` in `Installed at pin time`
means the gap is unknown, not absent. A project on 0.18 needs 0.18 code, whatever
these pages were written against.

`studio/scripts/project-coherence.sh` reports the `bevy` version it finds in
`Cargo.lock` (else `Cargo.toml`) beside `engine.version`, and calls MSRV drift a
warning rather than a failure.

## Post-Cutoff Version Timeline

| Version | Release | Risk Level | Key Theme |
|---------|---------|------------|-----------|
| 0.17 | 2025-09-30 | HIGH | Post-cutoff; API churn |
| 0.18 | 2026-01-13 | HIGH | Post-cutoff; API churn |
| 0.19 | 2026-06-19 | HIGH | Post-cutoff; API churn |
| 0.20 | 2026-10-08 | HIGH | Buffered events renamed to messages (`Message`, `MessageWriter`, `MessageReader`); `Event` now means entity events; `Trigger` → `On`; `Parent` → `ChildOf`; feature collections replace bare flags |
| 0.20.1 | 2026-10-28 | HIGH | Patch on 0.20 |

Before the cutoff: 0.16 (2025-04-24) came out just before the May 2025 floor and
may be thinly covered; 0.15 (2024-11-29) and earlier are in training data.

Dates are each release's first publish on crates.io, read 2026-11-13.

## Feature Collections (0.20)

0.20 replaced bare feature flags with **collections** that forward to the crates
that implement them. This is the part of 0.20 most likely to be wrong from
memory:

| Feature | What it enables |
|---------|-----------------|
| `default` | `2d`, `3d`, `ui`, `audio` |
| `default_app` | `async_executor`, `bevy_asset`, `bevy_log`, `bevy_state`, `reflect_auto_register` — the documented baseline for "headless apps that require no rendering (ex: command line tools, servers)" |
| `default_platform` | `std`, `bevy_gilrs`, `bevy_winit`, `bevy_clipboard`, `default_font`, `multi_threaded`, `webgl2`, `x11`, `wayland`, `custom_cursor`, `sysinfo_plugin` |
| `2d` / `3d` / `ui` | Each builds on `default_app` + `default_platform` and adds its renderer (`2d_bevy_render`, `3d_bevy_render`, `ui_bevy_render`) plus `scene` and `picking` |
| `audio` | `bevy_audio`, `vorbis`; `audio-all-formats` adds `aac`, `flac`, `mp3`, `mp4`, `wav` |
| `common_api` | `bevy_animation`, `bevy_camera`, `bevy_color`, `bevy_curve`, `bevy_gizmos`, `bevy_image`, `bevy_mesh`, `bevy_shader`, `bevy_material`, `bevy_text`, `bevy_window`, … |
| `dev` | `debug`, `bevy_dev_tools`, `render_dev_tools`, `file_watcher` — upstream notes it "should not be enabled for published apps!" |
| `picking` | `bevy_picking`, `mesh_picking`, `sprite_picking`, `ui_picking` |
| `scene` | `bevy_world_serialization`, `bevy_scene` |
| `dynamic_linking` | `dep:bevy_dylib` — improves iterative compile times in development |
| `hotpatching` | `bevy_internal/hotpatching` |

`no_std` is supported through `default_no_std`. A bare
`--no-default-features` without `default_app` is usually a mistake: it drops the
app framework itself.

Sources: `[features]` in `bevy` 0.20.1's `Cargo.toml`; the crate's `README.md`
for the cadence and the MSRV statement.
