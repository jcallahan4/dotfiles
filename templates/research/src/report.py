"""Tabulate every runs/*/summary.json into one table.

    uv run python -m {{PACKAGE}}.report runs/
"""

from __future__ import annotations

import json
import sys
from pathlib import Path


def main() -> None:
    root = Path(sys.argv[1] if len(sys.argv) > 1 else "runs")
    rows = []
    for summary in sorted(root.glob("*/summary.json")):
        meta_path = summary.parent / "meta.json"
        meta = json.loads(meta_path.read_text()) if meta_path.exists() else {}
        row = {"run": summary.parent.name, "git": (meta.get("git_describe") or "")[:20]}
        row.update({k: v for k, v in json.loads(summary.read_text()).items() if k != "config"})
        rows.append(row)
    if not rows:
        print(f"no summaries under {root}")
        return
    cols = list(dict.fromkeys(k for r in rows for k in r))
    widths = {c: max(len(c), *(len(f"{r.get(c, '')}") for r in rows)) for c in cols}
    print("  ".join(c.ljust(widths[c]) for c in cols))
    for r in rows:
        print("  ".join(f"{r.get(c, '')}".ljust(widths[c]) for c in cols))


if __name__ == "__main__":
    main()
