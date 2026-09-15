# Research project scaffolding. Sourced by zshrc_common.
#   startup            scaffold the current (empty or new) directory as a uv project
#   newexp <name>      create the next numbered experiment folder
# Templates live in ~/dotfiles/templates/research/. Placeholders: {{PROJECT}},
# {{PACKAGE}}, {{DATE}}, {{EXP_ID}}, {{EXP_NAME}}.

_research_tpl="$HOME/dotfiles/templates/research"

# _research_render SRC DST key=value ...
_research_render() {
  local src="$1" dst="$2"; shift 2
  local expr=""
  for kv in "$@"; do
    local k="${kv%%=*}" v="${kv#*=}"
    v="${v//\//\\/}"   # escape slashes for sed
    expr="$expr;s/{{$k}}/$v/g"
  done
  sed "${expr#;}" "$src" > "$dst"
}

startup() {
  local project="${1:-$(basename "$PWD")}"
  local package="${project//-/_}"; package="${package//./_}"; package="${(L)package}"
  local today="$(date +%Y-%m-%d)"

  if [[ -f pyproject.toml || -f PROJECT.md ]]; then
    echo "startup: pyproject.toml or PROJECT.md already exists here; refusing to overwrite." >&2
    return 1
  fi
  command -v uv >/dev/null 2>&1 || { echo "startup: uv not found (curl -LsSf https://astral.sh/uv/install.sh | sh)" >&2; return 1; }

  echo "==> uv init --lib ($package)"
  uv init --lib --name "$package" --python 3.12 --no-workspace --vcs none . >/dev/null
  rm -f README.md   # uv's stub; replaced below
  cat "$_research_tpl/pyproject-append.toml" >> pyproject.toml

  echo "==> layout"
  mkdir -p experiments configs runs tests paper
  touch experiments/.gitkeep runs/.gitkeep paper/.gitkeep
  _research_render "$_research_tpl/PROJECT.md" PROJECT.md PROJECT="$project" PACKAGE="$package" DATE="$today"
  _research_render "$_research_tpl/AGENTS.md"  AGENTS.md  PROJECT="$project" PACKAGE="$package" DATE="$today"
  _research_render "$_research_tpl/README.md"   README.md  PROJECT="$project" PACKAGE="$package" DATE="$today"
  _mtg_link "$PWD" || true   # MEETINGS.md -> ~/notes/meetings.md (gitignored)
  _research_render "$_research_tpl/gitignore"   .gitignore PROJECT="$project" PACKAGE="$package"
  _research_render "$_research_tpl/configs-smoke.yaml" configs/smoke.yaml PACKAGE="$package"
  cat > tests/test_smoke.py << PY
def test_import():
    import $package  # noqa: F401
PY
  # config loader, train/report entry points, config test, justfile, CI, git hooks
  for f in config.py run.py report.py; do
    _research_render "$_research_tpl/src/$f" "src/$package/$f" PACKAGE="$package"
  done
  _research_render "$_research_tpl/src/test_config.py" tests/test_config.py PACKAGE="$package"
  _research_render "$_research_tpl/justfile" justfile PACKAGE="$package"
  mkdir -p figures paper/figures && cp "$_research_tpl/figures/example.py" figures/example.py
  mkdir -p .github/workflows .githooks
  cp "$_research_tpl/github-workflows/test.yml" .github/workflows/test.yml
  cp "$_research_tpl/githooks/pre-commit" .githooks/pre-commit && chmod +x .githooks/pre-commit

  echo "==> dependencies + lock"
  uv add pyyaml matplotlib >/dev/null 2>&1
  uv add --dev pytest ruff >/dev/null 2>&1
  echo "==> lint + test"
  uv run ruff format . >/dev/null 2>&1 && uv run ruff check --fix . >/dev/null 2>&1 || true
  uv run pytest -q tests/ 2>&1 | tail -1

  echo "==> git"
  [[ -d .git ]] || git init -q
  git config core.hooksPath .githooks
  git add -A && git commit -q -m "Scaffold $project (startup)" && git tag -f baseline >/dev/null

  echo "==> smoke run (writes runs/smoke with the baseline git SHA)"
  uv run python -m "$package.run" --config configs/smoke.yaml 2>&1 | tail -1
  echo
  echo "Project '$project' ready (package '$package'). Tagged 'baseline'."
  echo "Pre-commit hook: ruff format+check, uv lock --check, gitleaks. 'just --list' for tasks."
  echo "Next: edit PROJECT.md, then 'newexp <name>' for the first experiment, then 'bench'."
}

