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
		swaylock
		playerctl
		brightnessctl
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
    theme = "Soliah";
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
	package = pkgs.niri;
  settings = {
		binds = with config.lib.niri.actions; {
    "Mod+Shift+Slash".action.show-hotkey-overlay = { };

    # Suggested binds for running programs: terminal, app launcher, screen locker.
    "Mod+T" = {
      hotkey-overlay.title = "Open a Terminal: kitty";
      action.spawn = "kitty";
    };
    "Mod+D" = {
      hotkey-overlay.title = "Run an Application: fuzzel";
      action.spawn = "fuzzel";
    };
    "Super+Alt+L" = {
      hotkey-overlay.title = "Lock the Screen: swaylock";
      action.spawn = "swaylock";
    };

    # spawn-sh pour les commandes shell (pipes, plusieurs commandes, etc.)
    "Super+Alt+S" = {
      allow-when-locked = true;
      action.spawn-sh = "pkill orca || exec orca";
    };

    # Volume (PipeWire / WirePlumber)
    "XF86AudioRaiseVolume" = {
      allow-when-locked = true;
      action.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0";
    };
    "XF86AudioLowerVolume" = {
      allow-when-locked = true;
      action.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
    };
    "XF86AudioMute" = {
      allow-when-locked = true;
      action.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
    };
    "XF86AudioMicMute" = {
      allow-when-locked = true;
      action.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
    };

    # Médias (playerctl, MPRIS)
    "XF86AudioPlay" = {
      allow-when-locked = true;
      action.spawn-sh = "playerctl play-pause";
    };
    "XF86AudioPause" = {
      allow-when-locked = true;
      action.spawn-sh = "playerctl play-pause";
    };
    "XF86AudioStop" = {
      allow-when-locked = true;
      action.spawn-sh = "playerctl stop";
    };
    "XF86AudioPrev" = {
      allow-when-locked = true;
      action.spawn-sh = "playerctl previous";
    };
    "XF86AudioNext" = {
      allow-when-locked = true;
      action.spawn-sh = "playerctl next";
    };

    # Luminosité (brightnessctl) - spawn avec liste d'arguments (évite de passer par sh)
    "XF86MonBrightnessUp" = {
      allow-when-locked = true;
      action.spawn = [ "brightnessctl" "--class=backlight" "set" "+10%" ];
    };
    "XF86MonBrightnessDown" = {
      allow-when-locked = true;
      action.spawn = [ "brightnessctl" "--class=backlight" "set" "10%-" ];
    };

    # Overview
    "Mod+O" = {
      repeat = false;
      action.toggle-overview = { };
    };

    "Mod+Q" = {
      repeat = false;
      action.close-window = { };
    };

    # Focus colonne / fenêtre
    "Mod+Left".action.focus-column-left = { };
    "Mod+Down".action.focus-window-down = { };
    "Mod+Up".action.focus-window-up = { };
    "Mod+Right".action.focus-column-right = { };
    "Mod+H".action.focus-column-left = { };
    "Mod+J".action.focus-window-down = { };
    "Mod+K".action.focus-window-up = { };
    "Mod+L".action.focus-column-right = { };

    # Déplacer colonne / fenêtre
    "Mod+Ctrl+Left".action.move-column-left = { };
    "Mod+Ctrl+Down".action.move-window-down = { };
    "Mod+Ctrl+Up".action.move-window-up = { };
    "Mod+Ctrl+Right".action.move-column-right = { };
    "Mod+Ctrl+H".action.move-column-left = { };
    "Mod+Ctrl+J".action.move-window-down = { };
    "Mod+Ctrl+K".action.move-window-up = { };
    "Mod+Ctrl+L".action.move-column-right = { };

    # Alternative : traverser les workspaces en bout de colonne (désactivé par défaut)
    # "Mod+J".action.focus-window-or-workspace-down = { };
    # "Mod+K".action.focus-window-or-workspace-up = { };
    # "Mod+Ctrl+J".action.move-window-down-or-to-workspace-down = { };
    # "Mod+Ctrl+K".action.move-window-up-or-to-workspace-up = { };

    "Mod+Home".action.focus-column-first = { };
    "Mod+End".action.focus-column-last = { };
    "Mod+Ctrl+Home".action.move-column-to-first = { };
    "Mod+Ctrl+End".action.move-column-to-last = { };

    # Focus écran
    "Mod+Shift+Left".action.focus-monitor-left = { };
    "Mod+Shift+Down".action.focus-monitor-down = { };
    "Mod+Shift+Up".action.focus-monitor-up = { };
    "Mod+Shift+Right".action.focus-monitor-right = { };
    "Mod+Shift+H".action.focus-monitor-left = { };
    "Mod+Shift+J".action.focus-monitor-down = { };
    "Mod+Shift+K".action.focus-monitor-up = { };
    "Mod+Shift+L".action.focus-monitor-right = { };

    # Déplacer colonne vers un autre écran
    "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left = { };
    "Mod+Shift+Ctrl+Down".action.move-column-to-monitor-down = { };
    "Mod+Shift+Ctrl+Up".action.move-column-to-monitor-up = { };
    "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = { };
    "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = { };
    "Mod+Shift+Ctrl+J".action.move-column-to-monitor-down = { };
    "Mod+Shift+Ctrl+K".action.move-column-to-monitor-up = { };
    "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = { };

    # Alternative : déplacer une seule fenêtre / tout le workspace vers un autre écran
    # "Mod+Shift+Ctrl+Left".action.move-window-to-monitor-left = { };
    # "Mod+Shift+Ctrl+Left".action.move-workspace-to-monitor-left = { };

    # Focus / déplacer workspace
    "Mod+Page_Down".action.focus-workspace-down = { };
    "Mod+Page_Up".action.focus-workspace-up = { };
    "Mod+U".action.focus-workspace-down = { };
    "Mod+I".action.focus-workspace-up = { };
    "Mod+Ctrl+Page_Down".action.move-column-to-workspace-down = { };
    "Mod+Ctrl+Page_Up".action.move-column-to-workspace-up = { };
    "Mod+Ctrl+U".action.move-column-to-workspace-down = { };
    "Mod+Ctrl+I".action.move-column-to-workspace-up = { };

    # Alternative : déplacer une seule fenêtre
    # "Mod+Ctrl+Page_Down".action.move-window-to-workspace-down = { };

    "Mod+Shift+Page_Down".action.move-workspace-down = { };
    "Mod+Shift+Page_Up".action.move-workspace-up = { };
    "Mod+Shift+U".action.move-workspace-down = { };
    "Mod+Shift+I".action.move-workspace-up = { };

    # Molette souris (cooldown-ms pour limiter le taux de déclenchement)
    "Mod+WheelScrollDown" = {
      cooldown-ms = 150;
      action.focus-workspace-down = { };
    };
    "Mod+WheelScrollUp" = {
      cooldown-ms = 150;
      action.focus-workspace-up = { };
    };
    "Mod+Ctrl+WheelScrollDown" = {
      cooldown-ms = 150;
      action.move-column-to-workspace-down = { };
    };
    "Mod+Ctrl+WheelScrollUp" = {
      cooldown-ms = 150;
      action.move-column-to-workspace-up = { };
    };

    "Mod+WheelScrollRight".action.focus-column-right = { };
    "Mod+WheelScrollLeft".action.focus-column-left = { };
    "Mod+Ctrl+WheelScrollRight".action.move-column-right = { };
    "Mod+Ctrl+WheelScrollLeft".action.move-column-left = { };

    # Scroll horizontal façon Shift+molette
    "Mod+Shift+WheelScrollDown".action.focus-column-right = { };
    "Mod+Shift+WheelScrollUp".action.focus-column-left = { };
    "Mod+Ctrl+Shift+WheelScrollDown".action.move-column-right = { };
    "Mod+Ctrl+Shift+WheelScrollUp".action.move-column-left = { };

    # Scroll trackpad (désactivé par défaut, exemple contrôle du volume)
    # "Mod+TouchpadScrollDown".action.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.02+";
    # "Mod+TouchpadScrollUp".action.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.02-";

    # Aller à un workspace par index (système dynamique, "best effort")
    "Mod+1".action.focus-workspace = 1;
    "Mod+2".action.focus-workspace = 2;
    "Mod+3".action.focus-workspace = 3;
    "Mod+4".action.focus-workspace = 4;
    "Mod+5".action.focus-workspace = 5;
    "Mod+6".action.focus-workspace = 6;
    "Mod+7".action.focus-workspace = 7;
    "Mod+8".action.focus-workspace = 8;
    "Mod+9".action.focus-workspace = 9;
    "Mod+Ctrl+1".action.move-column-to-workspace = 1;
    "Mod+Ctrl+2".action.move-column-to-workspace = 2;
    "Mod+Ctrl+3".action.move-column-to-workspace = 3;
    "Mod+Ctrl+4".action.move-column-to-workspace = 4;
    "Mod+Ctrl+5".action.move-column-to-workspace = 5;
    "Mod+Ctrl+6".action.move-column-to-workspace = 6;
    "Mod+Ctrl+7".action.move-column-to-workspace = 7;
    "Mod+Ctrl+8".action.move-column-to-workspace = 8;
    "Mod+Ctrl+9".action.move-column-to-workspace = 9;

    # Alternative : déplacer une seule fenêtre vers un workspace précis
    # "Mod+Ctrl+1".action.move-window-to-workspace = 1;

    # Bascule entre le workspace courant et le précédent (désactivé)
    # "Mod+Tab".action.focus-workspace-previous = { };

    # Insérer / expulser une fenêtre d'une colonne
    "Mod+BracketLeft".action.consume-or-expel-window-left = { };
    "Mod+BracketRight".action.consume-or-expel-window-right = { };

    "Mod+Comma".action.consume-window-into-column = { };
    "Mod+Period".action.expel-window-from-column = { };

    # Largeur / hauteur prédéfinies
    "Mod+R".action.switch-preset-column-width = { };
    "Mod+Shift+R".action.switch-preset-column-width-back = { };

    "Mod+Ctrl+Shift+R".action.switch-preset-window-height = { };
    "Mod+Ctrl+R".action.reset-window-height = { };

    "Mod+F".action.maximize-column = { };
    "Mod+Shift+F".action.fullscreen-window = { };
    "Mod+M".action.maximize-window-to-edges = { };

    "Mod+Ctrl+F".action.expand-column-to-available-width = { };

    "Mod+C".action.center-column = { };
    "Mod+Ctrl+C".action.center-visible-columns = { };

    # Réglages fins de largeur / hauteur
    # Accepte : pixels ("1000"), ajustement ("-5"/"+5"), pourcentage ("25%"), ajustement en % ("-10%"/"+10%")
    "Mod+Minus".action.set-column-width = "-10%";
    "Mod+Equal".action.set-column-width = "+10%";

    "Mod+Shift+Minus".action.set-window-height = "-10%";
    "Mod+Shift+Equal".action.set-window-height = "+10%";

    # Flottant / tiling
    "Mod+V".action.toggle-window-floating = { };
    "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = { };

    # Colonne en mode onglets
    "Mod+W".action.toggle-column-tabbed-display = { };

    # Changement de layout clavier (désactivé - attention aux conflits avec xkb options)
    # "Mod+Space".action.switch-layout = "next";
    # "Mod+Shift+Space".action.switch-layout = "prev";

    # Captures d'écran
    "Print".action.screenshot = { };
    "Ctrl+Print".action.screenshot-screen = { };
    "Alt+Print".action.screenshot-window = { };

    # Échappatoire pour l'inhibiteur de raccourcis (bureau à distance, KVM logiciel, etc.)
    "Mod+Escape" = {
      allow-inhibiting = false;
      action.toggle-keyboard-shortcuts-inhibit = { };
    };

    # Quitter (avec confirmation)
    "Mod+Shift+E".action.quit = { };
    "Ctrl+Alt+Delete".action.quit = { };

    # Éteindre les écrans
    "Mod+Shift+P".action.power-off-monitors = { };			};
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
