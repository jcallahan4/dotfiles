# Git basics

The agent commits after every change. You type four commands.

| Command | When | What it does |
|---|---|---|
| `git tag exp-003` | Before a long run | Names the current commit so you can compare against it later. |
| `just since exp-003` | The next morning | Lists the files that changed since the tag. |
| `git push` | End of day | Copies your commits to GitHub as a backup. |
| `git status` | When you are unsure | Shows modified and uncommitted files. It changes nothing. |

## Terms

- **Commit**: a saved snapshot of all files with a message. Each commit has an ID such as
  `a1b2c3d`.
- **Tag**: a permanent name for one commit. It does not move. `git tag` lists tags.
- **Branch**: a movable name for the latest commit on a line of work. You work on one
  branch. The `distributional_boed` repository is on `codex/iqn-gate1`, which is fine.
- **HEAD**: the commit you are on now.
- **Remote** or **origin**: the copy of the repository on GitHub.
- **Push** and **pull**: send your commits to GitHub, or bring GitHub's commits to you.

## Safe commands

These commands change nothing: `git status`, `git log --oneline`, `git diff`, `git tag`,
`git push` without flags, and the diff view in Neovim.

## Commands to stop and ask about

Stop before you run any command with `--force` or `-f`, except `git tag -f`, which only
moves a label. Stop before `git reset --hard` and `git rebase`. Stop if `git push` is
rejected. If an agent suggests one of these, ask it to explain the current state first,
and change nothing until it does. Waiting loses nothing.

## If something looks wrong

1. Run `git status` and `git log --oneline -5`, and read the output.
2. Ask the agent to explain the git state without changing anything.
3. To discard uncommitted edits to one file, run `git checkout -- path/to/file`. This
   never affects committed work.
