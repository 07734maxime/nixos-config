{ config, pkgs, ... }:

{
  home.username = "hello";
  home.homeDirectory = "/home/hello";

  home.stateVersion = "26.11"; 

  programs.home-manager.enable = true;
}
