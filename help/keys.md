# Keys

## tmux (prefix = F12, sent by the keyboard from FN+Space; Ctrl-Space also works)

| Prefix then | Action |
|---|---|
| `h` `j` `k` `l` | move between panes |
| `z` | zoom current pane full screen / unzoom |
| `d` | detach (everything keeps running; `nic` reattaches) |
| `s` | pick a session |
| `\|` / `-` | split right / below |
| `c` | new window |
| `[` | copy mode (vi keys; `v` select, `y` copy to clipboard, `q` quit) |
| `r` | reload tmux config |

Mouse works: click a pane, drag a border, scroll.

## Neovim (leader = Space)

| Keys | Action |
|---|---|
| `Space e e` | file tree toggle (`Space e f` reveal current file) |
| `Space g D` | diff of the last commit (the agent's last step) |
| `Space g d` | diff working tree vs HEAD |
| `Space g r` | diff a range; type a tag like `exp-001` or `baseline` |
| `Space g h` / `Space g H` | history of this file / whole repo |
| `Space g c` | close diff view |
| `Space f f` / `Space f s` | find file / grep (Telescope) |
| `Space s v` / `Space s h` | split vertical / horizontal |
| `Space v c` / `Space v s` | vimtex compile / forward search |
| `Space v Q` / `Space v q` | open / close LaTeX quickfix |

Inside diffview: `Tab` / `Shift-Tab` next / previous file.

## Codex prompt

`Shift+Enter` inserts a newline; `Enter` sends.

## Ghostty

`Cmd+Shift+,` reload config. `Cmd+T` tab, `Cmd+N` window. Finder: double-click a `.tex`
or `.py` opens it in nvim in a Ghostty window.
