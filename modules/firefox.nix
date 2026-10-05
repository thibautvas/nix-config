{
  lib,
  firefox,
  writeText,
  symlinkJoin,
  makeWrapper,
  ...
}:

let
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
    PictureInPicture.Enabled = false;
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

  chromeAttrs = {
    nav-bar = {
      max-height = 0;
      min-height = 0;
    };
    "nav-bar > :not(#nav-bar-customization-target)".display = "none";
    "nav-bar-customization-target > :not(#urlbar-container)".display = "none";
    navigator-toolbox.z-index = 3;
    urlbar-container = {
      position = "fixed";
      left = "10%";
      right = "10%";
      top = "20%";
      width = "auto";
    };
    "urlbar:not([focused]):not(:focus-within)" = {
      opacity = 0;
      pointer-events = "none";
    };
  };

  firefoxOvr = firefox.override {
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

  userChrome = writeText "userChrome.css" (
    lib.concatMapAttrsStringSep "\n" (selector: properties: ''
      #${selector} {
      ${lib.concatMapAttrsStringSep "\n" (
        property: value: "  ${property}: ${toString value} !important;"
      ) properties}
      }
    '') chromeAttrs
  );

  profileDir = "$HOME/.local/share/firefox-declarative/nx01dclv.default";

  runtimeScript = ''
    mkdir -p "${profileDir}/chrome"
    ln -sf ${userChrome} "${profileDir}/chrome/userChrome.css"
  '';

in
symlinkJoin {
  name = "firefox-wrapped";
  paths = [ firefoxOvr ];
  nativeBuildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/firefox \
      --run ${lib.escapeShellArg runtimeScript} \
      --add-flags ${lib.escapeShellArg "--profile ${profileDir}"}
  '';
}
