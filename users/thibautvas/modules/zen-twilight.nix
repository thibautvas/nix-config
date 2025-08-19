{ config, lib, pkgs, inputs, ... }:

let
  mkExtension = name: _: {
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/${name}/latest.xpi";
    installation_mode = "force_installed";
  };

  extensions = {
    "uBlock0@raymondhill.net" = "ublock-origin";
    "addon@darkreader.org" = "darkreader";
    "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = "vimium-ff";
  };

  extensionSettings = lib.mapAttrs mkExtension extensions;

in {
  imports = [ inputs.zen-browser.homeModules.twilight ];
  programs.zen-browser = {
    enable = true;
    policies.ExtensionSettings = extensionSettings;
    profiles.default.settings = {
      "signon.rememberSignons" = false;
      "browser.translations.neverTranslateLanguages" = "fr,es";
      "browser.ctrlTab.sortByRecentlyUsed" = true;
      "zen.view.compact.show-sidebar-and-toolbar-on-hover" = false;
    };
  };
}
