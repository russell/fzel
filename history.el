(setq user-init-file (or load-file-name (buffer-file-name)))
(setq user-emacs-directory (file-name-directory user-init-file))
(setq custom-file (concat user-emacs-directory "/custom.el"))
(setq package-enable-at-startup nil)
(package-initialize)

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;; and `package-pinned-packages`. Most users will not need or want to do this.
;;(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)

(package-install 'use-package)
(package-install 'helm)

(eval-when-compile
  (require 'use-package))

(use-package helm)
(setq helm-full-frame t)

(load-theme 'tsdh-dark t)
(load-file custom-file)

(defun fzel-file-candidates(filename)
  (with-current-buffer (find-file-read-only filename)
    (rename-buffer "*candidates*"))
  )

(defun helm-fzel-completion (filename)
  ""
  (with-temp-buffer
    (let ((item (helm :sources (helm-build-in-buffer-source "hl-stdin items"
                                 :data (get-buffer-create "*candidates*")
                                 :get-line #'buffer-substring)
                      :buffer "*helm completion*")))
      (if item (insert item)
        (kill-emacs)))
    (goto-char (point-min))
    (replace-regexp "^\s+" "")
    (forward-word)
    (kill-line)
    (write-region nil nil filename)
    )
  )
