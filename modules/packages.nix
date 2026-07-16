{ config, pkgs, ... }:

{
	environment.systemPackages = with pkgs; [
		sbctl
		tuigreet
		greetd

 	];

	fonts.packages = with pkgs; [
  	  jetbrains-mono
	];
}
