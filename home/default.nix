{ pkgs,  ... }:
{
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
		./hyprland/hyprland.nix
  ];


  gtk = {
    enable = true;
    font = {
      name = "JetBrains Mono";
      size = 12;
    };
  };

	programs.bash = {
		enable = true;
			bashrcExtra = ''
				fastfetch
			'';
	};

  programs.home-manager.enable = true;


  programs.kitty = {
		enable = true;
		background_opacity = "0.7";
		window_padding_width = 10;
	}

  home.sessionVariables.NIXOS_OZONE_WL = "1";
}
