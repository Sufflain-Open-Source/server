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
         html-parsing)

(provide scrape
         regex-select
         get-page)

;; regex-select: (listof string?) string? -> (listof string?)
;; Select data based on the provided regex.
(define (regex-select list-of-data rx)
  (let* 
      ([LIST-OF-REGEX-MATCH (map (lambda (element)
                                   (regexp-match (pregexp rx) element)) list-of-data)]
       [FILTERED-MATCHES    (filter list? LIST-OF-REGEX-MATCH)])
    (map (lambda (element) 
           (car element)) FILTERED-MATCHES)))

;; scrape: string? string? -> (listof string?)
;; Extract data from page.
(define (scrape page-url xpath #:page-mock [get-page get-page])
  (define PAGE-SXML (get-page page-url))
  ((sxpath xpath) PAGE-SXML))

;; get-page: string? -> xexp
;; Get a web page and returns it as an SXML.
(define (get-page url-string #:tcp-call-mock [call/input-url call/input-url])
  (let* ((URL                    (string->url url-string))
         (GET-PAGE/HTML          (call/input-url URL get-pure-port port->string))
         (PAGE-WITHOUT-NBSP/HTML (regexp-replace* "&nbsp;" GET-PAGE/HTML "")))
    (html->xexp PAGE-WITHOUT-NBSP/HTML)))

(module+ test
  (require rackunit
           mock)
  
  (define EXAMPLE-URL "http://test.lol")
  (define EXAMPLE-TITLE "Test")
  (define EXAMPLE-HTML
    (string-append "<html><head><title>" EXAMPLE-TITLE "</title></head></html>"))
  (define EXAMPLE-HTML/XEXPR
    `(*TOP* (html (head (title ,EXAMPLE-TITLE)))))
  
  (define TCP-CALL-MOCK (mock #:behavior (const EXAMPLE-HTML)))
  (define GET-PAGE-MOCK (mock #:behavior (const EXAMPLE-HTML/XEXPR)))
  
  (check-equal? (regex-select '("СА21-19 ауд.304б" "try me" "Ф21-19") "\\S{1,2}\\d{2}-\\d{2}")
                '("СА21-19" "Ф21-19"))
  (check-equal? (scrape EXAMPLE-URL "//title/text()" #:page-mock GET-PAGE-MOCK)
                `(,EXAMPLE-TITLE))
  (check-equal? (get-page EXAMPLE-URL #:tcp-call-mock TCP-CALL-MOCK)
                EXAMPLE-HTML/XEXPR))