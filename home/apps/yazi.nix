{ config, ... }:
let
  kitty = "${config.programs.kitty.package}/bin/kitty";
in
{
  programs.yazi = {
    enable = true;
    settings = {
      mgr = {
        show_hidden = true;
        sort_by = "mtime";
        sort_dir_first = true;
      };
    };
  };

  # yazi's own .desktop has Terminal=true, which gio/xdg-open can't run with
  # kitty, so wrap it in a kitty window ourselves
  xdg.desktopEntries.yazi-kitty = {
    name = "Yazi";
    icon = "yazi";
    exec = "${kitty} --class yazi -e yazi %U";
    terminal = false;
    mimeType = [ "inode/directory" ];
    categories = [ "System" "FileManager" ];
  };

  # "open folder" / "show in folder" everywhere (Firefox downloads, xdg-open, gio...)
  # goes to yazi instead of VS Code, which also claims inode/directory
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = "yazi-kitty.desktop";
      "x-scheme-handler/claude-cli" = "claude-code-url-handler.desktop";
    };
    associations.removed."inode/directory" = "code.desktop";
  };
}
