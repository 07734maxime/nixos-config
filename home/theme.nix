{ pkgs, ... }:

{
  # ---------------------------------------------------------------------
  # GTK (Firefox, terminaux, file managers, la plupart des apps non-Qt)
  # ---------------------------------------------------------------------
  gtk = {
    enable = true;

    theme = {
      name = "Catppuccin-Mocha-Standard-Blue-Dark";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "blue" ];
        size = "standard";
        tweaks = [ "rimless" ];
        variant = "mocha";
      };
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    cursorTheme = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
      size = 24;
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  # ---------------------------------------------------------------------
  # Qt (VLC, Okular, certains terminaux Qt, etc.) via qt5ct/qt6ct + Kvantum
  # ---------------------------------------------------------------------
  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "kvantum";
  };

  home.packages = with pkgs; [
    libsForQt5.qt5ct
    qt6Packages.qt6ct
    libsForQt5.qtstyleplugin-kvantum
    qt6Packages.qtstyleplugin-kvantum
    catppuccin-kvantum
  ];

  xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=Catppuccin-Mocha-Blue
  '';

  # ---------------------------------------------------------------------
  # Variables d'environnement (mode sombre global + forcer les backends)
  # ---------------------------------------------------------------------
  home.sessionVariables = {
    GTK_THEME = "Catppuccin-Mocha-Standard-Blue-Dark";
    QT_QPA_PLATFORMTHEME = "qt5ct";
  };
}
