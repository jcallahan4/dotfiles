# Keys

## tmux

The prefix is F12. Your keyboard sends F12 from FN+Space. Ctrl-Space also works as a
prefix.

| Prefix, then | Action |
|---|---|
| `h`, `j`, `k`, `l` | Move to the pane on the left, below, above, or right. |
| `z` | Zoom the current pane to full screen. Press again to restore. |
| `d` | Detach. Everything keeps running. `bench` reattaches. |
| `s` | Choose a session from a list. |
| `\|` or `-` | Split to the right or below. |
| `c` | Open a new window. |
| `[` | Enter copy mode. Use `v` to select, `y` to copy to the clipboard, and `q` to exit. |
| `r` | Reload the tmux configuration. |

The mouse also works. Click a pane, drag a border, or scroll.

Scrolling enters copy mode. The status bar shows `[tmux]` and a yellow box with your
position in the scrollback, such as `[5/11]`. The pane is read-only until you leave. Press
`q` to exit, or scroll back to the bottom. In copy mode, `/` searches, `n` finds the next
match, `v` starts a selection, and `y` copies it to the clipboard.

## Neovim

The leader key is Space.

| Keys | Action |
|---|---|
| `Space h` | In a secondary tab, such as the meeting notes that `mtg` opens, save and close the tab and return to the project tab. Otherwise close the current file and show the dashboard. Neovim stays open. |
| `Space e e` | Toggle the file tree. `Space e f` reveals the current file. |
| `Space g D` | Show the diff of the last commit. This is the agent's last step. |
| `Space g d` | Show the diff of the working tree against HEAD. |
| `Space g r` | Show the diff of a range. Type a tag such as `exp-001` or `baseline`. |
| `Space g h` or `Space g H` | Show the history of this file or of the whole repository. |
| `Space g c` | Close the diff view. |
| `Space f f` or `Space f s` | Find a file or search file contents with Telescope. |
| `Space s v` or `Space s h` | Split the window vertically or horizontally. |
| `Space v c` or `Space v s` | Compile the LaTeX document or forward-search in the PDF. |
| `Space v Q` or `Space v q` | Open or close the LaTeX quickfix list. |

In the diff view, `Tab` and `Shift-Tab` move to the next or previous file.

## Codex prompt

`Shift+Enter` inserts a newline. `Enter` sends the prompt.

## Ghostty and Finder

`Cmd+Shift+,` reloads the Ghostty configuration. `Cmd+T` opens a tab and `Cmd+N` opens a
window. In Finder, double-click a `.tex` or `.py` file to open it in Neovim in a Ghostty
window.
