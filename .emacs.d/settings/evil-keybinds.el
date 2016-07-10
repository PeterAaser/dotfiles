(key-chord-define evil-insert-state-map "ii" 'evil-normal-state)
(key-chord-define evil-insert-state-map "ar" "{")

(define-key evil-normal-state-map "l" 'evil-previous-line)
(define-key evil-normal-state-map "k" 'evil-next-line)

(provide 'evil-keybinds)
