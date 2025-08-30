# nix-config

Hi! I use this configuration on my work machine (macos), as well as on my personal machine (nixos).

I also use it on headless virtual machines, running various linux distributions.

## Modules

This configuration is cross-platform: it works seamlessly on linux and macos machines, provided that `nix` is installed.

Most of it is contained within the `home-manager` module, in [`./users/thibautvas/home.nix`](users/thibautvas/home.nix),
which manages configuration files on a user level, and installs related binaries too.

System configurations may be found in [`./machines`](machines).
Though, as of now, I am not leveraging `nix-darwin` to configure my macos machine on a system level.
Only my nixos configuration lives there.

## Rebuilding

The rebuilding process is managed by [`./flake.nix`](flake.nix):

- home-manager:
  - `home-manager switch --flake .#thibautvas@macos`
  - `home-manager switch --flake .#thibautvas@nixos`
  - `home-manager switch --flake .#thibautvas@hvm`

The main difference between these three configurations relates to the conditional imports that are operated in `home.nix`,
e.g., different window managers (or none at all).

- nixos system:
  - `sudo nixos-rebuild switch --flake .#nixos`

## Project structure

```text
.
├── .gitignore
├── README.md
├── flake.lock
├── flake.nix
├── machines
│   └── nixos
│       ├── configuration.nix
│       └── hardware
│           ├── guest-configuration.nix
│           └── host-configuration.nix
└── users
    └── thibautvas
        ├── home.nix
        └── modules
            ├── direnv.nix
            ├── ghostty.nix
            ├── git.nix
            ├── kmonad.nix
            ├── localbin.nix
            ├── neovim
            │   ├── blink.nix
            │   ├── catppuccin.nix
            │   ├── default.nix
            │   ├── fzf-lua.nix
            │   ├── gitsigns.nix
            │   ├── lsp.nix
            │   ├── neogit.nix
            │   ├── oil.nix
            │   ├── settings.nix
            │   └── treesitter.nix
            ├── nix.nix
            ├── pyproject.nix
            ├── shellrc.nix
            ├── tmux
            │   ├── bin.nix
            │   ├── default.nix
            │   └── settings.nix
            ├── vscode.nix
            ├── window-manager
            │   ├── aerospace
            │   │   ├── bin.nix
            │   │   ├── default.nix
            │   │   └── settings.nix
            │   └── hyprland
            │       ├── bin.nix
            │       ├── default.nix
            │       ├── hypridle.nix
            │       ├── hyprlock.nix
            │       ├── hyprpaper.nix
            │       └── settings.nix
            └── zen-twilight.nix

12 directories, 40 files
```
