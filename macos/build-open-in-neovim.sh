#!/bin/bash
# Build ~/Applications/Open in Neovim.app from open-in-neovim.applescript and
# make it the default handler for the extensions in DEFAULT_EXTS. Idempotent.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
app_dir="$HOME/Applications"
app="$app_dir/Open in Neovim.app"
bundle_id="local.dotfiles.open-in-neovim"
DEFAULT_EXTS=(tex py)                                   # made default
EXTRA_EXTS=(bib sty cls md txt toml yaml yml json lua sh zsh) # offered in "Open With"

mkdir -p "$app_dir"
rm -rf "$app"
osacompile -o "$app" "$here/open-in-neovim.applescript"

plist="$app/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $bundle_id" "$plist" 2>/dev/null || \
  /usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string $bundle_id" "$plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleName Open in Neovim" "$plist" 2>/dev/null || \
  /usr/libexec/PlistBuddy -c "Add :CFBundleName string Open in Neovim" "$plist"
# No Dock icon / menu bar: the applet only relays to Ghostty.
/usr/libexec/PlistBuddy -c "Add :LSUIElement bool true" "$plist" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Delete :CFBundleDocumentTypes" "$plist" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes array" "$plist"
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0 dict" "$plist"
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:CFBundleTypeName string Text file" "$plist"
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:CFBundleTypeRole string Editor" "$plist"
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:LSHandlerRank string Alternate" "$plist"
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:CFBundleTypeExtensions array" "$plist"
i=0
for ext in "${DEFAULT_EXTS[@]}" "${EXTRA_EXTS[@]}"; do
  /usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:CFBundleTypeExtensions:$i string $ext" "$plist"; i=$((i+1))
done

# Register with LaunchServices, then set defaults.
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$app"
sleep 1  # let LaunchServices finish indexing the new bundle before claiming defaults
if command -v duti >/dev/null 2>&1; then
  for ext in "${DEFAULT_EXTS[@]}"; do
    duti -s "$bundle_id" ".$ext" all
    # duti can silently lose the race with lsregister on a fresh bundle; retry once.
    [ "$(duti -x "$ext" 2>/dev/null | sed -n 2p)" = "$app" ] || { sleep 2; duti -s "$bundle_id" ".$ext" all; }
  done
else
  echo "duti not installed (brew install duti); set defaults by hand via Finder > Get Info > Open with > Change All" >&2
fi
echo "Built $app ($bundle_id); default for: ${DEFAULT_EXTS[*]}"
