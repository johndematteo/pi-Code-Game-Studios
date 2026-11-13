# /test-setup — Phase 4: Create CI/CD Workflow

> Part of `/test-setup`. `SKILL.md` names when to read this file; the settings it
> resolved and the rules under its later headings still apply here.

## Phase 4: Create CI/CD Workflow

**In this file:**

- Godot 4
- Unity
- Unreal Engine
- Web

### Godot 4

Create `.github/workflows/tests.yml`:

```yaml
name: Automated Tests

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    name: Run GdUnit4 Tests
    runs-on: ubuntu-latest
    # The action publishes its results as a check run. A new repository's
    # token is read-only, and without checks: write the job fails even when
    # every test passes. If you protect main, require the `Run GdUnit4 Tests` job
    # check, not `test-results`: that check run concludes success even when a
    # test fails.
    permissions:
      contents: read
      checks: write

    steps:
      - name: Checkout
        uses: actions/checkout@v7
        with:
          lfs: true

      # godot-version must be a full release such as 4.7.2 (`godot --version`
      # shows it); VERSION.md's "4.7" is not one. version: installed runs the
      # gdUnit4 committed in addons/ -- without it the action deletes that
      # copy and installs the latest release, which may not match your tests.
      - name: Run GdUnit4 Tests
        uses: godot-gdunit-labs/gdUnit4-action@v1
        with:
          godot-version: '[FULL GODOT VERSION, e.g. 4.7.2]'
          version: 'installed'
          paths: |
            tests/unit
            tests/integration
          report-name: test-results

      - name: Upload Test Results
        if: always()
        uses: actions/upload-artifact@v7
        with:
          name: test-results
          path: reports/
```

### Unity

Create `.github/workflows/tests.yml`:

```yaml
name: Automated Tests

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    name: Run Unity Tests
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v7
        with:
          lfs: true

      - name: Run Edit Mode Tests
        uses: game-ci/unity-test-runner@v4
        env:
          UNITY_LICENSE: ${{ secrets.UNITY_LICENSE }}
        with:
          testMode: editmode
          artifactsPath: test-results/editmode

      - name: Run Play Mode Tests
        uses: game-ci/unity-test-runner@v4
        env:
          UNITY_LICENSE: ${{ secrets.UNITY_LICENSE }}
        with:
          testMode: playmode
          artifactsPath: test-results/playmode

      - name: Upload Test Results
        if: always()
        uses: actions/upload-artifact@v7
        with:
          name: test-results
          path: test-results/
```

Note: Unity CI requires a `UNITY_LICENSE` secret. Add to GitHub repository
secrets before the first CI run.

### Unreal Engine

Create `.github/workflows/tests.yml`:

```yaml
name: Automated Tests

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    name: Run UE Automation Tests
    runs-on: [self-hosted, windows]  # UE requires a local runner with the editor installed

    # The quoted "{0}" in each `shell:` below: the Windows runner passes bash
    # its script path unquoted, so with plain `shell: bash` every step fails
    # ("No such file or directory") when the runner's folder has a space.
    steps:
      - name: Checkout
        uses: actions/checkout@v7
        with:
          lfs: true

      # Binaries/ is gitignored, so a fresh checkout has no compiled game
      # module: without this step the editor stops with "The game module could
      # not be found" before running any test. UnrealBuildTool.exe, not
      # Build.bat -- from bash, Build.bat fails on an engine path with spaces.
      - name: Build Editor Target
        run: |
          "$UE_ROOT/Engine/Binaries/DotNET/UnrealBuildTool/UnrealBuildTool.exe" [ProjectName]Editor Win64 Development \
            -Project="${{ github.workspace }}/[ProjectName].uproject"
        shell: bash --noprofile --norc -eo pipefail "{0}"

      # -stdout -FullStdOutLogOutput: without them the editor prints nothing
      # here, and the results are only in Saved/Logs/.
      - name: Run Automation Tests
        run: |
          "$UE_ROOT/Engine/Binaries/Win64/UnrealEditor-Cmd.exe" "${{ github.workspace }}/[ProjectName].uproject" \
            -nullrhi -nosound \
            -ExecCmds="Automation RunTests [ProjectName].; Quit" \
            -unattended -stdout -FullStdOutLogOutput
        shell: bash --noprofile --norc -eo pipefail "{0}"

      - name: Upload Logs
        if: always()
        uses: actions/upload-artifact@v7
        with:
          name: test-logs
          path: Saved/Logs/
```

