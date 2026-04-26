{
  lib,
  pkgs,
  ...
}:

let
  fileTypes = [
    "bash"
    "lua"
    "nix"
    "python"
    "sql"
  ];
  tsPlugins = p: lib.attrVals fileTypes p;
  fileTypePattern = lib.concatMapStringsSep ", " builtins.toJSON fileTypes;

  injections = {
    python =
      let
        ci =
          word: lib.concatMapStrings (c: "[${lib.toLower c}${lib.toUpper c}]") (lib.stringToCharacters word);
      in
      ''
        ;; extends
        (string
          (string_content) @injection.content
          (#match? @injection.content "^[ \t\n\r]*(${ci "select"}|${ci "with"})")
          (#set! injection.language "sql"))
      '';
    nix = ''
      ;; extends
      ((binding
          attrpath: (attrpath) @_path
          expression: (indented_string_expression
            (string_fragment) @injection.content))
       (#match? @_path "extraLuaConfig")
       (#set! injection.language "lua"))
    '';
  };

  tsInjections = (
    pkgs.runCommand "treesitter-injections" { } (
      lib.concatMapAttrsStringSep "" (lang: query: ''
        mkdir -p $out/queries/${lang}
        cat > $out/queries/${lang}/injections.scm << EOF
        ${query}
        EOF
      '') injections
    )
  );

in
{
  plugins = with pkgs.vimPlugins; [
    (nvim-treesitter.withPlugins tsPlugins)
    nvim-treesitter-textobjects
    tsInjections
  ];
  extraLuaConfig = ''
    vim.hl.priorities.semantic_tokens = 99
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { ${fileTypePattern} },
      group = vim.api.nvim_create_augroup("treesitter-highlight", { clear = true }),
      callback = function()
        vim.treesitter.start()
      end,
    })

    for textobject, keymap in pairs({
      ["@function.inner"] = "if",
      ["@function.outer"] = "af",
    }) do
      vim.keymap.set({ "o", "x" }, keymap, function()
        require("nvim-treesitter-textobjects.select").select_textobject(textobject, "textobjects")
      end, { desc = "Treesitter select " .. textobject })
    end
  '';
}
