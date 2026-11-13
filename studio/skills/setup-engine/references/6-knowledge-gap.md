# /setup-engine — Section 6: Determine Knowledge Gap

> Part of `/setup-engine`. `SKILL.md` names when to read this file; the settings it
> resolved and the rules under its later headings still apply here.

## 6. Determine Knowledge Gap

Check whether the engine version is likely beyond the LLM's training data.

**Known approximate coverage** — the same figures the shipped
`docs/engine-reference/*/VERSION.md` files record:
- LLM knowledge cutoff: **May 2025**, a floor: a newer model may know more, but
  the comparison below still uses May 2025
- Godot: training data likely covers up to ~4.3
- Unity: training data likely covers up to ~2022 LTS (2022.3)
- Unreal: training data likely covers up to ~5.3
- Bevy: training data likely covers up to ~0.16 (released 2025-04-24, just before the cutoff)

> **This table goes stale silently, and a stale table fails in the dangerous
> direction only if it is too *new*.** A cutoff left unchanged for a year after
> it stopped being true over-classifies risk — safe, but every project then pays
> for full reference docs it may not have needed.
> The opposite error is the harmful one: a cutoff claimed *later* than the model's
> actual one marks post-cutoff versions LOW RISK and suppresses the reference
> docs that exist to stop invented APIs.
>
> **If the model running this skill states an earlier training cutoff than the
> one above, do not trust the table.** Say so, and treat the engine version as
> `HIGH RISK` regardless of the comparison — a cutoff the model does not have is
> not a cutoff that was met.

**Web** is HIGH RISK: every version the scaffold pins is newer than the model's
training (`references/web.md`, W4).

**Bevy** is HIGH RISK from 0.17 onward: 0.17, 0.18, 0.19 and 0.20 all landed
after the cutoff, and Bevy ships breaking API changes roughly every release with
no semver stability promise. Treat any Bevy version above 0.16 as `HIGH RISK`
regardless of how close the comparison looks, and apply the source-read policy in
`docs/engine-reference/bevy/VERSION.md`: read the module page here, then
`docs.rs/bevy/<version>`, then the `bevyengine/bevy` examples tree and the
release's migration guide, before writing Bevy API from memory
(`references/bevy.md`, B4).

Name the renames that make the risk concrete, because they are what a remembered
answer gets wrong: on 0.20 a buffered event is `Message` (`MessageWriter`,
`MessageReader`) while `Event` now means an entity event; `Trigger` is `On`; and
`Parent` is `ChildOf`. Say them in one line, then move on.

Compare the user's chosen version against these baselines:

- **Within training data** → `LOW RISK` — reference docs optional but recommended
- **Near the edge** → `MEDIUM RISK` — reference docs recommended
- **Beyond training data** → `HIGH RISK` — reference docs required

Inform the user which category they're in and why.

---
