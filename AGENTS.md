# Game Studio Agent Architecture

Indie game development managed through 49 coordinated agents.
Each agent owns a specific domain, enforcing separation of concerns and quality.

The shared tree is `studio/`: skills, agents, rules, hooks, scripts, docs,
genres, and engines. `AGENTS.md` is the instruction file for every coding agent.
Platform folders (`.claude/`, `.cursor/`, `.agents/`) only point at that tree.

Before acting, read:

- `studio/docs/directory-structure.md`
- `studio/docs/coordination-rules.md`
- `studio/docs/coding-standards.md`

## Technology Stack

- **Engine**: [CHOOSE: Web / Godot 4 / Unity / Unreal Engine 5 / Bevy]
- **Language**: [CHOOSE: TypeScript / GDScript / C# / C++ / Blueprint / Rust]
- **Version Control**: Git with trunk-based development
- **Build System**: [SPECIFY after choosing engine]
- **Asset Pipeline**: [SPECIFY after choosing engine]

> **Note**: Engine-specialist agents exist for Godot, Unity, and Unreal with
> dedicated sub-specialists. Use the set matching your engine. Web and Bevy have
> no engine-specialist agent: engine work on those routes to `lead-programmer`
> against `docs/engine-reference/web/` or `docs/engine-reference/bevy/`.

## Project Structure

See `studio/docs/directory-structure.md`.

## Engine Version Reference

<!-- ENGINE-REFERENCE-IMPORT: the line under this comment is engine-specific,
     and there is none until an engine is set. /setup-engine, the grow's record
     step and /project-settings (engine.name) write
     @docs/engine-reference/<engine>/VERSION.md here for the chosen engine. Skills
     that need the pinned version read that file on demand either way. -->

When a line under that comment names a file, read it before using engine APIs.

## Technical Preferences

`project.yaml` at the repo root is the primary config store — engine, specialists,
naming, platform, performance, modes. Skills resolve it via `resolve_config`
(see `studio/docs/config-resolution.md`).

`studio/docs/technical-preferences.md` is the **legacy fallback**, read on demand
when a key is absent from `project.yaml`. It is not imported here: before
`/setup-engine` runs it is almost entirely `[TO BE CONFIGURED]` placeholders, and
after it runs `project.yaml` holds the real values.

## Coordination Rules

Follow `studio/docs/coordination-rules.md`.

## Collaboration Protocol

**User-driven collaboration, not autonomous execution.**
Every task follows: **Question -> Options -> Decision -> Draft -> Approval**

- Agents MUST ask "May I write this to [filepath]?" before using Write/Edit tools
  (exempt: `active.md` appends, agent memory, a subagent's new file at the path
  its orchestrating skill named; see `studio/rules/agent-memory.md`)
- Agents MUST show drafts or summaries before requesting approval
- Multi-file changes require explicit approval for the full changeset
- No commits without user instruction
- A skipped or dismissed question is not an answer: act on nothing, re-ask in
  plain text and wait
- On Claude Code, hooks, deny rules, and ask-first mode load only when the
  session starts in this folder. On every host, follow this file and `studio/`.

See `docs/COLLABORATIVE-DESIGN-PRINCIPLE.md` for full protocol and examples.

> **First session?** Say "make me a game", or run the prototype skill. Where the
> host has slash commands, that is `/prototype`. The guided onboarding skill is
> `/start` (or `studio/skills/start/SKILL.md`).

Skills are directories under `studio/skills/<name>/`. Agents are
`studio/agents/<name>.md`. A host that does not load those folders still follows
a skill when you open its `SKILL.md` or ask for it by name.

## Coding Standards

Follow `studio/docs/coding-standards.md`.

## Context Management

Read `studio/docs/context-management.md` on demand — it is a reference, not
session context. Two of its conventions are load-bearing and cited by name
elsewhere in the repo, so they are restated here rather than lost:

- **`production/session-state/active.md` is the session checkpoint.** The file is
  the memory, not the conversation. Read it first after any compaction, crash, or
  `/clear`.
- **Helpers in `studio/scripts/` emit observations, never verdicts.** A script
  that scores or judges will eventually contradict a mode or override it cannot
  see. (Cited by `artifact-check.sh` and `adr-dep-graph.sh`.)
