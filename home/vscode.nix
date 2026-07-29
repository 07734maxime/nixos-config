{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;

    profiles = {
      default = {
        userSettings = {
          "editor.fontSize" = 14;
          "editor.fontFamily" = "'JetBrainsMono Nerd Font'";
          "workbench.iconTheme" = "material-icon-theme";
          "workbench.colorTheme" = "Dracula Theme";
          "files.autoSave" = "afterDelay";
          "files.autoSaveDelay" = 1000;
          "explorer.confirmDelete" = false;
          "editor.mouseWheelZoom" = true;
          "workbench.activityBar.location" = "top";
          "workbench.sideBar.location" = "right";
        };

        extensions = with pkgs.vscode-marketplace; [
          pkief.material-icon-theme
          icrawl.discord-vscode
          bbenoist.nix
          dracula-theme.theme-dracula
        ];
      };
    };
  };
}