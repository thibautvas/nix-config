{
  pkgs,
  ...
}:

let
  emacsPkgs = with pkgs; emacsPackagesFor (if stdenv.isDarwin then emacs else emacs-pgtk);

  wrappedEmacs = emacsPkgs.emacsWithPackages (
    epkgs: with epkgs; [
      evil
      consult
      vertico
    ]
  );

  defaultConfig = pkgs.writeText "default.el" ''
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
  name = "emacs-with-config";
  paths = [ wrappedEmacs ];
  nativeBuildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/emacs \
      --add-flags "--load ${defaultConfig}"
  '';
}
