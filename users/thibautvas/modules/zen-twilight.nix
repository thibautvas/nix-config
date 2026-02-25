{
  config,
  lib,
  pkgs,
  flakes,
  ...
}:

let
  mkExtension = name: _: {
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/${name}/latest.xpi";
    installation_mode = "force_installed";
    default_area = "menupanel";
    private_browsing = "allow";
  };

  extensions = {
    "uBlock0@raymondhill.net" = "ublock-origin";
    "addon@darkreader.org" = "darkreader";
    "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = "vimium-ff";
    "vpn@proton.ch" = "proton-vpn-firefox-extension";
  };

  extensionSettings = lib.recursiveUpdate (lib.mapAttrs mkExtension extensions) {
    "vpn@proton.ch".default_area = "navbar";
  };

in
{
  imports = [ flakes.zen-browser.homeModules.twilight ];
  programs.zen-browser = {
    enable = true;
    policies.ExtensionSettings = extensionSettings;
    profiles.default = {
      search = lib.genAttrs [ "default" "privateDefault" ] (_: "ddg") // {
        force = true;
        engines.chatgpt = {
          name = "Chatgpt";
          urls = [ { template = "https://chatgpt.com/?temporary-chat=true&q={searchTerms}"; } ];
          icon = "https://chatgpt.com/cdn/assets/favicon-l4nq08hd.svg";
          definedAliases = [ "@gp" ];
        };
      };
      settings = {
        "browser.ctrlTab.sortByRecentlyUsed" = true;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.translations.neverTranslateLanguages" = "fr,es";
        "signon.rememberSignons" = false;
        "zen.theme.content-element-separation" = 0;
        "zen.view.compact.animate-sidebar" = false;
        "zen.view.compact.show-sidebar-and-toolbar-on-hover" = false;
        "zen.welcome-screen.seen" = true;
      };
    };
  };
}
