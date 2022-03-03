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
         "teachers-names-loader.rkt"
         racket/cmdline
         dyoo-while-loop)

(define (get-firebase-token)
  (get-token (user-email USER) (user-password USER) CONFIG))

(define CONFIG (get-config))
(define USER   (get-user-credentials CONFIG))
(define DB     (get-database-info CONFIG))
(define TOKEN  (get-firebase-token))
(define GROUPS (get-groups CONFIG TOKEN))

(define TRACKING-ITERATION-MSG-FIRST-PART "<<<---Tracking iteration [")
(define TRACKING-ITERATION-MSG-LAST-PART "]--->>>")

(define TRACKING-ITERATION-START-MSG
  (string-append TRACKING-ITERATION-MSG-FIRST-PART "START" TRACKING-ITERATION-MSG-LAST-PART))
(define TRACKING-ITERATION-END-MSG
  (string-append TRACKING-ITERATION-MSG-FIRST-PART "END" TRACKING-ITERATION-MSG-LAST-PART))
(define DELIMETER
  (make-string (string-length TRACKING-ITERATION-END-MSG) #\@))

(define (main)
  (let*
      ([APP-PROPS    (get-app-props CONFIG)]
       [SLEEP-TIME   (app-props-sleep-time APP-PROPS)])
    (while #t
           (displayln TRACKING-ITERATION-START-MSG)
           (listen-for-changes CONFIG)
           (displayln TRACKING-ITERATION-END-MSG)
           (displayln DELIMETER)
           (sleep SLEEP-TIME))))

(define (listen-for-changes config)
  (let*
      ([COLLEGE-SITE (get-college-site-info config)]
       [SITE-URL     (college-site-url COLLEGE-SITE)]
       [BLOG-PATH    (college-site-blog-path COLLEGE-SITE)]
       [FULL-URL     (string-append SITE-URL BLOG-PATH)]
       [BLOG-PAGE    (get-page FULL-URL)]
       [TOKEN        (get-firebase-token)])
    (track BLOG-PAGE GROUPS config TOKEN)))

;; read-names-and-add-to-db: string? jsexpr?
;; Read names from a file and upload to the DB.
(define (read-names-and-add-to-db file-path config)
  (let
      ([NAMES (read-names file-path)]
       [TOKEN (get-firebase-token)])
    (displayln
     (add-names NAMES TOKEN config))))

;; get-groups-and-add-to-db: string? jsexpr? -> void?
;; A frontend for add-groups
(define (get-groups-and-add-to-db url-str config)
  (let
      ([GROUPS (extract-groups-from-page url-str)])
    (displayln
     (add-groups (group-list-to-json GROUPS) TOKEN config))))

(command-line #:program "sfl"
              #:once-any
              (("-g" "--get-groups") PAGE-URL
                                     "Get groups and place them into the database. \
\nExisting groups' data will be overwritten if it exists!"
                                     (get-groups-and-add-to-db PAGE-URL CONFIG))
              (("-t" "--track") "Track timetables changes and upload them to the database."
                                (main))
              (("-n" "--read-names") FILE-PATH
                                     "Read teachers' names and upload them to the DB."
                                     (read-names-and-add-to-db FILE-PATH CONFIG))
              #:args () (void))