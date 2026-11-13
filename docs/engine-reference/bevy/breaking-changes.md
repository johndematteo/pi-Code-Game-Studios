# Bevy — Breaking Changes

Last verified: 2026-11-13 (0.20 rows, against `bevy` 0.20.1 crate source) | Engine: Bevy 0.20.1

Every Bevy release carries breaking changes, and upstream publishes a migration
guide per release. This page lists the ones that change code an agent is most
likely to write from memory. It is not the full guide — when a compile error is
not covered here, read the release's guide.

## Sources

- Migration guides, one per release: https://bevy.org/learn/migration-guides/
- Release notes: https://bevy.org/news/
- Release dates (crates.io, read 2026-11-13): 0.16 2025-04-24, 0.17 2025-09-30,
  0.18 2026-01-13, 0.19 2026-06-19, 0.20.0 2026-10-08, 0.20.1 2026-10-28.

## 0.20 — HIGH RISK

Verified against the `bevy_ecs` 0.20.1 source, where `event/` and `message/` are
separate modules.

### Buffered events are now messages

| Was | Now | What broke |
|-----|-----|-----------|
| `Event` (a buffered event) | `Message` | `Event` now means an **entity event** — the payload of an observer. Code that derives `Event` for a buffered event compiles but stops being readable by a reader, because it is no longer a message. |
| `EventWriter<T>` | `MessageWriter<T>` | Renamed. |
| `EventReader<T>` | `MessageReader<T>` | Renamed. |
| `Events<T>` | `Messages<T>` | Renamed. |
| `EventMutator<T>` | `MessageMutator<T>` | Renamed. |

```rust
// WRONG on 0.20 — a buffered event written as an Event.
#[derive(Event)]
struct DamageDealt { amount: u32 }

// RIGHT on 0.20 — a buffered event is a Message.
#[derive(Message)]
struct DamageDealt { amount: u32 }

fn apply_damage(mut reader: MessageReader<DamageDealt>) {
    for msg in reader.read() { /* ... */ }
}
```

An observer that reacts to an entity event takes `On<T>` instead.

### Observers and relationships

| Was | Now | Notes |
|-----|-----|-------|
| `Trigger<T>` | `On<T>` | The observer's event parameter. `On` is in `bevy_ecs::observer::system_param`. |
| `Parent` | `ChildOf` | Parent linkage is a relationship component. `Parent` survives only as a query-data alias in doc comments, so a query written against `Parent` will not compile. |

### Feature model

Bare flags were replaced by collections (`default_app`, `default_platform`,
`2d`, `3d`, `ui`, `audio`, `common_api`, `dev`, `picking`, `scene`, …). A
`Cargo.toml` copied from an older project names flags that no longer exist as
top-level features. See `VERSION.md` "Feature Collections (0.20)".

### Scene templates

`template` / `Template` / `FromTemplate` and the BSN scene-template path arrived
in this line. A scene written as `.scn.ron` and a scene written as a Rust
template are different mechanisms — do not mix them in one example.

### Hierarchy helpers

`hierarchy` / `propagate` / `HierarchyPropagatePlugin` exist as their own path.
An agent that remembers `Transform` propagation as an implicit side effect of
parenting should check this page before relying on it.

## 0.17 – 0.19 — HIGH RISK (post-cutoff, not itemised here)

All three landed after the May 2025 training floor. This page records only what
was verified for 0.20.1; for a project on 0.17, 0.18 or 0.19, read that release's
migration guide before assuming a 0.20 pattern applies.

## How to Read a Compile Error on a Bevy Project

Bevy's errors are ordinary Rust errors, and they name the crate that moved
(`error[E0433]: failed to resolve: use of undeclared crate or module`). The
sequence that resolves most of them:

1. `grep -n "bevy" Cargo.toml Cargo.lock` — the exact version, before anything else.
2. This page, for a rename.
3. `docs.rs/bevy/<version>` for the item the error names.
4. The migration guide for that version.

Do not guess a replacement name: `cargo add`-style intuition is what produces
`EventWriter` on a 0.20 project.
