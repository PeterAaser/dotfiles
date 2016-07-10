(require 'package)

(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/"))
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives '("melpa-stable" . "http://stable-melpa.org/packages/"))
(add-to-list 'package-archives '("marmalade" . "http://marmalage-repo.org/packages/"))

(let ((default-directory  "~/.emacs.d/lisp"))
    (normal-top-level-add-subdirs-to-load-path))

(package-initialize)

(provide 'setup-package)
