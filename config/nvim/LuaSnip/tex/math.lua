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

-- Return snippet tables
return {
	-- SUPERSCRIPT
	s(
		{ trig = '([%w%)%]%}])"', wordTrig = false, regTrig = true, snippetType = "autosnippet" },
		fmta("<>^{<>}", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			d(1, get_visual),
		}),
		{ condition = tex.in_mathzone }
	),
	-- SUBSCRIPT
	s(
		{ trig = "([%w%)%]%}]):", wordTrig = false, regTrig = true, snippetType = "autosnippet" },
		fmta("<>_{<>}", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			d(1, get_visual),
		}),
		{ condition = tex.in_mathzone }
	),
	-- SUBSCRIPT AND SUPERSCRIPT
	s(
		{ trig = "([%w%)%]%}])__", wordTrig = false, regTrig = true, snippetType = "autosnippet" },
		fmta("<>^{<>}_{<>}", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			i(1),
			i(2),
		}),
		{ condition = tex.in_mathzone }
	),
	-- TEXT SUBSCRIPT
	-- s(
	-- 	{ trig = "sd", snippetType = "autosnippet", wordTrig = false },
	-- 	fmta("_{\\mathrm{<>}}", { d(1, get_visual) }),
	-- 	{ condition = tex.in_mathzone }
	-- ),
	-- SUPERSCRIPT SHORTCUT
	-- Places the first alphanumeric character after the trigger into a superscript.
	s(
		{ trig = "([%w%)%]%}])'([%w])", regTrig = true, wordTrig = false, snippetType = "autosnippet" },
		fmta("<>^{<>}", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			f(function(_, snip)
				return snip.captures[2]
			end),
		}),
		{ condition = tex.in_mathzone }
	),
	-- SUBSCRIPT SHORTCUT
	-- Places the first alphanumeric character after the trigger into a subscript.
	s(
		{ trig = "([%w%)%]%}]);([%w%+%-])", regTrig = true, wordTrig = false, snippetType = "autosnippet" },
		fmta("<>_{<>}", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			f(function(_, snip)
				return snip.captures[2]
			end),
		}),
		{ condition = tex.in_mathzone }
	),
	-- EULER'S NUMBER SUPERSCRIPT SHORTCUT
	s(
		{ trig = "([^%a])ee", regTrig = true, wordTrig = false, snippetType = "autosnippet" },
		fmta("<>e^{<>}", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			d(1, get_visual),
		}),
		{ condition = tex.in_mathzone }
	),
	-- ZERO SUBSCRIPT SHORTCUT
	s(
		{ trig = "([%a%)%]%}])00", regTrig = true, wordTrig = false, snippetType = "autosnippet" },
		fmta("<>_{<>}", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			t("0"),
		}),
		{ condition = tex.in_mathzone }
	),
	-- MINUS ONE SUPERSCRIPT SHORTCUT
	s(
		{ trig = "([%a%)%]%}])11", regTrig = true, wordTrig = false, snippetType = "autosnippet" },
		fmta("<>^{<>}", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			t("-1"),
		}),
		{ condition = tex.in_mathzone }
	),
	-- J SUBSCRIPT SHORTCUT (since jk triggers snippet jump forward)
	s(
		{ trig = "([%a%)%]%}])JJ", wordTrig = false, regTrig = true, snippetType = "autosnippet" },
		fmta("<>_{<>}", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			t("j"),
		}),
		{ condition = tex.in_mathzone }
	),
	-- PLUS SUPERSCRIPT SHORTCUT
	s(
		{ trig = "([%a%)%]%}])%+%+", regTrig = true, wordTrig = false, snippetType = "autosnippet" },
		fmta("<>^{<>}", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			t("+"),
		}),
		{ condition = tex.in_mathzone }
	),
	-- COMPLEMENT SUPERSCRIPT
	s(
		{ trig = "([%a%)%]%}])CC", regTrig = true, wordTrig = false, snippetType = "autosnippet" },
		fmta("<>^{<>}", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			t("\\complement"),
		}),
		{ condition = tex.in_mathzone }
	),
	-- CONJUGATE (STAR) SUPERSCRIPT SHORTCUT
	s(
		{ trig = "([%a%)%]%}])%*%*", regTrig = true, wordTrig = false, snippetType = "autosnippet" },
		fmta("<>^{<>}", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			t("*"),
		}),
		{ condition = tex.in_mathzone }
	),
	-- VECTOR, i.e. \vec
	-- s(
	-- 	{ trig = "([^%a])vv", wordTrig = false, regTrig = true, snippetType = "autosnippet" },
	-- 	fmta("<>\\vec{<>}", {
	-- 		f(function(_, snip)
	-- 			return snip.captures[1]
	-- 		end),
	-- 		d(1, get_visual),
	-- 	}),
	-- 	{ condition = tex.in_mathzone }
	-- ),
	-- DEFAULT UNIT VECTOR WITH SUBSCRIPT, i.e. \unitvector_{}
	-- s(
	-- 	{ trig = "([^%a])ue", wordTrig = false, regTrig = true, snippetType = "autosnippet" },
	-- 	fmta("<>\\unitvector_{<>}", {
	-- 		f(function(_, snip)
	-- 			return snip.captures[1]
	-- 		end),
	-- 		d(1, get_visual),
	-- 	}),
	-- 	{ condition = tex.in_mathzone }
	-- ),
	-- UNIT VECTOR WITH HAT, i.e. \uvec{}
	-- s(
	-- 	{ trig = "([^%a])uv", wordTrig = false, regTrig = true, snippetType = "autosnippet" },
	-- 	fmta("<>\\uvec{<>}", {
	-- 		f(function(_, snip)
	-- 			return snip.captures[1]
	-- 		end),
	-- 		d(1, get_visual),
	-- 	}),
	-- 	{ condition = tex.in_mathzone }
	-- ),
	-- MATRIX, i.e. \vec
	-- s(
	-- 	{ trig = "([^%a])mt", wordTrig = false, regTrig = true, snippetType = "autosnippet" },
	-- 	fmta("<>\\mat{<>}", {
	-- 		f(function(_, snip)
	-- 			return snip.captures[1]
	-- 		end),
	-- 		d(1, get_visual),
	-- 	}),
	-- 	{ condition = tex.in_mathzone }
	-- ),
	-- FRACTION
	s(
		{ trig = "([^%a])ff", wordTrig = false, regTrig = true, snippetType = "autosnippet" },
		fmta("<>\\frac{<>}{<>}", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			d(1, get_visual),
			i(2),
		}),
		{ condition = tex.in_mathzone }
	),
	-- -- ANGLE
	-- s(
	-- 	{ trig = "([^%a])gg", regTrig = true, wordTrig = false, snippetType = "autosnippet" },
	-- 	fmta("<>\\ang{<>}", {
	-- 		f(function(_, snip)
	-- 			return snip.captures[1]
	-- 		end),
	-- 		d(1, get_visual),
	-- 	}),
	-- 	{ condition = tex.in_mathzone }
	-- ),
	-- ABSOLUTE VALUE
	-- s(
	-- 	{ trig = "([^%a])aa", regTrig = true, wordTrig = false, snippetType = "autosnippet" },
	-- 	fmta("<>\\|<>|", {
	-- 		f(function(_, snip)
	-- 			return snip.captures[1]
	-- 		end),
	-- 		d(1, get_visual),
	-- 	}),
	-- 	{ condition = tex.in_mathzone }
	-- ),
	-- SQUARE ROOT
	s(
		{ trig = "([^%\\])sq", wordTrig = false, regTrig = true, snippetType = "autosnippet" },
		fmta("<>\\sqrt{<>}", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			d(1, get_visual),
		}),
		{ condition = tex.in_mathzone }
	),
	-- EXPECTED VALUE, NO DISTRIBUTION (to be used with mathdoc preamble)
	s(
		{ trig = "([^%\\])EE", wordTrig = false, regTrig = true, snippetType = "autosnippet" },
		fmta("<>\\E{<>}", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			d(1, get_visual),
		}),
		{ condition = tex.in_mathzone }
	),
	-- EXPECTED VALUE WITH DISTRIBUTION (to be used with mathdoc preamble)
	s(
		{ trig = "([^%\\])ED", wordTrig = false, regTrig = true, snippetType = "autosnippet" },
		fmta("<>\\E[<>]{<>}", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			i(1),
			i(2),
		}),
		{ condition = tex.in_mathzone }
	),
	-- BINOMIAL SYMBOL
	s(
		{ trig = "([^%\\])bnn", wordTrig = false, regTrig = true, snippetType = "autosnippet" },
		fmta("<>\\binom{<>}{<>}", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			i(1),
			i(2),
		}),
		{ condition = tex.in_mathzone }
	),
	-- LOGARITHM
	s(
		{ trig = "([^%a%\\])ll", wordTrig = false, regTrig = true, snippetType = "autosnippet" },
		fmta("<>\\log(<>)", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			i(1),
		}),
		{ condition = tex.in_mathzone }
	),
	-- DERIVATIVE with denominator only
	s(
		{ trig = "([^%a])dV", wordTrig = false, regTrig = true, snippetType = "autosnippet" },
		fmta("<>\\dvOne{<>}", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			d(1, get_visual),
		}),
		{ condition = tex.in_mathzone }
	),
	-- DERIVATIVE with numerator and denominator
	s(
		{ trig = "([^%a])dvv", wordTrig = false, regTrig = true, snippetType = "autosnippet" },
		fmta("<>\\dv{<>}{<>}", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			i(1),
			i(2),
		}),
		{ condition = tex.in_mathzone }
	),
	-- DERIVATIVE with numerator, denominator, and higher-order argument
	s(
		{ trig = "([^%a])ddv", wordTrig = false, regTrig = true, snippetType = "autosnippet" },
		fmta("<>\\dvN{<>}{<>}{<>}", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			i(1),
			i(2),
			i(3),
		}),
		{ condition = tex.in_mathzone }
	),
	-- PARTIAL DERIVATIVE with denominator only
	s(
		{ trig = "([^%a])pV", wordTrig = false, regTrig = true, snippetType = "autosnippet" },
		fmta("<>\\pdivOne{<>}", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			d(1, get_visual),
		}),
		{ condition = tex.in_mathzone }
	),
	-- PARTIAL DERIVATIVE with numerator and denominator
	s(
		{ trig = "([^%a])pvv", wordTrig = false, regTrig = true, snippetType = "autosnippet" },
		fmta("<>\\pdiv{<>}{<>}", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			i(1),
			i(2),
		}),
		{ condition = tex.in_mathzone }
	),
	-- PARTIAL DERIVATIVE with numerator, denominator, and higher-order argument
	s(
		{ trig = "([^%a])ppv", wordTrig = false, regTrig = true, snippetType = "autosnippet" },
		fmta("<>\\pdvN{<>}{<>}{<>}", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			i(1),
			i(2),
			i(3),
		}),
		{ condition = tex.in_mathzone }
	),
	-- SUM with lower limit
	s(
		{ trig = "([^%a])Sum", wordTrig = false, regTrig = true, snippetType = "autosnippet" },
		fmta("<>\\sum_{<>}", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			i(1),
		}),
		{ condition = tex.in_mathzone }
	),
	-- SUM with upper and lower limit
	s(
		{ trig = "([^%a])sum", wordTrig = false, regTrig = true, snippetType = "autosnippet" },
		fmta("<>\\sum_{<>}^{<>}", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			i(1),
			i(2),
		}),
		{ condition = tex.in_mathzone }
	),
	-- INTEGRAL with upper and lower limit
	s(
		{ trig = "([^%a])int", wordTrig = false, regTrig = true, snippetType = "autosnippet" },
		fmta("<>\\int_{<>}^{<>} <> \\,d<>", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			i(1, "\\infty"),
			i(2, "\\infty"),
			i(3),
			i(4, "x"),
		}),
		{ condition = tex.in_mathzone }
	),
	-- INTEGRAL with no limits
	s(
		{ trig = "([^%a])bint", wordTrig = false, regTrig = true, snippetType = "autosnippet" },
		fmta("<>\\int <> \\,d<>", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			i(1),
			i(2, "x"),
		}),
		{ condition = tex.in_mathzone }
	),
	-- INTEGRAL with only lower limit
	s(
		{ trig = "([^%a])lint", wordTrig = false, regTrig = true, snippetType = "autosnippet" },
		fmta("<>\\int_{<>} <> \\,d<>", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			i(1, "\\R"),
			i(2),
			i(3, "x"),
		}),
		{ condition = tex.in_mathzone }
	),
	-- BOXED command
	-- s(
	-- 	{ trig = "([^%a])bb", wordTrig = false, regTrig = true, snippetType = "autosnippet" },
	-- 	fmta("<>\\boxed{<>}", {
	-- 		f(function(_, snip)
	-- 			return snip.captures[1]
	-- 		end),
	-- 		d(1, get_visual),
	-- 	}),
	-- 	{ condition = tex.in_mathzone }
	-- ),
	--
	-- BEGIN STATIC SNIPPETS
	--

	-- DIFFERENTIAL, i.e. \diff
	-- s({ trig = "df", snippetType = "autosnippet", priority = 2000, snippetType = "autosnippet" }, {
	-- 	t("\\diff"),
	-- }, { condition = tex.in_mathzone }),
	-- BASIC INTEGRAL SYMBOL, i.e. \int
	-- s({ trig = "in1", snippetType = "autosnippet" }, {
	-- 	t("\\int"),
	-- }, { condition = tex.in_mathzone }),
	-- -- DOUBLE INTEGRAL, i.e. \iint
	-- s({ trig = "in2", snippetType = "autosnippet" }, {
	-- 	t("\\iint"),
	-- }, { condition = tex.in_mathzone }),
	-- -- TRIPLE INTEGRAL, i.e. \iiint
	-- s({ trig = "in3", snippetType = "autosnippet" }, {
	-- 	t("\\iiint"),
	-- }, { condition = tex.in_mathzone }),
	-- -- CLOSED SINGLE INTEGRAL, i.e. \oint
	-- s({ trig = "oi1", snippetType = "autosnippet" }, {
	-- 	t("\\oint"),
	-- }, { condition = tex.in_mathzone }),
	-- -- CLOSED DOUBLE INTEGRAL, i.e. \oiint
	-- s({ trig = "oi2", snippetType = "autosnippet" }, {
	-- 	t("\\oiint"),
	-- }, { condition = tex.in_mathzone }),
	-- -- GRADIENT OPERATOR, i.e. \grad
	-- s({ trig = "gdd", snippetType = "autosnippet" }, {
	-- 	t("\\grad "),
	-- }, { condition = tex.in_mathzone }),
	-- -- CURL OPERATOR, i.e. \curl
	-- s({ trig = "cll", snippetType = "autosnippet" }, {
	-- 	t("\\curl "),
	-- }, { condition = tex.in_mathzone }),
	-- -- DIVERGENCE OPERATOR, i.e. \divergence
	-- s({ trig = "DI", snippetType = "autosnippet" }, {
	-- 	t("\\div "),
	-- }, { condition = tex.in_mathzone }),
	-- -- LAPLACIAN OPERATOR, i.e. \laplacian
	-- s({ trig = "laa", snippetType = "autosnippet" }, {
	-- 	t("\\laplacian "),
	-- }, { condition = tex.in_mathzone }),
	-- -- PARALLEL SYMBOL, i.e. \parallel
	-- s({ trig = "||", snippetType = "autosnippet" }, {
	-- 	t("\\parallel"),
	-- }, { condition = tex.in_mathzone }),
	-- -- CDOTS, i.e. \cdots
	-- s({ trig = "cdd", snippetType = "autosnippet" }, {
	-- 	t("\\cdots"),
	-- }, { condition = tex.in_mathzone }),
	-- -- LDOTS, i.e. \ldots
	-- s({ trig = "ldd", snippetType = "autosnippet" }, {
	-- 	t("\\ldots"),
	-- }, { condition = tex.in_mathzone }),
	-- -- EQUIV, i.e. \equiv
	-- s({ trig = "eqq", snippetType = "autosnippet" }, {
	-- 	t("\\equiv "),
	-- }, { condition = tex.in_mathzone }),
	-- SETMINUS, i.e. \setminus
	s({ trig = "stm", snippetType = "autosnippet" }, {
		t("\\setminus "),
	}, { condition = tex.in_mathzone }),
	-- SUBSET, i.e. \subset
	s({ trig = "sbb", snippetType = "autosnippet" }, {
		t("\\subset "),
	}, { condition = tex.in_mathzone }),
	-- APPROX, i.e. \approx
	s({ trig = "px", snippetType = "autosnippet" }, {
		t("\\approx "),
	}, { condition = tex.in_mathzone }),
	-- PROPTO, i.e. \propto
	s({ trig = "pt", snippetType = "autosnippet" }, {
		t("\\propto "),
	}, { condition = tex.in_mathzone }),
	-- COLON, i.e. \colon
	s({ trig = "::", snippetType = "autosnippet" }, {
		t("\\colon "),
	}, { condition = tex.in_mathzone }),
	-- MUCH LESS THAN i.e. \ll
	s({ trig = ">>", snippetType = "autosnippet" }, {
		t("\\ll "),
	}, { condition = tex.in_mathzone }),
	-- MUCH GREATER THAN i.e. \gg
	s({ trig = ">>", snippetType = "autosnippet" }, {
		t("\\gg "),
	}, { condition = tex.in_mathzone }),
	-- LESS THAN OR EQUAL TO i.e. \leq
	s({ trig = "leq", snippetType = "autosnippet" }, {
		t("\\leq"),
	}),
	-- GREATER THAN OR EQUAL TO i.e. \geq
	s({ trig = "geq", snippetType = "autosnippet" }, {
		t("\\geq"),
	}),
	-- DOT PRODUCT, i.e. \cdot
	s({ trig = ",.", snippetType = "autosnippet" }, {
		t("\\cdot "),
	}, { condition = tex.in_mathzone }),
	-- INFINITY, i.e. \infty
	s({ trig = "00", snippetType = "autosnippet" }, {
		t("\\infty"),
	}, { condition = tex.in_mathzone }),
	-- -- CROSS PRODUCT, i.e. \times
	-- s({ trig = "xx", snippetType = "autosnippet" }, {
	-- 	t("\\times "),
	-- }, { condition = tex.in_mathzone }),
	-- s({ trig = "smm", snippetType = "autosnippet" }, {
	-- 	t("\\sim"),
	-- }, { condition = tex.in_mathzone }),
}
