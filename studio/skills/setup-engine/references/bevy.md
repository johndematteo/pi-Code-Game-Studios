# /setup-engine — Bevy (a Rust game on Bevy)

> Part of `/setup-engine`. `SKILL.md` names when to read this file; the settings it
> resolved and the rules under its later headings still apply here.

Read when the engine is **Bevy** (`/setup-engine bevy`). For Bevy it replaces
Sections 3, 6 and 7.5, records the version from the project's own crate, and
gives the values Sections 4, 5 and 5.5 write; Sections 7, 8 and 12 still apply.
Never load `godot-language-config.md`.

**In this file:** B1 An existing Bevy crate · B2 Rust and the Bevy version · B3 The
values to write · B4 The reference docs · B5 No scaffold · B6 Build, test and look ·
B7 No engine specialist agent

Bevy is a Rust engine: one cargo binary crate, no editor, no project file.
`assets/` is its `AssetServer` root. It ships breaking API changes roughly every
release, so **the project's own `Cargo.toml` / `Cargo.lock` is the version, never
"latest"** and never a number this file remembers.

## B1. An existing Bevy crate

A `Cargo.toml` at the project root means an existing crate: record it as it is
and **write nothing into it** — no dependency edit, no feature edit, no
`rust-toolchain.toml`. B1 replaces B2 and B5 for it (B3, B4, B6, B7 and Sections
7, 8 and 12 still apply).

1. **Read the crate**, files only:
   - `grep -n "bevy" Cargo.toml Cargo.lock` — the version, and whether it is
     pinned (`=0.20.1`) or a range (`"0.20"`). A range is a warning: Bevy's
     breaking changes mean a caret range silently moves the API.
   - The crate's name and edition, and whether `Cargo.lock` is committed. A
     binary crate with no committed lock file is a warning, not a failure.
   - `src/` for the app's entry point; `tests/` for integration targets.
