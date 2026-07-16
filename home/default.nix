{ config, inputs, pkgs,  ... }:
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
		yazi
		xdg-utils
    alejandra
		noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
		noto-fonts-color-emoji
		tree
		inputs.awww.packages.${pkgs.stdenv.hostPlatform.system}.awww
		fuzzel
		wlr-randr
		waypaper
  ];

  imports = [
		./theme.nix
    ./nixvim.nix
		./firefox.nix
		./git.nix
		./vscode.nix
  ];

	programs.zsh = {
  enable = true;
  enableCompletion = true;
  autosuggestion.enable = true;
  syntaxHighlighting.enable = true;


  oh-my-zsh = {
    enable = true;
    theme = "soliah";
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

programs.niri = {
  enable = true;
  settings = {
		binds = with config.lib.niri.actions; {
			"Mod+Q".action = close-window;
			"Mod+Shift+E".action = quit;
		  "Mod+Left".action = focus-column-left;
  		"Mod+Right".action = focus-column-right;
  		"Mod+Shift+Left".action = move-column-left;
  		"Mod+Shift+Right".action = move-column-right;
			"Mod+T".action.spawn = "kitty";
			"Mod+D".action.spawn = "fuzzel";

			};
		outputs."DP-1".mode = { width = 1920; height = 1080; refresh = 180.0; };
		outputs."DP-2".mode = { width = 1920; height = 1080; refresh = 179.981995; };
		input = {
      keyboard = {
        xkb = {
          layout = "fr";
          variant = "latin9"; # "latin9" est souvent préférable à "azerty" pour éviter les bugs sur les symboles
        };
      };
    };
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
