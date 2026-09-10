{
  pkgs,
  ...
}:

let
  inherit (pkgs) lib;
  kernel = pkgs.stdenv.hostPlatform.parsed.kernel.name;

  defaultSearchEngine = "DuckDuckGo";

  extensions = {
    "uBlock0@raymondhill.net" = "ublock-origin";
    "addon@darkreader.org" = "darkreader";
    "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = "vimium-ff";
    "vpn@proton.ch" = "proton-vpn-firefox-extension";
  };

  prefs = {
    "browser.aboutwelcome.enabled" = false;
    "browser.ctrlTab.sortByRecentlyUsed" = true;
    "browser.shell.checkDefaultBrowser" = false;
    "browser.startup.page" = 3;
    "browser.tabs.closeWindowWithLastTab" = false;
    "browser.translations.neverTranslateLanguages" = "es,fr";
    "browser.urlbar.autoFill.adaptiveHistory.enabled" = true;
    "browser.urlbar.showSearchSuggestionsFirst" = false;
    "sidebar.animation.enabled" = false;
    "sidebar.verticalTabs" = true;
    "sidebar.visibility" = "hide-sidebar";
    "signon.rememberSignons" = false;
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
    "ui.systemUsesDarkTheme" = 1;
  };

  userChrome = pkgs.writeText "userChrome.css" ''
    #nav-bar {
      max-height: 0 !important;
      min-height: 0 !important;
      overflow: visible !important;
      background: transparent !important;
      border: none !important;
      box-shadow: none !important;
    }
    #navigator-toolbox {
      border-bottom: none !important;
    }
    #nav-bar-customization-target > :not(#urlbar-container),
    #nav-bar > :not(#nav-bar-customization-target) {
      display: none !important;
    }
    #urlbar-container {
      position: fixed !important;
      top: 20% !important;
      left: 10% !important;
    }
    #urlbar {
      width: 80% !important;
      max-width: none !important;
    }
    #urlbar:not([focused="true"]):not(:focus-within) {
      opacity: 0 !important;
      pointer-events: none !important;
    }
  '';

  extensionSettings = builtins.mapAttrs (name: value: {
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/${value}/latest.xpi";
    installation_mode = "force_installed";
    default_area = "navbar";
    private_browsing = true;
  }) extensions;

  extraPrefs = lib.concatMapAttrsStringSep "\n" (
    name: value: "lockPref(${builtins.toJSON name}, ${builtins.toJSON value});"
  ) prefs;

  firefoxOvr = pkgs.firefox.override {
    extraPolicies = {
      ExtensionSettings = extensionSettings;
      SearchEngines.Default = defaultSearchEngine;
    };
    inherit extraPrefs;
  };

  runtimeScript =
    let
      profilesGlob = {
        darwin = "$HOME/Library/Application Support/Firefox/Profiles";
        linux = "$HOME/.config/mozilla/firefox";
      };
    in
    ''
      profiles=(${profilesGlob.${kernel}}/*.default)
      profile="''${profiles[0]}"
      if [[ -d "$profile" ]]; then
        mkdir -p "$profile/chrome"
        ln -sf ${userChrome} "$profile/chrome/userChrome.css"
      fi
    '';

in
pkgs.symlinkJoin {
  name = "firefox-wrapped";
  meta.mainProgram = "firefox";
  paths = [ firefoxOvr ];
  nativeBuildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/firefox \
      --run ${lib.escapeShellArg runtimeScript}
  '';
}