2. **`rust-version` / toolchain:** `cargo --version` and `rustc --version`.
   Compare against the MSRV in `docs/engine-reference/bevy/VERSION.md`. **A
   mismatch is a warning, never a hard stop** — record it and say which way it
   runs (toolchain older than the crate's MSRV will not build).
3. **Show the record and confirm it** before writing, in one block: the crate
   name, the Bevy version and whether it is pinned, the toolchain and its MSRV
   position, the code root and test root, and the commands. Then write only
   `AGENTS.md`, `technical-preferences.md` and `project.yaml` (B3).
4. **No cargo installed:** record anyway, offer the install line
   (`curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`), and say
   that §8's verification is NOT ASSESSED until it is installed. Do not block.
5. **Bevy not in `Cargo.toml`:** the project is a Rust crate but not a Bevy game
   yet. Say so, write the config, and leave the dependency decision to the user —
   do not add `bevy` to their `Cargo.toml`.

## B2. Rust and the Bevy version (Section 3)

For a project with no crate yet, there is nothing to read, so look it up:

1. **The release.** Search `https://bevy.org/` and the crates.io API
   (`https://crates.io/api/v1/crates/bevy`) for the current stable version and
   its publish date. As of 2026-11-13 that is 0.20.1 (2026-10-28); confirm rather
   than trust this line.
2. **The MSRV.** The `rust-version` field in `bevy`'s own `Cargo.toml` for that
   release (0.20.1: 1.97.1). `cargo --version` on this machine: if it is older,
   say so — the crate will not build until the toolchain is updated.
3. **Show the pin and ask** before recording it: version, publish date, MSRV,
   the local toolchain. Never silently pick "latest" — a project may need to sit
   on an older release for a community crate (physics, networking) that has not
   caught up. If the user names a version, use it.

## B3. The values to write (Sections 4, 5 and 5.5)

On a yes, only these three files. **No file of the crate is touched.**

- **AGENTS.md**, with the import line `@docs/engine-reference/bevy/VERSION.md`:
  ```markdown
  - **Engine**: Bevy <version>
  - **Language**: Rust
  - **Build System**: Cargo — `cargo build` / `cargo run`
  - **Asset Pipeline**: `assets/` is Bevy's AssetServer root; the asset processor writes `.meta` files beside each asset
  ```
- **technical-preferences.md**: Engine Bevy and the version; language Rust; the
  naming defaults for Rust (B3's table below). No specialist rows (B7).
- **`project.yaml`**: `engine.name: "Bevy"`, `engine.version` (quoted string —
  `"0.20.1"`; an unquoted `0.20` is a YAML float and loses the trailing zero),
  `engine.language: "Rust"`, `engine.rendering` and `engine.physics` only when
  the project has chosen them (Bevy has no single engine default for either —
  physics is a crate choice, see `docs/engine-reference/bevy/PLUGINS.md`), and:
  ```yaml
  commands:
    build: "cargo build"
    run: "cargo run"
    test: "cargo test"
  ```
  No `smoke`: Bevy has no equivalent of Godot's `--quit-after`, so a smoke gate is
  project-specific. `/smoke-check` reads `commands.test`.

**Naming (Rust).** Files and modules `snake_case`; types, traits and enums
`UpperCamelCase`; functions, methods, locals and modules `snake_case`; constants
`SCREAMING_SNAKE_CASE`. Tests: `#[cfg(test)] mod tests` beside the code for unit
tests, `tests/<system>.rs` for integration targets, function names
`[scenario]_[expected]`. **A folder under `tests/` is not a cargo test target.**

**Quoting.** `engine.version` must be a quoted string. A value like `0.20.1` is
fine unquoted, but `0.20` is not: YAML reads it as a float and the reader returns
`0.2`. Quote every version.

## B4. The reference docs (Sections 6 and 7)

`docs/engine-reference/bevy/` ships populated (VERSION, breaking-changes,
deprecated-apis, current-best-practices, PLUGINS and `modules/`). Read
`docs/engine-reference/bevy/VERSION.md` and:

1. **Record the project's version** in `Project Pinned` and `Installed at pin
   time`, replacing `NOT DETERMINED`. This is the one write this phase makes to
   the reference folder.
2. **When the project's version differs from the pin** (the folder is written
   against 0.20.1), say so in one line and name the release's migration guide
   (`https://bevy.org/learn/migration-guides/`). Do not rewrite the pages: an API
   answer is checked against the project's version, and the pages say so.
3. **Bevy is HIGH RISK** for the knowledge gap (§6): everything from 0.17 onward
   is post-cutoff. Say that plainly and name the source-read policy in
   `VERSION.md` — read `modules/` here, then `docs.rs/bevy/<version>`, then the
   examples tree, before writing Bevy API from memory.

## B5. No scaffold (Section 7.5)

**Bevy is instruct-only: `/setup-engine bevy` creates no project file.** A
`Cargo.toml` is fully sourceable, so it would be easy to write one — and that is
exactly why it is not done: a crate that already exists has its name, edition,
dependencies and features, and rewriting it is a merge problem for no gain.

For a project with no crate, say what to create, in one block, and create
nothing:

```
Cargo.toml            # bevy = "=<version>"; commit Cargo.lock
src/main.rs           # App::new().add_plugins(GamePlugin).run();
assets/               # AssetServer root; create it empty
tests/                # cargo integration targets: tests/<name>.rs
```

`/test-setup` writes `tests/README.md`, `production/qa/evidence/.gitkeep`,
`.github/workflows/tests.yml` and `tests/smoke/critical-paths.md` (no folder under
`tests/`, because cargo would not compile it).

## B6. Build, test and look

Never install a toolchain unasked. In order:

1. **`cargo --version`.** Absent: show the `rustup` line and stop — §8's
   verification is NOT ASSESSED.
2. **`cargo check --tests`** — does the crate compile. A compile error is not a
   test failure; `cargo test` exits 101 for both, which is why the check runs
   first (`studio/scripts/test-run.sh bevy` does the same).
3. **`cargo test`** — the project's own command. `--no-default-features
   --features default_app` is the headless form for a machine with no GPU; see
   `docs/engine-reference/bevy/modules/testing.md`.
4. **`cargo run`** for the window. Bevy's first build of a full feature set is
   minutes, not seconds: say so before starting one.

`bash studio/scripts/test-run.sh bevy` prints what would run and the rule its exit
code falls on, and `--dry-run` runs nothing.

## B7. No engine specialist agent (Section 9)

There is no `bevy-specialist` agent. Engine work on Bevy routes to
`lead-programmer` against `docs/engine-reference/bevy/`, exactly as Web does
against its folder — `resolve_config --keys specialists` resolves
`primary=lead-programmer` for `engine.name: Bevy`. Say so, and skip the Version
Awareness edit: there is no engine agent file to edit.
