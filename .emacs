(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(custom-enabled-themes (quote (misterioso))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(let((default-directory "~/.emacs.d/lisp/"))
  (normal-top-level-add-subdirs-to-load-path))

(require 'package)
(package-initialize)

(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/"))
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives '("melpa-stable" . "http://stable-melpa.org/packages/"))
(add-to-list 'package-archives '("marmalade" . "http://marmalage-repo.org/packages/"))

(setq package-enable-at-startup nil)
(package-initialize)
(evil-mode t)

(global-set-key (kbd "s-SPC") 'execute-extended-command)
(global-set-key (kbd "C-x g") 'magit-status)

(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")
(load-theme 'gruvbox t)

(require 'key-chord)

(key-chord-mode 1)
(setq key-chord-two-keys-delay 0.1)
(setq key-chord-one-key-delay 0.2)

(key-chord-define evil-insert-state-map "ii" 'evil-normal-state)

;; (require 'helm)
;; (require 'helm-config)
;; (helm-mode 1)

(setq evil-search-wrap nil)
(setq tramp-default-method "ssh")

(require 'notmuch)
