# Phase 6: Parse check and capture on Unity, Unreal and Bevy

Read only when the engine is Unity, Unreal or Bevy. Report the command, its exit
code and any error lines. No executable: `parse NOT VERIFIED — engine binary not
available`.

## Unity

**Parse check:** the `commands.smoke` command (`-batchmode -quit -projectPath .
-logFile -`). Exit 1 with `error CS…` lines means a script does not compile.

**Capture** needs `Assets/Scripts/ScreenshotOnArg.cs`, given word for word in
`run-and-observe.md` (named in `SKILL.md`, Phase 6). When the project has none
(look for `Assets/**/ScreenshotOnArg.cs`), ask "May I write
`Assets/Scripts/ScreenshotOnArg.cs`?" and write it exactly as given before
launching. Declined: nothing can capture, so report
`Run result: NOT VERIFIED — ScreenshotOnArg.cs not written`.

## Unreal

**Parse check:** build the editor target. A compile error fails it (`Result:
Failed`, non-zero exit).

- Windows: `"<UE root>/Engine/Binaries/DotNET/UnrealBuildTool/UnrealBuildTool.exe" <Project>Editor Win64 Development -Project="<absolute path>/<Project>.uproject"`
- Linux: `"<UE root>/Engine/Build/BatchFiles/Linux/Build.sh" <Project>Editor Linux Development -Project=…`
- macOS: `"<UE root>/Engine/Build/BatchFiles/Mac/Build.sh" <Project>Editor Mac Development -Project=…`

The commands are from Epic's documentation, as recorded in
`docs/engine-reference/unreal/current-best-practices.md` ("Command Line").

**Capture:** launch straight into the map the story touched, as
`run-and-observe.md` gives it.

## Bevy

**Parse check:** `cargo check --tests`. A compile error fails it (`error[E…]`,
non-zero exit), and it is the check that separates a compile error from a failing
test — `cargo test` exits 101 for both. No `cargo`: `parse NOT VERIFIED — cargo not
available`.

**Capture:** Bevy has no screenshot hook in the engine. Run the game
(`cargo run`) and capture the window with the platform's own tool — on macOS
`screencapture -x <file>`, on Linux a compositor's screenshot tool — or, when the
project has wired `bevy_dev_tools`' `ci_testing`, let that write the screenshot.
With no capture path, report
`Run result: NOT VERIFIED — no screenshot capture path for Bevy` rather than
claiming the frame looked right.
