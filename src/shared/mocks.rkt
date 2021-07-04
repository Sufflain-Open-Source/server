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

(require "keys.rkt"
         racket/function
         mock)

(provide (all-defined-out))

(define EXAMPLE-API-KEY "XhfT4ih0k7!")
(define EXAMPLE-JSEXPR/STRING
  (string-append "{\"apiKey\" : \"" EXAMPLE-API-KEY "\"}"))
(define GET-CONFIG-MOCK 
  (mock #:behavior 
        (const
         (make-immutable-hasheq 
          `((,CONFIG-IDENTITY-TOOLKIT-KEY
             .
             ,(make-immutable-hasheq `((,CONFIG-IDENTITY-TOOLKIT-URL-KEY . "https://identity.url"))))
            (,CONFIG-DATABASE-KEY
             .
             ,(make-immutable-hasheq `((,CONFIG-DATABASE-URL-KEY . "https://ourdb.app")
                                       (,CONFIG-DATABASE-API-KEY . "uioy568y7"))))
            (,CONFIG-USER-KEY
             .
             ,(make-immutable-hasheq `((,CONFIG-USER-EMAIL-KEY    . "bruhmail@yeah.lol")
                                       (,CONFIG-USER-PASSWORD-KEY . "8543873487"))))
            (,CONFIG-COLLEGE-SITE-KEY
             .
             ,(make-immutable-hasheq `((,CONFIG-COLLEGE-SITE-BLOG-URL-KEY     . "https://college.site")
                                       (,CONFIG-COLLEGE-SITE-GROUPS-XPATH-KEY 
                                        . 
                                        "//tbody//p/strong/text()")
                                       (,CONFIG-COLLEGE-SITE-GROUPS-REGEX-KEY 
                                        . 
                                        "\\S{1,2}\\d{2}-\\d{2}")))))))))