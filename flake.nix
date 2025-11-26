{
  description = "nix configuration by thibautvas";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/nixos-wsl/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nix-darwin, nixos-wsl, home-manager, zen-browser, ... }:
    let
      mkSysCfg = { system, isHost, isWsl ? false }: let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (pkgs.stdenv) isDarwin;
        libSystem = if isDarwin then nix-darwin.lib.darwinSystem
                    else nixpkgs.lib.nixosSystem;
        machine = if isDarwin then "darwin"
                  else if isWsl then "wsl"
                  else "nixos";
      in libSystem {
        inherit pkgs;
        modules = [ ./machines/${machine}/configuration.nix ];
        specialArgs = {
          inherit isHost;
        } // nixpkgs.lib.optionalAttrs isWsl {
          flakes = {
            inherit nixos-wsl;
          };
        };
      };

      mkHmCfg = { system, isHost }: let
        pkgs = nixpkgs.legacyPackages.${system};
        unstablePkgs = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      in home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./users/thibautvas/home.nix ];
        extraSpecialArgs = {
          inherit unstablePkgs isHost;
          inherit (pkgs.stdenv) isDarwin isLinux;
          flakes = {
            inherit nixpkgs-unstable zen-browser;
          };
        };
      };

    in {
      # system config: nixos host and guest, wsl
      nixosConfigurations = let
        system = "x86_64-linux";
      in {
        host = mkSysCfg {
          inherit system;
          isHost = true;
        };
        guest = mkSysCfg {
          inherit system;
          isHost = false;
        };
        wsl = mkSysCfg {
          inherit system;
          isHost = false;
          isWsl = true;
        };
      };

      # system config: darwin
      darwinConfigurations = let
        system = "aarch64-darwin";
      in {
        darwin = mkSysCfg {
          inherit system;
          isHost = true;
        };
      };

      # home-manager config: linux host and guest, darwin
      homeConfigurations = {
        host = mkHmCfg {
          system = "x86_64-linux";
          isHost = true;
        };
        guest = mkHmCfg {
          system = "x86_64-linux";
          isHost = false;
        };
        darwin = mkHmCfg {
          system = "aarch64-darwin";
          isHost = true;
        };
      };
    };
}