newexp() {
  local name="$1"
  [[ -z "$name" ]] && { echo "usage: newexp <short-name>   (e.g. newexp huber-vs-mse)" >&2; return 1; }
  [[ -d experiments ]] || { echo "newexp: no experiments/ here; run from the project root (or run 'startup' first)" >&2; return 1; }
  name="${name// /-}"; name="${(L)name}"

  local last n
  local -a existing
  existing=( experiments/[0-9][0-9][0-9]-*(N/) )
  existing=( ${(o)existing} )
  last="${existing[-1]}"
  if [[ -n "$last" ]]; then n=$(( ${${last:t}[1,3]} + 1 )); else n=1; fi
  local id; id="$(printf '%03d' "$n")"
  local dir="experiments/$id-$name" today="$(date +%Y-%m-%d)"

  mkdir -p "$dir"
  _research_render "$_research_tpl/experiment/SPEC.md"  "$dir/SPEC.md"  EXP_ID="$id" EXP_NAME="$name" DATE="$today"
  _research_render "$_research_tpl/experiment/NOTES.md" "$dir/NOTES.md" EXP_ID="$id" EXP_NAME="$name" DATE="$today"
  # config: copy the previous experiment's as a starting point, else the template
  if [[ -n "$last" && -f "$last/config.yaml" ]]; then
    sed "s#^run_dir:.*#run_dir: runs/$id#" "$last/config.yaml" > "$dir/config.yaml"
    sed -i '' "1s#.*#\# Config for $id $name (copied from ${last:t}).#" "$dir/config.yaml"
  else
    _research_render "$_research_tpl/experiment/config.yaml" "$dir/config.yaml" EXP_ID="$id" EXP_NAME="$name" DATE="$today"
  fi
  mkdir -p "runs/$id"

  git add "$dir" 2>/dev/null && git commit -q -m "Add experiment $id-$name" 2>/dev/null || true
  echo "Created $dir"
  echo "Next: write $dir/SPEC.md before any code."
}

# mtg: meeting notes. One master file for all meetings, $MEETINGS_FILE
# (default ~/notes/meetings.md). Every project gets a gitignored MEETINGS.md symlink to
# it (created by `startup`, or by `mtg` on first use inside a project), so agents in any
# project read the same notes. Adds a dated header (newest first) and opens Neovim there.
#   mtg                 today's date
#   mtg "with Kate"     today's date plus a label
# Inside an entry, start a line with the project name when a meeting covers several.
: "${MEETINGS_FILE:=$HOME/notes/meetings.md}"

_mtg_ensure_master() {
  mkdir -p "${MEETINGS_FILE:h}"
  [[ -f "$MEETINGS_FILE" ]] || cp "$_research_tpl/MEETINGS.md" "$MEETINGS_FILE"
}

# _mtg_link DIR: make DIR/MEETINGS.md a symlink to the master (no-op if it already is).
_mtg_link() {
  local dir="$1"
  _mtg_ensure_master
  [[ -L "$dir/MEETINGS.md" ]] && return 0
  if [[ -f "$dir/MEETINGS.md" ]]; then
    echo "mtg: $dir/MEETINGS.md is a regular file; append its contents to $MEETINGS_FILE and remove it, then rerun" >&2
    return 1
  fi
  ln -s "$MEETINGS_FILE" "$dir/MEETINGS.md"
}


