# dotfiles

Personal shell, editor, and terminal configuration for Jake. `install.sh` links
everything into `$HOME`; see `NEW_MACHINE.md` for the full layout.

- Setting up a new machine, or asked to "make this machine match the work Mac":
  read `NEW_MACHINE.md` first and follow it. It also records every fix that was
  needed on earlier machines and why.
- This repo is public. Never add tokens, keys, `~/.npmrc`, `~/.ssh`, or
  Zanskar brand material (the `zanskar-design` skill).
- Edit configs here, not the symlinked copies in `$HOME`. After editing zsh
  files run `zsh -n <file>`; after editing `install.sh` run `bash -n install.sh`.
