# cyberdeck-engrave: bakes the live OS and wallpaper into Stylix. Writes them
# back into the repo (theme/os, theme/wallpaper), then rebuilds the system:
# every app gets the palette after this.
#
# CYBERDECK_DOTFILES and CYBERDECK_THEME come from tools.nix; CYBERDECK_REPO
# or the folder picked in SHELL SETTINGS override the repo.

# sudo and nixos-rebuild come from the system
export PATH=/run/wrappers/bin:/run/current-system/sw/bin:$PATH

settings=${XDG_STATE_HOME:-$HOME/.local/state}/cyberdeck/settings.json
repo=${CYBERDECK_REPO:-$(jq -r '.repo // empty' "$settings" 2>/dev/null || true)}
repo=${repo:-$CYBERDECK_DOTFILES}
os=$("$CYBERDECK_THEME" current)
name=$(basename "$("$CYBERDECK_THEME" wallpaper)")

printf '\e[1;35m'
cat <<'EOF'
╔══════════════════════════════════════════════╗
║   CYBERDECK // FIRMWARE ENGRAVING PROTOCOL   ║
╚══════════════════════════════════════════════╝
EOF
printf '\e[0m\n'

if [ ! -f "$repo/flake.nix" ]; then
  printf '\e[1;31m>> NO FIRMWARE SOURCE AT %s\e[0m\n' "$repo"
  printf 'Clone the repo there, or pick your clone in SHELL SETTINGS (or dotfiles in flake.nix).\n\n'
  read -r -n 1 -p "PRESS ANY KEY TO DISCONNECT"
  exit 1
fi

printf '\e[1;33m>> ENGRAVING %s INTO SYSTEM FIRMWARE\e[0m\n' "${os^^}"
printf '\e[2m   source     %s\e[0m\n' "$repo"
if git -C "$repo" rev-parse --git-dir >/dev/null 2>&1; then
  printf '\e[2m   commit     %s\e[0m\n' "$(git -C "$repo" log -1 --format='%h %s (%cr)')"
  printf '\e[2m   branch     %s\e[0m\n' "$(git -C "$repo" status -sb | head -n 1)"
fi
printf '\e[2m   wallpaper  %s\e[0m\n\n' "$name"

printf '%s\n' "$os" >"$repo/theme/os"
if [ -f "$repo/home/assets/wallpapers/$name" ]; then
  printf '%s\n' "$name" >"$repo/theme/wallpaper"
else
  printf '\e[1;33m>> %s IS NOT IN home/assets/wallpapers, KEEPING THE ENGRAVED ONE\e[0m\n' "$name"
fi

# flakes only see what git tracks: new wallpapers have to be added first
git -C "$repo" add -- theme/os theme/wallpaper home/assets/wallpapers 2>/dev/null || true

if sudo nixos-rebuild switch --flake "$repo#hello"; then
  printf '\n\e[1;32m>> FIRMWARE ENGRAVED. EVERY APP NOW RUNS %s.\e[0m\n' "${os^^}"
else
  printf '\n\e[1;31m>> ENGRAVING FAILED. ICE HELD.\e[0m\n'
fi
read -r -n 1 -p "PRESS ANY KEY TO DISCONNECT"
