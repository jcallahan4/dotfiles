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
	s(
		{ trig = "hw_title" },
		fmta(
			[[
            \title{Assignment \#<>\\Math <>}
            \author{
                Jake Callahan
                }




            \begin{document}

            \maketitle
            
            <>

            \end{document}



      ]],
			{
				i(1),
				i(2),
				i(0),
			}
		)
	),
}
