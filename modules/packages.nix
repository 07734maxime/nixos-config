{ config, pkgs, ... }:

{
	environment.systemPackages = with pkgs; [
   	neovim
   	wget
   	git
   	fastfetch
   	kitty
   	hyprlauncher
   	yazi
   	vscode
   	discord
   	spotify
   	zip
   	unzip
   	sbctl
   	lon
 	];
}
