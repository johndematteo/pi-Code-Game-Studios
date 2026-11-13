---
paths:
  - "assets/shaders/**"
  - "**/*.gdshader"
  - "**/*.wgsl"
  - "Assets/**/*.{shader,hlsl,cginc,compute,shadergraph}"
  - "Shaders/**"
  - "**/*.{usf,ush}"
---

# Shader Code Standards

All shader files, in every engine, must follow these standards to maintain
visual quality, performance, and cross-platform compatibility.

## Naming Conventions
- File naming: `[type]_[category]_[name].[ext]`
  - `spatial_env_water.gdshader` (Godot)
  - `SG_Env_Water` (Unity Shader Graph)
  - `M_Env_Water` (Unreal Material)
  - `env_water.wgsl` (Bevy)
- Use descriptive names that indicate the material purpose
- Prefix with the engine's shader type — Godot `spatial_`, `canvas_`, `particles_`,
  `post_`; Unity `SG_` (Shader Graph); Unreal `M_`, `MI_` (instance), `MF_` (function);
  Bevy has no type prefix — the file is loaded as a `Shader` asset, so the module
  path in `assets/` says what it is and the file name stays snake_case

## Code Quality
- All uniforms/parameters must have descriptive names and appropriate hints
- Group related parameters (Godot: `group_uniforms`, Unity: `[Header]`, Unreal: Category)
- Comment non-obvious calculations (especially math-heavy sections)
- No magic numbers — use named constants or documented uniform values
- Include authorship and purpose comment at the top of each shader file

## Performance Requirements
- Document the target platform and complexity budget for each shader
- Use appropriate precision: `half`/`mediump` on mobile where full precision isn't needed
- Minimize texture samples in fragment shaders
- Avoid dynamic branching in fragment shaders — use `step()`, `smoothstep()` and
  `mix()` (Godot, GLSL) or `lerp()` (HLSL: Unity, Unreal)
- No texture reads inside loops
- Two-pass approach for blur effects (horizontal then vertical)

## Cross-Platform
- Test shaders on minimum spec target hardware
- Provide fallback/simplified versions for lower quality tiers
- Document which render pipeline the shader targets (Forward/Deferred, URP/HDRP, Forward+/Mobile/Compatibility, Bevy's `2d`/`3d` collections)
- Do not mix shaders from different render pipelines in the same directory

## Bevy (`.wgsl`)

Bevy shaders are **WGSL**, not GLSL or HLSL, and there is no shader-graph editor.

- **Never write a `.gdshader` or `.hlsl` body for a Bevy project.** A shader
  copied from a Godot or Unity example is the wrong language.
- A `.wgsl` file is loaded through the `Shader` asset from a path relative to
  `assets/`, like any other asset.
- Custom pipelines go through `RenderPipelineDescriptor` and the render-graph
  API, which is the least stable surface in Bevy: treat a render-graph example
  from an older release as a rewrite, not a rename
  (`docs/engine-reference/bevy/modules/rendering.md`).
- The `precision`/`half` rules above are WGSL's `f32`/`f16`; `f16` needs the
  target to support it.

## Variant Management
- Minimize shader variants — each variant is a separate compiled shader
- Document all keywords/variants and their purpose
- Use feature stripping where possible to reduce build size
- Log and monitor total variant count per shader
