# Bevy Networking — Quick Reference

Last verified: 2026-11-13 | Engine: Bevy 0.20.1

Bevy has **no networking in the core crate**. Networking is a community crate, and
which one a project uses is a project decision recorded in its `Cargo.toml`. See
`../PLUGINS.md`.

## What Changed Since ~0.16 (LLM Cutoff)

- **`lightyear` is the de-facto networking crate** for Bevy. A model trained before
  2025 may reach for `bevy_networking_turbulence` (an older, different crate) or
  assume networking is in the engine.
- **`multi_threaded` is in `default_platform`** on native, but is not available on
  WASM. A web build of a Bevy game is single-threaded, which changes what a
  networking crate can do there.
- Bevy's own **`bevy_app` sub-app support** (a separate `App` with its own
  schedules) is the supported way to run a network client or server beside the game
  loop without sharing its schedules.

## Current API Patterns

- **Transport is separate from replication.** A crate provides the transport and
  the message types; what to replicate and how often is the game's design.
- **A server runs in a sub-app or a separate process**, not in the game's `Update`
  schedule.
- **Messages, not events, cross the boundary.** On 0.20 buffered events are
  `Message` types (see `ecs.md`), and a network crate's own types are its own.

## Gotchas

| Pattern | Problem |
|---------|---------|
| Assuming networking is in the engine | It is not |
| Naming `bevy_networking_turbulence` | It is a different, older crate |
| A web/WASM build expecting multithreading | `multi_threaded` is native-only |
| Replicating per frame | Bandwidth; tick the replication rate |
| One `Cargo.toml` mixing two networking crates | Duplicate transport, conflicting schedules |
| Testing networking without a local server | The crate's own test harness is the supported path |

## Where to Verify

`docs.rs/lightyear` at the version matching the project's Bevy release, and the
crate's `Cargo.toml` for the Bevy version it targets. This page records only what
holds across implementations.
