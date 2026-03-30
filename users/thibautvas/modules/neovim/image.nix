{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.neovim = {
    plugins = [ pkgs.vimPlugins.image-nvim ];
    extraLuaPackages = ps: [ ps.magick ];
    extraLuaConfig = ''
      local img = require("image")
      img.setup({ processor = "magick_rock" })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "image_nvim",
        callback = function()
          vim.opt_local.fillchars:append({ eob = " " })
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "fzf",
        callback = function()
          if #img.get_images() > 0 then
            img.clear()
          end
        end,
      })
    '';
  };
}
