# The Cyberdeck shell (Quickshell): bar, control center, quickhack launcher,
# breach protocol, OS / wallpaper / settings / package / phone menus,
# holocalls, notifications, sounds, lockscreen and idle handling, plus the
# niri bindings that drive them. The QML lives in ./quickshell, the commands
# in ./tools.nix.
{
  config,
  pkgs,
  lib,
  dotfiles,
  ...
}:
let
  theme = import ../../theme { inherit pkgs lib; };
  tools = import ./tools.nix {
    inherit
      config
      pkgs
      dotfiles
      theme
      ;
  };
  inherit (tools) ipc;
in
{
  xdg.configFile."quickshell/cyberdeck".source = ./quickshell;

  # what the shell needs to know about the system, read by services/Theme.qml
  xdg.configFile."cyberdeck/config.json".text = builtins.toJSON {
    # the engraved wallpaper, then every wallpaper of the flake with its prebuilt palettes
    wallpaper = theme.wallpaperSource;
    # default rebuild folder, SHELL SETTINGS can override it
    repo = dotfiles;
    wallpapers = theme.catalog;
    # images dropped here show up in the selector before the next rebuild
    wallpaperDir = "${dotfiles}/home/assets/wallpapers";
    wallpaperFile = "${dotfiles}/theme/wallpaper";
    defaultOs = theme.os;
    osFile = "${dotfiles}/theme/os";
    # empty: located from the IP by wttr.in, or e.g. "Paris"
    weatherLocation = "";
    bin = {
      quickshell = tools.qs;
      theme = tools.themeBin;
      engrave = "${tools.engrave}/bin/cyberdeck-engrave";
      pkgs = "${tools.packages}/bin/cyberdeck-pkgs";
      lock = "${tools.lock}/bin/cyberdeck-lock";
      kitty = tools.kitty;
      niri = tools.niri;
      pwplay = "${pkgs.pipewire}/bin/pw-play";
      pavucontrol = "${pkgs.pavucontrol}/bin/pavucontrol";
    };
  };

  home.packages = [
    pkgs.quickshell
    tools.shell
    tools.lock
    tools.engrave
    tools.sounds
    tools.cursor
    tools.packages
  ];

  programs.niri.settings = {
    spawn-at-startup = [
      { command = [ "${tools.shell}/bin/cyberdeck-shell" ]; }
      # swaybg (mpvpaper for a video) on the remembered wallpaper; the selector swaps it live
      {
        command = [
          tools.themeBin
          "wallpaper"
          "show"
        ];
      }
    ];

    binds = {
      "Mod+D".action.spawn = ipc [
        "quickhack"
        "toggle"
      ];
      "Mod+A".action.spawn = ipc [
        "cc"
        "toggle"
      ];
      "Mod+B".action.spawn = ipc [
        "breach"
        "open"
      ];
      "Mod+O".action.spawn = ipc [
        "os"
        "open"
      ];
      "Mod+W".action.spawn = ipc [
        "wallpaper"
        "open"
      ];
      "Mod+N".action.spawn = ipc [
        "dnd"
        "toggle"
      ];
      # Sandevistan: niri slows down, the optics tint (see services/Sandevistan.qml)
      "Mod+S".action.spawn = ipc [
        "sandevistan"
        "activate"
      ];
      # Kiroshi scanner: read the windows on screen like NPCs
      "Mod+Tab".action.spawn = ipc [
        "scanner"
        "toggle"
      ];
      "Mod+Alt+L".action.spawn = "${tools.lock}/bin/cyberdeck-lock";
      # reboot optics: the supervisor brings the shell back
      "Mod+Shift+R".action.spawn = [
        tools.qs
        "-c"
        "cyberdeck"
        "kill"
      ];
    };
  };

  # quickshell watches its files through the store symlinks, which never change:
  # without this a switch leaves the old shell running until the next login.
  # SIGTERM to the child of cyberdeck-shell, whose loop starts the new config
  # (`quickshell kill` exits 0 and would end the loop instead).
  home.activation.cyberdeckShellRestart = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    current=$(readlink -f "${config.xdg.configHome}/quickshell/cyberdeck" || true)
    seen="${config.xdg.stateHome}/cyberdeck/shell-config"
    if [[ -z "''${DRY_RUN+x}" && "$(cat "$seen" 2>/dev/null)" != "$current" ]]; then
      wrappers=$(${pkgs.procps}/bin/pgrep -d, -u "$(id -u)" -f '/bin/cyberdeck-shell$' || true)
      if [ -n "$wrappers" ]; then
        ${pkgs.procps}/bin/pkill -TERM -P "$wrappers" || true
      else
        # the loop gave up on a broken config: start it again in the running session
        for sock in "''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"/niri.*.sock; do
          [ -S "$sock" ] || continue
          NIRI_SOCKET=$sock ${tools.niri} msg action spawn -- ${tools.shell}/bin/cyberdeck-shell && break
        done
      fi
      mkdir -p "$(dirname "$seen")"
      printf '%s\n' "$current" > "$seen"
    fi
  '';

  # the launcher that came before the quickhack: an old generation may have left it behind
  home.activation.cyberdeckCleanup = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    for stale in "$HOME/.config/quickshell/quickhack.qml"; do
      if [ -L "$stale" ] && [[ "$(readlink "$stale")" == /nix/store/* ]]; then
        run rm -f "$stale"
      fi
    done
  '';

  # lock after 5 min, screens off after 10, always lock before sleeping
  systemd.user.services.cyberdeck-idle = {
    Unit = {
      Description = "Cyberdeck idle handling";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = lib.concatStringsSep " " [
        "${pkgs.swayidle}/bin/swayidle -w"
        "timeout 300 ${tools.lock}/bin/cyberdeck-lock"
        "timeout 600 '${tools.niri} msg action power-off-monitors'"
        "before-sleep ${tools.lock}/bin/cyberdeck-lock"
      ];
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
