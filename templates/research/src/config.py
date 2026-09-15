"""Run configuration: a dataclass with defaults, loaded from YAML, overridable from the
command line. Every run writes its resolved config to <run_dir>/config.json.

    uv run python -m {{PACKAGE}}.run --config configs/smoke.yaml --n_samples 200
"""

from __future__ import annotations

import argparse
import dataclasses
import json
import subprocess
from dataclasses import dataclass, field, fields
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, get_type_hints

import yaml


@dataclass
class Config:
    """Add a typed field for every setting an experiment needs. Delete the examples.
    Mark values the agent may change during an unattended run with `# tunable`."""

    seed: int = 0
    run_dir: str = "runs/scratch"
    device: str = "cpu"  # "cuda" on the cluster, "mps" on a Mac GPU
    n_samples: int = 1000  # example: Monte Carlo samples per estimate  # tunable
    n_designs: int = 10  # example: candidate designs to evaluate
    # Free-form extras that don't deserve a field yet. Promote them when they stabilize.
    extra: dict[str, Any] = field(default_factory=dict)


def load_config(argv: list[str] | None = None) -> Config:
    """YAML file (--config) then command-line overrides (--<field> value)."""
    parser = argparse.ArgumentParser()
    parser.add_argument("--config", type=Path, default=None)
    hints = get_type_hints(Config)  # real types, not the string annotations
    for f in fields(Config):
        if f.name == "extra":
            continue
        parser.add_argument(f"--{f.name}", type=hints[f.name] if hints[f.name] in (int, float, str) else str)
    args = parser.parse_args(argv)

    values: dict[str, Any] = {}
    if args.config is not None:
        values.update(yaml.safe_load(args.config.read_text()) or {})
    known = {f.name for f in fields(Config)}
    extra = {k: v for k, v in values.items() if k not in known}
    values = {k: v for k, v in values.items() if k in known}
    for f in fields(Config):
        override = getattr(args, f.name, None)
        if override is not None:
            values[f.name] = override
    cfg = Config(**values)
    cfg.extra.update(extra)
    return cfg


def run_metadata() -> dict[str, Any]:
    """What produced this run: git state, time, lockfile hash. Written next to outputs."""

    def git(*a: str) -> str:
        try:
            return subprocess.run(["git", *a], capture_output=True, text=True, check=True).stdout.strip()
        except (OSError, subprocess.CalledProcessError):
            return ""

    lock = Path("uv.lock")
    return {
        "git_sha": git("rev-parse", "HEAD"),
        "git_branch": git("rev-parse", "--abbrev-ref", "HEAD"),
        "git_dirty": bool(git("status", "--porcelain")),
        "git_describe": git("describe", "--tags", "--always", "--dirty"),
        "started_utc": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "uv_lock_sha256": __import__("hashlib").sha256(lock.read_bytes()).hexdigest() if lock.exists() else None,
    }


def start_run(cfg: Config) -> Path:
    """Create run_dir and write config.json and meta.json. Call once at the top of a run."""
    run_dir = Path(cfg.run_dir)
    run_dir.mkdir(parents=True, exist_ok=True)
    (run_dir / "config.json").write_text(json.dumps(dataclasses.asdict(cfg), indent=2) + "\n")
    (run_dir / "meta.json").write_text(json.dumps(run_metadata(), indent=2) + "\n")
    return run_dir
