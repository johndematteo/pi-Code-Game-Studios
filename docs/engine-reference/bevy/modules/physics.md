# Bevy Physics — Quick Reference

Last verified: 2026-11-13 | Engine: Bevy 0.20.1

Bevy has **no physics engine in the core crate**. Physics is a community crate,
and which one a project uses is a project decision recorded in its `Cargo.toml`.
See `../PLUGINS.md`.

## What Changed Since ~0.16 (LLM Cutoff)

- **Avian** became the de-facto ECS-native physics crate. A model trained before
  2025 may still default to `bevy_rapier` for every answer.
- **Both crates are viable**, with different APIs. Do not mix them: each owns the
  physics schedule, so adding both produces duplicate systems and doubled forces.
- Bevy's own `FixedUpdate` schedule is the correct home for physics regardless of
  crate.

## Deciding

| Need | Direction |
|------|-----------|
| ECS-native, components-as-colliders | Avian |
| A mature alternative with a different feature set | `bevy_rapier` |
| Simple collision without a full solver | A custom `FixedUpdate` system with AABB checks |

Read the project's `Cargo.toml` first. The answer to "which physics crate?" is
never "whichever one you remember".

## Patterns That Hold for Either Crate

- **Physics runs in `FixedUpdate`.** A variable-step schedule makes simulation
  frame-rate dependent.
- **Fixed timestep is configured once**, in the app's plugin, not per system. Bevy
  exposes a fixed-timestep configuration on the `FixedMain` schedule's runner.
- **Colliders are components**, spawned on the entity that also carries its
  transform and visual.
- **Determinism** requires a fixed step, a seeded RNG and no floating-point
  dependence on wall-clock time.

## Gotchas

| Pattern | Problem |
|---------|---------|
| Physics in `Update` | Frame-rate-dependent behaviour |
| Two physics crates in one `Cargo.toml` | Duplicate systems, doubled forces |
| Reading input inside `FixedUpdate` | Lost or duplicated input across ticks |
| Assuming a crate supports the project's Bevy version | It may be two releases behind; check its `Cargo.toml` |
| Writing physics code before checking the crate | Avian and Rapier APIs differ completely |

## Where to Verify

The crate's own docs at its pinned version (`docs.rs/avian3d`, `docs.rs/bevy_rapier3d`),
and the crate's `Cargo.toml` for the Bevy version it targets. This page records
only what holds across both.
