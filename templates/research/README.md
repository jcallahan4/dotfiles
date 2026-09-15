# {{PROJECT}}

See `PROJECT.md` for what this project is and `experiments/` for the record.

## Setup

```bash
uv sync
```

## Run

```bash
just --list        # all tasks
just smoke         # whole pipeline in under a minute
just run 001-name  # one experiment's config
just report        # table of every run's summary.json
```

## Layout

- `src/{{PACKAGE}}/` shared library code
- `experiments/NNN-name/` one folder per experiment: `SPEC.md`, `NOTES.md`, `config.yaml`
- `configs/` configs for the paper experiments
- `runs/` outputs (not tracked except `summary.json`, `config.json`, `meta.json`)
- `.githooks/pre-commit` ruff, `uv lock --check`, gitleaks; `.github/workflows/test.yml` CI
- `paper/` manuscript
