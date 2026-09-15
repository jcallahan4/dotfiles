# Plots

Every figure is a script. Notebooks are not used.

## The loop

1. Ask the agent: "Plot the EIG per design from run 003." It writes `figures/<name>.py`
   from the `figures/example.py` pattern, runs it, and reports the path of the PDF.
2. In the shell pane, run `just watch <name>`. Skim opens the PDF in its own window.
   Put that window on your second display or beside Ghostty.
3. Open `figures/<name>.py` in Neovim. Change a line. Save. The script reruns and Skim
   reloads within about two seconds.
4. If you need more room, press `F12 z` to zoom Neovim. Press it again to restore the
   panes.
5. Press Ctrl-C in the shell pane when you are done. The PDF is already in
   `paper/figures/`, where the manuscript reads it.

## Conventions

- One script per figure, in `figures/`, named after the figure.
- Scripts read from `runs/<id>/summary.json` or other run artifacts. They never contain
  typed-in numbers.
- Scripts write both PDF (paper) and PNG (slides).
- Style settings live in the `style()` function of each script. Copy them between
  scripts or move shared ones into `src/<pkg>/plotting.py` when they stabilize.
- `paper/figures/*.pdf` and `*.png` are not committed. `just figs` regenerates them all.

## Exploring data before you know what to plot

Ask the agent for a table first: `just report` for run summaries, or "print the first ten
rows of X" for anything else. Decide what the figure is, then ask for the script. If you
want a live Python session for poking at arrays, run `uv run ipython` in the shell pane;
it is a plain REPL and nothing depends on it.
