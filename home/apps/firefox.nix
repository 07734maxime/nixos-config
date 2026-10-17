# Firefox in the language of the deck: chamfered dark chrome and numbered tabs
# (userChrome.css), the new tab and about: pages to match (userContent.css),
# and a netrunner home page. Colours: the palette cyberdeck-theme writes for
# the live OS, read when Firefox starts; the engraved one underneath.
{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
let
  theme = import ../../theme { inherit pkgs lib; };
  state = "${config.xdg.stateHome}/cyberdeck";

  # the engraved palette, outranked by the live one (:root:root in firefox.css)
  fallback = lib.concatMapStrings (key: "--cd-${key}: ${theme.palette.roles.${key}}; ") [
    "bg"
    "surface"
    "overlay"
    "muted"
    "subtle"
    "fg"
    "bright"
    "white"
    "primary"
    "secondary"
    "tertiary"
    "danger"
    "alt"
    "warn"
    "ok"
  ];

  # @import has to come before every rule of the sheet
  sheet =
    file:
    ''
      @import url("file://${state}/firefox.css");
      :root { ${fallback}}
    ''
    + builtins.replaceStrings [ "@PALETTE@" ] [ "${state}/firefox.css" ] (builtins.readFile file);

  startpage = pkgs.writeText "cyberdeck-startpage.html" (
    builtins.replaceStrings [ "@STATE@" "@FALLBACK@" ] [ state fallback ] (
      builtins.readFile ./firefox/startpage.html
    )
  );
  home = "file://${config.xdg.configHome}/cyberdeck/startpage.html";
in
{
  xdg.configFile."cyberdeck/startpage.html".source = startpage;

  programs.firefox = {
    enable = true;
    profiles.default = {
      id = 0;
      name = "Default";
      isDefault = true;
      extensions.force = true;
      extensions.packages = with inputs.firefox-addons.packages.x86_64-linux; [ ublock-origin ];
      userChrome = sheet ./firefox/userChrome.css;
      userContent = sheet ./firefox/userContent.css;
      settings = {
        "browser.tabs.closeWindowWithLastTab" = false;
        "browser.startup.page" = 3;
        "privacy.trackingprotection.enabled" = true;
        "browser.ctrlTab.sortByRecentlyUsed" = true;

        # the two sheets above
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "svg.context-properties.content.enabled" = true;

        # the netrunner home page (Home button, Alt+Home)
        "browser.startup.homepage" = home;

        # dark everywhere, compact like the HUD
        "browser.theme.toolbar-theme" = 0;
        "browser.theme.content-theme" = 0;
        "layout.css.prefers-color-scheme.content-override" = 0;
        "devtools.theme" = "dark";
        "browser.uidensity" = 1;

        # a new tab with the shortcuts only: no sponsors, no stories, no Pocket
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.feeds.snippets" = false;
        "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
        "browser.newtabpage.activity-stream.showWeather" = false;
        "browser.newtabpage.activity-stream.feeds.topsites" = true;
        "extensions.pocket.enabled" = false;

        "browser.aboutConfig.showWarning" = false;
      };
    };
  };
}
