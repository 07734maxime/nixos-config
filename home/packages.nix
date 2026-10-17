# The programs of the user: the list below by hand, plus home/packages.json,
# written by the PACKAGE BROKER of the shell (cyberdeck-pkgs).
{
  pkgs,
  lib,
  ...
}:
{
  home.packages =
    with pkgs;
    [
      discord
      swaybg
      swaylock
      xwayland-satellite
      wl-clipboard
      pavucontrol
      yazi
      nixfmt
      playerctl
      libnotify
      jq
    ]
    # added from the PACKAGE BROKER of the shell (cyberdeck-pkgs), which checks
    # every name against nixpkgs; dotted names reach into package sets
    ++ map (name: lib.getAttrFromPath (lib.splitString "." name) pkgs) (lib.importJSON ./packages.json);
}
