{ config, pkgs, ... }:
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
    
    input.focus-follows-mouse.enable = true;

    spawn-at-startup = [
      { command = [ "waybar" ]; }
      {
        command = [
          "swaybg"
          "--image"
          "/home/hello/.dotfiles/home/assets/wallpaper.jpg"
          "--mode"
          "fill"
        ];
      }
    ];

    binds = import ./niri/shortcuts.nix { inherit config; };
  };

  xdg.configFile."xdg-desktop-portal-termfilechooser/config" = {
    enable = true;
    text = ''
      [filechooser]
      cmd=${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh
      default_dir=$HOME/Downloads
      env=TERMCMD='kitty --class=file_chooser'
      create_help_file=0
      open_mode=default
      save_mode=default
    '';
  };
}
