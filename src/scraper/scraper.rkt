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

(module+ test
  (require rackunit)
  
  (check-equal? (regex-select '("СА21-19" "try me" "Ф21-19") #px"\\S{1,2}\\d{2}-\\d{2}")
             '("СА21-19" "Ф21-19"))
  
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
(define (scrape page xpath #| #:mock-tcp? [mock-tcp #f] |#)
  (define page-sxml ;(cond
    #|[(eqv? mock-tcp #f)|# (get-page page);]
    #|[(eqv? mock-tcp #t) (get-page page #:tcp-call-mock tcp-call-mock)])|#)
  ((txpath xpath) page-sxml))

;; get-page: url? -> sxml?
;; Gets a web page and returns it as an SXML.
(define (get-page url-string #:tcp-call-mock [call/input-url call/input-url])
  (let* ((url           (string->url url-string))
         (get-page/html (call/input-url url get-pure-port port->string)))
    (html->xexp get-page/html)))
