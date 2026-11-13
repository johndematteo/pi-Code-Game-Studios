# Bevy — Plugin and Crate Index

Last verified: 2026-11-13 | Engine: Bevy 0.20.1

Bevy's "plugins" are crates. A plugin here is a crate that adds a `Plugin` to the
app. **The version of every community crate must match the project's Bevy
version**, and the community ecosystem trails each Bevy release by weeks. Check
the crate's own `Cargo.toml` for the `bevy` version it targets before adding it.

There is no `plugins/` folder for Bevy: the crates are named here and in
`modules/`, because a Bevy project's dependency list is its plugin list.

## In the engine (official crates, shipped with `bevy` 0.20.1)

| Crate | What it is | Notes |
|-------|-----------|-------|
| `bevy_ecs` | The ECS: components, systems, schedules, observers, relationships | The engine's centre; see `modules/ecs.md` |
| `bevy_app` | `App`, plugin groups, the main schedule, `ScheduleRunnerPlugin` | See `modules/testing.md` for the headless forms |
| `bevy_render` | wgpu-based renderer | See `modules/rendering.md` |
| `bevy_core_pipeline`, `bevy_pbr`, `bevy_sprite_render`, `bevy_post_process`, `bevy_anti_alias` | Render paths behind the `2d`/`3d` collections | Not separate decisions — they come with the collection |
| `bevy_ui`, `bevy_ui_render`, `bevy_ui_widgets` | In-engine UI | See `modules/ui.md` |
| `bevy_feathers` | Themed widget kit | Upstream describes it as **for editors and inspectors, deliberately not intended for game UI** |
| `bevy_audio` | Audio playback | See `modules/audio.md` |
| `bevy_animation` | Animation | See `modules/animation.md` |
| `bevy_asset` | Asset loading and processing | `assets/` root; `.meta` sidecars |
| `bevy_scene`, `bevy_world_serialization` | Scene serialisation | Behind the `scene` feature |
| `bevy_picking` | Picking (mesh/sprite/ui) | Behind the `picking` feature |
| `bevy_state` | State machines | Behind `default_app` |
| `bevy_gizmos`, `bevy_camera`, `bevy_color`, `bevy_image`, `bevy_mesh`, `bevy_shader`, `bevy_material`, `bevy_text`, `bevy_curve` | Subsystem crates in `common_api` | |
| `bevy_dev_tools` | Dev tools, including `ci_testing` | Behind `dev`; not for published apps |
| `bevy_solari` | Raytraced lighting | Experimental |

## Community crates that matter (not shipped with the engine)

These are the de-facto choices. **Compatibility is the project's decision** — a
crate that has not caught up to the project's Bevy version will not compile, and
pinning Bevy older to accommodate one crate is a normal trade.

| Need | Crate | Status |
|------|-------|--------|
| Physics | **Avian** | The ECS-native choice |
| Physics (alternative) | `bevy_rapier` | Mature alternative; a different API and a different feature set |
| Input mapping (actions, rebinding) | `leafwing-input-manager` | The de-facto action-mapping crate |
| Networking | `lightyear` | The de-facto networking crate |
| Audio (higher level) | `bevy_kira_audio` | Alternative to the in-engine `bevy_audio` |
| Tool/debug UI | `bevy_egui` | For tools and debug panels, not shipping game UI |
| Debug inspection | `bevy-inspector-egui` | Runtime inspector |
| Tweening | `bevy_tweening` | Tween/animation helpers |

## Rules

1. **One physics crate, not two.** Avian and `bevy_rapier` both own the physics
   schedule; adding both is a duplicate-system bug.
2. **A plugin's `Cargo.toml` decides compatibility**, not its README's badge.
   `cargo tree -i <crate>` and `grep -n bevy Cargo.lock` answer it.
3. **Do not pin Bevy older than `VERSION.md` to satisfy a plugin without saying
   so.** Record the reason in `docs/architecture/`; the reference pages here
   assume the pinned version.
4. **Check the crate is maintained against the project's release** before
   designing a system around it. The ecosystem lags each release by weeks, and a
   crate that is two releases behind is usually a rewrite rather than a bump.
