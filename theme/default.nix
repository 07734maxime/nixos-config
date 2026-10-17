# Everything colour related that both the system and home-manager need:
# the colour engine, the palettes it computes from the wallpapers at build
# time, the cursor theme and the fonts.
{ pkgs, lib }:
let
  firstLine = file: builtins.head (lib.splitString "\n" (builtins.readFile file));

  # the OS (colour algorithm) baked into Stylix; the bar rewrites this file
  # when you switch OS, so the next rebuild picks the same one
  os = firstLine ./os;

  # every image or video of home/assets/wallpapers can be picked live from the
  # shell; theme/wallpaper names the one baked into Stylix, the greeter and the cursor
  wallpapers = builtins.path {
    path = ../home/assets/wallpapers;
    name = "cyberdeck-wallpapers";
  };
  hasExt = exts: name: lib.any (ext: lib.hasSuffix ext (lib.toLower name)) exts;
  isImage = hasExt [
    ".jpg"
    ".jpeg"
    ".png"
    ".webp"
  ];
  # animated wallpapers, played by mpvpaper (see cyberdeck_theme.py)
  isVideo = hasExt [
    ".webm"
    ".mp4"
    ".mkv"
    ".mov"
    ".gif"
  ];
  wallpaperNames = lib.sort lib.lessThan (
    lib.attrNames (
      lib.filterAttrs (name: type: type == "regular" && (isImage name || isVideo name)) (
        builtins.readDir ../home/assets/wallpapers
      )
    )
  );
  selected = firstLine ./wallpaper;
  wallpaperName =
    if wallpaperNames == [ ] then
      throw "cyberdeck: home/assets/wallpapers holds no image or video"
    else if lib.elem selected wallpaperNames then
      selected
    else
      lib.head wallpaperNames;
  # the file the shell puts on screen, maybe a video
  wallpaperSource = "${wallpapers}/${wallpaperName}";
  # Stylix, the greeter and the lock screen need a still: a frame of the video
  wallpaper =
    if isVideo wallpaperName then
      "${
        pkgs.runCommand "cyberdeck-poster" { nativeBuildInputs = [ pkgs.ffmpeg-headless ]; } ''
          mkdir -p $out
          ffmpeg -v error -ss 1 -i ${lib.escapeShellArg wallpaperSource} -frames:v 1 $out/poster.png \
            || ffmpeg -v error -i ${lib.escapeShellArg wallpaperSource} -frames:v 1 $out/poster.png
        ''
      }/poster.png"
    else
      wallpaperSource;

  python = pkgs.python3.withPackages (ps: [ ps.pillow ]);

  tool =
    pkgs.runCommand "cyberdeck-theme"
      {
        nativeBuildInputs = [ pkgs.makeWrapper ];
        meta.mainProgram = "cyberdeck-theme";
      }
      ''
        install -Dm644 ${./cyberdeck_theme.py} $out/share/cyberdeck/cyberdeck_theme.py
        makeWrapper ${python}/bin/python3 $out/bin/cyberdeck-theme \
          --add-flags $out/share/cyberdeck/cyberdeck_theme.py \
          --prefix PATH : ${
            lib.makeBinPath [
              pkgs.procps
              pkgs.swaybg
              pkgs.mpvpaper
              pkgs.ffmpeg-headless
            ]
          }
      '';

  # one directory per wallpaper, one json per OS inside (read back at eval time)
  palettes = pkgs.runCommand "cyberdeck-palettes" { } (
    lib.concatMapStrings (name: ''
      ${tool}/bin/cyberdeck-theme palette --image ${wallpapers}/${lib.escapeShellArg name} --out $out/${lib.escapeShellArg name}
    '') wallpaperNames
  );

  palette = builtins.fromJSON (builtins.readFile "${palettes}/${wallpaperName}/${os}.json");

  # what the runtime engine needs to know about each wallpaper
  catalog = map (name: {
    inherit name;
    path = "${wallpapers}/${name}";
    palettes = "${palettes}/${name}";
  }) wallpaperNames;

  scheme = {
    scheme = "Cyberdeck ${palette.name}";
    author = "cyberdeck-theme";
  }
  // lib.mapAttrs (_: lib.removePrefix "#") palette.base16;

  cursors = pkgs.callPackage ./cursors {
    xcursorgen = pkgs.xcursorgen or pkgs.xorg.xcursorgen;
    colors = {
      bg = palette.roles.bg;
      primary = palette.roles.primary;
      accent = palette.roles.warn;
      danger = palette.roles.danger;
    };
  };

  # Rajdhani, the closest open font to the Cyberpunk 2077 UI
  rajdhani = pkgs.runCommand "rajdhani" { } (
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList
        (weight: hash: ''
          install -Dm444 ${
            pkgs.fetchurl {
              url = "https://raw.githubusercontent.com/google/fonts/5174b3333331c966c38f4355d50b03ca1c1df2f9/ofl/rajdhani/Rajdhani-${weight}.ttf";
              inherit hash;
            }
          } $out/share/fonts/truetype/Rajdhani-${weight}.ttf
        '')
        {
          Medium = "sha256-Ev99z+TCBuOHWsU7F2LqtX3movp/WobCa5e4jWWR6sI=";
          SemiBold = "sha256-lLvSWhjKZlmZ/rBaU33p/SuGDc+3i76coAJwglvyNdo=";
          Bold = "sha256-aRRw3TKGoU6Wd5QNC/dXlheYQbpSFcvaGiyJEKMiav0=";
        }
    )
  );
in
{
  inherit
    os
    wallpaper
    wallpaperSource
    wallpaperName
    wallpapers
    catalog
    tool
    palettes
    palette
    scheme
    cursors
    rajdhani
    ;
  cursorName = "Cyberdeck";
  cursorSize = 28;
}
