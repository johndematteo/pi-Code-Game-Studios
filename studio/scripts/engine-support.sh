#!/usr/bin/env bash
# engine-support.sh — what each engine the framework claims to support actually
# gets: its row in the engine table, whether the config validator accepts its
# name, whether every script that switches on an engine recognises it, whether
# its reference tree exists, and which specialist engine work routes to.
#
# WHY THIS EXISTS
#
# Adding an engine touches scripts that each keep their own `case` on the engine
# name (write-guard, asset-scan, content-count, test-run, test-scaffold,
# project-coherence) plus the config validator and the engine table. A missing
# arm does not fail loudly: the script exits 3, or silently reads the wrong
# engine's folders. studio/engines/README.md already carries one warning of this
# shape ("test-scaffold.sh does not read it ... a change to test_root here must
# also be made there"). This is the check that notices.
#
# It asks the scripts rather than reading their text: each one is run in the mode
# that only works when it recognises the engine, and its exit code is reported.
# A comment mentioning the engine does not satisfy it; an arm does.
#
# EMITS OBSERVATIONS, NOT A VERDICT (AGENTS.md, "Helpers in studio/scripts/").
# Nothing here is a PASS, WARN or FAIL: `ok` and `unknown-engine` are exit codes
# put into words, and whether a missing reference tree stops the work is the
# calling skill's call. A check that could not run says so by name and is not
# counted as agreement.
#
# Usage: bash studio/scripts/engine-support.sh [--root DIR]
#   --root DIR   the project; defaults to the repo this script is in
#   -h, --help   this text
#
# Output: TSV, one block per engine named in studio/engines/engines.tsv, in the
# order the table lists them:
#   engine        <name>
#   row           code_root=<v> test_root=<v> asset_root=<v> test=<v>  (- = none)
#   enum          <accepts|rejects>  <the validator's message, or ->
#   specialist    <agent|none>  <engine.name|technical-preferences.md|unset>
#   script        <name>  <ok|unknown-engine|usage|missing|error>  <exit code>
#   reference     <path>  <present|absent>
# and last:
#   table         <engine>  <present|absent>   the five engines this repo knows,
#                                               whether or not the table lists them
#   engines       <n>  <the table>
#   scripts       <n>  <the scripts asked>
#
# Exit codes: 0 read the table (whatever it found); 1 the engine table or
# engine-row.awk is missing, or the root cannot be read; 2 usage error.

set -u
export LC_ALL=C

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$HERE/../.."
usage() { echo "engine-support: $1 (try --help)" >&2; exit 2; }
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) sed -n '2,/^$/p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    --root) [ $# -ge 2 ] || usage "--root needs a directory"; ROOT="$2"; shift 2 ;;
    --root=*) ROOT="${1#--root=}"; shift ;;
    -?*) usage "unknown argument: $1" ;;
    *) usage "takes no positional arguments, got $1" ;;
  esac
done
ROOT="$(cd "$ROOT" 2>/dev/null && pwd)" || { echo "engine-support: cannot read root $ROOT" >&2; exit 1; }

ETAB="$ROOT/studio/engines/engines.tsv"
ROWER="$ROOT/studio/scripts/engine-row.awk"
YH="$ROOT/studio/hooks/yaml-helper.sh"
[ -f "$ETAB" ] || { echo "engine-support: the engine table $ETAB is missing" >&2; exit 1; }
[ -f "$ROWER" ] || { echo "engine-support: $ROWER is missing" >&2; exit 1; }

cell() { awk -F'\t' -v engine="$1" -v col="$2" -f "$ROWER" "$ETAB" 2>/dev/null; }
lc() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]'; }

# The engine names, skipping the header row: the table's first cell there is
# `engine`, which is not an engine.
NAMES=$(awk -F'\t' 'NR == 1 { next } /^#/ || $0 == "" { next } { print $1 }' "$ETAB" | tr -d '\r')

# A scratch project for the scripts that need somewhere to look. Every engine
# gets the same tree, with its own asset root present, so a script that reads the
# wrong row still finds something to scan.
WORK=$(mktemp -d "${TMPDIR:-/tmp}/engine-support-XXXXXX" 2>/dev/null) || {
  echo "engine-support: cannot create a scratch directory" >&2; exit 1; }
trap 'rm -rf "$WORK"' EXIT HUP INT TERM

# yh_call DIR FUNCTION ARGS... -- a yaml-helper function run with DIR as the
# project. `$0` is set to a name that is not the helper's path, because the
# helper runs its own command dispatch when those two match, and a dispatch
# would exit before the function ran.
yh_call() {
  local dir="$1"; shift
  ( cd "$dir" && bash -c 'source "$1"; shift; "$@"' _ "$YH" "$@" )
}

