
;;; tempgit.el --- Create temporary git repo

;; Copyright (C) 2017 Troy Pracy

;; Author: Troy Pracy
;; Keywords: git tempfile
;; Version: 0.0.1
;; Package-Requires: ((emacs "24") ())

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 2 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:

(defvar my/temp-repos (makehash))

(defun my/create-temp-repo (&optional file)
  "Create temporary a git repo for FILE.

Defaults to the current file."
  (interactive)
  (let* ((orig-file     (or file buffer-file-name))
         (basename      (file-name-nondirectory orig-file))
         (tempdir-name  (concat "TEMP_" basename))
         (tempdir       (make-temp-file tempdir-name :directory))
         (tempfile      (expand-file-name basename tempdir)))
    (copy-file orig-file tempdir)
    (magit-init tempdir)
    (find-file tempfile)
    (magit-stage-file tempfile)
    (puthash tempfile orig-file my/temp-repos)))

(defun my/push-temp-repo (&optional force)
  "Copy changes back to original file."
  (interactive)
  (let ((orig-file  (gethash buffer-file-name my/temp-repos))
        (contents   (buffer-string)))
    (find-file orig-file)
    (when (or force
              (and (buffer-modified-p)
                   (y-or-n-p "Save buffer? ")))
      (save-buffer))
    (when (or force
              (y-or-n-p "Replace buffer contents? "))
      (erase-buffer)
      (insert contents))))


(provide 'tempgit)

;;; tempgit ends here
