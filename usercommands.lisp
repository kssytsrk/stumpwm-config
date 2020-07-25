;; -*-lisp-*-
;;
;; usercommands.lisp

(in-package :stumpwm)

;; cat, helper function
(defun cat (&rest strings) "Concatenates strings, like the Unix command 'cat'.
    A shortcut for (concatenate 'string foo bar)."
       (apply 'concatenate 'string strings))

;; dictionary
(defcommand dict (dictn word)
  ((:string "Select a dictionary to search (if all, press RET): ")
   (:string "Input word: "))
  "Finds a word in dictn (if empty, searches anywhere available). Dependencies: dict."
  (let ((*suppress-echo-timeout* t))
    (message (run-shell-command (cond
                                ((= (length dictn) 0) (cat "dict " word))
                                (t (cat "dict -d " dictn " " word)))
                              t))))

;; thesaurus, finds the definition of a word in GCIDE
(defcommand thesaurus (word)
  ((:string "Input word: "))
  "Finds a word in GCIDE. Dependencies: dict, gcide."
  (dict "gcide" word))
