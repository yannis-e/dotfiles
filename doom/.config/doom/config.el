;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq user-full-name "Yannis Estermann"
      user-mail-address "yannis.estermann@outlook.com")

(setq doom-theme 'doom-gruvbox)

(setq display-line-numbers-type 'relative)

(setq org-directory "~/notes/org/")

;;; Spell Checking

(after! spell-fu
  (setq ispell-program-name "aspell"
        ispell-extra-args '("--sug-mode=ultra"))

  ;; Add both dictionaries
  (spell-fu-dictionary-add "en")
  (spell-fu-dictionary-add "de"))

;; Enable spell checking in Org files
(add-hook 'org-mode-hook #'spell-fu-mode)
