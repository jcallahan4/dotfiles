# {{PROJECT}}

See `PROJECT.md` for what this project is and `experiments/` for the record.

## Setup

```bash
uv sync
```

## Run

```bash
uv run python -m {{PACKAGE}}.train --config configs/smoke.yaml
```

## Layout

- `src/{{PACKAGE}}/` shared library code
- `experiments/NNN-name/` one folder per experiment: `SPEC.md`, `NOTES.md`, `config.yaml`
- `configs/` configs for the paper experiments
- `runs/` outputs (not tracked except summaries)
- `paper/` manuscript
