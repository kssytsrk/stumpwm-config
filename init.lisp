;; -*-lisp-*-
;;
;; init.lisp

(in-package :stumpwm)

(setf *startup-message* nil)

;; load external rc files

(defvar *load-directory*
  (directory-namestring
   (truename (merge-pathnames (user-homedir-pathname)
                              ".stumpwm.d")))
  "A directory with initially loaded files.")

(defun load-file (filename)
  "Load a file FILENAME (without extension) from `*load-directory*'."
  (let ((file (merge-pathnames (concat filename ".lisp")
                               *load-directory*)))
    (if (probe-file file)
        (load file)
        (format *error-output* "File '~a' doesn't exist." file))))

(defun load-files (filenames)
  "Load a list of files (without extensions) from `*load-directory*'."
  (mapcar #'load-file filenames))

;; do some stuff at startup - it's mostly personal and wouldn't be important
;; to anyone else

(defun just-startup-things ()
  ;; startup commands
  (run-shell-command "hsetroot -solid \"#1e1c1f\"") ; wallpaper, solid color

  (run-shell-command "setxkbmap us,ru,ua -option grp:ctrl_shift_toggle caps:ctrl ctrl:nocaps") ; ru and ua layouts toggled with C-S, remapped caps to another ctrl

  (run-shell-command "emacs --fg-daemon")
  (run-shell-command "emacs ~/usr/org/todo.org"))    ; loading my todo

(add-hook *start-hook* 'just-startup-things)

;; load all files

(load-files
 '("xresources"
   "keys"
   "mode-line"
   "usercommands"
   "lock"))
