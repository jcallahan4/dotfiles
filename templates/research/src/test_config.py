"""Config loader tests. Add a hand-computed case for every equation you write."""

from pathlib import Path

from {{PACKAGE}}.config import Config, load_config


def test_defaults_and_overrides(tmp_path: Path) -> None:
    cfg_file = tmp_path / "c.yaml"
    cfg_file.write_text("steps: 5\nlr: 0.01\nnot_a_field: 3\n")
    cfg = load_config(["--config", str(cfg_file), "--lr", "0.5"])
    assert cfg.steps == 5
    assert cfg.lr == 0.5  # command line beats file
    assert cfg.batch_size == Config.batch_size
    assert cfg.extra == {"not_a_field": 3}
