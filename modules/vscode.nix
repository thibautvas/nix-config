{
  self,
  stdenv,
  vscode-with-extensions,
  vscode-extensions,
  writeShellScript,
  writeText,
  symlinkJoin,
  makeWrapper,
  ...
}:

let
  wrappedCode = vscode-with-extensions.override {
    vscodeExtensions = with vscode-extensions; [
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

  vscodeJson = builtins.fromJSON (builtins.readFile (self + /dotfiles/vscode.json));

  settingsJson = writeText "settings.json" (builtins.toJSON vscodeJson.settings);

  keybindingsRaw = builtins.toJSON vscodeJson.keybindings;
  keybindingsJson = writeText "keybindings.json" (
    if stdenv.isDarwin then
      keybindingsRaw
    else
      builtins.replaceStrings [ "cmd" ] [ "ctrl" ] keybindingsRaw
  );

  outDir = "/tmp/vscode-declarative";

  runtimeScript = writeShellScript "vscode-declarative-gen" ''
    user_dir="${outDir}/User"
    mkdir -p "$user_dir"
    ln -sf ${settingsJson} "$user_dir/settings.json"
    ln -sf ${keybindingsJson} "$user_dir/keybindings.json"
  '';

in
symlinkJoin {
  name = "vscode-wrapped";
  paths = [ wrappedCode ];
  nativeBuildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/code \
      --run ${runtimeScript} \
      --add-flags "--user-data-dir ${outDir}"
  '';
}
