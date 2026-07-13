{ lib, ... }:

{
  wayland.windowManager.hyprland.enable = true;

  wayland.windowManager.hyprland.settings = {
    mod = {
      _var = "SUPER";
    };

    terminal = {
      _var = "kitty";
    };

    menu = {
      _var = "hyprlauncher";
    };

    fileManager = {
      _var = "bash -c 'kitty -e yazi'";
    };

    config = {
      input = {
        kb_layout = "fr";
      };

      general = {
        gaps_in = 10;
        gaps_out = 10;
        layout = "scrolling";
      };

      decoration = {
        rounding = 15;
      };
    };

    monitor = import ./monitors.nix;
    curve = import ./curves.nix;
    animation = import ./animations.nix;
    bind = import ./binds.nix { inherit lib; };
  };
}
