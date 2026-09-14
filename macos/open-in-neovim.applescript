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
	set nvimCmd to "exec nvim"
	set workDir to POSIX path of (path to home folder)
	if (count of theFiles) > 0 then
		repeat with f in theFiles
			set nvimCmd to nvimCmd & " " & quoted form of (POSIX path of f)
		end repeat
		set firstPath to POSIX path of (item 1 of theFiles)
		set workDir to do shell script "dirname " & quoted form of firstPath
	end if
	-- zsh -l gives nvim the login PATH (Homebrew, ~/.local/bin) without the
	-- interactive rc files, so no prompt noise and no conda startup cost.
	do shell script "open -na Ghostty.app --args --working-directory=" & quoted form of workDir & " -e /bin/zsh -lc " & quoted form of nvimCmd
end launchNvim
