"""Config loader tests. Add a hand-computed case for every equation you write."""

from pathlib import Path

from {{PACKAGE}}.config import Config, load_config


def test_defaults_and_overrides(tmp_path: Path) -> None:
    cfg_file = tmp_path / "c.yaml"
    cfg_file.write_text("n_designs: 5\nn_samples: 10\nnot_a_field: 3\n")
    cfg = load_config(["--config", str(cfg_file), "--n_samples", "50"])
    assert cfg.n_designs == 5
    assert cfg.n_samples == 50  # command line beats file
    assert cfg.device == Config.device
    assert cfg.extra == {"not_a_field": 3}
