;; Set up config path names
(setq site-lisp-dir
      (expand-file-name "lisp" user-emacs-directory))

(setq settings-dir
      (expand-file-name "settings" user-emacs-directory))

(setq custom-file
      (expand-file-name "custom.el" user-emacs-directory))

(add-to-list 'load-path settings-dir)
(add-to-list 'load-path site-lisp-dir)
(load custom-file)

(setq inhibit-startup-message t)

;; Have you ever had your ass saved by backups? me neither because I'm not retarded and it's $CURRENT_YEAR
(setq make-backup-files nil)
(setq auto-save-default nil)

(require 'setup-package)
(require 'helm-config)

(evil-mode t)
(global-evil-tabs-mode t)
(key-chord-mode t)

(require 'keybinds)

(setq key-chord-two-keys-delay 0.1)
(setq key-chord-one-key-delay 0.2)

(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")
(load-theme 'gruvbox t)

