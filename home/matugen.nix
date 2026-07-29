{ inputs, pkgs, ... }:
{

  home.packages = [ inputs.matugen.packages.${pkgs.system}.default ];

  xdg.configFile."matugen/config.toml".text = ''
    [config]
    reload_apps = true

    [templates.kitty]
    input_path = "~/.config/matugen/templates/kitty-theme.conf"
    output_path = "~/.config/kitty/theme.conf"

    [templates.fuzzel]
    input_path = "~/.config/matugen/templates/fuzzel.ini"
    output_path = "~/.config/fuzzel/fuzzel.ini"

    [templates.niri]
    input_path = "~/.config/matugen/templates/niri-colors.kdl"
    output_path = "~/.config/niri/colors.kdl"
  '';

	xdg.configFile."matugen/templates/yazi-theme.toml".source = ./templates/yazi-theme.toml;
  xdg.configFile."matugen/templates/kitty-theme.conf".source = ./templates/kitty-theme.conf;
  xdg.configFile."matugen/templates/fuzzel.ini".source = ./templates/fuzzel.ini;
	xdg.configFile."matugen/templates/niri-colors.kdl".source = ./templates/niri-colors.kdl;
  xdg.configFile."matugen/templates/vscode.json".source = ./templates/vscode.json;
}
