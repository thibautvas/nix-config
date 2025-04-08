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

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      pkgs = import nixpkgs {
        system = "x86_64-linux";
      };
      modules = [
        ./hosts/nixos/configuration.nix
        home-manager.nixosModules.home-manager {
          home-manager = {
	    useGlobalPkgs = true;
            useUserPackages = true;
            users."thibautvas" = import ./users/thibautvas/home.nix;
            extraSpecialArgs.pkgs = import nixpkgs-unstable {
              system = "x86_64-linux";
            };
          };
        }
      ];
    };

    homeConfigurations."thibautvas" = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs-unstable {
        system = "aarch64-darwin";
      };
      modules = [
        ./users/thibautvas/home.nix
      ];
    };
  };
}
