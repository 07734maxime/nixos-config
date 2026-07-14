{ pkgs, ... }:

{
  gtk = {
    enable = true;

    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

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
  ];

  xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=KvArcDark
  '';

  home.sessionVariables = {
    GTK_THEME = "Adwaita:dark";
    QT_QPA_PLATFORMTHEME = "qt5ct";
  };
}
