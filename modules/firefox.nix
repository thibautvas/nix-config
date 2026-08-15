{
  pkgs,
  ...
}:

let
  extensions = {
    "uBlock0@raymondhill.net" = "ublock-origin";
    "addon@darkreader.org" = "darkreader";
    "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = "vimium-ff";
    "vpn@proton.ch" = "proton-vpn-firefox-extension";
  };

  prefs = {
    "browser.ctrlTab.sortByRecentlyUsed" = true;
    "browser.shell.checkDefaultBrowser" = false;
    "browser.translations.neverTranslateLanguages" = "es,fr";
    "signon.rememberSignons" = false;
    "browser.startup.page" = 3;
    "sidebar.animation.enabled" = false;
    "sidebar.verticalTabs" = true;
    "sidebar.visibility" = "hide-sidebar";
  };

  extensionSettings = builtins.mapAttrs (name: value: {
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/${value}/latest.xpi";
    installation_mode = "force_installed";
    default_area = if name == "vpn@proton.ch" then "navbar" else "menupanel";
    private_browsing = "allow";
  }) extensions;

  extraPrefs = pkgs.lib.concatMapAttrsStringSep "\n" (
    name: value: "lockPref(${builtins.toJSON name}, ${builtins.toJSON value});"
  ) prefs;

in
pkgs.firefox.override {
  extraPolicies = {
    ExtensionSettings = extensionSettings;
    SearchEngines.Default = "DuckDuckGo";
  };
  inherit extraPrefs;
}
