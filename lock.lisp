;; -*-lisp-*-
;;
;; lock.lisp

;; this is a rough draft of a screenlocker. ill probably rewrite it
;; because now its not effective and "secure" at all (doesnt even block
;; notifications!)

;; TODO: verify password which is basically (crypt:crypt pwd salt) and
;; check if its equal to /etc/shadow thing in the end
;; this should probably be done with just cffi and/or a c file.

;; TODO: check if lock is effective on mutliple screens (you should probably
;; do smth with xrandr if it doesnt)
;; is xrandr available on all computers tho?

(in-package :stumpwm)

(defmacro fill-keymap (map &rest bindings)
  "Wipes the keymap and fills it with a list of binding pairs"
  `(setf ,map
         (let ((m (make-sparse-keymap)))
           ,@(loop for i = bindings then (cddr i)
                while i
                collect `(define-key m ,(first i) ,(second i)))
           m)))

(defvar *top-map-backup* *top-map*)

(defvar *locked* nil)

(defvar *incorrect-password-message* "Incorrect password.")

(defcommand unlock (passwd)
  ((:string "Enter password: "))
  (when *locked*
    ;; this is stupid in general
    (let ((res (run-shell-command (concatenate 'string
                                               "echo " "\"" passwd "\""
                                               " | sh ~/.stumpwm.d/sudo.sh")
                                  t)))
      ;; a stupid solution, need to reconsider
      (cond ((search "1" res) (message *incorrect-password-message*))
            (t
             (gkill)
             (setf *top-map* *top-map-backup*)
             (setf *locked* nil)
             (message "Unlocked."))))))

(defcommand lock () ()
            (setf *locked* t)
            (gnew "lock")
            (setf *top-map-backup* *top-map*)
            (setf *top-map* nil)
            (fill-keymap *top-map*
                         *escape-key* "unlock"))
