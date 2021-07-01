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

(require json
         racket/function
         racket/port
         mock)

(define EXAMPLE-API-KEY "XhfT4ih0k7!")
(define EXAMPLE-JSEXPR/STRING
  (string-append "{\"apiKey\" : \"" EXAMPLE-API-KEY "\"}"))
#;(define EXAMPLE-JSEXPR
    (make-immutable-hasheq `((apiKey . ,EXAMPLE-API-KEY))))
(define CONFIG-DIR-PATH
  (string-append 
   (path->string 
    (find-system-path 'home-dir))
   "/.config"))
(define CONFIG-PATH
  (string-append CONFIG-DIR-PATH "/sufflain-config.json"))

(define dir-or-file-exists-mock/true  (mock #:behavior (const #t)))
(define dir-or-file-exists-mock/false (mock #:behavior (const #f)))
(define string-port-mock              (mock #:behavior (const EXAMPLE-JSEXPR/STRING)))

(module+ test
  (require rackunit)
  
  (test-case "get-config"
             (check-pred jsexpr? (get-config #:config-exists-mock dir-or-file-exists-mock/true
                                             #:file-reader-mock   string-port-mock)))
  
  (test-case "config-exists?"
             (check-true  (config-exists? #:dir-check-mock  dir-or-file-exists-mock/true
                                          #:file-check-mock dir-or-file-exists-mock/true))
             (check-false (config-exists? #:dir-check-mock  dir-or-file-exists-mock/false
                                          #:file-check-mock dir-or-file-exists-mock/false))
             (check-false (config-exists? #:dir-check-mock  dir-or-file-exists-mock/true
                                          #:file-check-mock dir-or-file-exists-mock/false))))

;; get-config: nothing -> jsexpr
;; Reads data from the config file.
(define (get-config #:config-exists-mock [config-exists? config-exists?]
                    #:file-reader-mock   [port->string   port->string])
  (define file-port (if (config-exists?)
                        (open-input-file CONFIG-PATH)
                        #f))
  (if (boolean? file-port)
      (raise exn:fail:filesystem)
      (read-json file-port)))

;; config-exists?: nothing -> boolean?
;; Checks if the config file is present.
(define (config-exists? #:dir-check-mock  [directory-exists? directory-exists?]
                        #:file-check-mock [file-exists?      file-exists?])
  (let* 
      ([config-dir-path-exists? (directory-exists? CONFIG-DIR-PATH)]
       [config-file-exists?     (if config-dir-path-exists?
                                    (file-exists? CONFIG-PATH)
                                    #f)])
    config-file-exists?))