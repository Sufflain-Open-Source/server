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

(require "shared/const.rkt")

(provide (all-defined-out))

;; remove-internal-fields: hash? -> hash?
;; Remove internal fields from the hash
(define (remove-internal-fields hash)
  (hash-remove (hash-remove hash '_rev) '_id))

;; select-group-from-title: string? -> string?
(define (select-group-from-title title)
  (car (regexp-match (pregexp GROUPS-REGEX) title)))