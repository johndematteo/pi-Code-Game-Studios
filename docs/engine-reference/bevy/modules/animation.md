# Bevy Animation — Quick Reference

Last verified: 2026-11-13 (`[features]` in `bevy` 0.20.1's `Cargo.toml`) | Engine: Bevy 0.20.1

## What Changed Since ~0.16 (LLM Cutoff)

- **`bevy_animation` is a `common_api` member**, so it is available with the
  normal collections rather than as a separate opt-in flag.
- **glTF animation** comes through `bevy_gltf`'s `gltf_animation` feature, which is
  inside `3d_bevy_render`. A 2D project does not get it.
- **`bevy_tweening`** is the community tweening crate for procedural animation; it
  is not in the engine. See `../PLUGINS.md`.

## Current API Patterns

- Skeletal/glTF animation is **asset-driven**: an animation clip is loaded with the
  glTF, and playback is a player component on the animated entity.
- **Procedural motion belongs in systems**, not in an animation clip: a
  `FixedUpdate` or `Update` system that mutates a transform component.
- **Animation state machines are the game's own.** Bevy provides clip playback;
  transitions, blending policy and interruption are code you write (or a crate's).

## Gotchas

| Pattern | Problem |
|---------|---------|
| Expecting glTF animation in a 2D-only project | `gltf_animation` is inside `3d_bevy_render` |
| Driving animation from wall-clock time in `Update` | Frame-rate dependent; use a fixed step for simulation-driven motion |
| Assuming a tween crate is in the engine | It is a separate dependency |
| One system per animated entity | Loses parallelism; query the entities instead |

## Where to Verify

`docs.rs/bevy_animation/<version>` and the `bevyengine/bevy` examples tree
(`animation/`, `gltf/`) at the project's version.
