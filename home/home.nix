{
  pkgs,
  inputs,
  config,
  ...
}:
{
  home.stateVersion = "26.05";

  gtk = {
    enable = true;
    theme = {
      package = pkgs.dracula-theme;
      name = "Dracula";
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  imports = [
    ./apps/code.nix
    ./apps/firefox.nix
    ./apps/vim.nix
    ./apps/yazi.nix
    ./niri.nix
    ./niri/layout.nix
    ./packages.nix
  ];

  xdg.configFile."quickshell/quickhack.qml".source = ./quickhack.qml;

  xdg.configFile."kitty/kitty.conf".text = ''
    font_family JetBrains Mono
    font_size 12
    background #070b12
    background_opacity 0.88
    foreground #d9f7ff
    cursor #fcee0a
    cursor_shape block
    cursor_blink_interval 0.5
    selection_background #263346
    selection_foreground #ffffff
    active_border_color #00f0ff
    inactive_border_color #1a2638
    window_border_width 1px
    window_padding_width 12
    confirm_os_window_close 0
    enable_audio_bell no
    tab_bar_edge top
    tab_bar_style powerline
    active_tab_background #fcee0a
    active_tab_foreground #070b12
    inactive_tab_background #0d1420
    inactive_tab_foreground #6d8297

    color0 #070b12
    color1 #ff4d4d
    color2 #a8ff60
    color3 #fcee0a
    color4 #00a8ff
    color5 #ff2a9b
    color6 #00f0ff
    color7 #d9f7ff
    color8 #263346
    color9 #ff6b6b
    color10 #c5ff8a
    color11 #fff56b
    color12 #66d9ff
    color13 #ff72bb
    color14 #7df7ff
    color15 #ffffff
  '';

  xdg.configFile."fuzzel/fuzzel.ini".text = ''

    [main]
    font=JetBrains Mono:size=12
    prompt=> 
    layer=overlay
    icons-enabled=no
    width=52
    horizontal-pad=18
    vertical-pad=12
    inner-pad=8
    line-height=26
    lines=8

    [colors]
    background=070b12f2
    text=f5fbff
    prompt=fcee0a
    placeholder=afc4d4
    input=fcee0a
    match=ff2a9b
    selection=fcee0a
    selection-text=070b12
    selection-match=ff2a9b
    border=fcee0a

    [border]
    border-width=2
    border-radius=0
  '';

  programs.waybar = {
    enable = true;
    settings = [
      {
        layer = "top";
        position = "top";
        height = 36;
        margin-top = 8;
        margin-left = 8;
        margin-right = 8;
        spacing = 0;
        modules-left = [
          "niri/workspaces"
          "niri/window"
        ];
        modules-center = [ "clock" ];
        modules-right = [
          "network"
          "pulseaudio"
          "battery"
          "tray"
        ];

        "niri/workspaces" = {
          format = "{icon}";
          format-icons = {
            "1" = "01";
            "2" = "02";
            "3" = "03";
            "4" = "04";
            "5" = "05";
            "6" = "06";
            "7" = "07";
            "8" = "08";
            "9" = "09";
          };
          on-click = "activate";
          sort-by-number = true;
        };
        "niri/window" = {
          format = "{title}";
          max-length = 52;
          separate-outputs = true;
        };
        clock = {
          format = "{:%H:%M  /  %a %d %b}";
          tooltip-format = "{:%A, %d %B %Y\\nWeek %V}";
        };
        network = {
          format-wifi = "WIFI {signalStrength}%";
          format-ethernet = "LAN";
          format-disconnected = "OFFLINE";
          tooltip-format = "{ifname}: {ipaddr}";
        };
        pulseaudio = {
          format = "VOL {volume}%";
          format-muted = "MUTE";
          on-click = "pavucontrol";
          scroll-step = 5;
        };
        battery = {
          format = "BAT {capacity}%";
          format-charging = "CHG {capacity}%";
          states = {
            warning = 30;
            critical = 15;
          };
        };
        tray = {
          spacing = 8;
        };
      }
    ];
    style = ''
      @define-color void #070b12;
      @define-color panel #0d1420;
      @define-color panel-alt #121d2b;
      @define-color cyan #00f0ff;
      @define-color yellow #fcee0a;
      @define-color magenta #ff2a9b;
      @define-color text #d9f7ff;
      @define-color muted #6d8297;

      * {
        border: none;
        border-radius: 0;
        font-family: "JetBrains Mono";
        font-size: 11px;
        font-weight: 700;
        min-height: 0;
      }

      window#waybar {
        background: transparent;
        color: @text;
      }

      .modules-left,
      .modules-center,
      .modules-right {
        background: @panel;
        border: 1px solid @panel-alt;
        padding: 0 8px;
      }

      .modules-left {
        border-left: 3px solid @cyan;
      }

      .modules-center {
        border-bottom: 2px solid @yellow;
      }

      .modules-right {
        border-right: 3px solid @magenta;
      }

      #workspaces button {
        color: @muted;
        padding: 0 9px;
        background: transparent;
      }

      #workspaces button.active {
        color: @void;
        background: @yellow;
      }

      #workspaces button:hover {
        color: @void;
        background: @cyan;
      }

      #window {
        color: @cyan;
        padding: 0 14px;
      }

      #window.empty {
        min-width: 0;
        margin: 0;
        padding: 0;
      }

      #clock {
        color: @yellow;
        padding: 0 16px;
      }

      #network,
      #pulseaudio,
      #battery,
      #tray {
        padding: 0 9px;
      }

      #network { color: @cyan; }
      #pulseaudio { color: @magenta; }
      #battery { color: @yellow; }
      #battery.warning { color: @magenta; }
      #battery.critical { color: #ff4d4d; }
    '';
  };
}
