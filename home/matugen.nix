{ pkgs, ... }:
{
  programs.matugen = {
    enable = true;
    variant = "dark";
    jsonFormat = "hex";

    templates = {
      kitty = {
        input_path = ./templates/kitty-theme.conf;
        output_path = "~/.config/kitty/theme.conf";
      };
      fuzzel = {
        input_path = ./templates/fuzzel.ini;
        output_path = "~/.config/fuzzel/fuzzel.ini";
      };
      niri = {
        input_path = ./templates/niri-colors.kdl;
        output_path = "~/.config/niri/colors.kdl";
      };
    };
  };
}
