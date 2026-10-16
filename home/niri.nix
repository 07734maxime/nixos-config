{ pkgs, ... }:
{
  programs.niri.settings = {
    outputs.DP-2.mode = {
      height = 1080;
      width = 1920;
      refresh = 179.982;
    };

    outputs.DP-1.mode = {
      height = 1080;
      width = 1920;
      refresh = 180.00;
    };

    input.keyboard.xkb.layout = "fr";

    spawn-at-startup = [
      { command = [ "waybar" ]; }
    ];

    binds = import ./niri/shortcuts.nix;
  };

  xdg.configFile."xdg-desktop-portal-termfilechooser/config" = {
    enable = true;
    text = ''
      [filechooser]
      cmd=${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh
      default_dir=$HOME/Downloads
      env=TERMCMD='kitty --class=file_chooser'
    '';
  };
}