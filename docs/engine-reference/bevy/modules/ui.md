# Bevy UI — Quick Reference

Last verified: 2026-11-13 (`[features]` in `bevy` 0.20.1's `Cargo.toml`) | Engine: Bevy 0.20.1

## What Changed Since ~0.16 (LLM Cutoff)

- **UI is split into `bevy_ui`, `bevy_ui_render` and `bevy_ui_widgets`,** pulled by
  the `ui` collection (`ui_api`, `ui_bevy_render`, `bevy_ui_widgets`, plus `scene`
  and `picking`).
- **`bevy_feathers`** is a themed widget kit. Upstream describes it as being for
  **editors and inspectors and deliberately not intended** for game UI. Reaching for
  it because it looks nicer is a design decision, not a default.
- **`bevy_egui`** (community) is the standard tool/debug UI crate; see
  `../PLUGINS.md`.

## Current API Patterns

- In-engine UI is **ECS**: UI nodes are entities with layout and style components,
  spawned in systems. There is no retained-mode widget tree object.
- **Layout is flexbox-like** through the UI layout components. A screen is a
  hierarchy of nodes, not a `.ui` file.
- **Picking drives UI input.** `ui_picking` (inside `picking`, which `ui` pulls)
  is the supported path for clicks on UI nodes.
- **Tool and debug UI** is `bevy_egui`. Shipping game UI on `bevy_egui` is a
  choice, not the engine's default.

## Gotchas

| Pattern | Problem |
|---------|---------|
| Reaching for `bevy_feathers` for game UI | It is intended for editors/inspectors |
| Assuming a markup file describes the UI | UI is built in code; there is no UI scene format to rely on |
| A UI node with no picking feature | Clicks do nothing |
| Assuming `bevy_ui` needs no renderer | `ui_bevy_render` needs `bevy_render`; a headless build has no UI |
| Hand-rolling a click raycast | `ui_picking` does it |
| Testing UI in a headless app | Layout exists, rendering does not; assert on components, not pixels |

## Where to Verify

`docs.rs/bevy_ui/<version>`, `docs.rs/bevy_ui_widgets/<version>`, and the
`bevyengine/bevy` `examples/ui/` tree at the project's version. The UI API is one
of the faster-moving areas of Bevy — check before writing a screen.
