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
```bash
sudo nixos-rebuild switch --flake github:thibautvas/nix-config#host
# resp. #guest, #wsl
```

darwin-rebuild:
```bash
sudo darwin-rebuild switch --flake github:thibautvas/nix-config#darwin
```

home-manager:
```bash
home-manager switch --flake github:thibautvas/nix-config#host
# resp. #guest, #darwin
```

The main difference between these three configurations relates to the conditional imports that are operated in `home.nix`,
e.g., different window managers (or none at all).

## Packages

Two modules are exposed as packages to be used via `nix run` or `nix build`:
```bash
nix run github:thibautvas/nix-config#bash
```
```bash
nix run github:thibautvas/nix-config#nvim
```

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
│   └── nixos
│       ├── configuration.nix
│       ├── custom
│       │   ├── libvirtd-hooks.nix
│       │   └── thinkpad-leds.nix
│       └── hardware
│           ├── guest-configuration.nix
│           └── host-configuration.nix
└── users
    └── thibautvas
        ├── home.nix
        └── modules
            ├── bash
            │   ├── default.nix
            │   └── package.nix
            ├── direnv.nix
            ├── ghostty.nix
            ├── git.nix
            ├── kmonad.nix
            ├── localbin.nix
            ├── neovim
            │   ├── default.nix
            │   └── package.nix
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

14 directories, 30 files
```
