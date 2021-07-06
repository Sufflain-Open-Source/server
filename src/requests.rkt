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

(require  "shared/mocks.rkt"
          net/url
          racket/port
          json)

(provide with-json-payload/post
         with-json-payload/put)

;; with-json-payload/post: string? string? -> jsexpr?
(define (with-json-payload/post url-str json-str [request-pure-port post-pure-port])
  (with-json-payload url-str json-str request-pure-port))

;; with-json-payload/put string? string? -> jsexpr?
(define (with-json-payload/put url-str json-str [request-pure-port put-pure-port])
  (with-json-payload url-str json-str request-pure-port))

;; with-json-payload: symbol? string? string? -> jsexpr?
;; Perform a POST or a PUT request with JSON payload and response
(define (with-json-payload 
            url-str json-str request-pure-port)
  (let* ([URL                  (string->url url-str)]
         [RESPONSE-PORT/STRING (port->string 
                                (request-pure-port URL 
                                                   (string->bytes/utf-8 json-str) 
                                                   '("Content-Type: application/json")))])
    (string->jsexpr RESPONSE-PORT/STRING)))

(module+ test
  (require rackunit)
  
  (define (make-post-mock . args)
    (open-input-string EXAMPLE-JSEXPR/STRING))
  
  (test-case "with-json-payload/post"
             (check-pred jsexpr? 
                         (with-json-payload/post "https://example.mock" 
                           "true" 
                           make-post-mock))
             (check-equal? EXAMPLE-JSEXPR
                           (with-json-payload/post "https://example.mock" 
                             "true"
                             make-post-mock)))
  (test-case "with-json-payload/put"
             (check-pred jsexpr? 
                         (with-json-payload/put "https://example.mock" 
                           "true" 
                           make-post-mock))
             (check-equal? EXAMPLE-JSEXPR
                           (with-json-payload/put "https://example.mock" 
                             "true"
                             make-post-mock))))