{
  config,
  pkgs,
  lib,
  ...
}: {
  home.username = "hello";
  home.homeDirectory = "/home/hello";

  home.stateVersion = "26.11";

  home.packages = with pkgs; [
    vesktop
    fastfetch
    htop
    unzip
    zip
    wget
    hyprlauncher
    yazi
    alejandra
  ];

  imports = [
    ./nixvim.nix
		./firefox.nix
		./git.nix
		./vscode.nix
		./hyprland.nix
  ];


  gtk = {
    enable = true;
    font = {
      name = "JetBrains Mono";
      size = 11;
    };
  };

  programs.home-manager.enable = true;


  programs.kitty.enable = true;

  home.sessionVariables.NIXOS_OZONE_WL = "1";
}
