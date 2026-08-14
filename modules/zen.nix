{
  pkgs,
  zen-build,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) system;
  zen-browser = zen-build.packages.${system}.default;

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
    "zen.theme.content-element-separation" = 0;
    "zen.view.compact.animate-sidebar" = false;
    "zen.view.compact.show-sidebar-and-toolbar-on-hover" = false;
    "zen.welcome-screen.seen" = true;
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
zen-browser.override {
  extraPolicies = {
    ExtensionSettings = extensionSettings;
    SearchEngines.Default = "DuckDuckGo";
  };
  inherit extraPrefs;
}
