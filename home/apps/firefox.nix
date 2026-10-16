{ inputs, pkgs, ... }: {

  programs.firefox = {
    enable = true;
    profiles.default = {
      id = 0;
      name = "Default";
      isDefault = true;
      extensions.force = true;
      extensions.packages = with inputs.firefox-addons.packages.x86_64-linux; [ ublock-origin ];
      settings = {
        "browser.tabs.closeWindowWithLastTab" = false;
        "browser.startup.page" = 3;
        "privacy.trackingprotection.enabled" = true;
        "browser.ctrlTab.sortByRecentlyUsed" = true;
      };
    };
  };
  
}
