{ config, lib, pkgs, unstablePkgs, ... }:

{
  programs.firefox = {
    enable = true;
    package = unstablePkgs.firefox;
    profiles.default.settings = {
      "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
      "signon.rememberSignons" = false;
      "browser.translations.neverTranslateLanguages" = "fr,es";
    };
  };
}
