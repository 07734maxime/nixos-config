# The commands of the Cyberdeck: the shell supervisor, the lock, ENGRAVE and
# the tools behind the menus. The scripts live in ./tools; this gives them
# their dependencies. Everything is called by absolute path, so nothing
# depends on the session PATH.
{
  config,
  pkgs,
  dotfiles,
  theme,
}:
rec {
  qs = "${pkgs.quickshell}/bin/quickshell";
  themeBin = "${theme.tool}/bin/cyberdeck-theme";
  kitty = "${config.programs.kitty.package}/bin/kitty";
  niri = "${config.programs.niri.package}/bin/niri";

  # `quickshell ipc call ...` of the running shell
  ipc =
    call:
    [
      qs
      "-c"
      "cyberdeck"
      "ipc"
      "call"
    ]
    ++ call;

  # keeps the shell alive, but stops retrying if the config is broken
  shell = pkgs.writeShellScriptBin "cyberdeck-shell" ''
    crashes=0
    while true; do
      started=$(date +%s)
      ${qs} -c cyberdeck && exit 0
      if [ $(( $(date +%s) - started )) -lt 15 ]; then
        crashes=$((crashes + 1))
      else
        crashes=0
      fi
      if [ "$crashes" -ge 5 ]; then
        # the shell is the notification server: a terminal shows the errors instead
        ${kitty} --class cyberdeck-float --title "SHELL FLATLINED" --hold ${qs} -c cyberdeck
        exit 1
      fi
      sleep 1
    done
  '';

  # lock through the shell, swaylock if the shell is down
  lock = pkgs.writeShellScriptBin "cyberdeck-lock" ''
    ${qs} -c cyberdeck ipc call lock lock 2>/dev/null || ${pkgs.swaylock}/bin/swaylock -f -c 000000
  '';

  # bakes the live OS and wallpaper into Stylix with a rebuild
  engrave = pkgs.writeShellApplication {
    name = "cyberdeck-engrave";
    runtimeInputs = [
      pkgs.git
      pkgs.jq
    ];
    runtimeEnv = {
      CYBERDECK_DOTFILES = dotfiles;
      CYBERDECK_THEME = themeBin;
    };
    # it reports its own failures and waits for a key
    bashOptions = [ "nounset" ];
    text = builtins.readFile ./tools/engrave.sh;
  };

  # the real Cyberpunk 2077 UI sounds, from a zip that stays out of the repo
  sounds = pkgs.writeShellApplication {
    name = "cyberdeck-sounds";
    runtimeInputs = [
      pkgs.unzip
      pkgs.ffmpeg-headless
      pkgs.quickshell
    ];
    text = builtins.readFile ./tools/sounds.sh;
  };

  # a real Cyberpunk 2077 cursor pack (Windows .cur / .ani) over the drawn cursors
  cursor = pkgs.writeShellApplication {
    name = "cyberdeck-cursor";
    runtimeInputs = [
      pkgs.win2xcur
      pkgs.unzip
      pkgs.jq
      pkgs.git
      pkgs.findutils
      pkgs.gnused
      pkgs.coreutils
    ];
    runtimeEnv.CYBERDECK_DOTFILES = dotfiles;
    text = builtins.readFile ./tools/cursor.sh;
  };

  # the PACKAGE BROKER: nixpkgs search and home/packages.json edits
  packages = pkgs.writeShellApplication {
    name = "cyberdeck-pkgs";
    runtimeInputs = [
      pkgs.curl
      pkgs.brotli
      pkgs.jq
      pkgs.gawk
      pkgs.git
      pkgs.util-linux
      pkgs.findutils
      pkgs.gnused
      pkgs.coreutils
    ];
    runtimeEnv = {
      # the index matches the nixpkgs branch of flake.nix
      CYBERDECK_CHANNEL = "nixos-unstable";
      CYBERDECK_DOTFILES = dotfiles;
    };
    text = builtins.readFile ./tools/packages.sh;
  };
}
