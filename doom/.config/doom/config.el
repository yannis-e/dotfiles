;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq user-full-name "Yannis Estermann"
      user-mail-address "yannis.estermann@outlook.com")

(setq doom-theme 'doom-gruvbox)

(setq display-line-numbers-type 'relative)

(setq org-directory "~/notes/org/")

;;; Morning journal

(setq my/journal-directory "~/notes/org/journal/")

(defun my/open-morning-journal ()
  "Open today's morning journal."
  (interactive)
  (let ((file (expand-file-name
               (format-time-string "%Y-%m-%d.org")
               my/journal-directory)))
    (make-directory my/journal-directory t)
    (find-file file)
    (goto-char (point-max))
    (unless (re-search-forward "^\\* Morning$" nil t)
      (goto-char (point-max))
      (insert
       (format
        "#+title: Morning Journal — %s\n\n* Morning\n\n"
        (format-time-string "%Y-%m-%d"))))
    (goto-char (point-max))))

(map! :leader
      "n j" #'my/open-morning-journal)
