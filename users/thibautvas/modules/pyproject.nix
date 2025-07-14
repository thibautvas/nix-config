{ config, lib, pkgs, ... }:

let
  pythonVersion = "3.11";
  pythonVersionNoDot = lib.replaceStrings ["."] [""] pythonVersion;

in {
  home.packages = with pkgs; [
    uv
    ruff
    sqlfluff
  ];

  xdg.configFile = {
    "uv/uv.toml".text = ''
      python-downloads = "manual"
    '';

    "uv/.python-version".text = pythonVersion;

    "ruff/ruff.toml".text = ''
      target-version = "py${pythonVersionNoDot}"
      [lint]
      select = [ "E4", "E7", "E9", "F", "I", "UP" ]
    '';

    "sqlfluff/.sqlfluff".text = ''
      [sqlfluff:core]
      dialect = vertica
      [sqlfluff:indentation]
      allow_implicit_indents = True
      [sqlfluff:rules:references.keywords]
      ignore_words = day
    '';
  };
}
