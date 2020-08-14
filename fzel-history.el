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

(defun fzel-history (input-filename output-filename)
  (fzel-file-candidates input-filename)
  (helm-fzel-completion output-filename)
  (kill-emacs))
