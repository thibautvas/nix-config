{
  isHost,
  flakes,
  ...
}:

let
  primaryUser = "thibautvas";
  common = import ../nixos/configuration.nix {
    inherit isHost flakes;
  };

in
{
  system = {
    stateVersion = 6; # should not be changed

    inherit primaryUser;

    defaults = {
      NSGlobalDomain = {
        KeyRepeat = 2;
        InitialKeyRepeat = 15;
        "com.apple.swipescrolldirection" = false;
        _HIHideMenuBar = true;
      };

      dock = {
        orientation = "right";
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.0;
        static-only = true;
        launchanim = false;
      };

      finder.QuitMenuItem = true;
    };
  };

  inherit (common) nix nixpkgs time;

  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
    caskArgs.no_quarantine = true;
    casks = [
      "ghostty"
      "shortcat"
    ];
  };
}
