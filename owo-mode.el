;;; owo-mode.el --- Minor mode for studying kanji

;; Copyright (C) 2020 Correl Roush

;; Author: Correl Roush <correl@gmail.com>
;; Version: 1.0
;; Created: 2018-05-15
;; Package-Requires: ((seq "2.20"))

;; This file is NOT part of GNU Emacs.

;;; License:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; This obnoxious minor-mode uses overlays to owo-ify the text being displayed
;; in the buffer. It does not alter the actual text in any way, it is purely
;; cosmetic. Think of it as glasses-mode for weirdos.

;;; Code:

(require 'seq)

(defvar owo-table
  '(("l\\|r" . "w")
    ("n\\([aeiou]\\)" . "ny\\1")))

(defun owo-translate (text)
  "Translate TEXT into OwO dribble."
  (seq-reduce (lambda (acc pair)
                (replace-regexp-in-string (car pair) (cdr pair) acc))
              owo-table
              text))

(defun owo-set-overlay-properties ()
  "Set properties of kanji overlays."
  (put 'owo 'evaporate t)
  (put 'owo 'face '(bold highlight)))

(owo-set-overlay-properties)

(defun owo-overlay-p (overlay)
  "Return whether OVERLAY is an overlay of owo mode."
  (eq (overlay-get overlay 'category)
      'owo))

(defun owo-wipe (start end)
  "Clear owo overlays between START and END."
  (dolist (overlay (overlays-in start end))
    (when (owo-overlay-p overlay)
      (delete-overlay overlay))))

(defun owo-adjust (start end)
  "Apply owo to the region defined by START and END."

  (let ((pattern (concat "\\(" (mapconcat #'car owo-table "\\|") "\\)"))
        (case-fold-search nil))
    (save-excursion
      (save-match-data
        (goto-char start)
        (while (re-search-forward pattern)
          (message "OwO...%s" (match-string 1))
          (let ((overlay (make-overlay (match-beginning 1) (match-end 1))))
            (overlay-put overlay 'category 'owo)
            (overlay-put overlay 'invisible t)
            (overlay-put overlay 'after-string
                         (owo-translate (match-string 1)))))
        ))))

(defun owo-change (start end)
  "Fontification function to be registered to `jit-lock'.
Clears and re-applies owo overlays to the region
defined by START and END."
  (let ((start-line (save-excursion (goto-char start) (line-beginning-position)))
        (end-line (save-excursion (goto-char end) (line-end-position))))
    (owo-wipe start-line end-line)
    (owo-adjust start-line end-line)))

(define-minor-mode owo-mode
  "OwO"
  :lighter "OwO"
  (owo-wipe (point-min) (point-max))
  (if owo-mode
      (progn
        (jit-lock-register 'owo-change))
    (jit-lock-unregister 'owo-change)))

;;; owo-mode.el ends here
