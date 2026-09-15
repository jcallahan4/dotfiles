# Instructions for coding agents

Make one change per request, then stop and report. Do not continue to the
next step unless told to.

## Orientation

- Read `PROJECT.md` first. It states the claims this repo exists to test.
- Work inside the current experiment folder under `experiments/`. Read its
  `SPEC.md` before writing code.
- Shared code goes in `src/{{PACKAGE}}/`. Experiment folders hold configs,
  notes, and thin scripts only.

## Ownership

- Never modify another experiment's folder, `PROJECT.md`, or anything in
  `paper/` without being asked.
- Files listed under "Hands off" are edited only by me.
- When writing anything mathematical, add a comment stating the equation or
  the reference it implements. If I ask for an explanation, explain the math,
  not the code.

### Hands off

- (add files here as they are written, e.g. `src/{{PACKAGE}}/loss.py`)

## Increments

- One change per request, then stop and report.
- Commit after each change with a one-line message in the imperative. Never
  amend or rewrite history.
- Do not add a dependency without saying so. Use `uv add`, never
  `pip install`.

## Running things

- Use the `justfile` recipes (`just --list`): `just smoke`, `just test`, `just lint`,
  `just run <exp>`, `just report`. Don't invent commands that a recipe already covers.
- Use `uv run` for everything else. Never activate or create environments by hand.
- A pre-commit hook formats and lints staged Python, checks `uv.lock`, and scans for
  secrets. If it rewrites a file, the commit already includes the fix. Never bypass it
  with `--no-verify`.
- `src/{{PACKAGE}}/run.py` is the experiment entry point (`just run <exp>`). Every
  run starts with `start_run(cfg)` from `config.py`, which writes `config.json` and
  `meta.json` (git SHA, dirty flag, lockfile hash) into the run directory, and ends by
  writing `summary.json`. Keep that pattern whatever the experiment computes; add
  typed fields to `Config` instead of reading raw dicts.
- Before any run longer than a few minutes, run the smoke config
  (`configs/smoke.yaml`) and show me the result.
- All outputs go under `runs/<experiment-id>/`. Never write results anywhere
  else.
- Do not launch a long run, submit a Slurm job, or use the GPU without
  explicit instruction.

## Unattended runs

While babysitting a run you may:

- restart on crash,
- fix crashes in plumbing code (I/O, logging, argument handling),
- adjust values marked `# tunable` in the run's config.

You may not:

- change anything under `src/` that affects the method,
- change the experiment's metrics,
- start a different experiment.

When the run finishes or you hit this fence, append a results section to the
experiment's `SPEC.md` and stop.

## Writing

Applies to everything you write: docs, comments, commit messages, results
sections, and replies to me.

Avoid mannered prose. Mannered prose substitutes metaphor and flourish for
direct statement: "a dial worth turning" instead of "a parameter worth
varying," "this point earns its keep" instead of "this point still matters."
The phrases display the writer instead of conveying the idea, and metaphors
drag in connotations the writer did not choose. When a literal phrase is
available, use it.

Style (distilled from the Google developer documentation style guide):

- Second person ("you"), active voice, present tense.
- Short sentences, one idea each. Lead with the conclusion, then the reason.
- Plain words: "use" not "utilize," "before" not "prior to," "if" not
  "in the event that." No jargon the reader doesn't need.
- No filler: no "note that," "it's worth noting," "simply," "just,"
  "basically," "in order to."
- Define an acronym at first use. Don't invent names for things.
- Numbered lists for steps in order, bullets for everything else. Parallel
  structure within a list.
- Code, commands, filenames, and flags in backticks. Commands in fenced
  blocks, never inline in a sentence.
- Sentence-case headings. Serial comma. No exclamation marks.
- Don't hedge with stacked qualifiers or pad with pleasantries. State
  uncertainty once, precisely: "I haven't verified X."

`NOTES.md` files are mine. Do not write in them. Put your observations in the
results section of the experiment's `SPEC.md`. Keep reports short: what
happened, what you changed, what you're unsure about. Don't restate the plan.
