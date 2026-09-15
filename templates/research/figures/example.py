"""Figure script. One script per figure. Reads run outputs, writes paper/figures/<name>.pdf
and .png. Iterate with `just watch example` (reruns on save; Skim reloads the PDF).

Conventions the agent follows when asked to plot something:
- Read from runs/<id>/summary.json (or other run artifacts). Never hard-code numbers.
- Write both PDF (for the paper) and PNG (for slides and quick viewing).
- One figure per script, named after the figure. Keep style choices in `style()`.
- Print the output path at the end.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

import matplotlib

matplotlib.use("Agg")  # headless; the file is the output
import matplotlib.pyplot as plt

NAME = Path(__file__).stem
OUT = Path("paper/figures")


def style() -> None:
    plt.rcParams.update({
        "figure.figsize": (5.5, 3.4),
        "font.size": 9,
        "axes.spines.top": False,
        "axes.spines.right": False,
        "savefig.bbox": "tight",
    })


def load_runs(root: Path = Path("runs")) -> list[dict]:
    rows = []
    for summary in sorted(root.glob("*/summary.json")):
        row = json.loads(summary.read_text())
        row["run"] = summary.parent.name
        rows.append(row)
    return rows


def main() -> None:
    style()
    rows = load_runs()
    if not rows:
        sys.exit("no runs/*/summary.json to plot; run `just smoke` first")

    fig, ax = plt.subplots()
    # --- replace from here: the example plots one summary value per run -------------
    key = next(k for k in rows[0] if k not in ("run",) and isinstance(rows[0][k], (int, float)))
    ax.bar([r["run"] for r in rows], [r[key] for r in rows])
    ax.set_xlabel("run")
    ax.set_ylabel(key)
    # --- to here -------------------------------------------------------------------

    OUT.mkdir(parents=True, exist_ok=True)
    for ext in ("pdf", "png"):
        fig.savefig(OUT / f"{NAME}.{ext}", dpi=200)
    print(OUT / f"{NAME}.pdf")


if __name__ == "__main__":
    main()
