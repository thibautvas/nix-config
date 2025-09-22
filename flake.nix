{
  description = "nix configuration by thibautvas";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

  outputs = { self, nixpkgs, nixpkgs-unstable, nix-darwin, home-manager, zen-browser, ... }:
    let
      mkSysCfg = system: isHost: let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (pkgs.stdenv) isDarwin;
        inherit (if isDarwin then nix-darwin else nixpkgs) lib;
        machine = if isDarwin then "darwin" else "nixos";
      in lib."${machine}System" {
        inherit pkgs;
        modules = [ ./machines/${machine}/configuration.nix ];
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
        host = mkSysCfg "x86_64-linux" true;
        guest = mkSysCfg "x86_64-linux" false;
      };

      # system config: darwin
      darwinConfigurations = {
        darwin = mkSysCfg "aarch64-darwin" true;
      };

      # home-manager config: darwin, linux host and guest
      homeConfigurations = {
        host = mkHmCfg "x86_64-linux" true;
        guest = mkHmCfg "x86_64-linux" false;
        darwin = mkHmCfg "aarch64-darwin" true;
      };
    };
}