# mtg done: after a meeting. Commits ~/notes (making it a git repo on first use), then
# asks Codex (non-interactive, sandboxed to this project) to copy the lines of the newest
# entry that concern this project into docs/meetings.md with an action-item list, commits
# that, and prints the decisions, your todos, their todos, and next steps.
_mtg_done() {
  local root="$PWD"
  while [[ "$root" != / && ! -f "$root/PROJECT.md" ]]; do root="${root:h}"; done
  [[ -f "$root/PROJECT.md" ]] || { echo "mtg done: run inside a project (no PROJECT.md found)" >&2; return 1; }
  local project="${root:t}"
  _mtg_ensure_master

  # 1. commit the master notes
  ( cd "${MEETINGS_FILE:h}" && { [[ -d .git ]] || git init -q; } \
    && git add -A && { git diff --cached --quiet || git commit -q -m "Meeting notes $(date +%Y-%m-%d)"; } )

  # 2. newest entry
  local entry
  entry=$(python3 - "$MEETINGS_FILE" << 'PY'
import sys
lines = open(sys.argv[1]).read().splitlines()
starts = [i for i, l in enumerate(lines) if l.startswith("## ")]
if not starts: sys.exit("no entries")
a = starts[0]; b = starts[1] if len(starts) > 1 else len(lines)
print("\n".join(lines[a:b]).strip())
PY
  )
  [[ -n "$entry" ]] || return 1

  # 3. agent: extract the project-relevant part + action items into docs/meetings.md
  local codex_bin="${CODEX_BIN:-$HOME/.local/bin/codex}"; [[ -x "$codex_bin" ]] || codex_bin="$(command -v codex)"
  echo "==> extracting notes for '$project' into docs/meetings.md"
  ( cd "$root" && "$codex_bin" exec --ephemeral -s workspace-write -C "$root" "You are processing meeting notes for the research project '$project' (this repository; read PROJECT.md for context).

Below is the newest entry from the owner's master meeting file, which may cover several projects. Lines about other projects usually start with that project's name.

1. Create docs/meetings.md if it does not exist, with the header '# Meeting log' and one line: 'Extracted by the agent from the owner's master meeting notes after each meeting. Edit the master, not this file.'
2. Append a section for this entry: its '## ' header verbatim, then only the lines relevant to '$project' (if nothing names a project, include everything), lightly cleaned but not rewritten, then an 'Action items' list with three sublists: 'Owner owes', 'Others owe', 'Next steps'. Infer items only from the notes; do not invent.
3. Do not modify any other file. Do not commit.
4. Then print to stdout, in plain prose, no metaphors: 'Decisions:' with bullets, 'You owe:' with bullets, 'They owe:' with bullets, 'Next steps:' with bullets. Nothing else.

Entry:
$entry" 2>/dev/null | sed '/^\s*$/d' )

  # 4. commit the extracted log in the project
  ( cd "$root" && git add docs/meetings.md 2>/dev/null && { git diff --cached --quiet || git -c commit.gpgsign=false commit -q -m "Log meeting notes $(date +%Y-%m-%d)"; } ) || true
}

# dispatch: `mtg done` -> _mtg_done; anything else -> new entry with optional label
mtg() {
  if [[ "${1:-}" == done ]]; then _mtg_done; return; fi
  local label="${1:-}" root="$PWD"
  while [[ "$root" != / && ! -f "$root/PROJECT.md" ]]; do root="${root:h}"; done
  _mtg_ensure_master
  [[ -f "$root/PROJECT.md" ]] && _mtg_link "$root"
  local header="## $(date +%Y-%m-%d)${label:+ $label}"
  local line
  line=$(MTG_HEADER="$header" python3 - "$MEETINGS_FILE" << 'PY'
import os, sys
path = sys.argv[1]; header = os.environ["MTG_HEADER"]
lines = open(path).read().splitlines(keepends=True)
idx = next((i for i, l in enumerate(lines) if l.startswith("## ")), len(lines))
lines[idx:idx] = [header + "\n", "\n", "\n"]
open(path, "w").write("".join(lines))
print(idx + 2)
PY
  )
  nvim "+${line}" "+startinsert" "$MEETINGS_FILE"
}
