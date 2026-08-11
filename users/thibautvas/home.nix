{
  pkgs,
  lib,
  isHost,
  isDarwin,
  ...
}:

let
  username = "thibautvas";
  homeDirectory = "${(if isDarwin then "/Users" else "/home")}/${username}";

in
{
  imports = [
    ./modules/git.nix
    ./modules/bash
    ./modules/direnv.nix
    ./modules/nvim
  ]
  ++ lib.optionals isHost [
    ./modules/zen-twilight.nix
  ];

  home = {
    stateVersion = "24.11"; # should not be changed
    inherit username homeDirectory;

    packages = [
      (import ./modules/ghostty/package.nix {
        inherit pkgs;
      })
      (import ./modules/kmonad/package.nix {
        inherit pkgs;
      })
      (import ./modules/localbin/package.nix {
        inherit pkgs;
      })
    ]
    ++ lib.optionals (!isDarwin) [
      (import ./modules/hyprland/package.nix {
        inherit pkgs;
        env = {
          browser = "zen-twilight";
          terminal = "com.mitchellh.ghostty";
          sunset = 2000;
        };
      })
    ]
    ++ lib.optionals isDarwin [
      (import ./modules/aerospace/package.nix {
        inherit pkgs;
      })
    ];

  };

  programs.home-manager.enable = true; # let home manager manage itself
}
