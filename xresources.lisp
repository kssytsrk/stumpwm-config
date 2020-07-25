(in-package :stumpwm)

(export '(get-resource))

(defun resource-query (name)
  "Returns the shell command used by `get-resource'"
  (concatenate 'string
               ;; list all resources
               "xrdb -query -all     |"
               ;; search for ones containing name
               "grep -e \"" name "\" |"
               ;; take the last entry
               "tail -n 1            |"
               ;; take the 2nd column, containing the value
               "cut -f 2             |"
               ;; remove the trailing newline
               "tr -d '\\n'"))

(defun get-resource (name)
  "Returns the value bound to NAME in X resources."
  (let ((output (run-shell-command (resource-query name) t)))
    (when (> (length output) 0)
      output)))

(setf *maxsize-border-width* 1)
(setf *normal-border-width* 1)
(setf *window-border-style* :thin)
(set-msg-border-width 1)
(set-frame-outline-width 1)
(set-normal-gravity :center)


;;
;; -- extract resources --
;;

(defvar *fg-color*
  (get-resource "*.foreground"))

(defvar *bg-color*
  (get-resource "*.background"))

(defvar *border-color*
  (get-resource "*.foreground"))

;;(defvar *msg-border-width*
;;  (let ((value (get-resource "stumpwm.msg.border.width")))
;;    (when value
;;      (parse-integer value))))

;;(defvar *font*
;;  (get-resource "stumpwm.font"))

(defvar *win-bg-color*
  (get-resource "*.background"))

(defvar *focus-color*
  (get-resource "*.foreground"))

(defvar *unfocus-color*
  (get-resource "*.color2"))

(defvar *float-focus-color*
  (get-resource "*.foreground"))

(defvar *float-unfocus-color*
  (get-resource "*.color1"))

;; the following resources already have variables
;; just overwrite them if anything is set in X resources

(setf *mode-line-border-width*
      (let ((value (get-resource "stumpwm.mode.line.border.width")))
        (if value
            (parse-integer value)
            *mode-line-border-width*)))

(setf *mode-line-pad-x*
      (let ((value (get-resource "stumpwm.mode.line.pad.x")))
        (if value
            (parse-integer value)
            *mode-line-pad-x*)))

(setf *mode-line-pad-y*
      (let ((value (get-resource "stumpwm.mode.line.pad.y")))
        (if value
            (parse-integer value)
            *mode-line-pad-y*)))

(setf *mode-line-background-color*
      (get-resource "*.background"))
;;    (or (get-resource "*.background")
;;	  *mode-line-background-color*))

(setf *mode-line-foreground-color*
      (or (get-resource "*.color1")
          *mode-line-foreground-color*))

(setf *mode-line-border-color*
      (or (get-resource "*.color1")
          *mode-line-border-color*))


;;
;; -- assign resources --
;;

(defun apply-resources (resource-pairs)
  (dolist (pair resource-pairs)
    (let ((var (eval (first pair)))
          (fun (second pair)))
      (when var
        (funcall fun var)))))

(apply-resources
 '((*fg-color*            set-fg-color)
   (*bg-color*            set-bg-color)
   (*border-color*        set-border-color)
   ;; (*msg-border-width*    set-msg-border-width)
   ;; (*font*                set-font)
   (*win-bg-color*        set-win-bg-color)
   (*focus-color*         set-focus-color)
   (*unfocus-color*       set-unfocus-color)
   (*float-focus-color*   set-float-focus-color)
   (*float-unfocus-color* set-float-unfocus-color)))


;;
;; -- altering X resources --
;;

(defcommand xresources-load () ()
            "Load X resources from ~/.Xresources"
            (run-shell-command "xrdb -load ~/.Xresources"))

(defcommand xresources-merge () ()
            "Merge X resources from ~/.Xresources"
            (run-shell-command "xrdb -merge ~/.Xresources"))
