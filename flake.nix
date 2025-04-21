{
  description = "nix configuration by thibautvas";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }:
    let
      mkHmCfg = system: let
        pkgs = nixpkgs.legacyPackages.${system};
        unstablePkgs = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      in home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./users/thibautvas/home.nix ];
        extraSpecialArgs = {
          inherit unstablePkgs;
          inherit (pkgs.stdenv) isDarwin isLinux;
        };
      };

    in {
      # system config: nixos
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        modules = [ ./hosts/nixos/configuration.nix ];
      };

      # home-manager config: macos and nixos
      homeConfigurations."thibautvas@macos" = mkHmCfg "aarch64-darwin";
      homeConfigurations."thibautvas@nixos" = mkHmCfg "x86_64-linux";
    };
}
