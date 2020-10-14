;; -*-lisp-*-
;;
;; lock.lisp

;; this is a rough draft of a screenlocker. ill probably rewrite it
;; because now its not effective and "secure" at all (doesnt even block
;; notifications!)

;; TODO: verify password which is basically using the crypt function and
;; check if its equal to /etc/shadow thing in the end
;; this should probably be done with just cffi and/or a c file. right now
;; it verifies with the help of a bash file, but that's just terrible.

;; TODO: check if lock is effective on mutliple screens (you should probably
;; do smth with xrandr if it doesnt)
;; is xrandr available on all computers tho?

;; TODO: the notifications are still not being blocked and I don't know any
;; solutions to that. its obviously not possible to raise a window from a
;; notification which is good, but it's still possible to see them...
;; as notifications could contain sensitive information, that's bad.
;; the only solution i found is to stop the dbus service, but that's ugly
;; and needs sudo.

;; TODO: emacs integration! is there any kind of "secure" mode that would block
;; viewing other files aside from the one opened on startup or something like
;; that? need to research further.

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
(defvar *deny-map-request-backup* *deny-map-request*)
(defvar *deny-raise-request-backup* *deny-raise-request*)

(defvar *locked* nil)

(defvar *incorrect-password-message* "incorrect password lol")
(defvar *unlocked-message* "unlocked lol")

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
             (xlib:destroy-window (lock-window *lock*))

             (setf *top-map* *top-map-backup*)
             (setf *deny-map-request* *deny-map-request-backup*)
             (setf *deny-raise-request* *deny-raise-request-backup*)

             (setf *locked* nil)

             (message *unlocked-message*))))))

(defcommand lock () ()
            (setf *locked* t)
            (spawn-lock-window)

            (setf *deny-map-request-backup* *deny-map-request*)
            (setf *deny-map-request* t)

            (setf *deny-raise-request-backup* *deny-raise-request*)
            (setf *deny-raise-request* t)

            (setf *top-map-backup* *top-map*)
            (setf *top-map* nil)
            (fill-keymap *top-map*
                         *escape-key* "unlock"))

(defstruct (lock (:constructor %make-lock))
  window)

(defvar *lock* nil)

(defvar *lock-background-color* *mode-line-background-color*)

(defun make-lock-window (screen)
  (xlib:create-window
             :parent (screen-root screen)
             :x 0 :y 0
             :width (screen-width screen)
             :height (screen-height screen)
             :background (alloc-color screen *lock-background-color*)
             :override-redirect :on))

(defun make-lock (screen)
  (setf *lock* (%make-lock :window (make-lock-window screen)))
  (xlib:map-window (lock-window *lock*)))

(defcommand spawn-lock-window () ()
            (let ((screen (first *screen-list*)))
              (make-lock screen)))
