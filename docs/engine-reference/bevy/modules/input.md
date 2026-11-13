# Bevy Input — Quick Reference

Last verified: 2026-11-13 | Engine: Bevy 0.20.1

## What Changed Since ~0.16 (LLM Cutoff)

- **`bevy_gilrs` and `bevy_clipboard` are inside `default_platform`**, which every
  `2d`/`3d`/`ui` collection pulls. Gamepad support is therefore present by default
  in a normal desktop build — do not add `bevy_gilrs` by hand beside `default_platform`.
- **Picking is its own feature** (`picking`: `bevy_picking`, `mesh_picking`,
  `sprite_picking`, `ui_picking`), and it is pulled by `2d`, `3d` and `ui`.
- **Action mapping is not in the engine.** `leafwing-input-manager` is the
  de-facto crate; see `../PLUGINS.md`.

## Current API Patterns

- Keyboard, mouse, gamepad and touch arrive as **resources and messages** in
  `PreUpdate`/`Update`. Reading them in `FixedUpdate` loses or duplicates input
  across ticks.
- **A raw input read is not an action.** `ButtonInput<KeyCode>` answers "is this key
  down now"; a game needs "was jump pressed" with rebinding, dead zones and
  buffering. That is what an action-mapping crate provides.
- **Picking** gives you pointer hits as events on entities; it is the supported
  path for "what did the mouse click", not a manual raycast per frame.

## Gotchas

| Pattern | Problem |
|---------|---------|
| Reading input in `FixedUpdate` | Lost/duplicated input |
| `just_pressed` used across two systems | Both see the same press; one action fires twice |
| Hand-rolled action mapping | Rebindings, dead zones and buffering are the crate's job |
| A manual raycast per frame for UI clicks | `picking` already does it |
| Assuming gamepad support must be added | It is in `default_platform` |
| Assuming a gamepad exists | No gamepad means no events; test with none attached |

## Where to Verify

`docs.rs/bevy_input/<version>` and `docs.rs/bevy_picking/<version>`. For the
action-mapping crate, `docs.rs/leafwing-input-manager` at the version compatible
with the project's Bevy release.
