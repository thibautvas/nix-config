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
    require("nvim-treesitter.configs").setup({
      auto_install = false,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { "markdown" },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
          },
        },
      },
    })
  '';
}
