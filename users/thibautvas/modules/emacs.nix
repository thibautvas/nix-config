{
  config,
  lib,
  pkgs,
  isDarwin,
  ...
}:

{
  programs.emacs = {
    enable = true;
    extraPackages =
      epkgs: with epkgs; [
        evil
        consult
        vertico
        diff-hl
        magit
        pdf-tools
      ];
    extraConfig = ''
      (evil-mode 1)
      (vertico-mode 1)
      (global-diff-hl-mode 1)
      (pdf-tools-install)
      (load-theme 'wombat t)
      (tool-bar-mode -1)
      (menu-bar-mode -1)
      (scroll-bar-mode -1)
      (set-fringe-mode 1)
      (global-display-line-numbers-mode 1)
      (column-number-mode 1)
      (set-face-attribute 'default nil :height 120)
      (blink-cursor-mode 0)
      (setq-default truncate-lines t)
      (setq auto-save-default nil)
      (setq x-select-enable-clipboard nil)
      (setq org-confirm-babel-evaluate nil)
      (org-babel-do-load-languages
        'org-babel-load-languages
        '((python . t)))
      (dolist (mode '(shell-mode-hook pdf-view-mode-hook))
        (add-hook mode (lambda () (display-line-numbers-mode 0))))
      (dolist (state '(insert replace operator))
        (set (intern (format "evil-%s-state-cursor" state)) '(box)))
      (defun my/fd-wd ()
        (interactive)
          (consult-fd (getenv "WORK_DIR")))
      (defun my/fd-dl ()
        (interactive)
          (consult-fd "~/Downloads"))
      (with-eval-after-load 'evil-maps
        (define-key evil-visual-state-map (kbd "SPC y")
          (lambda ()
            (interactive)
            (evil-use-register ?+)
            (call-interactively 'evil-yank)))
        (define-key evil-insert-state-map (kbd "C-S-v")
          (lambda ()
            (interactive)
            (evil-paste-from-register ?+))))
    '';
  }
  // lib.optionalAttrs (!isDarwin) {
    package = pkgs.emacs-pgtk;
  };
}
