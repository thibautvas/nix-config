{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      neogit
      diffview-nvim
    ];
    extraLuaConfig = ''
      local ng = require("neogit")
      ng.setup({
        kind = "replace",
        disable_insert_on_commit = true,
        commit_editor = {
          kind = "replace",
          show_staged_diff = false,
          spell_check = false,
        },
        commit_select_view = { kind = "replace" },
        log_view = { kind = "replace" },
      })

      vim.keymap.set("n", "<leader>hs", ng.open, { desc = "Neogit status" })
      vim.keymap.set("n", "<leader>hc", ng.action("commit", "commit", { "--verbose" }), { desc = "Neogit commit" })
      vim.keymap.set("n", "<leader>he", ng.action("commit", "extend"), { desc = "Neogit extend" })
    '';
  };
}
