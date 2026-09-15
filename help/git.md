# Git, just enough

The agent commits for you after every change. You type four things.

| You type | When | What it does |
|---|---|---|
| `git tag exp-003` | before a long run | names the current commit so you can diff against it later |
| `just since exp-003` | the morning after | which files changed since the tag |
| `git push` | end of day | copies your commits to GitHub (backup) |
| `git status` | when unsure | shows what is modified and uncommitted; safe, changes nothing |

## Words

- **commit**: a saved snapshot of all files, with a message. Each has an ID like `a1b2c3d`.
- **tag**: a permanent name for one commit. Does not move. `git tag` lists them.
- **branch**: a movable name for "the latest commit on this line of work." You work on
  one branch. `distributional_boed` happens to be on `codex/iqn-gate1`; that is fine.
- **HEAD**: the commit you are on right now.
- **remote / origin**: the copy on GitHub.
- **push / pull**: send your commits up / bring GitHub's commits down.

## Things that are always safe

`git status`, `git log --oneline`, `git diff`, `git tag`, `git push` (without flags),
opening diffview in Neovim.

## Things to stop and ask about

Anything with `--force` or `-f` (except `git tag -f`, which only moves a label). `git
reset --hard`. `git rebase`. `git push` that is refused with "rejected". If an agent
suggests one of these, ask it to explain the current state first and do nothing until it
does. Nothing is lost by waiting.

## If something looks wrong

1. `git status` and `git log --oneline -5`. Read them.
2. Ask the agent: "explain the git state; do not change anything."
3. Uncommitted edits you want to throw away on one file: `git checkout -- path/to/file`.
   Committed work is never lost by that.
