{
  pkgs,
  ...
}:

{
  plugins = [ pkgs.vimPlugins.oil-nvim ];
  extraLuaConfig = ''
    local ol = require("oil")
    ol.setup({
      view_options = { show_hidden = true },
      skip_confirm_for_simple_edits = true,
    })

    vim.keymap.set("n", "-", ol.open, { desc = "Oil in parent directory" })
  '';
}
