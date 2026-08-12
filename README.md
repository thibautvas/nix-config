# nix-config

Hi! I use this configuration on my work machine (macos), as well as on my personal machine (nixos).

I also use it on headless virtual machines, running various linux distributions.

## Modules

This configuration is cross-platform: it works seamlessly across linux and macos machines,
provided that `nix` is installed.

With few exceptions, modules may be run individually:
```bash
nix run github:thibautvas/nix-config#nvim
```

Or built all at once:
```bash
nix build github:thibautvas/nix-config#all
```

## Rebuilding

Machine-specific configuration values are declared in
[`nixos/configuration.nix`](./machines/nixos/configuration.nix),
and [`darwin/configuration.nix`](./machines/darwin/configuration.nix).

Unless a bare install is advised (e.g., adhoc vm),
the same packages are sourced in system rebuilds:
[`common/packages.nix`](./machines/common/packages.nix).

One notable exception is `bash`, which is sourced from
[`bash/default.nix`](./users/thibautvas/modules/bash/default.nix),
as wrapping a new shell from scratch is not trivial.

The few modules that are not exposed as packages are also used in system rebuilds,
namely [`git.nix`](./users/thibautvas/modules/git.nix).

nixos-rebuild:
```bash
sudo nixos-rebuild switch --flake github:thibautvas/nix-config#host
# resp. #guest, #wsl
```

darwin-rebuild:
```bash
sudo darwin-rebuild switch --flake github:thibautvas/nix-config#darwin
```

## Project structure

```text
.
├── .gitignore
├── README.md
├── flake.lock
├── flake.nix
├── machines
│   ├── common
│   │   └── packages.nix
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
        └── modules
            ├── aerospace
            │   ├── aerospace.toml
            │   └── package.nix
            ├── bash
            │   ├── default.nix
            │   └── package.nix
            ├── direnv.nix
            ├── ghostty
            │   └── package.nix
            ├── git.nix
            ├── hyprland
            │   ├── hyprland.lua
            │   └── package.nix
            ├── kmonad
            │   ├── home_row_mods.kbd.in
            │   └── package.nix
            ├── localbin
            │   └── package.nix
            ├── nvim
            │   └── package.nix
            └── zen
                ├── build.nix
                └── package.nix

18 directories, 26 files
```
