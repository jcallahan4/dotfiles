# Commands

## Shell (from ~/dotfiles, available everywhere)

| Command | What |
|---|---|
| `startup` | scaffold the current empty directory as a research project (uv, templates, hooks, CI, justfile, `baseline` tag) |
| `newexp <name>` | next numbered `experiments/NNN-name/` with SPEC, NOTES, config (copied from the previous experiment) |
| `nic` | tmux cockpit for this directory: nvim left, agent right, shell below; reattaches if it exists. `NIC_AGENT=claude nic` |
| `ontheroad` | start/check Codex remote control, print status, keep the Mac awake (Ctrl-C to stop). `ontheroad status`, `ontheroad stop` |
| `help <topic>` | this. Topics: `workflow`, `commands`, `keys`, `git` |

## just (inside a project; `just --list` shows what this repo has)

| Recipe | What | Needs |
|---|---|---|
| `just smoke` | whole pipeline in under a minute | nothing |
| `just test` | pytest | nothing |
| `just lint` | ruff format + check | nothing |
| `just run <exp>` | train on `experiments/<exp>/config.yaml` | the folder name, e.g. `001-posterior-calibration` |
| `just report` | table of every `runs/*/summary.json` | at least one run |
| `just since <tag>` | `git diff --stat <tag>..HEAD` | a tag you made with `git tag <tag>` |
| `just paper` | latexmk in `paper/` | a `paper/paper.tex` |
| `just clean` | remove caches and scratch runs | nothing |

## uv (inside a project)

| Command | Conda equivalent |
|---|---|
| `uv add pkg` / `uv add --dev pkg` | `conda install pkg` (also records it in pyproject + lock) |
| `uv remove pkg` | |
| `uv run <cmd>` | activate, then run (no activate step exists) |
| `uv sync` | after pulling changes to the lockfile |
| `uv python pin 3.13` | change this project's Python |
| `uv lock --upgrade-package torch` | deliberately bump one version |

## Codex

| Command | What |
|---|---|
| `codex` | interactive session (the right pane of `nic`) |
| `codex resume` | pick up a previous session |
| `codex review` | non-interactive review of a diff |
| `codex remote-control start --json` | daemon status (what `ontheroad` calls) |
| `codex remote-control pair` | pairing code for the phone |

## Pre-commit hook (automatic)

On every commit: ruff format + check on staged Python (fixes are re-staged), `uv lock
--check` if pyproject/lock changed, refuses `.ipynb`, gitleaks secrets scan. Never
`--no-verify`.

## Machine notes

Behind Zscaler: `SSL_CERT_FILE`, `CODEX_CA_CERTIFICATE`, `UV_SYSTEM_CERTS=1` are set in
`~/.zshrc.local` and must point at the Sandia bundle. Details: `~/dotfiles/NEW_MACHINE.md`.
