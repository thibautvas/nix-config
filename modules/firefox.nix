{
  lib,
  zen-browser,
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
    SearchSuggestEnabled = false;
    SkipTermsOfUse = true;
  };

  zenPrefs = {
    "ui.systemUsesDarkTheme" = 1;
    "zen.theme.content-element-separation" = 0;
    "zen.view.compact.animate-sidebar" = false;
    "zen.view.compact.show-sidebar-and-toolbar-on-hover" = false;
    "zen.welcome-screen.seen" = true;
  };

  zenOvr = zen-browser.override {
    extraPolicies = policies // {
      ExtensionSettings = builtins.mapAttrs (_: value: {
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/${value}/latest.xpi";
        installation_mode = "force_installed";
        default_area = "navbar";
        private_browsing = true;
      }) extensions;

      SearchEngines.Default = defaultSearchEngine;
    };

    extraPrefs = lib.concatMapAttrsStringSep "\n" (
      name: value: "lockPref(${builtins.toJSON name}, ${builtins.toJSON value});"
    ) zenPrefs;
  };

  profileDir = "$HOME/.local/share/zen-declarative/nx02dclv.default";

  runtimeScript = ''
    mkdir -p "${profileDir}/chrome"
  '';

in
symlinkJoin {
  name = "zen-wrapped";
  paths = [ zenOvr ];
  nativeBuildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/zen \
      --run ${lib.escapeShellArg runtimeScript} \
      --add-flags ${lib.escapeShellArg "--profile ${profileDir}"}
  '';
}
