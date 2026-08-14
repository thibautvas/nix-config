{
  pkgs,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) system;

  version = "1.21.13b";

  zenBuilds = {
    x86_64-linux = {
      src = pkgs.fetchurl {
        url = "https://github.com/zen-browser/desktop/releases/download/${version}/zen.linux-x86_64.tar.xz";
        hash = "sha256-1UsLgm/N/f5jGoc8ekCM3+9oQhPopowPwTEMbC/4puk=";
      };

      nativeBuildInputs = [ pkgs.autoPatchelfHook ];

      buildInputs = with pkgs; [
        gtk3
        alsa-lib
      ];

      installPhase = ''
        mkdir -p "$out/lib/zen-${version}"
        cp -r ./* "$out/lib/zen-${version}/"
        mkdir -p "$out/bin"
        ln -s "$out/lib/zen-${version}/zen" "$out/bin/zen"
      '';
    };

    aarch64-darwin = {
      src = pkgs.fetchurl {
        url = "https://github.com/zen-browser/desktop/releases/download/${version}/zen.macos-universal.dmg";
        hash = "sha256-bufrCa4/ku9W0UNArMeUi0XXaAbSMqVN4jqM00g2Gwk=";
      };

      nativeBuildInputs = [ pkgs.undmg ];

      buildInputs = [ ];

      unpackPhase = "undmg $src";

      installPhase = ''
        mkdir -p "$out/Applications"
        cp -R "Zen.app" "$out/Applications/Zen Browser.app"
        mkdir -p "$out/bin"
        ln -s "$out/Applications/Zen Browser.app/Contents/MacOS/zen" "$out/bin/zen"
      '';
    };
  };

  zenUnwrapped = pkgs.stdenv.mkDerivation (
    {
      pname = "zen-browser-unwrapped";
      inherit version;

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
        license = pkgs.lib.licenses.mpl20;
        mainProgram = "zen";
        platforms = builtins.attrNames zenBuilds;
      };
    }
    // zenBuilds.${system}
  );

in
pkgs.wrapFirefox zenUnwrapped {
  pname = "zen-browser";
}
