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
	    hyprlauncher
	    yazi
			alejandra
	  ];

		import = [
		./nixvim.nix
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
	   
	   mod = {
		_var = "SUPER";
	   };

	   terminal = {
	   	_var = "kitty";
	   };

	   menu = {
		_var = "hyprlauncher";
	   };

	   fileManager = {
		_var = "bash -c 'kitty -e yazi'";
	   };

	    config = {
		input = {
		  kb_layout = "fr";
		};

		general = {
		  gaps_in=10;
		  gaps_out=10;

		  layout = "scrolling";
		};


		decoration = {
		  rounding = 15;
		};
	    };

	    monitor = [
	      { output = "DP-2"; mode = "1920x1080@180"; position = "0x0"; scale = 1; }
	      { output = "DP-1"; mode = "1920x1080@180"; position = "1920x0"; scale = 1; }
	    ];

	    curve = [
	      { _args = [ "easeOutQuint"   { type = "bezier"; points = [ [0.23 1]   [0.32 1] ]; } ]; }
	      { _args = [ "easeInOutCubic" { type = "bezier"; points = [ [0.65 0.05] [0.36 1] ]; } ]; }
	      { _args = [ "linear"         { type = "bezier"; points = [ [0 0]      [1 1] ]; } ]; }
	      { _args = [ "almostLinear"   { type = "bezier"; points = [ [0.5 0.5]  [0.75 1] ]; } ]; }
	      { _args = [ "quick"          { type = "bezier"; points = [ [0.15 0]   [0.1 1] ]; } ]; }
	      { _args = [ "easy"           { type = "spring"; mass = 1; stiffness = 71.2633; dampening = 15.8273644; } ]; }
	    ];

	    animation = [
	      { leaf = "global";        enabled = true; speed = 10;   bezier = "default"; }
	      { leaf = "border";        enabled = true; speed = 5.39; bezier = "easeOutQuint"; }
	      { leaf = "windows";       enabled = true; speed = 4.79; spring = "easy"; }
	      { leaf = "windowsIn";     enabled = true; speed = 4.1;  spring = "easy";         style = "popin 87%"; }
	      { leaf = "windowsOut";    enabled = true; speed = 1.49; bezier = "linear";       style = "popin 87%"; }
	      { leaf = "fadeIn";        enabled = true; speed = 1.73; bezier = "almostLinear"; }
	      { leaf = "fadeOut";       enabled = true; speed = 1.46; bezier = "almostLinear"; }
	      { leaf = "fade";          enabled = true; speed = 3.03; bezier = "quick"; }
	      { leaf = "layers";        enabled = true; speed = 3.81; bezier = "easeOutQuint"; }
	      { leaf = "layersIn";      enabled = true; speed = 4;    bezier = "easeOutQuint"; style = "fade"; }
	      { leaf = "layersOut";     enabled = true; speed = 1.5;  bezier = "linear";       style = "fade"; }
	      { leaf = "fadeLayersIn";  enabled = true; speed = 1.79; bezier = "almostLinear"; }
	      { leaf = "fadeLayersOut"; enabled = true; speed = 1.39; bezier = "almostLinear"; }
	      { leaf = "workspaces";    enabled = true; speed = 1.94; bezier = "almostLinear"; style = "fade"; }
	      { leaf = "workspacesIn";  enabled = true; speed = 1.21; bezier = "almostLinear"; style = "fade"; }
	      { leaf = "workspacesOut"; enabled = true; speed = 1.94; bezier = "almostLinear"; style = "fade"; }
	      { leaf = "zoomFactor";    enabled = true; speed = 7;    bezier = "quick"; }
	    ];


	    bind = [
		{
		_args = [
		(lib.generators.mkLuaInline "mod .. \" + Q\"")
		(lib.generators.mkLuaInline "hl.dsp.window.close()")
		];
		}
		{
		_args = [
		(lib. generators.mkLuaInline "mod .. \" + D\"")
	(lib.generators.mkLuaInline "hl.dsp.exec_cmd(menu)")
	];
	}
	{
	_args = [
	(lib.generators.mkLuaInline "mod .. \" + T\"")
	(lib.generators.mkLuaInline "hl.dsp.exec_cmd(terminal)")
	];
	}
	{
	_args = [
	(lib.generators.mkLuaInline "mod .. \" + SHIFT + M\"")
	(lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'\")")
	];
	}
	{
	_args = [
	(lib.generators.mkLuaInline "mod .. \" + E\"")
	(lib.generators.mkLuaInline "hl.dsp.exec_cmd(fileManager)")
	];
	}
		{
	_args = [
	(lib.generators.mkLuaInline "mod .. \" + V\"")
	(lib.generators.mkLuaInline "hl.dsp.window.float({ action = \"toggle\" })")
	];
	}

			{
	_args = [
	(lib.generators.mkLuaInline "mod .. \" + mouse:272\"")
	(lib.generators.mkLuaInline "hl.dsp.window.drag()")
	{ mouse = true; }
	];
	}

				{
	_args = [
	(lib.generators.mkLuaInline "mod .. \" + mouse:273\"")
	(lib.generators.mkLuaInline "hl.dsp.window.resize()")
	{ mouse = true; }
	];
	}



    ];


  };

  home.sessionVariables.NIXOS_OZONE_WL = "1";
}
