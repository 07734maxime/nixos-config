{pkgs, ...}: {
  programs.vscode = {
    enable = true;

    profiles = {
      default = {
        userSettings = {
          "editor.fontSize" = 14;
          "editor.fontFamily" = "'JetBrainsMono Nerd Font'";
        };
        extensions = with pkgs.vscode-marketplace; [
      pkief.material-icon-theme
      icrawl.discord-vscode
    ];
      };
    };
  };
}
