{ config, inputs, lib, pkgs, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      ./modules/packages.nix
      ./modules/system.nix
      ./modules/desktop.nix
			inputs.noctalia.nixosModules.default
		];

  programs.noctalia = {
    enable = true;
    recommendedServices.enable = true;   # active NetworkManager, Bluetooth, UPower, power-profiles-daemon
  };
	programs.noctalia.systemd.enable = true;
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

	nix.settings = {
  	extra-substituters = [ "https://noctalia.cachix.org" ];
  	extra-trusted-public-keys = [ "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4=" ];
	};


  nixpkgs.config.allowUnfree = true;
  programs.dconf.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;



  users.users.hello = {
     isNormalUser = true;
     extraGroups = [ "wheel" "networkmanager" ];
     packages = with pkgs; [
       tree
     ];
   };

  users.users.hello.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN1gvUOMOxzbopSZ0ISIHlIE4GRab7MHldYPx9yK463f 07734maxime@proton.me" ];


  system.stateVersion = "26.05";

}

