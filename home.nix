{ config, pkgs, ... }:

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
    neovim
  ];

  programs.git = {
    enable = true;
    userName = "07734maxime";
    userEmail = "07734maxime@proton.me";
  };



  programs.home-manager.enable = true;

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
    	discord-rpc
    ];

    userSettings = {
      "editor.fontSize" = 14;
      "editor.fontFamily" = "'JetBrainsMono Nerd Font'";
    };
  };

  programs.firefox = {
    enable = true;
    profiles.hello = {
      id = 0;
      name = "Default";
      isDefault = true;
    
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
      ];
    
      settings = {
        "browser.startup.homepage" = "https://nixos.org";
        "privacy.trackingprotection.enabled" = true;
        "browser.ctrlTab.sortByRecentlyUsed" = true;
      };
    };
  };
  programs.kitty.enable = true;
  wayland.windowManager.hyprland.enable = true;
  home.sessionVariables.NIXOS_OZONE_WL = "1";
}
