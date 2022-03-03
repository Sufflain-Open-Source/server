#|
    Copyright (C) 2021  Timofey Chuchkanov

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
|#

#lang racket/base

(provide all-defined-out)

;; read-names: string? -> (or/c (listof string?) null)
;; Reads the teachers' names from a file that contains raw Racket list data.
(define (read-names file-path)
  (if (file-exists? file-path)
      (let*
          ([FILE-PORT (open-input-file file-path)]
           [FILE-DATA (read FILE-PORT)]
           [NAMES     (eval FILE-DATA)])
        NAMES)
      null))
