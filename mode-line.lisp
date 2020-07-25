;; -*-lisp-*-
;;
;; mode-line.lisp

(in-package :stumpwm)

(setf *time-modeline-string*
      "%a %b %e %k:%M")

(setf *mode-line-timeout* 5)

(setf *screen-mode-line-format*
      (list "[^B%n^b] %W^>"
            '(:eval (run-shell-command "sh ~/.stumpwm.d/xsetcmus.sh" t))
            " | %d"))

(setf *mode-line-position*
      :bottom)

;; Turn on the modeline
(if (not (head-mode-line (current-head)))
    (toggle-mode-line (current-screen) (current-head)))
