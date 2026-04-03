;;; nukneval.el --- Nuke and reevaluate an Emacs Lisp buffer  -*- lexical-binding: t; -*-
;; Copyright 2002-2026 by Dave Pearson <davep@davep.org>

;; Author: Dave Pearson <davep@davep.org>
;; Version: 1.3
;; Keywords: lisp
;; URL: https://github.com/davep/nukneval.el
;; Package-Requires: ((emacs "24.4"))

;; This program is free software: you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by the
;; Free Software Foundation, either version 3 of the License, or (at your
;; option) any later version.
;;
;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
;; Public License for more details.
;;
;; You should have received a copy of the GNU General Public License along
;; with this program. If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; nukneval.el provides a command that attempts to cleanly reevaluate a
;; buffer of elisp code.

;;; Code:

(eval-when-compile
  (require 'cl-lib))

(defun nukneval--unbinder (type)
  "Return the unbinding function for the given form TYPE."
  (cond
   ((memq type '(defun defun* defsubst cl-defun defalias defmacro))
    #'fmakunbound)
   ((memq type '(defvar defparameter defconst defcustom))
    #'makunbound)))

;;;###autoload
(defun nukneval ()
  "Attempt to cleanly reevaluate a buffer of Emacs Lisp code."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (cl-loop with unbound = nil
             for form = (condition-case nil
                            (read (current-buffer))
                          (error nil))
             while form
             do (let ((type (car form))
                      (name (cadr form)))
                  (when-let ((unbind (nukneval--unbinder type)))
                    (funcall unbind name)
                    (push (format "%s %s" type name) unbound)))
             finally (if unbound
                         (with-help-window "*nukneval*"
                           (princ
                            (format "Nuked and evaluated:\n\n%s" (string-join (reverse unbound) "\n"))))
                       (message "Nothing to nuke and evaluate."))))
  (eval-buffer))

(provide 'nukneval)

;;; nukneval.el ends here
