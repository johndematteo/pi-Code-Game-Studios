# Bevy ECS — Quick Reference

Last verified: 2026-11-13 (against `bevy_ecs` 0.20.1 source) | Engine: Bevy 0.20.1

This is Bevy's defining subsystem and the one where a model's remembered API is
most often wrong. Read this page before writing systems.

## What Changed Since ~0.16 (LLM Cutoff)

### 0.20 — events and observers split

`bevy_ecs` 0.20.1 has **separate `event/` and `message/` modules**. They are
different mechanisms:

| Mechanism | Type | Written by | Read by |
|-----------|------|-----------|---------|
| Entity event (observer payload) | `Event` | `world.trigger` / observer dispatch | An observer taking `On<T>` |
| Buffered message | `Message` | `MessageWriter<T>` | `MessageReader<T>` |
| Buffered message storage | `Messages<T>` | — | — |

```rust
// WRONG on 0.20 — a buffered event written as an Event.
#[derive(Event)]
struct DamageDealt { amount: u32 }
fn apply(mut r: EventReader<DamageDealt>) { /* does not compile */ }

// RIGHT on 0.20 — buffered events are Messages.
#[derive(Message)]
struct DamageDealt { amount: u32 }
fn apply(mut r: MessageReader<DamageDealt>) {
    for msg in r.read() { /* ... */ }
}

// An observer reacts to an entity event and takes On<T>.
fn on_damage(event: On<DamageDealt>) { /* ... */ }
```

### 0.20 — relationships replaced parent components

`ChildOf` is a relationship component; `Parent` is no longer a component. The
relationship API (`relationship`, `hierarchy`) is the supported path, and
`HierarchyPropagatePlugin` / `propagate` exist as their own path for transform
propagation.

### 0.20 — scene templates

`template` / `Template` / `FromTemplate` (BSN) arrived in this line, alongside the
older `.scn.ron` world serialisation. They are different mechanisms.

## Schedules

`PreStartup`, `Startup`, `PostStartup`, `First`, `PreUpdate`, `FixedPreUpdate`,
`FixedUpdate`, `FixedPostUpdate`, `Update`, `PostUpdate`, `Last`, `Main`,
`FixedMain`.

- **`Startup` runs once.** Anything that must re-run belongs in `Update` or a state
  transition, not a second `Startup` system.
- **`FixedUpdate` is a fixed step.** Simulation (physics, deterministic gameplay)
  belongs there; input reading and presentation belong in `Update`. Reading input
  in `FixedUpdate` loses or duplicates events across ticks.
- **System order is not deterministic unless declared.** Use `.chain()`,
  `.before()`, `.after()`, `.in_set()`. A chain of three systems written as three
  `add_systems` calls without ordering is a latent bug.
- **Run conditions** (`.run_if(...)`) are how a system is gated; deleting and
  re-adding systems per frame is not.

## Resources, queries and conflicts

- `Res<T>` / `ResMut<T>` conflicts are a **runtime panic with a documented error
  code**, not a compile error. Two systems in one schedule that both take
  `ResMut<T>` cannot run concurrently.
- `Local<T>` keeps per-system state; `ParamSet` resolves a system that needs two
  conflicting parameters.
- Queries: `Query<(&A, &mut B), With<C>>`. Change detection filters (`Changed<T>`,
  `Added<T>`) are **frame-relative to that system's own last run** — a system
  added late sees everything as changed.
- A component is a type; a resource is a singleton. Prefer components plus queries
  over a resource holding a collection of entities.

## Anti-Patterns a Model Writes by Default

| Pattern | Problem | Do instead |
|---------|---------|-------------|
| `#[derive(Event)]` for a buffered event | Wrong mechanism on 0.20 | `#[derive(Message)]` + `MessageReader` |
| `Query<&Parent>` | `Parent` is not a component | `Query<&ChildOf>` |
| Three `add_systems` calls with no ordering | Non-deterministic order | `.chain()` / `.in_set()` |
| Physics in `Update` | Frame-rate-dependent simulation | `FixedUpdate` |
| One giant `Update` system | No parallelism, unorderable | Small systems in sets |
| A `Resource` holding `Vec<Enemy>` | Loses ECS queries, change detection | Components on entities |
| Calling `App::update()` during plugin build | Panics | Finish setup, then step |

## Verification

When a compile error names `bevy_ecs`, the answer is almost always a rename on
this page or in `../breaking-changes.md`. If neither has it, read
`docs.rs/bevy_ecs/<version>` for the item the error names — do not guess.
