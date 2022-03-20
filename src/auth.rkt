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

(require "config.rkt"
         net/base64)

(provide make-auth-header)

;; make-auth-header jsexpr? -> string?
;; Creates an HTTP header to authenticate in CouchDB.
(define (make-auth-header config)
  (let*
      ([USER          (get-user-credentials config)]
       [USER-NAME     (user-name USER)]
       [USER-PASSWORD (user-password USER)])
    (string-append "Authorization: Basic "
                   (bytes->string/utf-8
                    (base64-encode
                     (string->bytes/utf-8 (string-append USER-NAME
                                                         ":"
                                                         USER-PASSWORD))
                     #""))))) ;; This removes a newline at the end of the Base64-encoded string.