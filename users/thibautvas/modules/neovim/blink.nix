{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.neovim = {
    plugins = [ pkgs.vimPlugins.blink-cmp ];
    extraLuaConfig = ''
      require("blink.cmp").setup({
        keymap = { preset = "default" },
        appearance = { use_nvim_cmp_as_default = true },
        signature = { enabled = true },
      })
    '';
  };
}
