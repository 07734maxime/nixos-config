# cyberdeck-cursor: puts a real Cyberpunk 2077 cursor pack (the Windows .cur /
# .ani files, as a zip or a folder) over the drawn Cyberdeck cursors. Each file
# is converted to an Xcursor named after its role in
# theme/cursors/official of the repo; the next ENGRAVE bakes them into the
# theme, every alias follows. --reset goes back to the drawn cursors.
#
#   cyberdeck-cursor PACK.zip|FOLDER
#   cyberdeck-cursor --reset

settings=${XDG_STATE_HOME:-$HOME/.local/state}/cyberdeck/settings.json
repo=$(jq -r '.repo // empty' "$settings" 2>/dev/null || true)
repo=${repo:-${CYBERDECK_DOTFILES:-$HOME/.dotfiles}}
dest=$repo/theme/cursors/official

die() {
  printf 'cyberdeck-cursor: %s\n' "$1" >&2
  exit 1
}

[ $# -eq 1 ] || die "usage: cyberdeck-cursor PACK.zip|FOLDER | --reset"
[ -d "$repo/theme/cursors" ] || die "no repo at $repo"

if [ "$1" = --reset ]; then
  git -C "$repo" rm -rq --ignore-unmatch -- theme/cursors/official >/dev/null 2>&1 || true
  rm -rf "$dest"
  echo "back to the drawn cursors: ENGRAVE to apply"
  exit 0
fi

pack=$1
[ -e "$pack" ] || die "no such file: $pack"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

if [ -d "$pack" ]; then
  root=$pack
else
  unzip -q "$pack" -d "$work/zip" || die "not a zip: $pack"
  root=$work/zip
fi

# role of the deck | keys of a Windows install.inf | words of the file names
roles='default|pointer arrow normal|arrow normal default pointer
pointer|hand link|link hand select
text|text beam|text beam ibeam
wait|busy wait|busy wait
progress|work appstarting|working appstart background progress
not-allowed|unavailiable unavailable no|unavail forbid
crosshair|cross precision|precision cross
help|help|help
move|move sizeall|move sizeall
ns-resize|vert sizens|vert sizens
ew-resize|horz sizewe|horz horiz sizewe
nwse-resize|dgn1 sizenwse|dgn1 diag1 nwse
nesw-resize|dgn2 sizenesw|dgn2 diag2 nesw
alias|link|alias'

mapfile -t cursors < <(find "$root" -type f \( -iname '*.cur' -o -iname '*.ani' \))
[ "${#cursors[@]}" -gt 0 ] || die "no .cur or .ani file in $pack"

# install.inf names each file: [Strings] pointer = "Normal Select.ani"
inf=$(find "$root" -type f -iname '*.inf' -print -quit)
from_inf() {
  [ -n "$inf" ] || return 1
  local key
  for key in $1; do
    sed -nE "s/^[[:space:]]*${key}[[:space:]]*=[[:space:]]*\"?([^\"]+\.(cur|ani))\"?.*/\1/Ip" "$inf" | tr -d '\r' | head -n 1 | grep . && return 0
  done
  return 1
}

# otherwise the first file whose name holds one of the words
from_name() {
  local word file base
  for word in $1; do
    for file in "${cursors[@]}"; do
      base=$(basename "$file" | tr '[:upper:]' '[:lower:]')
      case $base in
        *"$word"*)
          echo "$file"
          return 0
          ;;
      esac
    done
  done
  return 1
}

mkdir -p "$work/out" "$work/x"
found=0
while IFS='|' read -r role keys words; do
  file=""
  if name=$(from_inf "$keys"); then
    file=$(find "$root" -type f -iname "$(basename "$name")" -print -quit)
  fi
  if [ -z "$file" ]; then
    file=$(from_name "$words") || true
  fi
  if [ -z "$file" ]; then
    printf '  %-12s MISSING\n' "$role"
    continue
  fi
  rm -rf "$work/x"/*
  win2xcur -o "$work/x" "$file" </dev/null >/dev/null 2>&1 || true
  # win2xcur exits 0 even when it cannot read a file
  converted=$(find "$work/x" -type f -print -quit)
  if [ -z "$converted" ]; then
    printf '  %-12s UNREADABLE %s\n' "$role" "$(basename "$file")"
    continue
  fi
  cp "$converted" "$work/out/$role"
  printf '  %-12s <- %s\n' "$role" "$(basename "$file")"
  found=$((found + 1))
done <<<"$roles"

[ -f "$work/out/default" ] || die "no arrow cursor in the pack, nothing installed"
rm -rf "$dest"
mkdir -p "$dest"
cp "$work/out"/* "$dest/"
# flakes only see what git tracks
git -C "$repo" add -- theme/cursors/official 2>/dev/null || true
echo "$found cursors in $dest: ENGRAVE to apply"
