# Bevy Rendering — Quick Reference

Last verified: 2026-11-13 (`[features]` in `bevy` 0.20.1's `Cargo.toml`) | Engine: Bevy 0.20.1

## What Changed Since ~0.16 (LLM Cutoff)

- **Feature collections replaced bare renderer flags.** `2d_bevy_render` and
  `3d_bevy_render` are collections: `2d_bevy_render` pulls `bevy_render`,
  `bevy_core_pipeline`, `bevy_post_process`, `bevy_sprite_render`,
  `bevy_gizmos_render`; `3d_bevy_render` pulls `bevy_render`,
  `bevy_core_pipeline`, `bevy_gizmos_render`, `bevy_anti_alias`, `bevy_gltf`,
  `bevy_pbr`, `bevy_post_process`, `gltf_animation`. `ui_bevy_render` pulls
  `bevy_render`, `bevy_core_pipeline`, `bevy_ui_render`.
- **`bevy_solari`** exists as an experimental raytraced-lighting crate. Do not
  assume it is on by default.
- **`bevy_feathers`** is the themed widget kit and is explicitly *not* for game UI.
- Renderer crates were split (`bevy_camera`, `bevy_image`, `bevy_mesh`,
  `bevy_shader`, `bevy_material` are separate `common_api` members), so a path
  that used to be `bevy::render::…` may now live in one of them.

## Current API Patterns

- **Add a renderer through the feature collection**, not by listing crates:
  `bevy = { version = "0.20.1", features = ["3d"] }`. A `Cargo.toml` that lists
  individual renderer crates is pre-0.20.
- **Cameras** are entities with `Camera3d`/`Camera2d` plus a projection
  component. A camera with no `RenderTarget` renders to the primary window.
- **Materials** are assets (`StandardMaterial` for PBR). A material handle lives in
  a component on the mesh entity.
- **Meshes** come from `bevy_mesh` primitives or glTF (`bevy_gltf` is inside
  `3d_bevy_render`).
- **Post-processing** is a `bevy_post_process` path; anti-aliasing is
  `bevy_anti_alias`. Both arrive with the collection — do not add them separately.

## Shaders

- Bevy shaders are **WGSL**, not GLSL or HLSL. A `.wgsl` file is loaded through
  the `Shader` asset; there is no shader-graph editor.
- Custom pipelines go through `RenderPipelineDescriptor` and the render-graph API,
  which is the least stable surface in Bevy. Treat a render-graph example from an
  older release as a rewrite, not a rename.
- `bevy_shader` is the crate that owns shader assets and the shader library.

## Performance Reality

- **Draw calls and material count are the lever.** Many distinct materials means
  many batches; instancing is explicit.
- **GPU work is not free of the frame budget.** A frame budget in
  `project.yaml` (`performance.frame_budget_ms`) is a target, not a measurement —
  measure with a profiler on the target hardware.
- **`bevy_dev_tools`** (`dev` feature) adds diagnostics; it is for development
  only and must not ship.

## Gotchas

| Pattern | Problem |
|---------|---------|
| `--no-default-features` with no collection | No renderer at all; a blank window or a panic |
| A camera with no projection | Nothing renders |
| Adding `bevy_pbr` by hand beside `3d` | Duplicate registration; use the collection |
| Assuming a shader from a blog post is WGSL | It may be GLSL from a pre-WGSL release |
| Testing rendering in CI with no adapter | wgpu finds no adapter; see `testing.md` |
| Assuming `bevy_solari` is production-ready | It is experimental |

## Where to Verify

`docs.rs/bevy_render/<version>`, `docs.rs/bevy_pbr/<version>`, and the
`bevyengine/bevy` examples tree at the project's version. Render-graph API details
are the one area where this page deliberately stays shallow.