# script_state NAME [ENV=KV] ARGS... -- run a studio script in the mode that only
# works when it recognises the engine, and put its exit code into words. 3 is the
# unknown-engine exit every one of these scripts shares; 2 is its usage error,
# which an arm that is present never reaches.
script_state() {
  local name="$1"; shift
  local kv=""
  case "${1:-}" in *=*) kv="$1"; shift ;; esac
  [ -f "$ROOT/studio/scripts/$name" ] || { printf 'script\t%s\tmissing\t-\n' "$name"; return 0; }
  if [ -n "$kv" ]; then
    env "$kv" bash "$ROOT/studio/scripts/$name" "$@" >/dev/null 2>&1
  else
    bash "$ROOT/studio/scripts/$name" "$@" >/dev/null 2>&1
  fi
  local code=$?
  case "$code" in
    0) printf 'script\t%s\tok\t0\n' "$name" ;;
    3) printf 'script\t%s\tunknown-engine\t3\n' "$name" ;;
    2) printf 'script\t%s\tusage\t2\n' "$name" ;;
    *) printf 'script\t%s\terror\t%s\n' "$name" "$code" ;;
  esac
}

NENG=0
for name in $NAMES; do
  [ -n "$name" ] || continue
  NENG=$((NENG + 1))
  d="$WORK/$(lc "$name")"
  mkdir -p "$d" 2>/dev/null
  printf 'engine:\n  name: %s\n' "$name" > "$d/project.yaml"
  : > "$d/keep.txt"

  printf 'engine\t%s\n' "$name"
  printf 'row\tcode_root=%s test_root=%s asset_root=%s test=%s\n' \
    "$(cell "$name" code_root)" "$(cell "$name" test_root)" \
    "$(cell "$name" asset_root)" "$(cell "$name" test)"

  # --- the config validator, asked about a file that names this engine ---
  if yh_call "$d" validate_yaml_enum project.yaml >/dev/null 2>&1; then
    printf 'enum\taccepts\t-\n'
  else
    msg=$(yh_call "$d" validate_yaml_enum project.yaml 2>&1 | tr -d '\r' | head -1)
    printf 'enum\trejects\t%s\n' "${msg:-no message}"
  fi

  # --- the specialist engine work routes to ---
  spec=$(yh_call "$d" resolve_config --keys specialists 2>/dev/null \
    | awk '/^specialists:/ { print; exit }')
  prim=$(printf '%s\n' "$spec" | awk '{ if (match($0, /primary=[^ ]*/)) { print substr($0, RSTART + 8, RLENGTH - 8); exit } }')
  if [ -n "$prim" ]; then
    agent=${prim%%(*}
    src=${prim#*(}; src=${src%)}
    printf 'specialist\t%s\t%s\n' "$agent" "${src:-unset}"
  else
    printf 'specialist\tnone\tunset\n'
  fi

  # --- the scripts that switch on an engine, asked to recognise it ---
  # The scratch tree gets this engine's asset root, so asset-scan and
  # content-count reach their scan instead of stopping at an absent folder.
  aroot=$(cell "$name" asset_root)
  [ -n "$aroot" ] && mkdir -p "$d/$aroot" 2>/dev/null
  script_state test-run.sh "$(lc "$name")" --root "$d" --dry-run
  script_state test-scaffold.sh "$(lc "$name")" --root "$d" --list
  script_state asset-scan.sh --root "$d" --engine "$(lc "$name")"
  script_state content-count.sh --root "$d" found --engine "$(lc "$name")"
  script_state write-guard.sh --root "$d" overwrite keep.txt
  # project-coherence.sh takes no --root: it reads CLAUDE_PROJECT_DIR.
  script_state project-coherence.sh "CLAUDE_PROJECT_DIR=$d"

  # --- the reference tree AGENTS.md's import points at ---
  REF="$ROOT/docs/engine-reference/$(lc "$name")/VERSION.md"
  if [ -f "$REF" ]; then printf 'reference\tdocs/engine-reference/%s/VERSION.md\tpresent\n' "$(lc "$name")"
  else printf 'reference\tdocs/engine-reference/%s/VERSION.md\tabsent\n' "$(lc "$name")"; fi
done

printf 'engines\t%s\t%s\n' "$NENG" "studio/engines/engines.tsv"

# A row deleted from the table would otherwise vanish from the report without a
# word. Name the engines this repo knows and say whether each has a row, so a
# dropped engine is visible as `absent` rather than silently missing.
for known in Godot Unity Unreal Web Bevy; do
  if awk -F'\t' -v e="$known" '$1 == e { f = 1 } END { exit(f ? 0 : 1) }' "$ETAB"; then
    printf 'table\t%s\tpresent\n' "$known"
  else
    printf 'table\t%s\tabsent\n' "$known"
  fi
done

printf 'scripts\t6\twrite-guard asset-scan content-count test-run test-scaffold project-coherence\n'
exit 0
