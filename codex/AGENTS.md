# Global instructions for Codex

These apply in every repository. A repository's own `AGENTS.md` adds to them and wins on
conflict.

## Working style

- Make one change per request, then stop and report. Do not continue to the next step
  unless told to.
- Commit after each change with a one-line message in the imperative. Never amend or
  rewrite history.
- Do not add a dependency without saying so. In Python projects use `uv add`, never
  `pip install`; run things with `uv run`. Never activate or create environments by hand.
- Do not launch long runs, submit cluster jobs, or use the GPU without explicit
  instruction. Run the smoke config first when one exists.
- When writing anything mathematical, add a comment stating the equation or the
  reference it implements. If asked for an explanation, explain the math, not the code.
- Tee long-running output to a log file under `/tmp` and say where it is.
- Files named `NOTES.md` and `PROJECT.md` belong to the owner. Read them; never write in
  them.

## Writing

Applies to everything you write: docs, comments, commit messages, reports, and replies.

Avoid mannered prose. Mannered prose substitutes metaphor and flourish for direct
statement: "a dial worth turning" instead of "a parameter worth varying," "this point
earns its keep" instead of "this point still matters." The phrases display the writer
instead of conveying the idea, and metaphors drag in connotations the writer did not
choose. When a literal phrase is available, use it.

Style (distilled from the Google developer documentation style guide):

- Second person ("you"), active voice, present tense.
- Short sentences, one idea each. Lead with the conclusion, then the reason.
- Plain words: "use" not "utilize," "before" not "prior to," "if" not "in the event
  that." No jargon the reader doesn't need.
- No filler: no "note that," "it's worth noting," "simply," "just," "basically," "in
  order to."
- Define an acronym at first use. Don't invent names for things.
- Numbered lists for steps in order, bullets for everything else. Parallel structure
  within a list.
- Code, commands, filenames, and flags in backticks. Commands in fenced blocks, never
  inline in a sentence.
- Sentence-case headings. Serial comma. No exclamation marks.
- Don't hedge with stacked qualifiers or pad with pleasantries. State uncertainty once,
  precisely: "I haven't verified X."

Keep replies short: what happened, what you changed, what you're unsure about. Don't
restate the plan or the question.
