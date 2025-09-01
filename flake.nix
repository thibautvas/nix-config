{
  description = "nix configuration by thibautvas";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
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

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, zen-browser, ... }:
    let
      mkSysCfg = isHost: nixpkgs.lib.nixosSystem {
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        modules = [ ./machines/nixos/configuration.nix ];
        specialArgs = {
          inherit isHost;
        };
      };

      mkHmCfg = system: isHost: let
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
          inputs = {
            inherit nixpkgs-unstable zen-browser;
          };
        };
      };

    in {
      # system config: nixos host and guest
      nixosConfigurations = {
        host = mkSysCfg true;
        guest = mkSysCfg false;
      };

      # home-manager config: darwin, linux host and guest
      homeConfigurations = {
        darwin = mkHmCfg "aarch64-darwin" true;
        host = mkHmCfg "x86_64-linux" true;
        guest = mkHmCfg "x86_64-linux" false;
      };
    };
}