Note: UE CI requires a self-hosted Windows runner with Unreal Editor installed.
The `windows` label keeps the job off any Linux self-hosted runner the
repository also has. Set the `UE_ROOT` environment variable on the runner to the engine folder
(e.g. `C:/Program Files/Epic Games/UE_5.8`). `[ProjectName]Editor` is the
editor target in `Source/[ProjectName]Editor.Target.cs`. `actions/checkout@v7`
and `actions/upload-artifact@v7` run on Node.js 24, which needs Actions Runner
2.327.1 or newer: update the self-hosted runner before the first run
(https://github.com/actions/checkout/blob/v7.0.1/README.md).

### Web

`test-scaffold.sh web` writes it (Phase 3); its text:

```yaml
name: Automated Tests

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    name: Run Vitest and Playwright Tests
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v7

      - name: Set up Node
        uses: actions/setup-node@v7
        with:
          node-version: 24

      # npm ci installs exactly what package-lock.json pins.
      - name: Install
        run: npm ci

      # Playwright launches the runner's Chrome, the browser
      # studio/scripts/page-shot.sh finds, so no browser is downloaded.
      - name: Run Tests
        run: npm test

      - name: Upload Test Results
        if: always()
        uses: actions/upload-artifact@v7
        with:
          name: test-results
          path: test-results/
          if-no-files-found: ignore
```

`npm test` exits non-zero when either half fails, so the job fails with it.
GitHub's `ubuntu-latest` image has Google Chrome on the `PATH`, which is what
`page-shot.sh --which` finds there; `.claude/` must be in the repository, as it
is in every Claude Code Game Studios project. `test-results/` holds Playwright's traces and
screenshots of a failing test, and is empty when every test passed.

### Bevy

`test-scaffold.sh bevy` writes it (Phase 3); its text:

```yaml
name: Automated Tests

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    name: Run cargo test
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v7

      # The toolchain the crate needs: a rust-toolchain.toml, if the project has
      # one, wins over this. Bevy 0.20's MSRV is 1.97.1.
      - name: Set up Rust
        uses: dtolnay/rust-toolchain@stable

      # Bevy's Linux build links ALSA and udev; without them the build stops
      # before any test compiles. mesa-vulkan-drivers gives wgpu a software
      # Vulkan adapter, so a test that builds a renderer can still run.
      - name: Install system libraries
        run: |
          sudo apt-get update
          sudo apt-get install -y libasound2-dev libudev-dev mesa-vulkan-drivers

      # The crate's own test command. A project whose tests need a real GPU
      # should gate them behind a feature and name the headless set here:
      # cargo test --no-default-features --features default_app
      - name: Run Tests
        run: cargo test
```

`cargo test` exits non-zero when any test fails, so the job fails with it. Two
things are not optional: **`libasound2-dev` and `libudev-dev`** (Bevy's Linux
build links them, and without them nothing compiles), and the toolchain the crate
declares — a crate whose `rust-version` is above the runner's stable will not
build. `mesa-vulkan-drivers` is the software adapter that lets a render-touching
test run on a hosted runner; a project that does not want it should gate its
render tests behind a feature instead.

**Never** put a `cd tests/unit && cargo test` in CI. Cargo resolves the crate
from `Cargo.toml` upward, so a nested invocation runs the same workspace from a
different directory and finds no crate of its own.

---

---
