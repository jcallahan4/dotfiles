-- "Open in Neovim.app": Finder file handler that opens files in nvim inside a
-- Ghostty window. Built by macos/build-open-in-neovim.sh (run from install.sh).
-- Each open spawns a dedicated Ghostty process for that nvim (macOS `open -n`),
-- which exits when nvim exits; Ghostty's +new-window action is Linux-only.

on run
	launchNvim({})
end run

on open theFiles
	launchNvim(theFiles)
end open

on launchNvim(theFiles)
	-- Build:  zsh -lc "exec nvim '/path/a.tex' '/path/b.py'"
	-- zsh -l gives nvim the login PATH (Homebrew, ~/.local/bin) without the
	-- interactive rc files, so no prompt noise and no conda startup cost.
	set fileArgs to ""
	set workDir to POSIX path of (path to home folder)
	if (count of theFiles) > 0 then
		repeat with f in theFiles
			set fileArgs to fileArgs & " " & quoted form of (POSIX path of f)
		end repeat
		set workDir to do shell script "dirname " & quoted form of (POSIX path of (item 1 of theFiles))
	end if
	set innerCmd to "zsh -lc \"exec nvim" & fileArgs & "\""
	-- Everything is passed as --option=value. Ghostty treats any bare argv item
	-- that is an existing path (e.g. /bin/zsh after -e) as a file to open,
	-- which produced an "Allow Ghostty to execute /bin/zsh?" prompt and a stray
	-- window. --initial-command runs via /bin/sh -c; quit-after-last-window-closed
	-- makes this dedicated Ghostty process exit when nvim exits (what -e did).
	do shell script "open -na Ghostty.app --args --working-directory=" & quoted form of workDir & " --quit-after-last-window-closed=true --initial-command=" & quoted form of innerCmd
end launchNvim
