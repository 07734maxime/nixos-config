{
  config,
  inputs,
  pkgs,
  ...
}: {
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
		./niri.nix
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
      nixswitch = "sudo nixos-rebuild switch --flake ~/nixos-dotfiles#nixos";
      v = "nvim";
    };
  };

  home.pointerCursor = {
    enable = true;
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
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
			enable_audio_bell = "no";
      background_opacity = "0.7";
      window_padding_width = 25;
    };
  };

  home.sessionVariables.NIXOS_OZONE_WL = "1";
}
