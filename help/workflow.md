# Research workflow

One repo per paper-scale question. One folder per experiment. You write the spec and the
notes; the agent writes code in small steps you read as diffs.

## Files and who owns them

| File | Owner | When |
|---|---|---|
| `PROJECT.md` | you | written on day one; read before every experiment; edited 1-3 lines when a result changes a claim; ends up holding the paper outline |
| `experiments/NNN-name/SPEC.md` | you, then agent | you write question / setup / what would convince me / plan **before code**; agent appends **Results** after a run; you add one verdict line |
| `experiments/NNN-name/NOTES.md` | you only | a few sentences after every run, in your words |
| `AGENTS.md` | you | rules the agent follows; add files to "Hands off" as you write them |
| `runs/<id>/` | scripts | `config.json`, `meta.json` (git SHA), `summary.json` |

## The loop

1. `newexp name`, write the SPEC (20 min).
2. Prompt the agent for **one** change. It edits, the hook lints, it commits, it stops.
3. Read the diff: `Space g D` in Neovim. Read the math line by line, skim the plumbing.
4. Repeat 2-3. Write pieces yourself when that is faster than explaining.
5. `just test`, `just smoke` before anything long.
6. `git tag exp-NNN`, then `just run NNN-name 2>&1 | tee runs/NNN/train.log`.
7. Tell the agent to babysit under the "Unattended runs" rules; `Ctrl-Space d` or `F12 d`
   to detach; `ontheroad` if leaving.
8. Morning: `just since exp-NNN`, `just report`, `Space g r` with the tag, then read the
   Results in SPEC. Never read the transcript first.
9. Write NOTES. Update PROJECT.md only if a claim changed. `git push`.

## New project

```
mkdir proj && cd proj && startup     # uv project, templates, hooks, CI, justfile, tag baseline
# write PROJECT.md
newexp first-question
nic
```

## When to make a new project vs a new experiment

New project = a new thesis that could become its own paper. New experiment = a question
that serves an existing claim in `PROJECT.md`. When unsure, it is an experiment.

## Unattended runs

The agent may restart on crash, fix plumbing crashes, and adjust values marked
`# tunable`. It may not change method code under `src/`, change metrics or seeds, or
start another experiment. It appends Results to the SPEC and stops.

More: `help commands`, `help keys`, `help git`.
