{ ... }:

{
  programs.noctalia = {
    enable = true;
    systemd.enable = true;

    settings = {
      theme = {
        mode = "dark";
      };

      wallpaper = {
        enabled = true;
				directory = "/home/hello/nixos-dotfiles/home/assets";
      };

			backdrop = {
				blur_intensity = 0.5;
				enabled = true;
			};
    };
  };
}
