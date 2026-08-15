{
  description = "nix configuration by thibautvas";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    templates = {
      url = "github:thibautvas/flake-templates";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    gitutils-nvim = {
      url = "github:thibautvas/gitutils.nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-build = {
      url = "github:thibautvas/zen-build";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      templates,
      gitutils-nvim,
      zen-build,
      ...
    }:
    let
      inherit (nixpkgs) lib;

      vimOverlay = final: prev: {
        vimPlugins = prev.vimPlugins // {
          gitutils-nvim = gitutils-nvim.packages.${prev.stdenv.hostPlatform.system}.default;
        };
      };

      perSystem = lib.genAttrs [ "x86_64-linux" "aarch64-darwin" ] (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          vimPkgs = pkgs.extend vimOverlay;
          unfreePkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };

          mkPkg =
            module: pkgs: extraAttrs:
            import ./modules/${module}.nix (
              {
                inherit self pkgs;
              }
              // extraAttrs
            );

        in
        {
          inherit pkgs;

          flkPkgs = {
            bash = mkPkg "bash" pkgs { };
            nvim-git = mkPkg "nvim" vimPkgs {
              wrapGit = true;
            };
          };

          appPkgs = {
            nvim = mkPkg "nvim" vimPkgs { };
            ghostty = mkPkg "ghostty" pkgs { };
            zen = mkPkg "zen" pkgs {
              inherit zen-build;
            };
            emacs = mkPkg "emacs" pkgs { };
            code = mkPkg "vscode" unfreePkgs { };
            firefox = mkPkg "firefox" pkgs { };
          }
          // lib.optionalAttrs pkgs.stdenv.isDarwin {
            aero = mkPkg "aerospace" pkgs { };
          }
          // lib.optionalAttrs (!pkgs.stdenv.isDarwin) {
            Hyprland = mkPkg "hyprland" pkgs {
              env = {
                browser = "zen";
                terminal = "com.mitchellh.ghostty";
                sunset = 2000;
              };
            };
          };

          bldPkgs = {
            kmonad = mkPkg "kmonad" pkgs { };
            localbin = mkPkg "localbin" pkgs { };
          };
        }
      );

    in
    {
      # system config: nixos host and guest
      nixosConfigurations = lib.genAttrs [ "host" "guest" ] (
        machine:
        lib.nixosSystem {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [ ./machines/nixos/configuration.nix ];
          specialArgs = {
            inherit self templates machine;
          };
        }
      );

      # system config: darwin
      darwinConfigurations.darwin = nix-darwin.lib.darwinSystem {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        modules = [ ./machines/darwin/configuration.nix ];
        specialArgs = {
          inherit self templates;
          machine = "darwin";
        };
      };

      # exposed packages
      packages = builtins.mapAttrs (
        system: p:
        let
          impPkgs = p.appPkgs // p.bldPkgs;
          allPkgs = impPkgs // p.flkPkgs;
        in
        allPkgs
        // {
          imp = p.pkgs.symlinkJoin {
            name = "imp-wrapped";
            paths = builtins.attrValues impPkgs;
          };
          all = p.pkgs.symlinkJoin {
            name = "all-wrapped";
            paths = builtins.attrValues allPkgs;
          };
        }
      ) perSystem;

      apps = builtins.mapAttrs (
        system: p:
        let
          drvPkgs = p.appPkgs // p.flkPkgs;
          drvApps = builtins.mapAttrs (name: drv: {
            type = "app";
            program = "${drv}/bin/${name}";
          }) drvPkgs;
          localbinApps = lib.genAttrs p.bldPkgs.localbin.passthru.binaries (name: {
            type = "app";
            program = "${p.bldPkgs.localbin}/bin/${name}";
          });
        in
        drvApps // localbinApps
      ) perSystem;
    };
}
