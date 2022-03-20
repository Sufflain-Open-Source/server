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

(require "scraper.rkt"
         "shared/const.rkt"
         json
         racket/function)

(provide group-list-to-json
         extract-groups-from-page)

;; group-list is one of:
;;  - null
;;  - (cons string? group-list)
;; It contains IDs for groups.
;; Example:
;;  '("СА21-19" "ИБ31-18")

;; group-list-to-json: group-list -> string?
;; Create a JSON string with a list of groups.
(define (group-list-to-json groups)
  (jsexpr->string (make-hasheq (list `(data . ,groups)))))

;; extract-groups-from-page: string? -> group-list
;; Find groups on a page with timetable.
(define (extract-groups-from-page url-str
                                  #:scrape-mock [scrape scrape])
  (define SCRAPED-DATA (scrape url-str GROUP-TIMETABLE-TITLE-XPATH))
  (regex-select SCRAPED-DATA GROUPS-REGEX))

(module+ test
  (require rackunit
           mock)

  (check-equal? (group-list-to-json '("СА21-19" "ИБ31-18")) "[\"СА21-19\",\"ИБ31-18\"]")

  (test-case "extract-groups-from-page"
             (define SCRAPE-MOCK
               (mock #:behavior (const '("время " "СА21-19 ауд.304б"))))

             (check-equal? (extract-groups-from-page "https://url.here"
                                                     #:scrape-mock SCRAPE-MOCK)
                           '("СА21-19"))))