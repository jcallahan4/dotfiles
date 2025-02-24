local helpers = require("luasnip-helper-funcs")
local get_visual = helpers.get_visual

-- Math context detection
local tex = {}
tex.in_mathzone = function()
	return vim.fn["vimtex#syntax#in_mathzone"]() == 1
end
tex.in_text = function()
	return not tex.in_mathzone()
end

local line_begin = require("luasnip.extras.expand_conditions").line_begin

-- Return snippet tables
return {
	-- GENERIC ENVIRONMENT
	s(
		{ trig = "env", snippetType = "autosnippet" },
		fmta(
			[[
        \begin{<>}
            <>
        \end{<>}
      ]],
			{
				i(1),
				d(2, get_visual),
				rep(1),
			}
		),
		{ condition = line_begin }
	),
	-- EQUATION
	s(
		{ trig = "dm", snippetType = "autosnippet" },
		fmta(
			[[
        \[
            <>
        \]
      ]],
			{
				i(1),
			}
		),
		{ condition = line_begin }
	),
	-- SPLIT EQUATION
	s(
		{ trig = "ss", snippetType = "autosnippet" },
		fmta(
			[[
        \begin{equation*}
            \begin{split}
                <>
            \end{split}
        \end{equation*}
      ]],
			{
				d(1, get_visual),
			}
		),
		{ condition = line_begin }
	),
	-- ALIGN
	s(
		{ trig = "align", snippetType = "autosnippet" },
		fmta(
			[[
        \begin{align*}
            <>
        \end{align*}
      ]],
			{
				i(1),
			}
		),
		{ condition = line_begin }
	),
	-- ITEMIZE
	s(
		{ trig = "itt", snippetType = "autosnippet" },
		fmta(
			[[
        \begin{itemize}

            \item <>

        \end{itemize}
      ]],
			{
				i(0),
			}
		),
		{ condition = line_begin }
	),
	-- ENUMERATE
	s(
		{ trig = "enn", snippetType = "autosnippet" },
		fmta(
			[[
        \begin{enumerate}[<>]

            \item <>

        \end{enumerate}
      ]],
			{
				i(1),
				i(0),
			}
		)
	),
	-- INLINE MATH
	s(
		{ trig = "([^%l])fm", regTrig = true, wordTrig = false, snippetType = "autosnippet" },
		fmta("<>\\(<>\\)", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			d(1, get_visual),
		}),
		{ condition = tex.in_text }
	),
	-- INLINE MATH ON NEW LINE
	s(
		{ trig = "^mm", regTrig = true, wordTrig = false, snippetType = "autosnippet" },
		fmta("\\(<>\\)", {
			i(1),
		})
	),
	-- FIGURE
	s(
		{ trig = "fig" },
		fmta(
			[[
        \begin{figure}[htb!]
          \centering
          \includegraphics[width=<>\linewidth]{<>}
          \caption{<>}
          \label{fig:<>}
        \end{figure}
        ]],
			{
				i(1),
				i(2),
				i(3),
				i(4),
			}
		),
		{ condition = line_begin }
	),
	-- CASES
	s(
		{ trig = "cases" },
		fmta(
			[[
        \begin{cases}
            <> & <>
        \end{cases}
        <>
        ]],
			{
				i(1),
				i(2),
				i(3),
			}
		),
		{ condition = tex.in_mathzone }
	),
}
