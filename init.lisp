;; -*-lisp-*-
;;
;; init.lisp

(in-package :stumpwm)


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

(load "~/.stumpwm.d/stumpwm-cmus/src/stumpwm-cmus.lisp")

;; load all files
(load-files
 '("xresources"
   "keys"
   "mode-line"
   "usercommands"
   "system"))

;; startup commands
(run-shell-command "hsetroot -solid \"#1e1c1f\"") ; wallpaper, solid color
(run-shell-command "xinput --disable 20") ; disabling touchpad
(run-shell-command "xinput --disable 16") ; disabling touchpad, too
(run-shell-command "setxkbmap us,ru,ua -option grp:ctrl_shift_toggle caps:ctrl ctrl:nocaps") ; ru and ua layouts toggled with C-S, remapped caps to another ctrl

;; for connecting to slime
(ql:quickload "swank")
(swank:create-server)
