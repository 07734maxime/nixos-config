{
  pkgs,
  inputs,
  config,
  ...
}:
{
  home.stateVersion = "26.05";

  imports = [
    ./apps/code.nix
    ./apps/firefox.nix
    ./apps/vim.nix
    ./apps/yazi.nix
    ./niri.nix
    ./packages.nix
  ];

  programs.waybar.enable = true;
}
