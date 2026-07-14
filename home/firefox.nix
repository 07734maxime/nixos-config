{
	programs.firefox = {
    enable = true;
    profiles.hello = {
      id = 0;
      name = "Default";
      isDefault = true;
      settings = {
				"browser.tabs.closeWindowWithLastTab" = false;
				"browser.startup.page" = 3;
        "browser.startup.homepage" = "https://nixos.org";
        "privacy.trackingprotection.enabled" = true;
        "browser.ctrlTab.sortByRecentlyUsed" = true;
      };
    };
  };
}
