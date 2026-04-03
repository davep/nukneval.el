;;; nukneval.el --- Nuke and reevaluate an Emacs Lisp buffer
;; Copyright 2002-2017 by Dave Pearson <davep@davep.org>

;; Author: Dave Pearson <davep@davep.org>
;; Version: 1.2
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

;;;###autoload
(defun nukneval ()
  "Attempt to cleanly reevaluate a buffer of Emacs Lisp code."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (cl-loop for form = (condition-case nil
                            (read (current-buffer))
                          (error nil))
             with unbound = nil
             while form
             do (let ((type (car form))
                      (name (cadr form)))
                  (cond
                   ((memq type '(defun defun* defsubst cl-defun defalias defmacro))
                    (fmakunbound name)
                    (push name unbound))
                   ((memq type '(defvar defparameter defconst defcustom))
                    (makunbound name)
                    (push name unbound))))
             finally
             (message "Rebound: %s" (string-join (sort (mapcar #'symbol-name unbound) #'string<) ", "))))
  (eval-buffer))

(provide 'nukneval)

;;; nukneval.el ends here
