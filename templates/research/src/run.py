"""Experiment entry point. Replace the body of `main`. Keep the pattern: load config,
start the run (writes config.json and meta.json), do the work, write summary.json.

    uv run python -m {{PACKAGE}}.run --config configs/smoke.yaml
    just run 001-name          # same, with experiments/001-name/config.yaml

The "work" can be anything: a Monte Carlo EIG estimate over candidate designs, a
sensitivity sweep, a posterior check, a training loop. summary.json holds the numbers
you would put in a table.
"""

from __future__ import annotations

import json
import random

from {{PACKAGE}}.config import load_config, start_run


def main() -> None:
    cfg = load_config()
    run_dir = start_run(cfg)
    rng = random.Random(cfg.seed)

    # --- replace from here ---------------------------------------------------------
    draws = [rng.random() for _ in range(cfg.n_samples)]
    results = {"mean": sum(draws) / len(draws), "n_samples": cfg.n_samples}
    # --- to here -------------------------------------------------------------------

    (run_dir / "summary.json").write_text(json.dumps(results, indent=2) + "\n")
    print(f"run complete: {run_dir}  {results}")


if __name__ == "__main__":
    main()
