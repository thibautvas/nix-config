{
  pkgs,
  ...
}:

let
  wrappedCode = pkgs.vscode-with-extensions.override {
    vscodeExtensions = with pkgs.vscode-extensions; [
      ms-python.python
      ms-python.vscode-pylance
      ms-toolsai.jupyter
      ms-toolsai.jupyter-renderers
      ms-toolsai.datawrangler
      charliermarsh.ruff
      vscodevim.vim
      catppuccin.catppuccin-vsc
    ];
  };

  settingsJson = ./settings.json;
  keybindingsJson =
    if pkgs.stdenv.isDarwin then
      ./keybindings.json
    else
      let
        rawKb = builtins.readFile ./keybindings.json;
        fmtKb = builtins.replaceStrings [ "cmd" ] [ "ctrl" ] rawKb;
      in
      pkgs.writeText "keybindings.json" fmtKb;

in
pkgs.writeShellScriptBin "code" ''
  dir="/tmp/vscode-declarative"
  mkdir -p "$dir/User"
  ln -sf ${settingsJson} "$dir/User/settings.json"
  ln -sf ${keybindingsJson} "$dir/User/keybindings.json"
  exec ${wrappedCode}/bin/code --user-data-dir "$dir" "''${@:-.}"
''
