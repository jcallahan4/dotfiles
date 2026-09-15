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
  cp "$_research_tpl/MEETINGS.md" MEETINGS.md
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

# mtg: take meeting notes. Adds a dated header to MEETINGS.md (newest first) and opens
# Neovim at it. Inside a project (a directory with PROJECT.md up the tree) it uses that
# project's MEETINGS.md; otherwise ~/Desktop/writing/meetings.md.
#   mtg                 today's date
#   mtg "with Kate"     today's date plus a label
mtg() {
  local label="${1:-}" root="$PWD" file
  while [[ "$root" != / && ! -f "$root/PROJECT.md" ]]; do root="${root:h}"; done
  if [[ -f "$root/PROJECT.md" ]]; then
    file="$root/MEETINGS.md"
    [[ -f "$file" ]] || cp "$_research_tpl/MEETINGS.md" "$file"
  else
    file="$HOME/Desktop/writing/meetings.md"
    mkdir -p "${file:h}"
    [[ -f "$file" ]] || printf '# Meetings\n\nPersonal meeting notes not tied to one project. Newest first.\n\n' > "$file"
  fi
  local header="## $(date +%Y-%m-%d)${label:+ $label}"
  # insert after the intro block: first blank line that follows the first "## " or end of intro
  python3 - "$file" "$header" << 'PY'
import sys
path, header = sys.argv[1], sys.argv[2]
text = open(path).read()
lines = text.splitlines(keepends=True)
# insert before the first existing entry header, else at end
idx = next((i for i, l in enumerate(lines) if l.startswith("## ")), len(lines))
lines[idx:idx] = [header + "\n", "\n", "\n"]
open(path, "w").write("".join(lines))
PY
  local line; line=$(python3 -c "
import sys
for i,l in enumerate(open('$file'),1):
    if l.rstrip()=='''$header''': print(i+1); break")
  nvim "+${line}" "+startinsert" "$file"
}
