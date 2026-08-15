{
  pkgs,
  ...
}:

let
  kernel = pkgs.stdenv.hostPlatform.parsed.kernel.name;

  emacsFor = {
    linux = pkgs.emacsPackagesFor pkgs.emacs-pgtk; # wayland
    darwin = pkgs.emacsPackagesFor pkgs.emacs;
  };

  wrappedEmacs = emacsFor.${kernel}.emacsWithPackages (
    epkgs: with epkgs; [
      evil
      consult
      vertico
    ]
  );

  defaultCfg = pkgs.writeText "default.el" ''
    (tool-bar-mode -1)
    (menu-bar-mode -1)
    (scroll-bar-mode -1)
    (set-fringe-mode 1)
    (blink-cursor-mode 0)
    (set-face-attribute 'default nil :height 120)
    (load-theme 'wombat t)
    (evil-mode 1)
    (vertico-mode 1)
    (setq inhibit-startup-screen t
          auto-save-default nil
          make-backup-files nil
          create-lockfiles nil)
    (setq-default truncate-lines t)
    (dolist (state '(insert replace operator))
      (set (intern (format "evil-%s-state-cursor" state)) '(box)))
  '';

in
pkgs.symlinkJoin {
  name = "emacs-wrapped";
  paths = [ wrappedEmacs ];
  nativeBuildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/emacs \
      --add-flags "--load ${defaultCfg}"
  '';
}
