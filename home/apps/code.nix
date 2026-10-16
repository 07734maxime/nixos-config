{ inputs, pkgs, ... }: {

  programs.vscode = {
    enable = true;

    profiles.default = {

      extensions = with pkgs.vscode-extensions; [
        dracula-theme.theme-dracula
        jnoortheen.nix-ide
        pkief.material-icon-theme
      ];

      userSettings = {
        "editor.fontSize" = 14;
        "workbench.colorTheme" = "Dracula Theme";
        "editor.fontFamily" = "'JetBrainsMono Nerd Font'";
        "editor.fontLigatures" = true;
        "workbench.iconTheme" = "material-icon-theme";
        "editor.tabSize" = 2;
        "telemetry.telemetryLevel" = "off";
        "files.autoSave" = "afterDelay";
        "files.autoSaveDelay" = 1000;
        "editor.mouseWheelZoom" = true;
        "security.workspace.trust.enabled" = false;
        "workbench.layoutControl" = true;
        "window.dialogStyle" = "modern";
        "workbench.activityBar.location" = "side";
        "workbench.experimental.modernUIEditorTabStyle" = "modern";
        "workbench.editor.showTabs" = "multiple";
        "window.titleBarStyle" = "custom";
        "mutableExtensionsDir" = false;
        "settingsSync.keybindings" = false;
      };
    };
  };

}
