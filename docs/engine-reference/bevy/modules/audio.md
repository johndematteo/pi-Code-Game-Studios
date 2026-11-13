# Bevy Audio — Quick Reference

Last verified: 2026-11-13 (`[features]` in `bevy` 0.20.1's `Cargo.toml`) | Engine: Bevy 0.20.1

## What Changed Since ~0.16 (LLM Cutoff)

- **Format support is a feature decision.** `audio` enables `bevy_audio` plus
  `vorbis` only. `audio-all-formats` adds `aac`, `flac`, `mp3`, `mp4` and `wav`. A
  project that plays an `.ogg` needs `audio`; one that plays a `.wav` needs
  `audio-all-formats` or `wav` explicitly. A model that assumes "audio just works"
  writes code that panics on a load error.
- **`bevy_kira_audio`** is the higher-level alternative crate. The in-engine
  `bevy_audio` is the default; picking one is a project decision.
- On Linux the build links ALSA: `libasound2-dev` must be installed or nothing
  compiles. `studio/scripts/test-scaffold.sh bevy` writes that into CI.

## Current API Patterns

- Audio is an **asset** loaded through `AssetServer` (path relative to `assets/`),
  played by spawning an entity with an audio component.
- **Spatial audio** is a component configuration on that entity, not a separate
  system.
- Volume/mixing is a resource-level setting; a per-frame volume write is a bug.

## Gotchas

| Pattern | Problem |
|---------|---------|
| Loading a `.wav` with only `audio` enabled | Unsupported format at load |
| Assuming `mp3` works | `mp3` is in `audio-all-formats`, not `audio` |
| Building on Linux without ALSA headers | Build stops before any test compiles |
| Playing audio in a headless test | No audio device; the test may fail for a reason that is not the game's |
| Hand-rolling a music crossfade | `bevy_kira_audio` has it |

## Where to Verify

`docs.rs/bevy_audio/<version>`, and the `[features]` table in `bevy`'s
`Cargo.toml` for the format flags at the project's version.
