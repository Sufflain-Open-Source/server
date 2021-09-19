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

(require "groups.rkt"
         "config.rkt"
         "database.rkt"
         "auth.rkt"
         "tracker.rkt"
         "scraper.rkt"
         racket/cmdline)

(define (listen-for-changes config)
  (let*
      ([USER         (get-user-credentials config)]
       [DB           (get-database-info config)]
       [TOKEN        (get-token (user-email USER) (user-password USER) config)]
       [APP-PROPS    (get-app-props config)]
       [GROUPS       (get-groups config)]
       [SLEEP-TIME   (app-props-sleep-time APP-PROPS)]
       [COLLEGE-SITE (get-college-site-info config)]
       [SITE-URL     (college-site-url COLLEGE-SITE)]
       [BLOG-PATH    (college-site-blog-path COLLEGE-SITE)]
       [FULL-URL     (string-append SITE-URL BLOG-PATH)]
       [BLOG-PAGE    (get-page FULL-URL)])
    (track BLOG-PAGE GROUPS config TOKEN)
    (sleep SLEEP-TIME)
    (listen-for-changes config)))

;; get-groups-and-add-to-db: string? jsexpr? -> void?
;; A frontend for add-groups
(define (get-groups-and-add-to-db url-str config)
  (let*
      ([USER   (get-user-credentials config)]
       [DB     (get-database-info config)]
       [GROUPS (extract-groups-from-page url-str)]
       [TOKEN  (get-token (user-email USER) (user-password USER) config)])
    (displayln 
     (add-groups (group-list-to-json GROUPS) TOKEN config))))

(command-line #:program "sfl"
              #:once-any
              (("-g" "--get-groups") PAGE-URL 
                                     "Get groups and place them into the database. \
\nExisting groups' data will be overwritten if it exists!"
                                     (get-groups PAGE-URL))
              #:args () (void))