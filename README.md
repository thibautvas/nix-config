# nix-config

Hi! I use this configuration on my work machine (macos), as well as on my personal machine (nixos).

I also use it on headless virtual machines, running various linux distributions.

## Modules

This configuration is cross-platform: it works seamlessly on linux and macos machines, provided that `nix` is installed.

Most of it is contained within the `home-manager` module, in [`./users/thibautvas/home.nix`](users/thibautvas/home.nix),
which manages configuration files on a user level, and installs related binaries too.

System configurations may be found in [`./machines`](machines).

## Rebuilding

The rebuilding process is managed by [`./flake.nix`](flake.nix).

The flake may be run:
- from a local clone of the repository: `--flake .#host`
- from its github url: `--flake github:thibautvas/nix-config#host`

nixos-rebuild:
- `sudo nixos-rebuild switch --flake github:thibautvas/nix-config#host`
- `sudo nixos-rebuild switch --flake github:thibautvas/nix-config#guest`
- `sudo nixos-rebuild switch --flake github:thibautvas/nix-config#wsl`

darwin-rebuild:
- `sudo darwin-rebuild switch --flake github:thibautvas/nix-config#darwin`

home-manager:
- `home-manager switch --flake github:thibautvas/nix-config#host`
- `home-manager switch --flake github:thibautvas/nix-config#guest`
- `home-manager switch --flake github:thibautvas/nix-config#darwin`

The main difference between these three configurations relates to the conditional imports that are operated in `home.nix`,
e.g., different window managers (or none at all).

## Project structure

```text
.
├── .gitignore
├── README.md
├── flake.lock
├── flake.nix
├── machines
│   ├── darwin
│   │   └── configuration.nix
│   ├── nixos
│   │   ├── configuration.nix
│   │   └── hardware
│   │       ├── guest-configuration.nix
│   │       ├── host-configuration.nix
│   │       └── thinkpad-leds.nix
│   └── wsl
│       └── configuration.nix
└── users
    └── thibautvas
        ├── home.nix
        └── modules
            ├── bash
            │   ├── default.nix
            │   ├── package.nix
            │   └── settings.nix
            ├── direnv.nix
            ├── emacs.nix
            ├── ghostty.nix
            ├── git.nix
            ├── kmonad.nix
            ├── localbin.nix
            ├── neovim
            │   ├── blink.nix
            │   ├── default.nix
            │   ├── fzf-lua.nix
            │   ├── gitsigns.nix
            │   ├── gitutils.nix
            │   ├── image.nix
            │   ├── kanagawa.nix
            │   ├── lsp.nix
            │   ├── oil.nix
            │   ├── package.nix
            │   ├── settings.nix
            │   └── treesitter.nix
            ├── nix.nix
            ├── vscode.nix
            ├── window-managers
            │   ├── aerospace
            │   │   ├── bin.nix
            │   │   ├── default.nix
            │   │   └── settings.nix
            │   ├── default.nix
            │   └── hyprland
            │       ├── default.nix
            │       ├── hypridle.nix
            │       ├── hyprlock.nix
            │       ├── hyprpaper.nix
            │       └── settings.lua
            └── zen-twilight.nix

14 directories, 44 files
