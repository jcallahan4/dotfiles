"""Training entry point. Replace the body of `main`; keep the config/start_run/summary
pattern so every run is recorded the same way.

    uv run python -m {{PACKAGE}}.train --config configs/smoke.yaml
"""

from __future__ import annotations

import json
import random

from {{PACKAGE}}.config import load_config, start_run


def main() -> None:
    cfg = load_config()
    run_dir = start_run(cfg)
    random.seed(cfg.seed)

    # --- replace from here ---------------------------------------------------------
    metrics = {"final_loss": 1.0 / (1 + cfg.steps)}
    # --- to here -------------------------------------------------------------------

    (run_dir / "summary.json").write_text(json.dumps({"config": cfg.run_dir, **metrics}, indent=2) + "\n")
    print(f"run complete: {run_dir}  {metrics}")


if __name__ == "__main__":
    main()
