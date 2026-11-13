# Engine table

`engines.tsv` holds one row per engine `engine.name` can name: Godot, Unity,
Unreal, Web and Bevy. The hooks, helpers and skills read it instead of keeping
their own copy of each engine's folders.

| Column | What it is | Read by |
|---|---|---|
| `engine` | The `engine.name` value. Matched in any case; any name starting with "unreal" is the Unreal row | every reader |
| `code_root` | Where the game's code lives, unless `engine.code_root` says otherwise | `resolve_code_root` (`yaml-helper.sh`), `project-state.sh`, `write-guard.sh`, `content-count.sh` |
| `test_root` | Where the tests live, unless `engine.test_root` says otherwise | `resolve_test_root` (`yaml-helper.sh`) |
| `asset_root` | Where the assets live | `asset-scan.sh`, `content-count.sh` |
| `run`, `build`, `test`, `smoke` | The default commands. `-` where the command needs something only `/setup-engine` can ask for (the editor's path, a build target) | `test-run.sh` (`test`, when `commands.test` is unset) |

**Bevy's row** is a native Rust desktop crate: `src/` code root, `tests/`,
`assets/` (which is Bevy's `AssetServer` root), and plain `cargo run` /
`cargo build` / `cargo test`. Its `smoke` cell is `-` because a smoke gate is
project-specific — Bevy has no equivalent of Godot's `--quit-after`, so
`/setup-engine` asks. Render tests need a real wgpu adapter; the headless recipe
is in `docs/engine-reference/bevy/modules/testing.md`, and a project's
`commands.test` still wins over the row.

**Bevy's `src/` is not the Godot row.** Both engines use `src/`, so the table
cannot tell them apart on folders alone: a project is Bevy only when
`engine.name` says so or a `Cargo.toml` with a `bevy` dependency is present.
`resolve_config --keys engine_row` returns Bevy's row only for the name `Bevy`.

**Bevy has no engine specialist agent**, the same as Web: engine work routes to
`lead-programmer` against `docs/engine-reference/bevy/`.

**`web/` has no Bevy counterpart.** `/setup-engine bevy` is instruct-only: it
writes `project.yaml`, the `AGENTS.md` reference import and
`docs/engine-reference/bevy/`, and never writes into an existing `Cargo.toml`
or `src/`.

Skills read a row with `resolve_config --keys engine_row`. The files listed above
read the table through one reader, `studio/scripts/engine-row.awk`.
`test-scaffold.sh` does not read it: it writes its own copy of each engine's test
paths, so a change to `test_root` here must also be made there.

**Format.** Tab-separated, LF line ends, a header row first. A `-` is an empty
cell; no cell is left blank. Read it with `awk -F'\t'`: a bash `IFS` read merges
empty fields.

## `web/`

The files a new web project starts from. `scaffold/` holds every file
`/setup-engine web` copies into the project root, through
`studio/scripts/web-scaffold.sh` (which never overwrites a file); its
`playwright.config.ts` is also the one `/test-setup` writes
(`test-scaffold.sh web`). `web/README.md` says what each file is for.
