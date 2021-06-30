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

(require net/url
         sxml
         racket/port
         racket/function
         html-parsing
         mock)

(provide scrape)

(define EXAMPLE-URL "http://test.lol")
(define EXAMPLE-TITLE "Test")
(define EXAMPLE-HTML
  (string-append "<html><head><title>" EXAMPLE-TITLE "</title></head></html>"))
(define EXAMPLE-HTML/XEXPR
  `(*TOP* (html (head (title ,EXAMPLE-TITLE)))))

(define tcp-call-mock (mock #:behavior (const EXAMPLE-HTML)))
(define get-page-mock (mock #:behavior (const EXAMPLE-HTML/XEXPR)))

(module+ test
  (require rackunit)
  
  (test-case "regex-select"
             (check-equal? (regex-select '("СА21-19" "try me" "Ф21-19") #px"\\S{1,2}\\d{2}-\\d{2}")
                           '("СА21-19" "Ф21-19")))
  
  (test-case "scrape"
             (check-equal? (scrape EXAMPLE-URL "//title/text()" #:page-mock get-page-mock)
                           `(,EXAMPLE-TITLE)))
  
  (test-case "get-page"
             (check-equal? (get-page EXAMPLE-URL #:tcp-call-mock tcp-call-mock)
                           EXAMPLE-HTML/XEXPR)))

;; regex-select: (listof string?) regexp? -> (listof string?)
;; Selects data based on the provided regex.
(define (regex-select list-of-data rx)
  (let* 
      ([list-of-regex-match (map (lambda (element)
                                   (regexp-match rx element)) list-of-data)]
       [filtered-matches    (filter list? list-of-regex-match)])
    (map (lambda (element) 
           (car element)) filtered-matches)))

;; scrape: url? txpath? -> (listof string?)
;; Extracts data from page.
(define (scrape page-url xpath #:page-mock [get-page get-page])
  (define page-sxml (get-page page-url))
  ((txpath xpath) page-sxml))

;; get-page: url? -> sxml?
;; Gets a web page and returns it as an SXML.
(define (get-page url-string #:tcp-call-mock [call/input-url call/input-url])
  (let* ((url           (string->url url-string))
         (get-page/html (call/input-url url get-pure-port port->string)))
    (html->xexp get-page/html)))
