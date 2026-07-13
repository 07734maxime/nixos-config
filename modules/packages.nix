{ config, pkgs, ... }:

{
	environment.systemPackages = with pkgs; [
   	  sbctl
 	];

	fonts.packages = with pkgs; [
  	  jetbrains-mono
	];
}
