{
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
}
