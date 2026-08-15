{
  self,
  pkgs,
  ...
}:

let
  outDir = "/tmp/vscode-declarative";

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

  settingsJson = self + /dotfiles/vscode/settings.json;

  keybindingsJson =
    let
      cmdCtrl = if pkgs.stdenv.isDarwin then "cmd" else "ctrl";
      rawKb = builtins.readFile (self + /dotfiles/vscode/keybindings.json);
      fmtKb = builtins.replaceStrings [ "cmd" ] [ cmdCtrl ] rawKb;
    in
    pkgs.writeText "keybindings.json" fmtKb;

  runtimeScript = pkgs.writeShellScript "vscode-declarative-gen" ''
    user_dir="${outDir}/User"
    mkdir -p "$user_dir"
    ln -sf ${settingsJson} "$user_dir/settings.json"
    ln -sf ${keybindingsJson} "$user_dir/keybindings.json"
  '';

in
pkgs.symlinkJoin {
  name = "vscode-wrapped";
  paths = [ wrappedCode ];
  nativeBuildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/code \
      --run ${runtimeScript} \
      --add-flags "--user-data-dir ${outDir}"
  '';
}
