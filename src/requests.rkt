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

(provide http-delete
         http-get
         with-json-payload/post
         with-json-payload/put)

(define RECONNECT-SLEEP-SECONDS 10)
(define TRYING-TO-RECONNECT-MESSAGE
  (string-append "Trying to reconnect in "
                 (number->string RECONNECT-SLEEP-SECONDS)
                 " seconds..."))

;; http-delete: string? -> jsexpr?
(define (http-delete url-str #:header [header ""] [request-pure-port delete-pure-port])
  (http-request url-str delete-pure-port #:header header))

;; get: string? -> jsexpr?
(define (http-get url-str #:header [header ""] [request-pure-port get-pure-port])
  (http-request url-str request-pure-port #:header header))

;; with-json-payload/post: string? string? -> jsexpr?
(define (with-json-payload/post url-str json-str #:header [header ""] [request-pure-port post-pure-port])
  (http-request url-str #:json-payload json-str request-pure-port #:header header))

;; with-json-payload/put string? string? -> jsexpr?
(define (with-json-payload/put url-str json-str #:header [header ""] [request-pure-port put-pure-port])
  (http-request url-str #:json-payload json-str request-pure-port #:header header))

;; with-json-payload: string? -> jsexpr?
;; Perform an HTTP request with/without JSON payload.
(define (http-request url-str #:header [header ""] #:json-payload [json-str null] request-pure-port)
  (let* ([URL                  (string->url url-str)]
         [RESPONSE-PORT/STRING (port->string
                                (if (equal? json-str null)
                                    (make-network-request-with-handler
                                     (lambda () (request-pure-port URL (list header))))
                                    (make-network-request-with-handler
                                     (lambda () (request-pure-port URL
                                                                   (string->bytes/utf-8 json-str)
                                                                   (list "Content-Type: application/json" header))))))])
    (string->jsexpr RESPONSE-PORT/STRING)))

;; make-network-request-with-handler: procedure -> any
;; Make a network request and try to reconnect in 10 seconds if there is an error.
(define (make-network-request-with-handler proc)
  (with-handlers ([exn? (lambda (ex)
                          (displayln (exn-message ex))
                          (when (exn:break? ex)
                            (displayln TRYING-TO-RECONNECT-MESSAGE)
                            (sleep RECONNECT-SLEEP-SECONDS)
                            (make-network-request-with-handler proc)))])
    (proc)))

(module+ test
  (require "shared/mocks.rkt"
           rackunit)

  (define (make-post-mock . args)
    (open-input-string EXAMPLE-JSEXPR/STRING))

  (check-equal? (http-get "" get-groups-mock)
                '("СА21-19"))

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