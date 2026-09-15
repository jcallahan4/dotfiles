# Commands

## Shell commands

These come from `~/dotfiles` and work in any directory.

| Command | What it does |
|---|---|
| `startup` | Scaffolds the current empty directory as a research project: uv project, templates, pre-commit hook, CI workflow, justfile, and a `baseline` tag. |
| `newexp <name>` | Creates the next numbered `experiments/NNN-name/` folder with `SPEC.md`, `NOTES.md`, and a `config.yaml` copied from the previous experiment. |
| `nic` | Opens a tmux session for this directory: Neovim top left, a shell under it, and the agent in a full-height pane on the right (40% wide). Reattaches if the session exists. `NIC_AGENT=claude nic` uses Claude Code; `NIC_AGENT_WIDTH=35 nic` changes the agent width. |
| `ontheroad` | Starts Codex remote control if it is not running, prints the connection status, and keeps the Mac awake until you press Ctrl-C. Use `ontheroad status` or `ontheroad stop` for those actions alone. |
| `help <topic>` | Shows this reference. Topics: `workflow`, `commands`, `keys`, `git`, `plots`. |
| `skim-place [file.pdf]` | Moves the Skim window for that PDF to the second display, or the right half of one display. `just watch` and `just paper` call it. |

## just recipes

Run these inside a project. `just --list` shows the recipes that this repository has.

| Recipe | What it does | Requires |
|---|---|---|
| `just smoke` | Runs `src/<pkg>/run.py` with `configs/smoke.yaml`: the whole pipeline in under a minute. | Nothing |
| `just test` | Runs pytest. | Nothing |
| `just lint` | Runs `ruff format` and `ruff check --fix`. | Nothing |
| `just run <exp>` | Runs `src/<pkg>/run.py` with `experiments/<exp>/config.yaml`. The script computes whatever the experiment is: an EIG estimate, a sweep, a training loop. | The folder name, for example `001-posterior-calibration` |
| `just report` | Prints a table of every `runs/*/summary.json`. | At least one completed run |
| `just since <tag>` | Runs `git diff --stat <tag>..HEAD`. | A tag you created with `git tag <tag>` |
| `just fig <name>` | Runs `figures/<name>.py`, which writes `paper/figures/<name>.pdf` and `.png`. | The script |
| `just watch <name>` | Opens the PDF in Skim, then reruns the script every time you save it. Ctrl-C stops. | The script |
| `just figs` | Renders every figure script. | |
| `just paper` | Runs latexmk in `paper/`. | `paper/paper.tex` |
| `just clean` | Removes caches and scratch runs. | Nothing |

## uv commands

Run these inside a project.

| Command | Conda equivalent |
|---|---|
| `uv add <pkg>` or `uv add --dev <pkg>` | `conda install <pkg>`. Also records the package in `pyproject.toml` and `uv.lock`. |
| `uv remove <pkg>` | `conda remove <pkg>` |
| `uv run <command>` | Activate the environment, then run the command. There is no separate activate step. |
| `uv sync` | Recreate the environment after the lockfile changes. |
| `uv python pin 3.13` | Change this project's Python version. |
| `uv lock --upgrade-package torch` | Upgrade one package deliberately. |

## Codex commands

| Command | What it does |
|---|---|
| `codex` | Starts an interactive session. This runs in the right pane of `nic`. |
| `codex resume` | Resumes a previous session. |
| `codex review` | Reviews a diff without a conversation. |
| `codex remote-control start --json` | Prints the daemon status. `ontheroad` calls this. |
| `codex remote-control pair` | Prints a pairing code for the phone app. |

## Pre-commit hook

The hook runs on every commit. It formats and lints staged Python files and re-stages
the fixes, checks `uv.lock` when `pyproject.toml` or `uv.lock` changed, refuses `.ipynb`
files, and scans staged changes for secrets with gitleaks. Do not use `--no-verify`.

## Machine notes

This Mac is behind Zscaler. `SSL_CERT_FILE`, `CODEX_CA_CERTIFICATE`, and
`UV_SYSTEM_CERTS=1` are set in `~/.zshrc.local` and point at the Sandia certificate
bundle. See `~/dotfiles/NEW_MACHINE.md` for details.
