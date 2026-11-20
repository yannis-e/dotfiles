;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq user-full-name "Yannis Estermann"
      user-mail-address "yannis.estermann@outlook.com")

(setq doom-theme 'doom-gruvbox)

(setq display-line-numbers-type 'relative)

(setq org-directory "~/notes/org/")

;;; German and English spell checking

(after! ispell
  (setq ispell-program-name "hunspell"
        ispell-dictionary "de_DE,en_US")

  (ispell-set-spellchecker-params)
  (ispell-hunspell-add-multi-dic "de_DE,en_US"))
