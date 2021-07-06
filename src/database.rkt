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
         "requests.rkt")

(provide add-groups)

;; add-groups: string? string? -> string?
;; Add groups to the database. If they are already present, replace them.
(define (add-groups groups auth-token 
                    #:get-database-info-mock [get-database-info     get-database-info]
                    #:with-json-payload-mock [with-json-payload/put with-json-payload/put])
  (let*
      ([DB          (get-database-info)]
       [DB-URL      (database-url DB)]
       [GROUPS-PATH (database-groups-path DB)]
       [REQUEST-URL (string-append DB-URL GROUPS-PATH ".json" "?auth=" auth-token)])
    (with-json-payload/put REQUEST-URL groups)))

(module+ test
  (require "shared/mocks.rkt"
           rackunit
           racket/function
           mock)
  
  (define GET-DATABASE-INFO-MOCK (mock 
                                  #:behavior (const 
                                              (get-database-info #:get-config-mock GET-CONFIG-MOCK))))
  (define WITH-JSON-PAYLOAD-MOCK (mock
                                  #:behavior (const "[\"СА21-19\"]")))
  
  (check-equal? (add-groups "[\"СА21-19\"]"  ""
                            #:get-database-info-mock GET-DATABASE-INFO-MOCK
                            #:with-json-payload-mock WITH-JSON-PAYLOAD-MOCK) "[\"СА21-19\"]"))