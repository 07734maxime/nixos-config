{ config, pkgs, lib, ... }:

{
  home.username = "hello";
  home.homeDirectory = "/home/hello";

  home.stateVersion = "26.11";

  home.packages = with pkgs; [
    vesktop
    fastfetch
    htop
    unzip
    zip
    wget
    neovim
  ];

  programs.git = {
    enable = true;
    settings = {
	user = {
	  name = "07734maxime";
	  email = "07734maxime@proton.me";
	};
    };
  };

  gtk = {
    enable = true;
    font = {
      name = "JetBrains Mono";
      size = 11;
   };
  };



  programs.home-manager.enable = true;

  programs.vscode = {
    enable = true;

    profiles = {
      default = {
        userSettings = {
          "editor.fontSize" = 14;
          "editor.fontFamily" = "'JetBrainsMono Nerd Font'";
        };
      };
    };
  };

  programs.firefox = {
    enable = true;
    profiles.hello = {
      id = 0;
      name = "Default";
      isDefault = true;
    
      settings = {
        "browser.startup.homepage" = "https://nixos.org";
        "privacy.trackingprotection.enabled" = true;
        "browser.ctrlTab.sortByRecentlyUsed" = true;
      };
    };
  };
  programs.kitty.enable = true;
  wayland.windowManager.hyprland.enable = true;

  wayland.windowManager.hyprland.settings = {
    
    mod = { _var = "SUPER"; };

    config = {
	input = {
	  kb_layout = "fr";
    	};
    };

    monitor = [
      { output = "DP-2"; mode = "1920x1080@180"; position = "0x0"; scale = 1; }
      { output = "DP-1"; mode = "1920x1080@180"; position = "1920x0"; scale = 1; }
    ];

  bind = [
    {
      _args = [
        (lib.generators.mkLuaInline "mod .. \" + Q\"")
        (lib.generators.mkLuaInline "hl.dsp.window.close()")
        { locked = true; }
      ];
    }
    {
      _args = [
        "SUPER + T"
        (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"kitty\")")
      ];
    }
    {
      _args = [
        "ALT + R"
        (lib.generators.mkLuaInline "hl.dsp.submap(\"resize\")")
      ];
    }
  ];

  };

  home.sessionVariables.NIXOS_OZONE_WL = "1";
}
