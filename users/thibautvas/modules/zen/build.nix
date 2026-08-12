{
  pkgs,
  ...
}:

let
  inherit (pkgs) lib;

  version = "1.21.13b";
  src = {
    url = "https://github.com/zen-browser/desktop/releases/download/${version}/zen.linux-x86_64.tar.xz";
    hash = "sha256-1UsLgm/N/f5jGoc8ekCM3+9oQhPopowPwTEMbC/4puk=";
  };

  zen-browser-unwrapped = pkgs.stdenv.mkDerivation {
    pname = "zen-browser-unwrapped";
    inherit version;

    src = pkgs.fetchurl src;

    nativeBuildInputs = [ pkgs.autoPatchelfHook ];

    buildInputs = with pkgs; [
      gtk3
      alsa-lib
    ];

    installPhase = ''
      mkdir -p "$out/lib/zen-${version}" "$out/bin"
      cp -r ./* "$out/lib/zen-${version}/"
      ln -s "$out/lib/zen-${version}/zen" "$out/bin/zen"
    '';

    passthru = {
      applicationName = "Zen Browser";
      libName = "zen-${version}";
      binaryName = "zen";
      inherit (pkgs) gtk3;
      gssSupport = true;
      ffmpegSupport = true;
    };

    meta = {
      description = "Zen Browser";
      homepage = "https://zen-browser.app/";
      license = lib.licenses.mpl20;
      mainProgram = "zen";
      platforms = [ "x86_64-linux" ];
    };
  };

in
pkgs.wrapFirefox zen-browser-unwrapped {
  pname = "zen-browser";
}
