# latex-new <name> [article|report|beamer] [title]: a LaTeX project ready for
# VSCode (LaTeX Workshop builds it with latexmk on save)
usage() {
  echo "usage: latex-new <name> [article|report|beamer] [title]" >&2
  exit 1
}

[ $# -ge 1 ] || usage
name=$1
kind=${2:-article}
title=${3:-$name}
templates=$LATEX_TEMPLATES

[ -d "$templates/$kind" ] || { echo "unknown template: $kind" >&2; usage; }
[ -e "$name" ] && { echo "$name already exists" >&2; exit 1; }

# a title like "Maths & physique" must stay valid LaTeX
title=$(printf '%s' "$title" | sed 's/[&%$#_]/\\&/g')
author=$(git config --get user.name || echo "$USER")
date=$(date +%d/%m/%Y)

mkdir -p "$name"
# store files are read-only: copy the contents, not the permissions
cp -r --no-preserve=mode "$templates/common/." "$templates/$kind/." "$name/"

# & and \ are special in sed replacements
esc() { printf '%s' "$1" | sed 's/[&\\|]/\\&/g'; }
sed -i \
  -e "s|@TITLE@|$(esc "$title")|g" \
  -e "s|@AUTHOR@|$(esc "$author")|g" \
  -e "s|@DATE@|$(esc "$date")|g" \
  "$name/main.tex"

git -C "$name" init -q
echo "$kind project created in $name/"

if [ -t 1 ]; then
  code "$name" "$name/main.tex"
fi
