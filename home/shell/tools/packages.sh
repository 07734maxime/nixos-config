# cyberdeck-pkgs: the PACKAGE BROKER of the shell. Searches nixpkgs through the
# package index nixos.org publishes for the channel, and edits the list in
# home/packages.json so nobody has to open a .nix file to add a program.
#
#   cyberdeck-pkgs status          json: channel, index size and age, managed list
#   cyberdeck-pkgs search QUERY    json: best matches first
#   cyberdeck-pkgs add NAME        refuses what is not in nixpkgs
#   cyberdeck-pkgs remove NAME
#   cyberdeck-pkgs refresh         downloads the index again
#
# CYBERDECK_CHANNEL and CYBERDECK_DOTFILES come from ../tools.nix.

channel=${CYBERDECK_CHANNEL:-nixos-unstable}
cache=${XDG_CACHE_HOME:-$HOME/.cache}/cyberdeck
index=$cache/packages.tsv
settings=${XDG_STATE_HOME:-$HOME/.local/state}/cyberdeck/settings.json
repo=$(jq -r '.repo // empty' "$settings" 2>/dev/null || true)
repo=${repo:-${CYBERDECK_DOTFILES:-$HOME/.dotfiles}}
list=$repo/home/packages.json
static=$repo/home/packages.nix

die() {
  printf 'cyberdeck-pkgs: %s\n' "$1" >&2
  exit "${2:-1}"
}

# one line per package: attribute path, version, description
fetch_index() {
  local tmp
  tmp=$(mktemp "$cache/.index-XXXXXX")
  if curl -fsSL --max-time 120 "https://channels.nixos.org/$channel/packages.json.br" \
    | brotli -dc \
    | jq -r '.packages | to_entries[] | [.key, (.value.version // ""), ((.value.meta.description // "") | gsub("[\t\n\r]"; " "))] | @tsv' >"$tmp" \
    && [ -s "$tmp" ]; then
    mv "$tmp" "$index"
  else
    rm -f "$tmp"
    return 1
  fi
}

# downloaded on first use, then once a week; a stale index beats none
ensure_index() {
  mkdir -p "$cache"
  exec 9>"$cache/packages.lock"
  flock 9
  if [ ! -s "$index" ] || [ -n "$(find "$index" -mmin +10080 2>/dev/null)" ]; then
    fetch_index || [ -s "$index" ] || die "PACKAGE INDEX UNREACHABLE (channels.nixos.org)"
  fi
  flock -u 9
}

managed() {
  if [ -f "$list" ]; then jq -c '.' "$list"; else echo '[]'; fi
}

# everything already installed through packages.nix: its own list plus the json
installed() {
  {
    [ -f "$static" ] && sed -nE 's/^[[:space:]]+([A-Za-z0-9_.+-]+)[[:space:]]*$/\1/p' "$static"
    managed | jq -r '.[]'
  } | sort -u
}

known() {
  awk -F'\t' -v n="$1" '$1 == n { found = 1; exit } END { exit !found }' "$index"
}

cmd_status() {
  local count=0 age=-1
  if [ -s "$index" ]; then
    count=$(wc -l <"$index")
    age=$(($(date +%s) - $(stat -c %Y "$index")))
  fi
  jq -nc --arg channel "$channel" --arg repo "$repo" --argjson count "$count" --argjson age "$age" \
    --argjson managed "$(managed)" --argjson writable "$([ -f "$list" ] && echo true || echo false)" \
    '{channel: $channel, repo: $repo, count: $count, age: $age, managed: $managed, writable: $writable}'
}

# exact name, then prefix, then inside a package set (python3Packages.<q>...),
# then anywhere in the name, then in the description; shorter names first
cmd_search() {
  local query=${1:-}
  [ -n "$query" ] || { echo '[]'; return; }
  ensure_index
  awk -F'\t' -v q="$query" '
    BEGIN { q = tolower(q) }
    {
      n = tolower($1); r = -1
      if (n == q) r = 0
      else if (index(n, q) == 1) r = 1
      else if (index(n, "." q) > 0) r = 3
      else if (index(n, q) > 0) r = 2
      else if (index(tolower($3), q) > 0) r = 4
      if (r >= 0) print r "\t" length($1) "\t" $0
    }' "$index" \
    | sort -t "$(printf '\t')" -k1,1n -k2,2n \
    | awk 'NR <= 40' \
    | cut -f3- \
    | jq -Rsc --argjson have "$(installed | jq -Rsc 'split("\n") | map(select(length > 0))')" '
        split("\n") | map(select(length > 0) | split("\t")
          | {name: .[0], version: (.[1] // ""), description: (.[2] // "")}
          | .installed = (.name as $n | $have | index($n) != null))'
}

cmd_add() {
  local name=${1:-}
  [[ $name =~ ^[A-Za-z0-9_+.-]+$ ]] || die "INVALID PACKAGE NAME '$name'" 2
  [ -f "$list" ] || die "NO PACKAGE LIST AT $list" 4
  ensure_index
  known "$name" || die "REFUSED: '$name' IS NOT A PACKAGE OF NIXPKGS ($channel)" 2
  local have
  have=$(installed)
  grep -qxF -- "$name" <<<"$have" && die "'$name' IS ALREADY INSTALLED" 3
  jq --arg n "$name" '. + [$n] | unique' "$list" >"$list.tmp" && mv "$list.tmp" "$list"
  # flakes only see what git tracks
  git -C "$repo" add -- home/packages.json 2>/dev/null || true
  printf 'ADDED %s\n' "$name"
}

cmd_remove() {
  local name=${1:-}
  [ -f "$list" ] || die "NO PACKAGE LIST AT $list" 4
  managed | jq -e --arg n "$name" 'index($n) != null' >/dev/null || die "'$name' WAS NOT ADDED FROM THE BROKER" 3
  jq --arg n "$name" 'map(select(. != $n))' "$list" >"$list.tmp" && mv "$list.tmp" "$list"
  git -C "$repo" add -- home/packages.json 2>/dev/null || true
  printf 'REMOVED %s\n' "$name"
}

case "${1:-}" in
  status) cmd_status ;;
  search) cmd_search "${2:-}" ;;
  add) cmd_add "${2:-}" ;;
  remove) cmd_remove "${2:-}" ;;
  refresh)
    mkdir -p "$cache"
    fetch_index || die "PACKAGE INDEX UNREACHABLE (channels.nixos.org)"
    cmd_status
    ;;
  *) die "usage: cyberdeck-pkgs status|search QUERY|add NAME|remove NAME|refresh" ;;
esac
