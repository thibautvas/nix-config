{
  description = "nix configuration by thibautvas";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }:
  let
    mkPkgs = nixpkgs: system: import nixpkgs {
      inherit system;
    };
    mkExtraArgs = pkgs: {
      pkgs = pkgs;
      isDarwin = pkgs.stdenv.isDarwin;
      isLinux = pkgs.stdenv.isLinux;
    };

    systems = {
      darwin = "aarch64-darwin";
      linux = "x86_64-linux";
    };
    nixPkgs = {
      darwinUnstable = mkPkgs nixpkgs-unstable systems.darwin;
      linuxStable = mkPkgs nixpkgs systems.linux;
      linuxUnstable = mkPkgs nixpkgs-unstable systems.linux;
    };
    extraArgs = {
      darwin = mkExtraArgs nixPkgs.darwinUnstable;
      linux = mkExtraArgs nixPkgs.linuxUnstable;
    };

  in {
    # macos config: standalone home manager
    homeConfigurations."thibautvas" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixPkgs.darwinUnstable;
      modules = [ ./users/thibautvas/home.nix ];
      extraSpecialArgs = extraArgs.darwin;
    };

    # nixos config: system and home manager
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      pkgs = nixPkgs.linuxStable;
      modules = [
        ./hosts/nixos/configuration.nix
        home-manager.nixosModules.home-manager {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users."thibautvas" = import ./users/thibautvas/home.nix;
            extraSpecialArgs = extraArgs.linux;
          };
        }
      ];
    };
  };
}
