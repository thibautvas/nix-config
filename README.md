# nix-config

## Project structure

```bash
.
├── .gitignore
├── README.md
├── flake.lock
├── flake.nix
├── hosts
│   └── nixos
│       ├── configuration.nix
│       └── hardware-configuration.nix
└── users
    └── thibautvas
        ├── home.nix
        └── modules
            ├── direnv.nix
            ├── firefox.nix
            ├── ghostty.nix
            ├── git.nix
            ├── kmonad.nix
            ├── neovim
            │   ├── blink.nix
            │   ├── catppuccin.nix
            │   ├── gitsigns.nix
            │   ├── lspconfig.nix
            │   ├── main.nix
            │   ├── settings.nix
            │   ├── telescope.nix
            │   └── treesitter.nix
            ├── shell.nix
            ├── tmux
            │   ├── bin.nix
            │   └── main.nix
            └── window-manager
                ├── aerospace
                │   ├── bin.nix
                │   ├── main.nix
                │   └── settings.nix
                └── hyprland
                    ├── bin.nix
                    ├── hypridle.nix
                    ├── hyprlock.nix
                    ├── hyprpaper.nix
                    ├── main.nix
                    └── settings.nix

11 directories, 32 files
```
