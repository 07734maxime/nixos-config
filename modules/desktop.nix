{ config, pkgs, ... }:
{
  # Nvidia
  hardware.graphics = { enable = true; enable32Bit = true; };
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
	modesetting.enable = true;
	powerManagement.enable = false;
	open = true;
    	nvidiaSettings = true;
    	package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Hyprland & Audio
  programs.hyprland.enable = true;
  services.pipewire = { enable = true; pulse.enable = true; };
  programs.firefox.enable = true;
}
