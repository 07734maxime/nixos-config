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
    unzip
    zip
    wget
		xdg-utils
    alejandra
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    tree
    playerctl
    brightnessctl
  ];

  imports = [
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

		initContent = ''
			fastfetch
		'';

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
 
  programs.zoxide.enable = true;
  programs.fzf.enable = true;
  programs.home-manager.enable = true;
  home.sessionVariables.NIXOS_OZONE_WL = "1";
}
