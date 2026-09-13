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

  policies = {
    AIControls.Default = {
      Value = "blocked";
      Locked = true;
    };
    DisableRemoteImprovements = true;
    DisableTelemetry = true;
    DontCheckDefaultBrowser = true;
    OfferToSaveLogins = false;
    OverrideFirstRunPage = "";
    SearchSuggestEnabled = false;
    SkipTermsOfUse = true;
  };

  preferences = {
    "browser.ctrlTab.sortByRecentlyUsed" = true;
    "browser.startup.page" = 3;
    "browser.tabs.closeWindowWithLastTab" = false;
    "browser.translations.neverTranslateLanguages" = "es,fr";
    "browser.urlbar.autoFill.adaptiveHistory.enabled" = true;
    "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
    "sidebar.animation.enabled" = false;
    "sidebar.verticalTabs" = true;
    "sidebar.visibility" = "hide-sidebar";
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
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

  firefoxOvr = pkgs.firefox.override {
    extraPolicies = policies // {
      ExtensionSettings = builtins.mapAttrs (_: value: {
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/${value}/latest.xpi";
        installation_mode = "force_installed";
        default_area = "navbar";
        private_browsing = true;
      }) extensions;

      Preferences = builtins.mapAttrs (_: value: {
        Value = value;
        Status = "locked";
      }) preferences;

      SearchEngines.Default = defaultSearchEngine;
    };
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
  paths = [ firefoxOvr ];
  nativeBuildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/firefox \
      --run ${lib.escapeShellArg runtimeScript}
  '';
}
