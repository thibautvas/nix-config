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
[`common/base.nix`](./machines/common/base.nix).

nixos-rebuild:
```bash
sudo nixos-rebuild switch --flake github:thibautvas/nix-config#host
# resp. #guest
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
│   │   ├── base.nix
│   │   └── settings.nix
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
└── modules
    ├── aerospace.nix
    ├── bash.nix
    ├── ext
    │   ├── aerospace.toml
    │   ├── hyprland.lua
    │   └── kmonad_hrm.kbd.in
    ├── ghostty.nix
    ├── hyprland.nix
    ├── kmonad.nix
    ├── localbin.nix
    ├── nvim.nix
    └── zen.nix

9 directories, 23 files
