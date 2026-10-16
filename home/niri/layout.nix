{ ... }:
{
  programs.niri.settings = {
    layout = {
      gaps = 12;
      struts = {
        left = 8;
        right = 8;
        top = 32;
        bottom = 8;
      };
      focus-ring = {
        width = 2;
        active = {
          color = "#fcee0a";
        };
        inactive = {
          color = "#263346";
        };
      };
      border = {
        enable = false;
        width = 1;
        active = {
          color = "#00f0ff";
        };
        inactive = {
          color = "#1a2638";
        };
      };
      shadow = {
        enable = true;
        softness = 24;
        spread = 4;
        offset = {
          x = 0;
          y = 8;
        };
        color = "#00000080";
      };
    };

    animations = {
      workspace-switch.kind = {
        spring = {
          damping-ratio = 0.85;
          stiffness = 720;
          epsilon = 0.0001;
        };
      };
      window-movement.kind = {
        spring = {
          damping-ratio = 0.9;
          stiffness = 680;
          epsilon = 0.0001;
        };
      };
    };

    window-rules = [
      {
        geometry-corner-radius = {
          top-left = 0.0;
          top-right = 0.0;
          bottom-left = 0.0;
          bottom-right = 0.0;
        };
        clip-to-geometry = true;
      }
      {
        matches = [
          { app-id = "file_chooser"; }
          { app-id = "kitty"; }
        ];
        open-floating = true;
      }
    ];

    prefer-no-csd = true;
  };
}
