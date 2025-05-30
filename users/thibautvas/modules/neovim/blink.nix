{ config, lib, pkgs, unstablePkgs, ... }:

{
  programs.neovim = {
    plugins = [ unstablePkgs.vimPlugins.blink-cmp ];
    extraLuaConfig = ''
      opts = {
        keymap = { preset = "default" },
        appearance = { use_nvim_cmp_as_default = true },
        signature = { enabled = true },
      }
      require("blink.cmp").setup(opts)
    '';
  };
}
