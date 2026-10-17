# The Cyberdeck xcursor theme, drawn from shapes.py and coloured with the palette.
# Xcursors in ./official (written by cyberdeck-cursor from a real cursor pack)
# replace the drawn ones of the same role; every alias follows them.
{
  lib,
  runCommand,
  python3,
  librsvg,
  xcursorgen,
  colors,
}:
runCommand "cyberdeck-cursors"
  {
    nativeBuildInputs = [
      python3
      librsvg
      xcursorgen
    ];
  }
  ''
    python3 ${./.}/build.py '${builtins.toJSON colors}' frames 24,32,48,64,96
    cd frames

    for svg in *.svg; do
      for size in 24 32 48 64 96; do
        rsvg-convert -w "$size" -h "$size" "$svg" -o "''${svg%.svg}-$size.png"
      done
    done

    theme=$out/share/icons/Cyberdeck
    mkdir -p "$theme/cursors"
    for cfg in *.cfg; do
      xcursorgen "$cfg" "$theme/cursors/''${cfg%.cfg}"
    done
    ${lib.optionalString (builtins.pathExists ./official) ''
      for official in ${./official}/*; do
        install -m644 "$official" "$theme/cursors/$(basename "$official")"
      done
    ''}
    while read -r target alias; do
      ln -sf "$target" "$theme/cursors/$alias"
    done < aliases

    cat > "$theme/index.theme" <<EOF
    [Icon Theme]
    Name=Cyberdeck
    Comment=Cyberpunk 2077 inspired cursors, coloured by the active OS
    EOF
  ''
