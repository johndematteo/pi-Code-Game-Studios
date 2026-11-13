# Lens: the engine specialist's second look (Phase 5)

Read after the engine audit, once an engine is set. It holds what the primary
engine specialist checked; you apply it here. Use the section for `engine.name`:
Godot, Unity, Unreal or Bevy; for Web, the lead programmer's section.

## How to look

Go through every ADR with engine-specific decisions or a `Post-Cutoff APIs Used`
field, the engine reference docs, and the audit findings above, and:

1. Confirm or challenge each audit finding.
2. Find engine anti-patterns the audit missed: an ADR can use only current APIs
   and still pick the wrong tool for the job. The lists below are the usual ones;
   they are prompts, not the limit.
3. Flag an ADR that assumes behaviour the pinned version does not have.

Every API or version claim comes from the engine reference,
`docs/engine-reference/[engine]/*.md` and `docs/engine-reference/[engine]/modules/*.md`
(`VERSION.md`, `breaking-changes.md`, `deprecated-apis.md`,
`current-best-practices.md`, the modules). An anti-pattern that is engine
practice rather than an API fact may come from these lists; an API behaviour the
reference does not cover is marked `unverified`, never asserted from memory.

## Godot

- The wrong node type for the job: a `RigidBody` driven by setting its position
  each frame (use `CharacterBody` or `AnimatableBody`), physics bodies or
  `RayCast`s for a pure overlap check (`Area`), individual nodes for hundreds of
  identical meshes (`MultiMeshInstance`), a `Timer` node per entity for many
  entities, `Node` where `RefCounted` or a `Resource` would do.
- Work every frame where events would do; per-frame logic in `_process` that
  belongs in `_physics_process`, or the reverse.
- Long `get_node()` paths to distant nodes instead of signals, groups or exported
  references; "call down, signal up" broken.
- Autoloads as a dumping ground, or depending on scene state; game state in more
  than one autoload.
- Shared data hard-coded in scripts instead of `Resource`/`.tres`; path-based
  references where a UID would survive a rename.
- Many short-lived instances (projectiles, enemies) with no pooling.

## Unity

- `Find()`, `FindObjectOfType()` or `SendMessage()` as the wiring; `GetComponent`
  in `Update()`.
- `Resources.Load()` for runtime loading (use Addressables); hard prefab
  references that drag content into every build.
- Allocation in hot paths; no pooling for frequent spawns.
- The legacy input manager or the built-in render pipeline for a new project.
- UI that owns game state; `DontDestroyOnLoad` as the scene pattern;
  init-order assumptions with no script execution order set.
- Thousands of entities as MonoBehaviours with no case made against DOTS.

## Unreal

- Actors ticking with no work; spawning and destroying every frame instead of
  pooling; string work where `FName` lookups belong.
- Stats changed directly where the project uses GAS (Gameplay Effects,
  Attribute Sets); booleans where Gameplay Tags fit.
- Hard references that load content always; no soft references or Asset Manager
  for game data.
- Large logic in Blueprint graphs that belongs in C++; raw UObject pointers with
  no `UPROPERTY`.
- Multiplayer state not server-authoritative, or replicated more than needed.

## Bevy

- Systems that reach for `Query<&mut T>` on a wide set every frame, or a
  `Resource` holding game state that several systems mutate: both are the
  archetype and borrow-check costs the ECS exists to avoid. Ask what the schedule
  ordering actually is.
- `Event` where 0.20's `Message` belongs. Since 0.20 `Event` is an entity-event
  observer type and buffered events are `Message`/`MessageWriter`/`MessageReader`;
  an ADR written from memory will name the old API (`breaking-changes.md`).
- `Parent`/`Trigger` instead of `ChildOf`/`On` — renamed in 0.20. A design that
  assumes `Trigger<E>` for observers has the wrong type.
- Rendering assumptions that only hold with the default features: a headless or
  CI design that does not name `--no-default-features --features default_app`
  will pull in the renderer and fail without a GPU.
- Plugin ordering assumed rather than declared — `MinimalPlugins`, `DefaultPlugins`
  and community plugin groups differ, and `add_plugins` order is load-bearing.
- Physics chosen by habit: Avian and `bevy_rapier` are mutually exclusive, and a
  design naming both, or neither, is unresolved (`PLUGINS.md`).
- An ecosystem crate pinned to a Bevy version the project does not build — the
  community lags each release by weeks, so `Cargo.lock` is the claim to check.
- UI built on the retained `bevy_ui` tree where an immediate-mode crate was
  chosen, or vice versa; and text/asset paths hard-coded rather than loaded.

## Web (the lead programmer's lens)

- Decisions hard to implement with the stated framework and language;
  interfaces programmers would have to invent.
- Global mutable state or singletons for game state; tuning values hard-coded.
- Work every frame that could be event-driven; allocation in the frame loop.
- Cost claims with numbers: cite the entity counts and frame budget and the gap,
  and name one alternative that fits.

## Output

Write the findings under `### Engine Specialist Findings`, each naming the ADR
and the reference file behind it (or `unverified`). They weigh the same as the
audit's findings in the verdict.
