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

(provide get-config
         CONFIG-USER-KEY
         CONFIG-USER-EMAIL-KEY
         CONFIG-USER-PASSWORD-KEY
         CONFIG-DATABASE-KEY
         CONFIG-DATABASE-URL-KEY
         CONFIG-DATABASE-API-KEY
         EXAMPLE-JSEXPR/STRING)

(define CONFIG-USER-KEY          'user)
(define CONFIG-USER-EMAIL-KEY    'email)
(define CONFIG-USER-PASSWORD-KEY 'password)

(define CONFIG-DATABASE-KEY     'database)
(define CONFIG-DATABASE-URL-KEY 'url)
(define CONFIG-DATABASE-API-KEY 'apiKey)


(define EXAMPLE-API-KEY "XhfT4ih0k7!")
(define EXAMPLE-JSEXPR/STRING
  (string-append "{\"apiKey\" : \"" EXAMPLE-API-KEY "\"}"))
(define CONFIG-DIR-PATH
  (string-append 
   (path->string 
    (find-system-path 'home-dir))
   "/.config"))
(define CONFIG-PATH
  (string-append CONFIG-DIR-PATH "/sufflain-config.json"))

(define DIR-OR-FILE-EXISTS-MOCK/TRUE  (mock #:behavior (const #t)))
(define DIR-OR-FILE-EXISTS-MOCK/FALSE (mock #:behavior (const #f)))
(define STRING-PORT-MOCK              (mock #:behavior (const EXAMPLE-JSEXPR/STRING)))

(module+ test
  (require rackunit)
  
  
  (check-pred jsexpr? (get-config #:config-exists-mock DIR-OR-FILE-EXISTS-MOCK/TRUE
                                  #:file-reader-mock   STRING-PORT-MOCK))
  
  (test-case "config-exists?"
             (check-true  (config-exists? #:dir-check-mock  DIR-OR-FILE-EXISTS-MOCK/TRUE
                                          #:file-check-mock DIR-OR-FILE-EXISTS-MOCK/TRUE))
             (check-false (config-exists? #:dir-check-mock  DIR-OR-FILE-EXISTS-MOCK/FALSE
                                          #:file-check-mock DIR-OR-FILE-EXISTS-MOCK/FALSE))
             (check-false (config-exists? #:dir-check-mock  DIR-OR-FILE-EXISTS-MOCK/TRUE
                                          #:file-check-mock DIR-OR-FILE-EXISTS-MOCK/FALSE))))

;; get-config: nothing -> jsexpr
;; Reads data from the config file.
(define (get-config #:config-exists-mock [config-exists? config-exists?]
                    #:file-reader-mock   [port->string   port->string])
  (define FILE-PORT (if (config-exists?)
                        (open-input-file CONFIG-PATH)
                        #f))
  (if (boolean? FILE-PORT)
      (raise exn:fail:filesystem)
      (read-json FILE-PORT)))

;; config-exists?: nothing -> boolean?
;; Checks if the config file is present.
(define (config-exists? #:dir-check-mock  [directory-exists? directory-exists?]
                        #:file-check-mock [file-exists?      file-exists?])
  (let* 
      ([CONFIG-DIR-PATH-EXISTS? (directory-exists? CONFIG-DIR-PATH)]
       [CONFIG-FILE-EXISTS     (if CONFIG-DIR-PATH-EXISTS?
                                    (file-exists? CONFIG-PATH)
                                    #f)])
    CONFIG-FILE-EXISTS))