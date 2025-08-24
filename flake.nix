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
      mkHmCfg = system: isDesktop: let
        pkgs = nixpkgs.legacyPackages.${system};
        unstablePkgs = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      in home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./users/thibautvas/home.nix ];
        extraSpecialArgs = {
          inherit unstablePkgs isDesktop;
          inherit (pkgs.stdenv) isDarwin isLinux;
          inputs = {
            inherit nixpkgs-unstable zen-browser;
          };
        };
      };

    in {
      # system config: nixos
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        modules = [ ./hosts/nixos/configuration.nix ];
      };

      # home-manager config: macos, nixos, and hvm
      homeConfigurations = {
        "thibautvas@macos" = mkHmCfg "aarch64-darwin" true;
        "thibautvas@nixos" = mkHmCfg "x86_64-linux" true;
        "thibautvas@hvm" = mkHmCfg "x86_64-linux" false;
      };
    };
}
