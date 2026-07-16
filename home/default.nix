{ pkgs,  ... }:
{
  home.username = "hello";
  home.homeDirectory = "/home/hello";

  home.stateVersion = "26.11";

  home.packages = with pkgs; [
    vesktop
    fastfetch
    btop
    unzip
    zip
    wget
    hyprlauncher
    yazi
		xdg-utils
    alejandra
		noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
		noto-fonts-color-emoji
		tree
  ];

  imports = [
		./theme.nix
    ./nixvim.nix
		./firefox.nix
		./git.nix
		./vscode.nix
		./hyprland/default.nix
  ];

	programs.zsh = {
  enable = true;
  enableCompletion = true;
  autosuggestion.enable = true;
  syntaxHighlighting.enable = true;


  oh-my-zsh = {
    enable = true;
    theme = "robbyrussell";
    plugins = [
      "git"
      "zoxide"
      "fzf"
    ];
  };


  shellAliases = {
    ll = "ls -l";
    nixswitch = "nh os switch";
    v = "nvim";
  };
};


programs.zoxide.enable = true;
programs.fzf.enable = true;






	programs.bash = {
		enable = true;
			bashrcExtra = ''
				fastfetch
			'';
	};

  programs.home-manager.enable = true;


  programs.kitty = {
		enable = true;
		settings = {
			background_opacity = "0.7";
			window_padding_width = 25;
		};
	};

  home.sessionVariables.NIXOS_OZONE_WL = "1";
}
