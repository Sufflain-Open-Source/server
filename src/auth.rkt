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
         mock
         racket/function
         racket/port
         net/url
         json)

(define IDENTITY-TOOLKIT-URL 
  "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=")
(define EXAMPLE-JSEXPR
  (string->jsexpr EXAMPLE-JSEXPR/STRING))
(define EXAMPLE-TOKEN "fbcpent64")
(define EXAMPLE-AUTH-RESPONSE
  (string->jsexpr
   (string-append "{\"idToken\": \"" EXAMPLE-TOKEN "\"}")))

(define POST-RESPONSE-MOCK
  (mock #:behavior (const EXAMPLE-AUTH-RESPONSE)))
(define (make-post-mock . args)
  (open-input-string EXAMPLE-JSEXPR/STRING))
(define GET-CONFIG-MOCK 
  (mock #:behavior 
        (const (make-immutable-hasheq 
                `((database
                   .
                   ,(make-immutable-hasheq `((,CONFIG-DATABASE-URL-KEY
                                              .
                                              "https://ourdb.app")
                                             (,CONFIG-DATABASE-API-KEY
                                              .
                                              "uioy568y7"))))
                  (user
                   .
                   ,(make-immutable-hasheq `((,CONFIG-USER-EMAIL-KEY . "bruhmail@yeah.lol")
                                             (,CONFIG-USER-PASSWORD-KEY . "8543873487")))))))))

(module+ test
  (require rackunit)
  
  (check-equal? 
   (get-token "testmail@example.xd"
              "1234509876"
              #:json-post-mock POST-RESPONSE-MOCK) EXAMPLE-TOKEN)
  
  (check-equal? 
   (construct-sign-in-payload "testmail@example.xd" "1234509876")
   "{\"email\":\"testmail@example.xd\",\"password\":\"1234509876\",\"returnSecureToken\":true}")
  
  (test-case "post-with-json-payload"
             (check-pred jsexpr? (post-with-json-payload "https://example.mock" 
                                                         "true" 
                                                         #:post-mock make-post-mock))
             (check-equal? (post-with-json-payload "https://example.mock" 
                                                   "true"
                                                   #:post-mock make-post-mock)
                           EXAMPLE-JSEXPR))
  
  (check-pred user? (get-user-credentials #:get-config-mock GET-CONFIG-MOCK))
  (check-pred database? (get-database-info #:get-config-mock GET-CONFIG-MOCK)))

;; user is a structure.
;; It contatins user's email and password that are used for authentication.
;; (user string? string?)
(struct user [email password])

;; database is a structure.
;; It contains a URL of the database and an api key.
;; (database string? string?)
(struct database [url api-key])

;; get-token: string? string? string? -> string?
;; Gets a sign in token for the database.
(define (get-token email password
                   #:json-post-mock [post-with-json-payload post-with-json-payload])
  (let* ([API-KEY  (database-api-key (get-database-info))]
         [URL-STR  (string-append
                    "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key="
                    API-KEY)]
         [PAYLOAD  (construct-sign-in-payload email password)]
         [RESPONSE (post-with-json-payload URL-STR PAYLOAD)])
    (hash-ref RESPONSE 'idToken)))

;; construct-sign-in-payload: string? string? -> string?
;; Creates a JSON string for auth requests.
(define (construct-sign-in-payload email password)
  (define JSON-PAYLOAD
    (make-immutable-hasheq `((email . ,email)
                             (password . ,password)
                             (returnSecureToken . #t))))
  (jsexpr->string JSON-PAYLOAD))

;; post-with-json-payload: string? string? -> jsexpr?
;; Performs a POST request with JSON in payload and response.
(define (post-with-json-payload url-str json-str #:post-mock [post-pure-port post-pure-port])
  (let* ([URL (string->url url-str)]
         [RESPONSE-PORT/STRING (port->string 
                                (post-pure-port URL 
                                                (string->bytes/utf-8 json-str) 
                                                '("Content-Type: application/json")))])
    (string->jsexpr RESPONSE-PORT/STRING)))

;; get-user-credentials: nothing -> user?
;; Read user credentials from the config file.
(define (get-user-credentials #:get-config-mock [get-config get-config])
  (let*
      ([CONFIG   (get-config)]
       [USER     (hash-ref CONFIG CONFIG-USER-KEY)]
       [EMAIL    (hash-ref USER   CONFIG-USER-EMAIL-KEY)]
       [PASSWORD (hash-ref USER   CONFIG-USER-PASSWORD-KEY)])
    (user EMAIL PASSWORD)))

;; get-database-info: nothing -> database?
;; Read necessary info about the database from the config file.
(define (get-database-info #:get-config-mock [get-config get-config]) 
  (let*
      ([CONFIG   (get-config)]
       [DATABASE (hash-ref CONFIG   CONFIG-DATABASE-KEY)]
       [URL      (hash-ref DATABASE CONFIG-DATABASE-URL-KEY)]
       [API-KEY  (hash-ref DATABASE CONFIG-DATABASE-API-KEY)])
    (database URL API-KEY)))