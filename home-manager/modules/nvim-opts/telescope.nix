{ config, pkgs, ... }:

{
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      plenary-nvim # dependency
      telescope-fzf-native-nvim
    ];

    extraLuaConfig = ''
      opts = { extensions = { fzf = {} } }
      require("telescope").setup(opts)
      require("telescope").load_extension("fzf")

      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope find files in buffers" })
      vim.keymap.set("n", "<leader>fr", builtin.git_files, { desc = "Telescope find files in git repo" })
      vim.keymap.set("n", "<leader>fs", builtin.git_status, { desc = "Telescope find files in $(git status)" })
      vim.keymap.set("n", "<leader>fa", function()
        builtin.find_files { cwd = vim.fn.getenv("HOSTRD") }
      end,
      { desc = "Telescope find files in root directory" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
    '';
  };
}
