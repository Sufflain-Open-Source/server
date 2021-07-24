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
         "requests.rkt"
         racket/function
         json)

(provide get-token)

;; get-token: string? string? -> string?
;; Get a sign in token for the database.
(define (get-token email password config
                   #:db-info-mock [get-database-info get-database-info]
                   #:identity-toolkit-mock [get-identity-toolkit get-identity-toolkit]
                   #:json-post-mock [with-json-payload/post with-json-payload/post])
  (let* ([API-KEY  (database-api-key (get-database-info config))]
         [URL-STR  (string-append (identity-toolkit-url (get-identity-toolkit config)) API-KEY)]
         [PAYLOAD  (construct-sign-in-payload email password)]
         [RESPONSE (with-json-payload/post URL-STR PAYLOAD)])
    (hash-ref RESPONSE 'idToken)))

;; construct-sign-in-payload: string? string? -> string?
;; Create a JSON string for auth requests.
(define (construct-sign-in-payload email password)
  (define JSON-PAYLOAD
    (make-immutable-hasheq `((email             . ,email)
                             (password          . ,password)
                             (returnSecureToken . #t))))
  (jsexpr->string JSON-PAYLOAD))

(module+ test
  (require "shared/mocks.rkt"
           rackunit
           mock)
  
  (define EXAMPLE-TOKEN "fbcpent64")
  (define EXAMPLE-AUTH-RESPONSE
    (string->jsexpr
     (string-append "{\"idToken\": \"" EXAMPLE-TOKEN "\"}")))
  
  (define POST-RESPONSE-MOCK
    (mock #:behavior (const EXAMPLE-AUTH-RESPONSE)))
  (define DB-INFO-MOCK
    (mock #:behavior (const (database "" "k3y" "" ""))))
  (define IDENTITY-TOOLKIT-MOCK
    (mock #:behavior (const (identity-toolkit "url"))))
  
  (check-equal? EXAMPLE-TOKEN
                (get-token "testmail@example.xd"
                           "1234509876"
                           (GET-CONFIG-MOCK)
                           #:db-info-mock DB-INFO-MOCK
                           #:identity-toolkit-mock IDENTITY-TOOLKIT-MOCK
                           #:json-post-mock POST-RESPONSE-MOCK))
  
  (check-equal? 
   (construct-sign-in-payload "testmail@example.xd" "1234509876")
   "{\"email\":\"testmail@example.xd\",\"password\":\"1234509876\",\"returnSecureToken\":true}"))