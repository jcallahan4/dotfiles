# Research workflow

Use one repository for each question that can become a paper. Inside it, use one folder
for each experiment. You write the spec and the notes. The agent writes code in small
steps, and you read each step as a diff.

## Files and owners

| File | Owner | When you use it |
|---|---|---|
| `PROJECT.md` | You | Write it on day one. Read it before you start an experiment. Edit one to three lines when a result changes a claim. By the end it holds the paper outline. |
| `experiments/NNN-name/SPEC.md` | You, then the agent | Write the question, setup, success criterion, and plan before any code. The agent appends a Results section after a run. You add one verdict line. |
| `experiments/NNN-name/NOTES.md` | You only | Write a few sentences after every run, in your own words. |
| `meetings/<person>.md` | You only | A link to `~/notes/meetings/`, one file per advisor across all projects. Run `mtg <person>` when a meeting starts and `mtg done <person>` when it ends. Start a line with the project name when a meeting covers several. |
| `AGENTS.md` | You | Rules the agent follows. Add files to the "Hands off" list as you write them. |
| `runs/<id>/` | Scripts | `config.json`, `meta.json` (git SHA and lockfile hash), and `summary.json`. |

## The loop

1. Run `newexp <name>` and write the spec. Plan for 20 minutes.
2. Ask the agent for one change. It edits, the pre-commit hook lints, it commits, and it
   stops.
3. Read the diff with `Space g D` in Neovim. Read the math line by line. Skim the
   plumbing.
4. Repeat steps 2 and 3. Write code yourself when that is faster than explaining it.
5. Run `just test` and `just smoke` before any long run.
6. Tag the commit, then start the run:

   ```
   git tag exp-NNN
   just run NNN-name 2>&1 | tee runs/NNN/train.log
   ```

7. Tell the agent to monitor the run under the "Unattended runs" rules. Detach with
   `F12 d` or `Ctrl-Space d`. Run `ontheroad` if you are leaving.
8. The next morning, run `just since exp-NNN` and `just report`, then open `Space g r`
   with the tag, then read the Results section in the spec. Read the agent transcript
   last, if at all.
9. Write your notes. Update `PROJECT.md` only if a claim changed. Run `git push`.

## Start a new project

```
mkdir proj && cd proj
startup          # uv project, templates, hooks, CI, justfile, baseline tag
# write PROJECT.md
newexp first-question
bench
```

## Sessions

Start a new Codex session for each experiment, when the topic changes, and each morning.
The files are the memory: `AGENTS.md` makes every session read `PROJECT.md` and the spec,
so a first prompt is one line ("Working on experiments/003. Next is plan item 2."). If
you are re-explaining something, it belongs in a file. Use `think` for discussion
sessions; write the conclusions into your files yourself. One coding session per repo at
a time.

## New project or new experiment

Start a new project when the question is a new thesis that could become its own paper.
Start a new experiment when the question serves a claim that already exists in
`PROJECT.md`. If you are unsure, start an experiment.

## Unattended runs

The agent can restart a crashed run, fix crashes in plumbing code, and change values
marked `# tunable`. It cannot change method code under `src/`, change metrics or seeds,
or start another experiment. When the run ends, it appends a Results section to the spec
and stops.

See also `help commands`, `help keys`, and `help git`.
