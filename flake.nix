{
  description = "nix configuration by thibautvas";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/nixos-wsl/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    templates = {
      url = "github:thibautvas/flake-templates";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    gitutils-nvim = {
      url = "github:thibautvas/gitutils.nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dotfiles = {
      url = "github:thibautvas/dotfiles";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      nix-darwin,
      nixos-wsl,
      home-manager,
      zen-browser,
      templates,
      gitutils-nvim,
      dotfiles,
      ...
    }:
    let
      inherit (nixpkgs) lib;

      vimOverlay = final: prev: {
        vimPlugins = prev.vimPlugins // {
          gitutils-nvim = gitutils-nvim.packages.${prev.stdenv.hostPlatform.system}.default;
        };
      };

    in
    {
      # system config: nixos host and guest
      nixosConfigurations = lib.genAttrs [ "host" "guest" "wsl" ] (
        machine:
        lib.nixosSystem {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [ ./machines/nixos/configuration.nix ];
          specialArgs = {
            isHost = machine == "host";
            flakes = lib.optionalAttrs (machine == "wsl") {
              inherit nixos-wsl;
            };
          };
        }
      );

      # system config: darwin
      darwinConfigurations.darwin = nix-darwin.lib.darwinSystem {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        modules = [ ./machines/darwin/configuration.nix ];
      };

      # home-manager config: linux host and guest, darwin
      homeConfigurations = lib.genAttrs [ "host" "guest" "darwin" ] (
        machine:
        let
          system = if machine == "darwin" then "aarch64-darwin" else "x86_64-linux";
          pkgs = nixpkgs.legacyPackages.${system}.extend vimOverlay;
          unstablePkgs = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./users/thibautvas/home.nix ];
          extraSpecialArgs = {
            inherit unstablePkgs dotfiles;
            inherit (pkgs.stdenv) isDarwin;
            isHost = machine != "guest";
            flakes = {
              inherit
                nixpkgs-unstable
                zen-browser
                templates
                ;
            };
          };
        }
      );

      # exposed packages
      packages = lib.genAttrs [ "x86_64-linux" "aarch64-darwin" ] (system: {
        bash = import ./users/thibautvas/modules/bash/package.nix {
          pkgs = nixpkgs.legacyPackages.${system};
          inherit dotfiles;
        };
        nvim = import ./users/thibautvas/modules/neovim/package.nix {
          pkgs = nixpkgs.legacyPackages.${system}.extend vimOverlay;
          unstablePkgs = nixpkgs-unstable.legacyPackages.${system};
          inherit dotfiles;
        };
        code = import ./users/thibautvas/modules/vscode/package.nix {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        };
      });

      apps = lib.genAttrs [ "x86_64-linux" "aarch64-darwin" ] (
        system:
        builtins.mapAttrs (name: drv: {
          type = "app";
          program = "${drv}/bin/${name}";
        }) self.packages.${system}
      );
    };
}
